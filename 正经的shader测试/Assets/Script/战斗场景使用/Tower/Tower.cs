using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum TOWERTYPE:int
{
    激光=1,
    箭塔=2 
}
public class Tower : MonoBehaviour
{
    //基础属性
    public float attackInterval ;                   // 攻击间隔
    public float attackArea;                  //测试时在编译器窗口设置的值
    [SerializeField]private int blood ;             // 血量
    [SerializeField]private int cost ;              // 部署花费
    private string towerName ;                      // 塔名
    private int cardNum ;                           // 牌名
    private Dictionary<TowerCard,int> cardDic;
    private Dictionary<Buff,int> debuffToEne;
    private UnityAction<GameObject> callBack;       //对象池使用以
    [SerializeField]protected TOWERTYPE AttackType; // 攻击类型
    [SerializeField]private bool towerWorking = true  ; //防御塔是否处于激活状态
    //索敌相关
    public Collider[] AllColliders ;
    private GameObject[] EneObject ;
    //攻击相关
    public bool canAttack = true ; //防御塔是否能攻击
    public float LastUseTime = 0 ; //最后一次攻击时间
    private GameObject target ; 
    public int towerDamage ; 


    void Start()
    {
      if(AttackType==TOWERTYPE.箭塔)  callBack += MakeBullet;

    }

    private void Update()
    {
       FindEnemy();
       ChoseTarget();
        
        if(Time.time >= LastUseTime + attackInterval  && canAttack == true){
            //
            if(target)
            {
                Attack();
                Debug.Log(name + "攻击目标为   " +target);
            }            
        } 
       
    }

    //方法
    private void Attack(){
        LastUseTime = Time.time;

        //根据防御塔模式选择攻击方式
        switch (AttackType)
        {
            case TOWERTYPE.激光: 
                target.GetComponent<Enemy>().Hurt(towerDamage);
            break ; 
            
            case TOWERTYPE.箭塔:
                Debug.Log("射击");
                PoolMgr.GetInstance().GetObj("Prefabs/Bullet/TempBullet",callBack);     // 对象池中取出子弹
            break ; 

            default: 
            break ;
        }
    }

    public void Hurt(int damage){
        this.blood -= damage ;
    }

    /// <summary>
    /// 卡牌使用添加属性
    /// </summary>
    public void ChangeAttribute(float attackInterval,int attackArea, int blood)
    {
        this.attackArea+=attackArea;
        this.attackInterval-=attackInterval;
        if(attackInterval<0) attackInterval=0.1f;
        blood+=blood;
    }

    /// <summary>
    /// 这个是见到buff的话根据buff不同内容添加
    /// </summary>
    /// <param name="newBuff"></param>
    public void AddBuff(Buff newBuff, int layer)
    {
        
    }

    private void AddCardFunction(TowerCard card)
    {
        card.UsedCard(this);
    }

    /// <summary>
    /// 索敌，填充范围内所有敌方数组
    /// </summary>
    private void FindEnemy(){
        AllColliders = Physics.OverlapSphere(transform.position, attackArea, LayerMask.GetMask("Enemy"));
        //从中挑选Enemy并重新组成数组
        EneObject = new GameObject [AllColliders.Length];
        for (int i = 0; i < AllColliders.Length; i++)
        {
            if (AllColliders[i] .gameObject.tag == "Enemy")
            {
                EneObject[i] = AllColliders[i].gameObject ;
            }
        }
        //得到一个敌人的数组
    }

    /// <summary>
    /// 选择被攻击的敌人
    /// </summary>
    private void ChoseTarget(){
        try{
            if(EneObject[0] != null) target = EneObject[0];
        }catch(IndexOutOfRangeException){
            target = null;
        }      
    }
 
    private void MakeBullet(GameObject bullet)
    {
        bullet.transform.position = new Vector3(transform.position.x,transform.position.y,-1);
        bullet.GetComponent<Bullet>().SetBulletAttribute(towerDamage, debuffToEne, target.transform);
    }

    public TOWERTYPE GetTOWERTYPE()
    {
        return AttackType;
    } 
}
