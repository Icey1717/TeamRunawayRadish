using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectableController : MonoBehaviour
{
    public enum States
    {
        Waiting,
        Following,
    }

    [HideInInspector]
    public GameObject targetObject;
    FollowerTracker tracker;
	private AudioSource audioSource;

	Queue<Vector3> TrackedPositions = new Queue<Vector3>();

	[SerializeField]
	public List<AudioClip> collectSounds;

	[SerializeField]
	public AudioClip followSound;

	[SerializeField]
	public List<AudioClip> proximitySounds;

	[SerializeField]
	private GameObject scoreKeeper;
	private ScoreKeeper score;

	public float bobSpeed = 2.0f;
	public float bobHeight = 0.1f;

	float time;

	public float minCryTime = 5f;
	public float maxCryTime = 10f;

	private float timer;

	void PlaySoundInList(List<AudioClip> list)
	{
		audioSource.clip = list[Random.Range(0, list.Count - 1)];
		audioSource.Play();
	}

	void PlaySoundLooping(AudioClip clip)
	{
		if (audioSource.loop != true)
		{
			audioSource.clip = clip;
			audioSource.loop = true;
			audioSource.Play();
		}
	}

	public void StopSoundLooping()
	{
		audioSource.loop = false;
		audioSource.Stop();
	}

	// Start is called before the first frame update
	void Start()
    {
		audioSource = GetComponent<AudioSource>();
		score = scoreKeeper.GetComponent<ScoreKeeper>();
		timer = Random.Range(minCryTime, maxCryTime);
	}
    
    // Update is called once per frame
    void Update()
    {
		time += Time.deltaTime * bobSpeed;

		if (targetObject != null)
        {
            if ((targetObject.transform.position - transform.position).magnitude > tracker.minDistance)
            {
                TrackedPositions.Enqueue(targetObject.transform.position);

                if (TrackedPositions.Count > tracker.chainLength)
                {
					Vector3 lastPos = transform.position;

					Vector3 targetPosition = TrackedPositions.Dequeue();
                    transform.position = targetPosition;

					//if ((lastPos - targetPosition).magnitude > 0.0f)
					//{
					//	PlaySoundLooping(followSound);
					//}
					//else
					//{
					//	StopSoundLooping();
					//}

					if ((targetObject.transform.position - targetPosition).magnitude < 0.01f)
					{
						// Idle mode
						//transform.RotateAround(pivot.position, Vector3.up, speed * Time.deltaTime);
					}

					float yOffset = Mathf.Sin(time) * bobHeight;
					transform.position += new Vector3(0.0f, yOffset, 0.0f);
				}
				else if (TrackedPositions.Count > 0)
                {
                    Vector3 targetPosition = TrackedPositions.Peek();
                    transform.position = Vector3.Lerp(transform.position, targetPosition, (float)TrackedPositions.Count / (float)tracker.chainLength);
                }
            }
        }
		else
		{
			timer -= Time.deltaTime;
			if (timer <= 0f)
			{
				PlaySoundInList(proximitySounds);

				// Reset the timer
				timer = Random.Range(minCryTime, maxCryTime);
			}

			float yOffset = Mathf.Sin(time) * bobHeight * 0.01f;
			transform.position += new Vector3(0.0f, yOffset, 0.0f);
		}
	}

    void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.name == "PlayerBody")
        {
            tracker = collision.gameObject.GetComponent<FollowerTracker>();

            Debug.Log("Getting the follower tracker from: " + collision.gameObject.name);

			PlaySoundInList(collectSounds);

            targetObject = tracker.GetNextFollower(transform.gameObject);

            SphereCollider collider = GetComponent<SphereCollider>();
            collider.enabled = false;
			
			PlayerController.followerAmount++;
            FinishLine.curCollectible++;
			score.incrementBaby();
            PlayerController.followers.Add(this);

			PlaySoundLooping(followSound);
			audioSource.volume = 0.2f;
        }
    }
}
