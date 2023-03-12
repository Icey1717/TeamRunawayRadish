using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoreKeeper : EnvSound
{

    private static int attempt = 0;

    private string finishTime;

    private string blankFirstTime;
    private string previousFinishTime;

    private int babiesCollected;
    private int maxBabies;

    FinishLine finishLine;

    void awake()
    {
        finishLine = GameObject.Find("FinishLine").GetComponent<FinishLine>();
    }

    // Update is called once per frame
    void Update()
    {
        if (FinishLine.completed == true)
        {
            finishTime = FinishLine.temp;

            babiesCollected = FinishLine.curCollectible;

            maxBabies = finishLine.tarCollectible;
        }
    }

    public static void incrementRound()
    {
        attempt++;
    }

    public void switchTime()
    {
        previousFinishTime = finishTime;
    }
}
