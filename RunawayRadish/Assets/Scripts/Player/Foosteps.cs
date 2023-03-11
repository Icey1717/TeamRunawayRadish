using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Foosteps : MonoBehaviour
{
    [SerializeField]    
    private AudioClip[] clips;

    [SerializeField]
    private AudioClip[] dirtClipsLeft;

    [SerializeField]
    private AudioClip[] dirtClipsRight;

    [SerializeField]
    private AudioClip[] rockClipsLeft;

    [SerializeField]
    private AudioClip[] rockClipsRight;

    [SerializeField]
    private AudioClip[] woodClipsLeft;

    [SerializeField]
    private AudioClip[] woodClipsRight;

    private AudioSource audioSource;

    private string surface;


    // Start is called before the first frame update
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        GetComponent<BoxCollider>();
    }

    private void OnTriggerEnter(Collider floor)
    {
        if (floor.tag == "Dirt")
        {
            surface = floor.tag;
        }

        if (floor.tag == "Brick")
        {
            surface = floor.tag;
        }

        if (floor.tag == "Wood")
        {
            surface = floor.tag;
        }
        
    }

    private void LStep()
    {
        AudioClip lClip = getLClip();

        audioSource.PlayOneShot(lClip);

        Debug.Log("walking on " + surface);
    }

    private void RStep()
    {
        AudioClip rClip = getRClip();

        audioSource.PlayOneShot(rClip);

        Debug.Log("walking on " + surface);
    }

    private AudioClip getLClip()
    {
 
        if (surface == "Dirt")
        {
            return dirtClipsLeft[UnityEngine.Random.Range(0, dirtClipsLeft.Length)];
        }

        if (surface == "Brick")
        {
            return rockClipsLeft[UnityEngine.Random.Range(0, rockClipsLeft.Length)];
        }

        if (surface == "Wood")
        {
            return woodClipsLeft[UnityEngine.Random.Range(0, woodClipsLeft.Length)];
        }

        else
        {
            return clips[0];
        }
        Debug.Log("path 5 :o!");
        return clips[0];

    }


    private AudioClip getRClip()
    {
        if (surface == "Dirt")
        {
            return dirtClipsRight[UnityEngine.Random.Range(0, dirtClipsRight.Length)];
        }

        if (surface == "Brick")
        {
            return rockClipsRight[UnityEngine.Random.Range(0, rockClipsRight.Length)];
        }

        if (surface == "Wood")
        {
            return woodClipsRight[UnityEngine.Random.Range(0, woodClipsRight.Length)];
        }

        else
        {
            return clips[1];
        }

        Debug.Log("path 5 :o!");
        return clips[1];
    }

}
