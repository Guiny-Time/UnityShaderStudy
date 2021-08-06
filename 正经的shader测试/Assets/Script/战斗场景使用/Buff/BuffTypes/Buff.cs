using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "TempBuff", menuName = "Buff/TempBuff")]
public class Buff: ScriptableObject
{
    /// <summary>
    /// BUFF是给敌人还是给塔用的还是公用的
    /// </summary>
    public BuffType buffType;
    public string buffName;
    // buff是否允许叠加
    public bool increasable;
    [Header("true为临时buff，false为永久buff")]
    public bool isTemp;
    
    // 临时buff存在时间单元
     [Header("永久buff不填这个")]
    public int buffExistTime;
    public enum BuffType
    {
        OTower,OEnemy,Both
    }
}
