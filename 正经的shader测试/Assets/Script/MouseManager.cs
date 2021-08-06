using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

 /// <summary>
    /// 当前是在给卡放置牌，选择塔安置地点，还是什么都不做,最后一个是预留的，考虑到之后可能让牌在不是塔的地方使用
    /// </summary>
    public enum MouseMode
    {
        PutCard,PutTower,None
    }

/// <summary>
/// 专家模式
/// 因为鼠标变化我实在没想到除了战斗还有什么时候用得到鼠标变化，所以将战斗的判定都交给这个了
/// </summary>
public class MouseManager : SingletonAutoMono<MouseManager>
{
    [SerializeReference]private Texture2D mouseTexture;
    private Card cardFunction;
    private string towerName;
    private MouseMode mode=MouseMode.None;
    private bool readyToChange;


    //!因为塔和牌的实体有部分信息未定义，所以当前update方法不完整
    private void Update()
    {
        if(Input.GetMouseButtonDown(0))//左键
        {
            if(readyToChange)
                switch(mode)
            {
                case MouseMode.None: 
                    return;
                case MouseMode.PutCard:
                    ClearState();
                     break;
                case MouseMode.PutTower:
                    CheckToPutTower(); 
                    ClearState();
                    MapManger.GetInstance().HighlightEmptyPlaces(false);
                    break;        
                default:
                    ClearState();
                break;
            }
            else if(mode!=MouseMode.None) readyToChange=true;
        }
         
    }

    /// <summary>
    /// 检查是否能够在这个位置放置塔
    /// </summary>
    private void CheckToPutTower()
    {
        Ray ray=Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        bool isCollider=Physics.Raycast(ray,out hit,1000f,LayerMask.GetMask("Default"));
        if(isCollider) 
        {
           GameObject towerPlace=hit.collider.gameObject;
           if(towerPlace.tag.Equals("TowerPlace")) MapManger.GetInstance().PutTower(towerPlace,towerName);
        }
    }

    /// <summary>
    /// 使用牌的时候
    /// </summary>
    public void SelectToUseCard(Card card)
    {
        cardFunction=card;
        towerName="";
        ChangeStyle(MouseStyle.Aim);
        mode=MouseMode.PutCard;
        readyToChange=false;
        MapManger.GetInstance().HighlightEmptyPlaces(false);
    }

    /// <summary>
    /// 选择放置塔
    /// </summary>
    /// <param name="tower"></param>
    public void SelectToPutTower(String towerName)
    {
        this.towerName=towerName;
        cardFunction=null;
        ChangeStyle(MouseStyle.Aim);
        this.mode=MouseMode.PutTower;
        MapManger.GetInstance().HighlightEmptyPlaces(true);
        readyToChange=false;
    }

    /// <summary>
    /// 更换鼠标箭头样式
    /// </summary>
    /// <param name="style"></param>
    private void ChangeStyle(MouseStyle style)
    {
        switch(style)
        {
            case MouseStyle.Aim: 
                Cursor.SetCursor(mouseTexture,new Vector2(16,16),CursorMode.Auto);
                break;
            case MouseStyle.Arrow:
                Cursor.SetCursor(null,Vector2.zero,CursorMode.Auto);
                break;
        }
        
    }

    /// <summary>
    /// 改鼠标样式
    /// </summary>
    private void ClearState()
    {
        towerName="";
        cardFunction=null;
        mode=MouseMode.None;
        ChangeStyle(MouseStyle.Arrow);
    }
 public enum MouseStyle
{
    Arrow,Aim
}


}
