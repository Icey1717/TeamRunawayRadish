using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowerTracker : MonoBehaviour
{
    GameObject nextFollower;

    public int chainLength = 50;
    public float minDistance = 0.0f;

    // Start is called before the first frame update
    void Start()
    {
        nextFollower = transform.gameObject;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public GameObject GetNextFollower(GameObject requestee) 
    {
        GameObject returnValue = nextFollower;
        nextFollower = requestee;
        return returnValue;
    }
}
