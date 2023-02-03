using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TriggerEvent : MonoBehaviour
{
    /// <summary>
    /// This handles running UnityEvents based on tagged objects entering a trigger
    /// 
    /// -- Nathan
    /// </summary>
    public string targetTag = "Player";
    public CollisionTypes collisionType;
    public enum CollisionTypes { onEnter,onStay, onExit};

    public UnityEvent triggerEvent;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (collisionType == CollisionTypes.onEnter)
        {
            if (other.tag == targetTag)
                triggerEvent.Invoke();
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (collisionType == CollisionTypes.onStay)
        {
            if (other.tag == targetTag)
                triggerEvent.Invoke();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (collisionType == CollisionTypes.onExit)
        {
            if (other.tag == targetTag)
                triggerEvent.Invoke();
        }
    }
}
