using System.Collections;
using UnityEngine.Events;
using UnityEngine;
using System.Collections.Generic;
using System;

/// <summary>
/// 敌方进攻波控制器
/// </summary>
public class WaveController : MonoBehaviour{
    
    //设置波数
    [System.Serializable]
    public class Wave{
        public float rate;              // 敌人生成的间隔，根据移速不同可以适当调整
        public List<GameObject> enemyObj;     // 敌人的预制件列表，如果在一波中需要出现好几个敌人可以自行添加
    }

    [Header("进攻波参数信息")]
    public Wave[] waves;                // 自定义进攻波数
    private int nextWaveCount = 0;      // 下一波倒计时
    public float timeBetweenWaves = 5f; // 波之间的时间间隔
    public float waveCount;             // 波数计数
    private float countingTime = 1;     // 搜索计时
    public SpawnState state = SpawnState.COUNTING;      // 当前状态
    public UnityAction<GameObject> getObjectCallBack;   // 获取预制件的委托
    public static Action messionCompleted;              // 任务完成
    
    void Start(){
        waveCount = timeBetweenWaves;   // 开始计时
    }

    void Update()   {
        if(state == SpawnState.WAITING){
            if(!EnermyIsAlive()){
                WaveCompleted();        // 进攻完成
            }else{
                return;
            }
        }
        if(waveCount <=0){
            if(state != SpawnState.SPAWING){
                StartCoroutine(SpawnWave(waves[nextWaveCount]));    // 开始下一波
            }
        }else{
            waveCount -= Time.deltaTime;           
        }
    }

    /// <summary>
    /// 进攻完成
    /// </summary>
    void WaveCompleted(){
        state = SpawnState.COUNTING;
        waveCount = timeBetweenWaves;
        if(nextWaveCount + 1 > waves.Length - 1){
            messionCompleted?.Invoke();
            GetComponent<WaveController>().enabled = false;            
        }else{
            nextWaveCount++;
        }
    }

    /// <summary>
    /// 判断场内是否还存在敌方物体
    /// </summary>
    bool EnermyIsAlive(){
        countingTime -= Time.deltaTime;
        if(countingTime<=0){
            countingTime = 1f;
            if(GameObject.FindGameObjectWithTag("Enemy") == null){
                return false;
            }
        }
        return true;
    }

    /// <summary>
    /// 波内敌人的生成和生成间隔
    /// </summary>
    IEnumerator SpawnWave(Wave _wave){
        state = SpawnState.SPAWING;
        for(int j = 0; j < _wave.enemyObj.Count;j++){
            SpawnEnermy(_wave.enemyObj[j]);
            yield return new WaitForSeconds(1f/_wave.rate);
        }           
        state = SpawnState.WAITING;
        yield break;
    }

    /// <summary>
    /// 生成敌人
    /// </summary>
    void SpawnEnermy(GameObject _enermy){
        PoolMgr.GetInstance().GetObj("Prefabs/Enemies/Test/"+_enermy.name, getObjectCallBack);       
    }

}

/// <summary>
/// 进攻状态
/// </summary>
public enum SpawnState
{
    SPAWING,WAITING,COUNTING
}