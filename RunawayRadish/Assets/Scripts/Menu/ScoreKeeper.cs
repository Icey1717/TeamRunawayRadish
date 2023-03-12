using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ScoreKeeper : MonoBehaviour
{
    private static int attempt = 0;
    public int Attempt
    {
        get
        {
            return attempt;
        }
    }

    private string finishTime;
    public string FinishTime
    {
        get
        {
            return finishTime;
        }
    }

    private string previousFinishTime;
    public string PreviousFinishTime
    {
        get
        {
            return previousFinishTime;
        }
    }

    private static int babiesCollected;

    //scenetracking
    private bool onStartMenu;
    private bool onLevel;
    private bool onScoreScreen;

    public static ScoreKeeper instance;

    Music music;

	public void Awake()
	{
		if (instance == null)
		{
			instance = this;
			DontDestroyOnLoad(this.gameObject);
		}
		
		else
		{
			Destroy(this.gameObject);
		}

        music = GameObject.FindGameObjectWithTag("Music").GetComponent<Music>();
	}

    public void start()
    {
        onStartMenu = true;
        onLevel = false;
        onScoreScreen = false;

        
    }

    public void incrementRound()
    {
        attempt++;
    }

    public void newTime(string time)
    {
        finishTime = time;
    }

    public void incrementBaby()
    {
        babiesCollected++;
    }

    public void switchTime()
    {
        previousFinishTime = finishTime;
    }

    public void leavingStartMenu()
    {
        onStartMenu = false;
        onLevel = true;

        music.inLevel();

        //Debug.Log("Leaving start menu. onstartMenu =" + onStartMenu + " and onLevel =" + onLevel);
    }

    public void leavingLevel()
    {
        onLevel = false;
        onScoreScreen = true;

        music.inMenus();
        music.partyTime();

        //Debug.Log("Attempt #: " + attempt);
        //Debug.Log("Finish time is: " + finishTime);
        //Debug.Log("Babies collected: " + babiesCollected);

        //Debug.Log("Leaving level. onLevel =" + onLevel + " and onScoreScreen =" + onScoreScreen);

    }

    public void restart()
    {
        onScoreScreen = false;
        onStartMenu = true;

        FinishLine.curCollectible = 0;
        FinishLine.completed = false;

        music.inMenus();
        music.stopMusic();

        //Debug.Log("Restarting. onScoreScreen =" + onScoreScreen + " and onStartMenu =" + onStartMenu);

        babiesCollected = 0;

        switchTime();

        SceneManager.LoadScene("MainMenu", LoadSceneMode.Single);
    }




}
