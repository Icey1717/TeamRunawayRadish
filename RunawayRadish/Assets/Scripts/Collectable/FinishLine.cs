using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;

public class FinishLine : MonoBehaviour
{
    [Tooltip ("Use 0 to disable timer")]
    public float timeLimit = 0;
    [Tooltip ("Use 0 to disable collect needed")]
    public int tarCollectible = 0;

    [HideInInspector]
    public int curCollectible = 0;
    
    public bool takeCollectibles = true;
    public bool showCollectibleText = true;

    public UnityEvent finishEvent;
    public UnityEvent timeOutEvent;

    [HideInInspector]
    public float timer;

    public TextMeshPro timerText;
    public TextMeshPro collectedText;


    public finishTypeEnum finishType = finishTypeEnum.collectX;
    public enum finishTypeEnum { collectX, reachHere};
    // Start is called before the first frame update
    void Start()
    {
        if (!showCollectibleText)
            collectedText.gameObject.SetActive(false);
        else
        {
            if (tarCollectible > 0)
                collectedText.text = "0/" + tarCollectible.ToString() + " Collected";
            else
                collectedText.text = "0 Collected";
        }
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        if (timeLimit > 0)
            timerText.text = getTime(true);
        else
            timerText.text = getTime(false);

        if (!takeCollectibles)
        {
            curCollectible = PlayerController.followerAmount;
            if (tarCollectible > 0)
                collectedText.text = curCollectible + "/" + tarCollectible.ToString() + " Collected";
            else
                collectedText.text = curCollectible + " Collected";
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            if (finishType == finishTypeEnum.reachHere)
            {
                if (curCollectible >= tarCollectible)
                    finishEvent.Invoke();
            }
            else
            {
                if (takeCollectibles)
                {
                    other.GetComponent<FollowerTracker>().ResetChain();
                    curCollectible += PlayerController.followerAmount;
                    PlayerController.followerAmount = 0;

                    PlayerController.followers[0].targetObject = gameObject;
                    PlayerController.followers = new List<CollectableController>();
                    string text = "";
                    if (tarCollectible > 0)
                    {
                        text = curCollectible.ToString() + "/" + tarCollectible.ToString() + " Collected";
                    }
                    else
                        text = curCollectible.ToString() + " Collected";
                    collectedText.text = text;

                    if (curCollectible >= tarCollectible)
                        finishEvent.Invoke();
                }
            }
        }
    }

    string getTime(bool countdown)
    {
        string temp = "";
        float time = timer * 100;
        if (countdown)
        {
            time = timeLimit - timer * 100;
        }
        if (time < 0)
        {
            timeOutEvent.Invoke();
            return "00:00:00";
        }
        else
        {
            float minutes = Mathf.Floor(time / 3600);
            float seconds = Mathf.Floor((time - (minutes * 3600)) / 60);
            float milliseconds = Mathf.Floor(time - (minutes * 3600) - (seconds * 60));

            if (minutes < 10)
                temp += "0";
            temp += minutes.ToString() + ":";
            if (seconds < 10)
                temp += "0";
            temp += seconds.ToString() + ":";
            if (milliseconds < 10)
                temp += "0";
            temp += milliseconds.ToString();

            return temp;
        }
    }
}
