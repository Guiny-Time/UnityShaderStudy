// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// 本代码不适用于URP/HDRP，需用HLSL重写，仅适用于内置渲染管道

Shader "Custom/逐片元漫反射"
{
    Properties{
          _Diffuse("漫反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        }
        SubShader{
            Pass{
                Tags{ "LightMode"="ForwardBase" }
 
            CGPROGRAM
 
            #pragma vertex vert
            #pragma fragment frag
 
            #include "Lighting.cginc"
 
            fixed4 _Diffuse;
 
            struct a2v{
                float4 vertex : POSITION;           // 获取模型空间顶点位置
                float3 normal : NORMAL;             // 获取模型空间法线位置
            };
 
            struct v2f{
                float4 pos : SV_POSITION;           // 获取裁剪空间像素位置
                fixed3 worldNormal : TEXCOORD0;     // 获取世界法线(纹理坐标)
            };

            // 顶点着色器，基本任务为将顶点位置由模型空间转换到裁剪空间
            v2f vert (a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);                         // MVP变换得到裁剪坐标的位置信息
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);   // 世界空间下的法线
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;                  // 环境光
                fixed3 worldNormal = normalize(i.worldNormal);                  // 世界法线，单位向量化
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);     // 入射光，单位向量化
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));   // 兰伯特公式，计算出射的漫反射光线
                fixed3 color = ambient + diffuse;                               // 最终颜色 = 环境光 + 漫反射光
                return fixed4(color.rgb, 1.0);
            }
 
            ENDCG
        }
    }
    Fallback "Diffuse"
}
