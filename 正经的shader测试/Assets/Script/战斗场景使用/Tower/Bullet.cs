using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    //>子弹相关
    [SerializeField]private float speed ;       // 子弹速度
    [SerializeField]private int damage ;        // 子弹伤害
    [SerializeField]private Transform target ;  // 攻击目标
    private Dictionary<Buff,int> debuffs;       // buff字典
    private float MaxLifeTime = 3f;             // 子弹最长生命时间
    private float LifeTime;


    /// <summary>
    /// 动态更改子弹属性
    /// </summary>
    /// <param name="damage"></param>
    /// <param name="debuffs"></param>
    public void SetBulletAttribute(int damage, Dictionary<Buff,int> debuffs, Transform target)
    {
        this.damage = damage;
        this.target = target;
        LifeTime = MaxLifeTime;
    }

    private void Update()
    {
        //>子弹生成时若具有目标则自动索敌攻击
        if(target != null){
            FlyToEne();
        }else{
            Debug.Log("原目标丢失");
        }
        LifeTime -= 0.05f;
        if(LifeTime < 0) PoolMgr.GetInstance().PushObj(this.name,gameObject);     // 超出生命时间自动推回池子
    }

    /// <summary>
    /// 飞向敌人    （好直白的中文
    /// </summary>
    private void FlyToEne()
    {
        //>索敌攻击
        transform.position = Vector3.Lerp(transform.position, target.position, speed * Time.deltaTime * MaxLifeTime);
    }

    /// <summary>
    /// OnTriggerEnter is called when the Collider other enters the trigger.
    /// </summary>
    /// <param name="other">The other Collider involved in this collision.</param>
    void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Enemy")
        {    
            Enemy enemy=other.GetComponent<Enemy>();
            enemy.Hurt(damage);
            PoolMgr.GetInstance().PushObj(this.name,gameObject);
        }

    }
    

}
