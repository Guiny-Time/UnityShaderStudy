// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/逐片元漫反射"
{
    Properties{
        _Diffuse("漫反射颜色", Color) = (1, 1, 1, 1)        // 漫反射的颜色，默认为白色
    }
    
    SubShader
    {
        Pass
        {
            Tags{ "LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;                            // 为了使用属性中定义的漫反射的颜色而声明的变量（材质的漫反射属性）

            struct a2v{
                float4 vertex : POSITION;               // 获取顶点位置
                float3 normal : NORMAL;                 // 获取顶点的法线
            };

            struct v2f{
                float4 pos : SV_POSITION;               // 获取裁剪空间的位置
                float3 worldNormal : TEXCOORD0;         // 获取世界空间的法线
            };

            // 顶点着色器
            v2f vert(a2v v){
                v2f o;
                // 顶点转移到投影空间(Projection)
                o.pos = UnityObjectToClipPos(v.vertex);
                // 获得世界空间法线
                o.worldNormal = UnityObjectToClipPos(v.vertex);
                // 输出结构体v2f, 准备传入片元着色器执行下一步操作
                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i) : SV_Target{
                // 获取环境光参数
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz
                // 获取世界空间法线的单位向量
                fixed3 worldNormal = normalize(i.worldNormal);
                // 获取世界光照的单位向量
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 使用兰伯特定律计算漫反射光
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                // 最终颜色 --> 漫反射光 + 环境光
                fixed3 color = ambient + diffuse;
                // 输出顶点颜色
                return fixed4(color, 1.0);
            }
            ENDCG
        }      
    }
    Fallback "Diffuse"
}
