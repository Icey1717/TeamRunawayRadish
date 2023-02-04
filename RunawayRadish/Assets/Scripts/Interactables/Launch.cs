using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static TriggerEvent;
using static UnityEngine.EventSystems.EventTrigger;

public class Launch : MonoBehaviour
{
    /// <summary>
    /// This launches the player by the given launchForce and disables their movement interaction for x amount of time
    /// 
    /// --Nathan
    /// </summary>
    public Vector3 launchForce;
    public float disableMovementLength = 0.3f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.tag == "Player")
        {
            other.GetComponentInParent<PlayerController>().Launch(launchForce,disableMovementLength);
        }
    }
}
