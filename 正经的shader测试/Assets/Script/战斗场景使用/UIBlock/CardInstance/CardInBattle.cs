using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class CardInBattle : CardOutlook,IPointerDownHandler
{
    private MouseManager mouseControl;
    private Card card;

    public override void MakeCard(int idx)
    {
        base.MakeCard(idx);
        card=CardManager.GetInstance().GetCardInfoByIndex(idx);
    }
    
    public void OnPointerDown(PointerEventData eventData)
    {
        MouseManager.GetInstance().SelectToUseCard(card);
    }
}
