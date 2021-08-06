using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CostManager : SingletonMono<CostManager>
{
    private int cost=0;

    /// <summary>
    /// 消耗cost，同时返回能否正常消耗
    /// </summary>
    /// <param name="need"></param>
    /// <returns></returns>
    public bool UseCost(int need)
    {
        if(cost>=need) 
        {
            cost-=need;
            return true;
        }
        else return false;
    }

    public int AddCost(int addition)
    {
        cost+=addition;
        return cost;
    }

}
