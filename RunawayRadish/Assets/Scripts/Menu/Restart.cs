using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Restart : MonoBehaviour
{
    private ScoreKeeper score;
    
    // Start is called before the first frame update
    void Start()
    {
        score = GameObject.FindGameObjectWithTag("ScoreKeeper").GetComponent<ScoreKeeper>();
    }

    float time = 5f;

    // Update is called once per frame
    void Update()
    {
        if (time > 0f)
        {
            time -= Time.deltaTime;
        }

		if (Input.anyKey && time  <= 0f)
		{
            score.restart();
			SceneManager.LoadScene("MainMenu", LoadSceneMode.Single);
		}
	}

    IEnumerator wait()
    {
        yield return new WaitForSeconds(5);
    }
}
