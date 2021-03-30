using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ShaderHelper  
{
    const string plugins_path = @"Assets\ShaderHelper\Editor\";
    private static string GetClickedDirFullPath()
    {
        if (Selection.assetGUIDs.Length == 0)
            return null;
        string clickedAssetGuid = Selection.assetGUIDs[0];
        string clickedPath = AssetDatabase.GUIDToAssetPath(clickedAssetGuid);
        //string clickedPathFull = Path.Combine(Directory.GetCurrentDirectory(), clickedPath);

        FileAttributes attr = File.GetAttributes(clickedPath);
        return attr.HasFlag(FileAttributes.Directory) ? clickedPath : Path.GetDirectoryName(clickedPath);
    }

    static void CreateShaderFromTemp(string fileName)
    {
        string path = GetClickedDirFullPath();
        string txt = File.ReadAllText(plugins_path + fileName+ ".txt");
        for (int i = 0; ; i++)
        {
            string full_path = path + @"\"+ fileName + "_"+i + ".shader";
            if (!File.Exists(full_path))
            {
                txt = txt.Replace("[#index]", i.ToString());
                txt = txt.Replace("[$index]", "[#index]");
                File.WriteAllText(full_path, txt);
                AssetDatabase.ImportAsset(full_path);
                break;
            }
        }
    }
    [MenuItem("Assets/Create/Shader/URP Shader Simple")]
    public static void CreateSimple()
    {
        CreateShaderFromTemp("simple_shader");
         
    }

    [MenuItem("Assets/Create/Shader/URP SimpleLit")]
    public static void CreateSimpleLit()
    {
        CreateShaderFromTemp("SimpleLit");
    }

    [MenuItem("Assets/Create/Shader/URP Lit")]
    public static void CreateLit()
    {
        CreateShaderFromTemp("Lit");
    }

}
