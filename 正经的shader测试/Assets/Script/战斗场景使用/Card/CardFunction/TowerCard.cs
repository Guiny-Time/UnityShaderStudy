using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "TowerCard", menuName = "Card/TowerCard")]
public class TowerCard : Card
{
   [Header("可用于塔类型")]
   [SerializeReference]private List<TOWERTYPE> availTowers;
   [Header("卡牌属性")]
   [SerializeReference] private int additionalPhysicalDamage;
   [SerializeReference] private int additionalMagicDamage;
   [SerializeReference] private int attackSpeed;
   [SerializeReference] private int increaseSpeed;
   [SerializeReference] private int increaseArea;

    /// <summary>
    /// 使用卡牌
    /// </summary>
    /// <param name="tower"></param>
   public void UsedCard(Tower tower)
   {
       if(!CheckTower(tower)) return;
   }

   private bool CheckTower(Tower tower)
   {
       return availTowers.Contains(tower.GetTOWERTYPE());
   }
 
}
