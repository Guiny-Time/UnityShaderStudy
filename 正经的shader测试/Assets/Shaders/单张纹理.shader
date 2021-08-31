Shader "Custom/单张纹理"        // 基于Blinn-Phong高光模型
{
    Properties{
        _Color ("整体色调", Color) = (1.0, 1.0, 1.0, 1.0)           // 其实就是漫反射颜色
        // 2D是纹理属性的声明方式
        _MainTex("纹理", 2D) = "white" {}
        _Specular("高光反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("光泽度", Range(8.0, 256)) = 20
    }
    SubShader{
        Pass{
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            // 这个名字并不是随便起的，而是按照“纹理名字_ST”的方式来声明对应纹理的属性。ST指缩放(Scale，xy)和平移(Trans，zw)
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v{
                float4 vertex : POSITION;               // 顶点位置
                float3 normal : NORMAL;                 // 顶点法线
                float4 texcoord : TEXCOORD0;            // 用于储存第一组纹理坐标
            };

            struct v2f{
                float4 pos : SV_POSITION;               // 裁剪空间的片元位置
                float3 worldNormal : TEXCOORD0;         // 片元的世界法线
                float3 worldPos : TEXCOORD1;            // 片元的世界位置
                float2 uv : TEXCOORD2;                  // 储存纹理坐标以便纹理采样
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);    // 顶点坐标从模型空间到投影空间
                // 世界空间的法线
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject); 
                // 顶点的世界空间位置
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                // 纹理坐标，为基础值 * 贴图缩放 + 贴图偏移
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);     // 内置函数，当贴图不能正好覆盖而启用了镜像等设置的时候调用
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                // 用于漫反射和高光计算
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);             // 世界空间的入射光单位向量

                // 反照率与环境光
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;                 // 反照率，对贴图进行纹理采样（计算出的纹素值与主色调相乘）
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;                 // 环境光，与反照率有关(因为有贴图颜色的存在)

                // 计算漫反射光线
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir)); 

                // 计算高光，使用Blinn-Phong公式
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);  // 计算视觉方向(v)的单位向量
                fixed3 halfDir = normalize(worldLightDir + viewDir);                    // 计算h单位向量，使用Blinn公式
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                // 呈现颜色：环境光 + 漫反射 + 高光反射
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
