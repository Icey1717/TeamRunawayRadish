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

    [SerializeField]
    private AudioClip[] endCelebration;

    private AudioSource audioSource;

    private int i;

    private IEnumerator musicTracks;

    // Start is called before the first frame update
    public void Start()
    {
        audioSource = GetComponent<AudioSource>();

        musicTracks = playAudioSequentially();

        startMusic();
    }

    public void Update()
    {
        if (!audioSource.isPlaying)
        {
            startMusic();
        }
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

    public void startMusic()
    {
        Debug.Log("Starting music");

        audioSource.Stop();

        StartCoroutine(musicTracks);
    }

    public void partyTime()
    {
        Debug.Log("Party time");
        StopCoroutine(musicTracks);
        
        audioSource.clip = endCelebration[0];

        audioSource.Play();
    }

    public void inLevel()
    {
        Debug.Log("Turning down");
        audioSource.volume = 0.214f;
    }

    public void inMenus()
    {
        Debug.Log("Turning up");
        audioSource.volume = 0.5f;
    }

    public void stopMusic()
    {
        audioSource.Stop();
    }
}
