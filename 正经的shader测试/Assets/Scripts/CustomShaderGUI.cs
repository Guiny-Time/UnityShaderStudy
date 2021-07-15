using UnityEngine;
using UnityEditor;
using System;

public class CustomShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // 渲染默认 GUI
        base.OnGUI(materialEditor, properties);

        Material targetMat = materialEditor.target as Material;

        // 检查是否设置了 redify 并显示一个复选框
        bool redify = Array.IndexOf(targetMat.shaderKeywords, "REDIFY_ON") != -1;
        EditorGUI.BeginChangeCheck();
        redify = EditorGUILayout.Toggle("Redify material", redify);
        if (EditorGUI.EndChangeCheck())
        {
            // 根据复选框来启用或禁用关键字
            if (redify)
                targetMat.EnableKeyword("REDIFY_ON");
            else
                targetMat.DisableKeyword("REDIFY_ON");
        }
    }
}