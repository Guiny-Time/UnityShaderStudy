using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;


/// <summary>
/// 这里是牌的洗牌区，手牌区
/// </summary>
public class CardArea : SingletonMono<CardArea>
{
   private PoolMgr poolMgr;
   private UnityAction<GameObject> callBack;
   /// <summary>
   /// 未使用卡牌
   /// </summary>
   private Queue<int> unusedCards;
   /// <summary>
   /// 已使用卡牌
   /// </summary>
   private List<int> usedCards;
   /// <summary>
   /// 当前卡牌数量
   /// </summary>
   private int cardsInHand=0;
   

   /// <summary>
   /// 对象池
   /// </summary>
   private PoolData poolData;

    /// <summary>
    /// 游戏初始化使用
    /// </summary>
   private new void Awake()
   {
       base.Awake();
       poolMgr=PoolMgr.GetInstance();
       unusedCards=new Queue<int>();
       usedCards=new List<int>();
       callBack+=PutCard; 
       callBack+=MakeCard;
   }
   

    public void AddCard(int i)
    {
        unusedCards.Enqueue(i);
        if(cardsInHand<4) poolMgr.GetObj("Prefabs/Cards/CardInGameUI",callBack);
        
    }

  

/*
    /// <summary>
    /// 初始化手牌状况
    /// </summary>
    private void InitializeCards()
    {
        BasicTool.Shuffle(cardHeap);
        foreach(int i in cardHeap)
        {
            unusedCards.Enqueue(i);
        }
        for(int i=0;i<4;i++)poolMgr.GetObj("Prefabs/Cards/CardInUI",callBack);
    }
*/

    /// <summary>
    /// 将抽到的卡牌放入手牌区域
    /// </summary>
    /// <param name="card"></param>
    private void PutCard(GameObject card)
    {
        card.transform.SetParent(gameObject.transform);
        card.transform.localScale=new Vector3(1,1,1);
        card.SetActive(true);
    }

    /// <summary>
    /// 改变卡牌外貌以及效果
    /// </summary>
    /// <param name="card"></param>
    private void MakeCard(GameObject card)
    {
        if(unusedCards.Count==0) Shuffle();
        int cardID=unusedCards.Dequeue();
        card.GetComponent<CardOutlook>().MakeCard(cardID);
        cardsInHand++;
    }

    /// <summary>
    /// 洗牌
    /// </summary>
    private void Shuffle()
    {
        int[] used=BasicTool.ToArray(usedCards);
        usedCards.Clear();
        BasicTool.Shuffle(used);
        foreach(int i in used)unusedCards.Enqueue(i); 
    }

}
