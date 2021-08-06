using System;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 这个东西就是个辅助算法用的，其就像java的Math类
/// </summary>
public class BasicTool 
{
    /// <summary>
    /// 洗牌算法，打乱数组结构
    /// </summary>
    /// <param name="target"></param>
    /// <typeparam name="T"></typeparam>
    public static void Shuffle<T>(T[] target)
    {
        int len=target.Length;
        int max=target.Length-1;
        Random random=new Random();
        for(int i=0;i<len;i++)
        {
            Swap(target,random.Next(0,max),i);
        }
    }

     /// <summary>
    /// 洗牌算法，打乱列表结构
    /// </summary>
    /// <param name="target"></param>
    /// <typeparam name="T"></typeparam>
    public static void Shuffle<T>(List<T> target)
    {
        T[] temp=ToArray(target);
        Shuffle(temp);
        target.Clear();
        foreach (var item in temp)
        {
            target.Add(item);
        }
    }

    /// <summary>
    /// 交换数组中的两个元素
    /// </summary>
    /// <param name="target"></param>
    /// <param name="idxa"></param>
    /// <param name="idxb"></param>
    /// <typeparam name="T"></typeparam>
    public static void Swap<T>(T[] target, int idxa, int idxb)
    {
        T temp=target[idxa];
        target[idxa]=target[idxb];
        target[idxb]=temp;
    }

    /// <summary>
    /// 将一个list转为数组
    /// </summary>
    /// <param name="list"></param>
    /// <typeparam name="T"></typeparam>
    /// <returns></returns>
    public static T[] ToArray<T>(List<T> list)
    {
        int len=list.Count;
        T[] target=new T[len];
        for(int i=0;i<len;i++) target[i]=list[i];
        return target;
    }
}
