using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    /// <summary>
    /// This Connects the Camera to the Player and handles feedback such as camera shake & delay
    /// 
    /// -- Nathan
    /// </summary>
    public Transform camHolder;
    public Transform camHook;
    public float speed = 2;
    public float deadZone = 0.8f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Vector3 tarPosition = Vector3.MoveTowards(camHook.position, camHolder.position, deadZone);
            camHolder.position = Vector3.Lerp(camHolder.position, tarPosition, speed);
    }
}
