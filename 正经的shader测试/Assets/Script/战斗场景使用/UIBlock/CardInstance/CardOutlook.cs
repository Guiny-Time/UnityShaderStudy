using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CardOutlook : MonoBehaviour
{
  //[SerializeReference]private Text describe;
  [SerializeReference]private Image icon;
  public int cardID;
    
    /// <summary>
    /// 根据卡片的序号制作一张牌
    /// </summary>
    /// <param name="idx"></param>
  public virtual void MakeCard(int idx)
  {
    CardManager manager = CardManager.GetInstance();
    Card card= manager.GetCardInfoByIndex(idx);
    icon.sprite=card.cardSprite;
    cardID=idx;
    //describe.text=card.describe;
  }
}
