// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Lec5/着色器之间的通信"
{
    Properties {
        // 声明一个Color类型的属性
        _Color ("颜色拾取器", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // 在Cg中，我们需要定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;

            // 这是一个结构体，定义了顶点着色器的输入
            // 结构体内部必须是: 类型 变量名 : 语义
            // a2v表示应用阶段到顶点着色器
            struct a2v{
                // POSITION语义：用**模型空间的顶点坐标**填充vertex变量
                float4 vertex : POSITION;
                // NORMAL语义：用**模型空间的法线方向**填充normal变量
                float3 normal : NORMAL;
                // TEXCOORD语义：用**模型的第一套纹理坐标**填充texcoord变量
                float4 texcoord : TEXCOORD0;
            };

            // v2f表示顶点着色器到片元着色器的通信
            struct v2f{
                // SV_POSITION语义：用**裁剪空间中的位置信息**填充pos变量
                float4 pos : SV_POSITION;
                // COLOR0语义：储存**颜色信息**
                float3 color : COLOR0;
            };
            
            // 这是一个返回v2f的函数，输入是a2v
            v2f vert (a2v v)
            {
                // 声明输出结构为v2f
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // v.normal包含了模型空间的法线方向，分量在1与-1之间
                // 这里把分量**映射到了0与1之间**，储存到o.color中传给片元着色器
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                /*// 将插值后的i.color显示在屏幕上
                return fixed4(i.color, 1.0);*/

                fixed3 c = i.color;
                // 使用Color属性控制输出的颜色
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
}
