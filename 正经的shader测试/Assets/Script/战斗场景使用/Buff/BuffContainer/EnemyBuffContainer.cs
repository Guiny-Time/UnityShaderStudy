using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 这里只写某些buff的效果与buff的具体实现，采取订阅方式
/// </summary>
public class EnemyBuffControl : BuffContainer<Enemy>
{
    private new void AddBuff(Buff buff, int layer)
    {
        base.AddBuff(buff,layer);
    }

    /// <summary>
    /// 模板方法
    /// </summary>
   private void Templete()
   {

   }
}
