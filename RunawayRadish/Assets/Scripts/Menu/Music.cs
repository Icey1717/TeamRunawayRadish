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

    //private IEnumerator musicTracks;

    private int i;

    private bool party = false;

    // Start is called before the first frame update
    public void Start()
    {
        audioSource = GetComponent<AudioSource>();

        //musicTracks = playAudioSequentially();

        startMusic();
    }

    public void Update()
    {
        if (!audioSource.isPlaying)
        {
            StartCoroutine("Wait");
        }
    }

    private IEnumerator PlayAudioSequentially()
    {
        Debug.Log("Coroutine started" + i);


        for (i = 0; i < music.Length; i++)
        {
            audioSource.clip = music[i];
            Debug.Log("playing clip " + i);

            audioSource.Play();

            while (audioSource.isPlaying)
            {
                if (party)
                {
                    Debug.Log("coroutine broken");
                    yield break;
                }

                yield return null;
            }
        }
        
        if (i >= music.Length)
        {
            i = 0;
        }

        
    }

    public void startMusic()
    {
        Debug.Log("Starting music" + i);

        if (i >= music.Length)
        {
            i = 0;

            StartCoroutine("PlayAudioSequentially");
        }

        else
        {
            StartCoroutine("PlayAudioSequentially");
        }
    }

    public void partyTime()
    {
        Debug.Log("Party time");

        StopCoroutine("PlayAudioSequentially");

        i++;

        party = true;
        
        audioSource.clip = endCelebration[0];

        audioSource.Play();
    }

    public void inLevel()
    {
        Debug.Log("Turning down");
        audioSource.volume = 0.195f;
    }

    public void inMenus()
    {
        Debug.Log("Turning up");
        audioSource.volume = 0.5f;
    }

    public void restartMusic()
    {
        Debug.Log("Restarting music");
        audioSource.Stop();

        party = false;

        startMusic();
    }

    private IEnumerator Wait()
    {
        Debug.Log("waiting");
        yield return new WaitForSeconds(15);

        if(!audioSource.isPlaying)
        {
            startMusic();
        }
    }
}
