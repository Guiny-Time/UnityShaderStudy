using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public abstract class BuffContainer<T> : MonoBehaviour
{
    [Header("自带固定原始buff")]
    [SerializeReference]private Buff[] fixedBuff;
    /// <summary>
    /// 当前获得的临时Buff状态
    /// </summary>
    protected Dictionary<Buff,int> TempBuffs;
    /// <summary>
    /// 当前获得的永久buff
    /// </summary>
    protected List<Buff> EssentialBuffs;

    /// <summary>
    /// 用于塔与牌不同结算方式的通用委托
    /// </summary>
    protected UnityAction TempBuffHandler;

    protected T owner;

    private void OnEnable()
    {
        TempBuffHandler=null;
        EssentialBuffs.Clear();
        TempBuffs.Clear();

        foreach(Buff buff in fixedBuff)
        {
            EssentialBuffs.Add(buff);
        }
    }

    private void Start()
    {
        TempBuffs=new Dictionary<Buff, int>();
        EssentialBuffs=new List<Buff>();
    }

    /// <summary>
    /// 少数单个Buff添加
    /// </summary>
    /// <param name="buff"></param>
    /// <param name="layer"></param>
    public virtual void AddBuff(Buff buff,int layer)
    {
        
        if(!TempBuffs.ContainsKey(buff)) TempBuffs.Add(buff,1);
        else if(buff.isTemp) 
        {
            if(buff.increasable) TempBuffs[buff]++;//可叠加类型刷新层数
            else TempBuffs[buff]=buff.buffExistTime;//不可刷新类型刷新时间
        }
        else if(!EssentialBuffs.Contains(buff)) EssentialBuffs.Add(buff);
        if(TempBuffs.Count==1) StartCoroutine("CalTempBuff");//!当前只有1个buff时候启动，避免多次启动，这个需要测试
    }

    /// <summary>
    /// 以字典形式添加Buff
    /// </summary>
    /// <param name="AdditionalTempBuff"></param>
    public void AddBuff(Dictionary<Buff,int> AdditionalTempBuff)
    {
        foreach(var item in AdditionalTempBuff)
        {
            AddBuff(item.Key,item.Value);
        }
    }

    /// <summary>
    /// 用于清空某个buff
    /// </summary>
    /// <param name="buff"></param>
    public void RemoveBuff(Buff buff)
    {
        if(!TempBuffs.ContainsKey(buff)) return;
        TempBuffs.Remove(buff);
    }

    /// <summary>
    /// 非常重要的方法，临时buff务必实现
    /// </summary>
    /// <param name="buff"></param>
    /// <returns></returns>
    protected int DecreaseBuff(Buff buff)
    {
        if(!TempBuffs.ContainsKey(buff)) return 0;
        TempBuffs[buff]--;
        if(TempBuffs[buff]==0) TempBuffs.Remove(buff);
        if(!TempBuffs.ContainsKey(buff)) return 0;
        else return TempBuffs[buff];
    }
    /// <summary>
    /// 有BUFF的话，每秒结算一次
    /// </summary>
    /// <returns></returns>
    IEnumerator CalTempBuff()
    {
        while(TempBuffs.Count>0) TempBuffHandler();
        yield return new WaitForSeconds(1);
    }
}

