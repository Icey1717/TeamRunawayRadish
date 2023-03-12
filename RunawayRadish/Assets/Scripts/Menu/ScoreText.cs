using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ScoreText : MonoBehaviour
{

    [SerializeField]
    private GameObject attemptNumber;

    [SerializeField]
    private GameObject finishTime;

    [SerializeField]
    private GameObject previousFinishTime;

    private ScoreKeeper score;

    private int attemptNumberScore;
    private string finishtimeScore;
    private string previousFinishTimeScore;

    private TextMeshProUGUI attemptNumberText;
    private TextMeshProUGUI finishTimeText;
    private TextMeshProUGUI previousFinishTimeText;



    // Start is called before the first frame update
    void Start()
    {
        score = GameObject.FindGameObjectWithTag("ScoreKeeper").GetComponent<ScoreKeeper>();

        attemptNumberText = attemptNumber.GetComponent<TextMeshProUGUI>();
        finishTimeText = finishTime.GetComponent<TextMeshProUGUI>();
        previousFinishTimeText = previousFinishTime.GetComponent<TextMeshProUGUI>();

        attemptNumberScore = score.Attempt;
        finishtimeScore = score.FinishTime;
        previousFinishTimeScore = score.PreviousFinishTime;

        attemptNumberText.text = "Attempt #: " + attemptNumberScore.ToString();
        finishTimeText.text = "Finish time: " +  finishtimeScore;
        
        if (previousFinishTimeScore == null)
        {
            previousFinishTime.SetActive(false);
        }
        else
        {
            previousFinishTime.SetActive(true);
            previousFinishTimeText.text = "Last finish time: " + previousFinishTimeScore;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }


}
