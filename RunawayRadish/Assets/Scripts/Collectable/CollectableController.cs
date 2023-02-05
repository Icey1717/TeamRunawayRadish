using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectableController : MonoBehaviour
{
    public enum States
    {
        Waiting,
        Following,
    }

    GameObject targetObject;
    FollowerTracker tracker;

    Queue<Vector3> TrackedPositions = new Queue<Vector3>();

    // Start is called before the first frame update
    void Start()
    {
        
    }
    
    // Update is called once per frame
    void Update()
    {
        if (targetObject != null)
        {
            if ((targetObject.transform.position - transform.position).magnitude > tracker.minDistance)
            {
                TrackedPositions.Enqueue(targetObject.transform.position);

                if (TrackedPositions.Count > tracker.chainLength)
                {
                    Vector3 targetPosition = TrackedPositions.Dequeue();
                    transform.position = targetPosition;
                }
                else if (TrackedPositions.Count > 0)
                {
                    Vector3 targetPosition = TrackedPositions.Peek();
                    transform.position = Vector3.Lerp(transform.position, targetPosition, (float)TrackedPositions.Count / (float)tracker.chainLength);
                }
            }
        }
    }

    void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.name == "PlayerBody")
        {
            tracker = collision.gameObject.GetComponent<FollowerTracker>();

            Debug.Log("Getting the follower tracker from: " + collision.gameObject.name);

            targetObject = tracker.GetNextFollower(transform.gameObject);

            SphereCollider collider = GetComponent<SphereCollider>();
            collider.enabled = false;
        }
    }
}
