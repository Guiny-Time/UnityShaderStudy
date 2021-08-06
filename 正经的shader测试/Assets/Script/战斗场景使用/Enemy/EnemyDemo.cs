using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

/// <summary>
/// 挂载在**同一种敌人类型**上的预制件上的类
/// </summary>
public class EnemyDemo : Enemy
{
    

    // 初始化预制件位置
    void Start(){
        this.transform.position = path[0];
    }

    void Update(){
        MoveGameObject();
        if(blood<=0) PoolMgr.GetInstance().PushObj(this.name,gameObject);

    }
}
