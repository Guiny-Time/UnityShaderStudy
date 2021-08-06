using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class TowerBlock : MonoBehaviour, IPointerDownHandler
{
    [SerializeReference]private string towerName;
     public void OnPointerDown(PointerEventData eventData)
    {
        MouseManager.GetInstance().SelectToPutTower(towerName);

    }
}
