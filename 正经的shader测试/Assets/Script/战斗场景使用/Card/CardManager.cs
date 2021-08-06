using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// 卡牌管理器类，洗牌刷牌，管理对象池
/// </summary>
public class CardManager : SingletonAutoMono<CardManager>
{
    [SerializeReference]private CardDic cardDic;

    private new void Awake()
    {
        base.Awake();
        int lent=cardDic.towerCards.Length,lena=cardDic.attackCards.Length,len=lent+lena;
        cardDic.cardInfo=new Card[len];

        for(int i=0;i<cardDic.towerCards.Length;i++) cardDic.cardInfo[i]=cardDic.towerCards[i];
        for(int i=lent;i<len;i++) cardDic.cardInfo[i]=cardDic.attackCards[i];
    }
    public CardArea cardArea;
    
    /// <summary>
    /// 角色解锁的卡牌
    /// </summary>
    private List<int> useableCards;

    /// <summary>
    /// 角色当前手牌
    /// </summary>
    [SerializeReference]private int[] playerCard;

    /// <summary>
    /// 游戏开始调用，用于初始化
    /// </summary>
    public void GameStart()
    {
        cardArea=CardArea.GetInstance();
        
    }

    /// <summary>
    /// 用于外界获取指定序号卡牌
    /// </summary>
    /// <param name="i"></param>
    public void AddCardInGame(int i)
    {
        cardArea.AddCard(i);
    }

    /// <summary>
    /// 留着存档用的接口
    /// </summary>
    public void ReadCardOfPlayer()
    {

    }
    /// <summary>
    /// 通过ID获取卡牌
    /// </summary>
    /// <param name="idx"></param>
    /// <returns></returns>
    public Card GetCardInfoByIndex(int idx)
    {
        return cardDic.cardInfo[idx];
    }
}
