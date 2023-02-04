using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEditor;

public class MovingPlatform : MonoBehaviour
{
    public Vector3 moveToPositionLocal = new Vector3(0,1,0);
    public float speed = 1.0f;

    Vector3 moveToPositionAbsolute;
    Vector3 moveToOriginAbsolute;
    bool towards;
    
    void Awake()
    {
        moveToOriginAbsolute = transform.position;
        moveToPositionAbsolute = transform.position + moveToPositionLocal;
    }

    void FixedUpdate()
    {
        var target = (towards)? moveToPositionAbsolute : moveToOriginAbsolute;
        var targetDirection = target - transform.position;
        if(targetDirection.magnitude < speed * Time.fixedDeltaTime)
        {
            towards = !towards;
            transform.position += targetDirection;
        }
        else
        {
            transform.position += targetDirection.normalized * speed * Time.fixedDeltaTime;
        }
    }
}
