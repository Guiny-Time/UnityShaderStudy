// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Lec5/简单的顶点着色器"      // 保持良好的命名习惯
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert     // 这两行告诉了Unity包含了哪种着色器的代码
            #pragma fragment frag   // 这里的vert和frag是着色器的名字，前面的是着色器类型

            // 第一个顶点着色器方法，把顶点的模型空间的坐标转化成裁剪空间的坐标
            // POSITION是输入，代表顶点的位置
            // SV_POSITION是输出，代表裁剪空间的位置
            float4 vert(float4 v : POSITION) : SV_POSITION{
                return UnityObjectToClipPos(v);
            }

            // 返回值为“把输出颜色存储到一个渲染目标(target)”的float4类型
            fixed4 frag() : SV_Target{
                return fixed4(1.0,1.0,1.0,1.0);
            }
            ENDCG
        }
    }
}
