Shader "Custom/前向渲染（多光源）"
{
   Properties{
        _Diffuse ("漫反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("高光反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("光泽度", Range(8.0, 256)) = 20
    }
    SubShader{
        // base pass
        Pass{
            Tags{ "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v{
                float4 vertex : POSITION;               // 顶点位置
                float3 normal : NORMAL;                 // 顶点法线
            };

            struct v2f{
                float4 pos : SV_POSITION;               // 裁剪空间的片元位置
                float3 worldNormal : TEXCOORD0;         // 片元的世界法线
                float3 worldPos : TEXCOORD1;            // 片元的世界位置
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject); 
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                fixed atten =1.0;
                
                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
        
        Pass{
            // addition pass
            Tags{ "LightMode" = "ForwardAdd" }
            
            // 设置混合模式为叠加，防止覆盖掉之前渲染的结果
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 访问正确的光照变量
            #pragma multi_compile_fwdbase
            // 得到正确的光照
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;               // 顶点位置
                float3 normal : NORMAL;                 // 顶点法线
            };

            struct v2f{
                float4 pos : SV_POSITION;               // 裁剪空间的片元位置
                float3 worldNormal : TEXCOORD0;         // 片元的世界法线
                float3 worldPos : TEXCOORD1;            // 片元的世界位置
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject); 
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target{

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir;
                 #if USING_DIRECTIONAL_LIGHT
                    worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                fixed atten;
                #ifdef USING_DIRECTION_LIGHT
                    atten = 1.0;
                #else
                    float3 lightCoord = mul(_lightMatrix0, float4(i.worldPosition, 1)).xyz;
                    atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif
                
                return fixed4(ambient + diffuse + specular, 1.0);
            }

           
            

            ENDCG
        }
    }
    Fallback "Specular"
}
