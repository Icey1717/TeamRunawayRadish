using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCollider : MonoBehaviour
{
    /// <summary>
    /// This just links OnTrigger and OnCollider with the PlayerController script
    /// 
    /// --Nathan
    /// </summary>
    /// 

    private PlayerController controller;

    // Start is called before the first frame update
    void Start()
    {
        controller = GetComponentInParent<PlayerController>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void OnCollisionEnter(Collision collision)
    {
       controller.CollisionEnter(collision);
    }
}
