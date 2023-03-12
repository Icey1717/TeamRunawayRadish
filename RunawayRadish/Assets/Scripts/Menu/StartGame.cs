using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StartGame : MonoBehaviour
{
  
  private ScoreKeeper score;

  // Start is called before the first frame update
  void Start()
  {
    score = GameObject.FindGameObjectWithTag("ScoreKeeper").GetComponent<ScoreKeeper>();
  }

    // Update is called once per frame
  void Update()
  {
		if (Input.anyKey)
		{
      score.leavingStartMenu();

			SceneManager.LoadScene("YuutaScene", LoadSceneMode.Single);
		}
	}
}
