// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/逐顶点高光"
{
    Properties{
        _Diffuse ("漫反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
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

            // 为了调用编辑器赋值的三个值而创建的载体
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;               // 顶点位置
                float3 normal : NORMAL;                 // 顶点法线
            };

            struct v2f{
                float4 pos : SV_POSITION;               // 裁剪空间的片元位置
                fixed3 color : COLOR;                   // 颜色
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);    // 顶点坐标从模型空间到投影空间
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;  // 获取环境光
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); // 世界空间的法线单位向量
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);             // 世界空间的入射光单位向量
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir)); // 计算漫反射光线
                // 计算高光反射光线(r)的单位向量，使用Phong公式
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                // 计算视觉方向(v)的单位向量
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                // 计算高光，使用Phong公式
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                // 呈现颜色：环境光 + 漫反射 + 高光反射
                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
