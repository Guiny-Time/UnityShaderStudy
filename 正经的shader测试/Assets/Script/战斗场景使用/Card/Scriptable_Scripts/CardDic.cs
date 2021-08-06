using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CardDic", menuName = "Card/CardDic")]
public class CardDic : ScriptableObject
{
    public Card[] cardInfo;
    public TowerCard[] towerCards;
    public AttackCard[] attackCards;
}
