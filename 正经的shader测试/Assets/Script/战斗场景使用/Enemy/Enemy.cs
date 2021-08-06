using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 敌人父类

public abstract class Enemy : MonoBehaviour
{
    // 怪物移速
    [SerializeReference] protected float speed;     // 编译器输入速度,除以10之后得到真实速度，值越大速度越大

    // 怪物血量
    [SerializeReference] protected int blood;

    // 怪物伤害
    [SerializeReference] private int damage;

    // buff字典，存储怪物身上携带的所有buff
    [SerializeReference] private Dictionary<Buff, int> buffs = new Dictionary<Buff, int>();

    // 击杀怪物之后回复的费用
    [SerializeReference] private int cost;

    // 自定义路径
    [SerializeReference]protected List<Vector2> path;

    // 用于移动控制
    private int i;

    // 初始旋转（面朝下）
    private Quaternion defaultRotation;

    void Start() {
        defaultRotation = new Quaternion(-90,90,-90,0);
        transform.position = path[0];
    }

    void Update(){
        if(blood == 0){
            PoolMgr.GetInstance().PushObj(this.name,this.gameObject);
            transform.position = new Vector3(path[0].x,path[0].y,-1);
            transform.rotation = defaultRotation;
        }
    }

    /// <summary>
    /// 调用结算buff
    /// </summary>
    virtual protected void CallBuff()
    {
        
    }

    /// <summary>
    /// 受到伤害，同时触发身上携带的buff
    /// </summary>
    /// <param name="damage"></param>
    public void Hurt(int damage,Dictionary<Buff,int> buffDic)
    {
        blood -= damage;
    }

    /// <summary>
    /// 受到伤害，同时身上并没有buff
    /// </summary>
    /// <param name="damage"></param>
    public void Hurt(int damage)
    {
        blood -= damage;
    }

    /// <summary>
    /// 接受buff,处理buff接收
    /// </summary>
    /// <param name="buff"></param>
    /// <param name="value"></param>
    protected void AddBuff(Buff buff, int value)
    {
        buffs.Add(buff, value);
    }

    /// <summary>
    /// 移除buff
    /// </summary>
    /// <param name="buffName"></param>
    protected void RemoveBuff(string buffName)
    {
        // 遍历删除防止报错
        foreach(KeyValuePair<Buff, int> kvp in buffs)
        {
            if(kvp.Key.ToString() == buffName)
            {
                buffs.Remove(kvp.Key);
            }
        }
    }

    /// <summary>
    /// 敌人根据路径进行移动
    /// </summary>
    protected void MoveGameObject(){
        if(transform.position.x == path[i].x && transform.position.y == path[i].y){
            i++;
        }else{
            // 向右走
            if(path[i].x < transform.position.x && path[i].y == transform.position.y){
                 
                this.transform.rotation = Quaternion.Euler(0,90,-90);
            }
            // 向左走
            if(path[i].x > transform.position.x && path[i].y == transform.position.y){
                 
                this.transform.rotation = Quaternion.Euler(180,90,-90);
            }
            // 向上走
            if(path[i].x == transform.position.x && path[i].y < transform.position.y){
                this.transform.rotation = Quaternion.Euler(-90,90,-90);
            }
            // 向下走
            if(path[i].x == transform.position.x && path[i].y > transform.position.y){
                this.transform.rotation = Quaternion.Euler(90,90,-90);
            }
            transform.position = Vector3.MoveTowards(transform.position, path[i], (speed / 10) * Time.deltaTime);      // 移动到下一位置
        }

        if(i == path.Count){        // 到达终点
            SafeCubeCatcher();
            i = 0;
        }
    }

    /// <summary>
    /// 敌人移动到防御点
    /// </summary>
    void SafeCubeCatcher()
    {
        PoolMgr.GetInstance().PushObj(this.name,this.gameObject);
        transform.position = new Vector3(path[0].x,path[0].y,-1);
        transform.rotation = defaultRotation;
        // 进防御点之后相关事件
    }
    
}