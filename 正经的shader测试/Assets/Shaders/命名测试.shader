Shader "Lec3/Shader命名测试"
{
    Properties
    {
        //属性名("展示在面板上的名字", 属性类型) = 默认值
        _Int("Int类型", Int) = 2
        _Float("Float类型", Float) = 1.5
        _Range("Range类型", Range(0.0,5.0)) = 3.0   //Range类型默认内部为float，在声明属性类型的时候就要加上范围值
        _Color("Color类型", Color) = (0.2,0.3,1,1)  //Color是一个四元组，表示RGBA
        _Vector("Vector类型", Vector) = (1,2,3,4)   //Vector同样是四元组，表示一个四维向量
        _2D("2D类型", 2D) = ""{}                    //纹理类型，双引号内是内置纹理名称，花括号是纹理属性
        _Cube("Cube类型", Cube) = "white"{}         //纹理类型
        _3D("3D类型", 3D) = "black"{}               //纹理类型
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }  // 标签
        // 下面这两个都是状态设置
        Cull Off                        
        LOD 100

        Pass
        {
            Name "GuinyFirstPass"
            tags {"LightMode"="ForwardBase"}
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog   

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
