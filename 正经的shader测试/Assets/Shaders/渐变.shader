Shader "Custom/渐变"
{

    Properties
    {
        // 对比度
        _Contrast("Contrast",Range(0,1))=0.1
        _RampTex("渐变纹理", 2D) = "white"{}
        // 渐变
        _UpColor("UpColor",Color)=(1,1,1,1)
        _DownColor("DownColor",Color)=(1,1,1,1)
        // 渐变程度
        _WorldYDeno("WorldYDeno",float)=0
        // 渐变中心位置
        _Skyline("地平线", float) = 0
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
                float3 worldPos:TEXCOORD1;
                float3 worldN : TEXCOORD0;
                float2 uv : TEXCOORD2;
            };

            float _Contrast;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            float4 _UpColor;
            float4 _DownColor;
            float _WorldYDeno;
            float _Skyline;
            
            v2f vert(appdata v)
            {
                v2f o;
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
                float light = clamp(NdotL * _Contrast + (1 - _Contrast), 0, 1);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Half-Lambert漫反射模型
                fixed halfLambert = 0.5 * dot(worldN, worldLightDir) + 0.5;
                // 漫反射的颜色，受半兰伯特本身、渐变纹理与主色调影响
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;
                
                float4 col = fixed4(ambient + diffuse + light * lerp(_DownColor, _UpColor, clamp( (i.worldPos.y - _Skyline) / _WorldYDeno, 0, 1)), 1.0);
                
                return col;
            }
            ENDCG 
        }
    }
}