using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;


/// <summary>
/// 缓存池模块
/// 1.Dictionary List
/// 2.GameObject 和 Resources 两个公共类中的 API 
/// </summary>
public class PoolMgr : BaseManager<PoolMgr>
{

    //缓存池容器 （衣柜）
    public Dictionary<string, PoolData> poolDic = new Dictionary<string, PoolData>();
    protected GameObject poolObj;

    /// <summary>
    /// 往外拿东西,name是池子名字
    /// callBack是自定义委托，这里可以用来代码定义被取出物品的行为
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public virtual void GetObj(string name, UnityAction<GameObject> callBack)
    {
        //有抽屉 并且抽屉里有东西
        if (poolDic.ContainsKey(name) && poolDic[name].poolList.Count > 0)
        {
            callBack(poolDic[name].GetObj());
        }
        else//通过异步加载资源 创建对象给外部用
        {
            ResMgr.GetInstance().LoadAsync<GameObject>(name, (o) =>
            {
                o.name = name;
                if(callBack!=null)callBack(o);
            });
        }
    }

    /// <summary>
    /// 换暂时不用的东西给我
    /// </summary>
    public void PushObj(string name, GameObject obj)
    {

       if (poolObj == null)
            poolObj = new GameObject("Pool");

        //里面有抽屉
        if (poolDic.ContainsKey(name))
        {
            poolDic[name].PushObj(obj);
        }
        //里面没有抽屉
        else
        {
            poolDic.Add(name, new PoolData(obj, poolObj));
        }
    }


    /// <summary>
    /// 清空缓存池的方法 
    /// 主要用在 场景切换时
    /// </summary>
    public void Clear()
    {
        poolDic.Clear();
        poolObj = null;
    }
}
