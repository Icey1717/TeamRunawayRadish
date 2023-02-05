using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HideOnTrigger : MonoBehaviour
{

    public float reappearTime = 1;
    public float reappearTimerIncreaseWithFollower = 0.1f;
    private float _reappearTimer = 0;

    public MeshRenderer mr;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (_reappearTimer <= 0)
            mr.enabled = true;
        else
            _reappearTimer -= Time.deltaTime;
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.tag == "Player")
        {
            _reappearTimer = reappearTime + (reappearTimerIncreaseWithFollower * PlayerController.followerAmount);
            mr.enabled = false;
        }
    }
}
