// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/切线空间法线纹理"
{
    Properties{
        _Color ("材质基础色调", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("纹理", 2D) = "white" {}
        _BumpMap ("法线纹理", 2D) = "bump" {}
        _BumpScale ("凹凸程度", Float) = 1.0
        _Specular ("高光颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("光泽度", Range(8.0, 256)) = 20
    }
    SubShader{
        Pass{
            Tags{ "LightMode" = "ForwardBase" }         // 光照模式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
            
            struct a2v{
                float4 vertex : POSITION;               // 顶点位置
                float3 normal : NORMAL;                 // 顶点法线
                float4 tangent : TANGENT;               // 顶点切线，用于切线空间的搭建
                float4 texcoord : TEXCOORD0;            // 用于储存第一组纹理坐标
            };

            struct v2f{
                float4 pos : SV_POSITION;               // 裁剪空间的片元位置
                float4 uv : TEXCOORD0;                  // 储存纹理坐标
                float3 lightDir : TEXCOORD1;            // 储存变化后的光照方向
                float3 viewDir : TEXCOORD2;             // 储存变化后的视觉方向                
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);    // 顶点坐标从模型空间到投影空间

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;      // 用xy分量储存纹理
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;      // 用zw分量储存法线

                // 从模型空间变换到切线空间
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
                float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

                // Transform the light and view dir from world space to tangent space
				o.lightDir = mul(worldToTangent, WorldSpaceLightDir(v.vertex));
				o.viewDir = mul(worldToTangent, WorldSpaceViewDir(v.vertex));
				
				return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                // 用于漫反射和高光计算
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 tangentLightDir = normalize(i.lightDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal;

                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 反照率与环境光
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;                 // 反照率，对贴图进行纹理采样（计算出的纹素值与主色调相乘）
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;                 // 环境光，与反照率有关(因为有贴图颜色的存在)

                // 计算漫反射光线
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir)); 

                // 计算高光，使用Blinn-Phong公式
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);                    // 计算h单位向量，使用Blinn公式
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                // 呈现颜色：环境光 + 漫反射 + 高光反射
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
