Shader "Custom/近地雾"
{

    Properties
    {
        _RampTex("渐变纹理", 2D) = "white"{}
        // 颜色设置
        _UpColor("Main Color",Color)=(1,1,1,1)
        _DownColor("Fog Color",Color)=(1,1,1,1)
        // 雾气浓度
        _Concentration("Fog Concentration", float) = 0
        // 最高雾气位置
        _Test("Skyline",float) = 0
    }
    
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float3 worldNormal : NORMAL;
                float4 vertex : SV_POSITION;
                float3 worldN : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float distance : TEXCOORD3;
            };

            sampler2D _RampTex;
            float4 _RampTex_ST;
            float4 _UpColor;
            float4 _DownColor;
            float _Concentration;
            float _Test;
            
            v2f vert(appdata v)
            {
                v2f o;
                // 获取观察空间坐标
				float3 cameraPos = mul(UNITY_MATRIX_MV,v.vertex).xyz;
				// 计算与相机距离
				o.distance = length(cameraPos);
                // 获取世界空间坐标
                o.worldPos=mul(UNITY_MATRIX_M,v.vertex);
                // 获取裁剪空间坐标
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul((float3x3)UNITY_MATRIX_M, v.normal));
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                fixed3 worldN = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float NdotL = dot(i.worldNormal, _WorldSpaceLightPos0);
                float light = clamp(NdotL * 0.237 + 0.763, 0, 1);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Half-Lambert漫反射模型
                fixed halfLambert = 0.5 * dot(worldN, worldLightDir) + 0.5;
                // 漫反射的颜色，受半兰伯特本身、渐变纹理与主色调影响
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;

                _Concentration = min(_Concentration + i.distance, _Test);
                
                float4 fogCol = light * lerp(_DownColor, _UpColor, clamp( (i.worldPos.y - _Concentration) / 7.5, 0, 1));
                float4 col = fixed4(ambient + diffuse + fogCol, 1.0);
                
                return col;
            }
            ENDCG 
        }
    }
}