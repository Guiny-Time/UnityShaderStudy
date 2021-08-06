using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// 目前它只是用来放置塔
/// 但是我想让它顺便把路径也负责了如果可以的话
/// </summary>
public class MapManger : SingletonMono<MapManger>
{
    [SerializeReference]private GameObject[] towerPlaces;//所有能够放塔的地方
    private bool[] placeableStates;//塔的放置状况
    [SerializeReference]private Material highlight;
    [SerializeReference]private Material normal;
    private PoolMgr poolMGR;
    private GameObject chosenPlace;

    private UnityAction<GameObject> callBack;


    private new void Awake()
    {
        base.Awake();
        towerPlaces=GameObject.FindGameObjectsWithTag("TowerPlace");
        placeableStates=new bool[towerPlaces.Length];
        for(int i=0;i<placeableStates.Length;i++) placeableStates[i]=true;
        poolMGR=PoolMgr.GetInstance();
        callBack+=PlaceTower;
    }

    /// <summary>
    /// true 表示显示，false表示关闭
    /// </summary>
    public void HighlightEmptyPlaces(bool isHighlight)
    {
        Material material;
        if(isHighlight) material=highlight;
        else material=normal;
        for(int i=0;i<placeableStates.Length;i++)
        {
            if(placeableStates[i]) towerPlaces[i].GetComponent<Renderer>().material=material;
        }
    }
    /// <summary>
    /// 在某个位置放置塔
    /// </summary>
    /// <param name="area"></param>
    public void PutTower(GameObject area,string towerName)
    {
        for(int i=0;i<towerPlaces.Length;i++)
        {
            if(towerPlaces[i].Equals(area)) 
            {
                if(!placeableStates[i])
                return;
                chosenPlace=area;
                placeableStates[i]=false;
                break;
            }
        }
        poolMGR.GetObj("Prefabs/Tower/"+towerName,callBack);
    }
    /// <summary>
    /// 调整被放置塔的位置
    /// </summary>
    /// <param name="tower"></param>
    private void PlaceTower(GameObject tower)
    {
        if(chosenPlace==null) 
        {
            print(true);
            return;
        }
        tower.transform.SetParent(chosenPlace.gameObject.transform);
        tower.transform.localPosition=new Vector3(0,0,-0.6f);
        tower.transform.localScale=new Vector3(0.2f,0.2f,0.2f);
        tower.transform.localRotation=Quaternion.Euler(-90f,0f,0f);
    }


}
