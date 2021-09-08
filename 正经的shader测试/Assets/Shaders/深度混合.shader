Shader "Custom/深度混合"
{
    Properties{
        _Color("主色调", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("纹理贴图", 2D) = "white"{}
        _AlphaScale("透明度范围", Range(0, 1)) = 1
    }

    fixed4 _Color;
    sampler2D _MainTex;
    fixed _AlphaScale;

    SubShader{
        Tags{ 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        Pass{
            Tags{ "LightMode" = "ForwardBase" }
            // 关闭深度写入，准备深度混合
            ZWrite Off;
            Blend SrcAlpha OneMinusSrcAlpha;    // 将源颜色混合因子设置成SrcAlpha，目标颜色的混合因子设置成OneMinusSrcAplha
        }
    }
    
}
