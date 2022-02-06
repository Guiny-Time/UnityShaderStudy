Shader "Custom/可交互边缘光"
{
    Properties
    {
        _MainColor ("MainColor", Color) = (0,0,0,1)
        
        _InSideRimColor ("InSideRimColor", Color) = (1,1,1,1)               // 边缘光颜色
        _InSideRimPower("InSideRimPower", Range(0.0,5)) = 0                 // 边缘光强度,这个值可以控制菲涅尔影响范围的大小，这个值越大，效果上越边缘化
        _InSideRimIntensity("InSideRimIntensity", Range(0, 50)) = 0       // 边缘光强度系数 这个值是反射的强度， 值越大，返回的强度越大，导致边缘的颜色不那么明显  
        
        _MainTex("纹理", 2D) = "white" {}
        _Specular("高光反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  }
        LOD 100
        Pass  //内边缘光pass
        {
            Tags{ "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _MainColor;
            uniform float4 _InSideRimColor;
            float  _InSideRimPower;
            float _InSideRimIntensity;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 wold_normal : TEXCOORD1;
                float4 vertexWorld : TEXCOORD2;

            };
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wold_normal = mul(unity_ObjectToWorld, float4(v.normal,0)).xyz;
                o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                const fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainColor.rgb;               // 反照率，对贴图进行纹理采样（计算出的纹素值与主色调相乘）
                const fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                
                i.wold_normal = normalize(i.wold_normal);                                       //下面计算方式套用菲涅尔计算
                float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWorld.xyz);  //获取单位视角方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz); 
                const fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(i.wold_normal, worldLightDir)); 
                
                half NdotV = max(0, dot(i.wold_normal, worldViewDir));                          // 计算法线方向和视角方向点积,约靠近边缘夹角越大，值约小，那就是会越在圆球中间约亮，越边缘约暗
                NdotV = 1.0-NdotV;
                float fresnel = pow(NdotV,_InSideRimPower) * _InSideRimIntensity;
                float3  Emissive=_InSideRimColor.rgb*fresnel;                                   // 内边缘光颜色
                return fixed4(Emissive + diffuse + ambient,1.0);
            }
            ENDCG
        }
    }
}