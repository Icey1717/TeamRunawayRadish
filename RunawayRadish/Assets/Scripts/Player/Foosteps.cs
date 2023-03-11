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
    private TerrainDetector terrainDetector;


    // Start is called before the first frame update
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        terrainDetector = new TerrainDetector();
    }

    private void LStep()
    {
        audioSource.PlayOneShot(clips[0]);
    }

    private void RStep()
    {
        audioSource.PlayOneShot(clips[1]);
    }

}
