using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class FinishLine : MonoBehaviour
{
    [Tooltip ("Use 0 to disable timer")]
    public float timeLimit = 0;
    [Tooltip ("Use 0 to disable collect needed")]
    public int tarCollectible = 0;

    [HideInInspector]
    public static int curCollectible = 0;
    
    public bool takeCollectibles = true;
    public bool showCollectibleText = true;

    private ScoreKeeper score;

    public UnityEvent finishEvent;
    public UnityEvent timeOutEvent;

    [HideInInspector]
    public float timer;

	public TextMeshProUGUI timerText;
	public TextMeshProUGUI collectedText;


	public finishTypeEnum finishType = finishTypeEnum.collectX;
    public enum finishTypeEnum { collectX, reachHere};

	public static bool completed = false;

    public static string temp;
 

    // Start is called before the first frame update
    void Start()
    {
        score = GameObject.FindGameObjectWithTag("ScoreKeeper").GetComponent<ScoreKeeper>();
        //score = scoreKeeper.GetComponent<ScoreKeeper>();

		if (!showCollectibleText)
        {
            collectedText.gameObject.SetActive(false);
        }
        else
        {
            if (tarCollectible > 0)
            {
                collectedText.text = "0/" + tarCollectible.ToString() + "";
            }

            else
            {
                collectedText.text = "0";
            }
		}
    }

    // Update is called once per frame
    void Update()
    {

        //Debug.Log("FinishLine is completed = " + completed);
		if (!completed)
        {
			timer += Time.deltaTime;
        }
        
		if (timeLimit > 0)
        {
            timerText.text = getTime(true);
        }

        else
        {
            timerText.text = getTime(false);
        }

        //Debug.Log("tarCollectible is: " + tarCollectible);

		//curCollectible = PlayerController.FollowerAmount; collectible controller now increments this
		if (tarCollectible > 0)
        {
			collectedText.text = curCollectible + "/" + tarCollectible.ToString() + " Collected";
        }

		else
        {
			collectedText.text = curCollectible + " Collected";
        }

		if (curCollectible >= tarCollectible)
        {
            //Debug.Log("I've reached this point");
			completed = true;

            score.incrementRound();

            score.newTime(temp);

            score.leavingLevel();
            

            SceneManager.LoadScene("ScoreScreen", LoadSceneMode.Single);

            
        }
	}

   
    string getTime(bool countdown)
    {
        temp = "";
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
			temp += seconds.ToString();

            return temp;
        }
    }
}
