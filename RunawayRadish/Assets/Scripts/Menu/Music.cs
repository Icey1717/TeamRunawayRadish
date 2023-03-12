using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Music : MonoBehaviour
{
    public static Music instance;

	private void Awake()
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
	}
    
    [SerializeField]
    private AudioClip[] music;

    private AudioSource audioSource;

    private int i;

    // Start is called before the first frame update
    private void Start()
    {
        audioSource = GetComponent<AudioSource>();

        StartCoroutine(playAudioSequentially());
    }

    IEnumerator playAudioSequentially()
    {

        for (i = 0; i < music.Length; i++)
        {
            audioSource.clip = music[i];

            audioSource.Play();

            while (audioSource.isPlaying)
            {
                yield return null;
            }
        }

        if (i == music.Length)
        {
            i = 0;
        }
    }
}
