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

	public float bobSpeed = 2.0f;
	public float bobHeight = 0.1f;

	float time;

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
	}
    
    // Update is called once per frame
    void Update()
    {
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

					if ((lastPos - targetPosition).magnitude > 0.001f)
					{
						PlaySoundLooping(followSound);
					}
					else
					{
						StopSoundLooping();
					}

					if ((targetObject.transform.position - targetPosition).magnitude < 0.01f)
					{
						// Idle mode
						//transform.RotateAround(pivot.position, Vector3.up, speed * Time.deltaTime);
					}
                }
                else if (TrackedPositions.Count > 0)
                {
                    Vector3 targetPosition = TrackedPositions.Peek();
                    transform.position = Vector3.Lerp(transform.position, targetPosition, (float)TrackedPositions.Count / (float)tracker.chainLength);
                }
            }
        }

		//time += Time.deltaTime * bobSpeed;
		//float yOffset = Mathf.Sin(time) * bobHeight;
		//transform.position += new Vector3(0.0f, yOffset, 0.0f);
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
            PlayerController.followers.Add(this);
        }
    }
}
