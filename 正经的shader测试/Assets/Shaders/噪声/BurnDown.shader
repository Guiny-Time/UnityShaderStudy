// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 消融的原理是噪声 + 透明度测试，边缘的燃烧效果是平滑混合得到的
Shader "Custom/边缘消融"
{
    Properties{
        _BurnAmount("消融程度", Range(0.0, 1.0)) = 0.0
        _LineWidth("熔融带宽", Range(0.0, 0.2)) = 0.1
        _MainTex("纹理贴图(RGB)", 2D) = "white" {}
        _BumpMap("法线纹理", 2D) = "bump" {}
        _BurnFirstColor("第一消融颜色", Color) = (1, 0, 0, 1)
        _BurnSecondColor("第二消融颜色", Color) = (1, 0, 0, 1)
        // 嘿嘿，重头戏
        _BurnMap("噪声纹理", 2D) = "white"{}
    }
    SubShader{
        Pass{
            Tags{"LightMode" = "ForwardBase"}
            // 关闭剔除，目的是在透明的时候可以看到后面
            Cull Off
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            
            // 得到正确的光照
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed _BurnAmount;
            fixed _LineWidth;
            sampler2D _MainTex;
			float4 _MainTex_ST;
            sampler2D _BumpMap;
			float4 _BumpMap_ST;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;
            sampler2D _BurnMap;
			float4 _BurnMap_ST;
            
            struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
			};

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                // ？？
                SHADOW_COORDS(5)
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 纹理映射
                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
                
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 宏，阴影纹理采样
                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                // 裁剪掉不显示的像素。消融程度越大被抛弃的像素越多
                clip(burn.r - _BurnAmount);
                // 用于切线空间下法线纹理的计算
                float3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

                // 贴图
                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                /*消融效果部分*/
                // 边缘控制变量，在不可见区域往里的带宽范围内。step的作用是范围外不显示（但是是模糊的边缘而不是锐边）
                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
                // 计算边缘烧焦的颜色，在两种颜色中用t进行插值，实现渐变效果（纯色也行）
                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                // 指数处理
                burnColor = pow(burnColor, 5);

                // 宏，计算光照衰减系数
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t* step(0.0001, _BurnAmount));

                return  fixed4(finalColor, 1);
            }
            ENDCG
        }
        
        // 用于计算真实的阴影，即剔除掉透明部分的阴影
        Pass{
            Tags{"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed _BurnAmount;
            sampler2D _BurnMap;
			float4 _BurnMap_ST;
            
            struct appdata_Base {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
                float3 tangent : TANGENT;
			};

            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
            };
            
            v2f vert(appdata_Base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target{
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}
