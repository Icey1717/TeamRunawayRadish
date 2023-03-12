using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    /// <summary>
    /// This is intended to handle:
    /// + all basic player interaction
    /// + movement synergy
    /// + keeping the player on track
    /// 
    /// -- Nathan
    /// </summary>
    public bool programmerAnimation;
    public Animator animator;
    public MovementVar movement;
	private AudioSource audioSource;

    public static int followerAmount = 0;

    public static List<CollectableController> followers = new List<CollectableController>();

	[System.Serializable]
    public class MovementVar
    {
        public float moveSpeed;
        public float maxSpeed;
        [HideInInspector]
        public float disabledMovementTimer = 0;
        [Tooltip("How Long Before The Player Can Be Launched By Other Objects Again")]
        public float launchDelay = 0.25f;
        [HideInInspector]
        public float launchDelayTimer = 0;
		[SerializeField]
		public List<AudioClip> launchSounds;
	}

    public TunnelVar tunnel;
    [System.Serializable]
    public class TunnelVar
    {
        [HideInInspector]
        public Vector3 tunnelMoveDir;
        public float launchForce;
        public float tunnelSpeed;
        public float turnSpeed;
        [HideInInspector]
        public bool inTunnel = false;
		[SerializeField]
		public AudioClip digSound;
	}
    public SwingVar swing;
    [System.Serializable]
    public class SwingVar
    {
        [HideInInspector]
        public Transform swingPivot;
        public float swingSpeed = 5;
        public float launchForce = 7;
        [HideInInspector]
        public int swingDir = 0;
        [HideInInspector]
        public bool swinging = false;
        [HideInInspector]
        public float swingDist;
        public float minSwingDist = 1;

        public AnimationCurve velocityOppositionAfterSwing;
        [System.NonSerialized]
        public float lastSwingTime = -100.0f;

        public LineRenderer LR;

		[SerializeField]
		public List<AudioClip> swingSounds;

		[SerializeField]
		public List<AudioClip> releaseSounds;
	}
    public JumpVar jump;
    [System.Serializable]
    public class JumpVar
    {
        public bool onlyJumpOnGround = true;
        public float basePower = 7f;
        public float holdPower = 2f;
        public float holdIgnore = 0.05f;
        public float holdMax = 0.3f;
        [HideInInspector]
        public float holdTimer = 0;
        [HideInInspector]
        public int jumpsRemaining = 0;
        public int maxJumps = 1;
        [HideInInspector]
        public bool canHold = false;
        public float jumpDelay = 0.2f;
        [HideInInspector]
        public float jumpDelayTimer = 0;
		[SerializeField]
		public List<AudioClip> jumpSounds;

	}

    public DashVar dash;
    [System.Serializable]
    public class DashVar
    {
        public directionEnum direction = directionEnum.omnidirectional;
        public dashEnum dashOnGround = dashEnum.sprint;
        public float dashPower = 5f;
        public float sprintMultiplier = 1.5f;
        [HideInInspector]
        public bool sprintActive = false;
        [HideInInspector]
        public int dashesRemaining = 0;
        public int maxDashes = 2;

        public float dashDelay = 0.7f;
        [HideInInspector]
        public float dashDelayTimer = 0;
        public Transform dashCounterHolder;

        public Color dashColor = Color.cyan;
        public float bounceMultiplier = 2;

		public List<AudioClip> dashSounds;
	}

    public enum directionEnum {horizontal,vertical,omnidirectional };
    public enum dashEnum { dashOnGround, sprint};

    public PhysicsVar physics;
    [System.Serializable]
    public class PhysicsVar
    {
        [HideInInspector]
        public bool onGround = false;
        public float radius = 0.5f;
        public float groundDetectionDist = 0.55f;
        public LayerMask groundLayers;
        public float zLevelChangeRate = 3;
        [HideInInspector]
        public Vector3[] prevVelocity = new Vector3[2];
		[SerializeField]
		public List<AudioClip> landSounds;

        [HideInInspector]
        public Vector3 lastGroundedPos;
    }

    public Rigidbody rb;
    public MeshRenderer mr;
    public Transform artContainer;

    private float curZLevel = 0;
    public float tarZLevel = 0;

	public class AnimationHashes
	{
        public int land;
        public int jump;
        
        public void Init()
		{
            jump = Animator.StringToHash("Jump");
            land = Animator.StringToHash("Land");
        }
	}
    AnimationHashes animHashes = new AnimationHashes();

    void PlaySoundInList(List<AudioClip> list)
	{
		audioSource.clip = list[Random.Range(0, list.Count - 1)];
		audioSource.Play();
	}

	void PlaySoundLooping(AudioClip clip)
	{
		audioSource.clip = clip;
		audioSource.loop = true;
		audioSource.Play();
	}

	void StopSoundLooping()
	{
		audioSource.loop = false;
		audioSource.Stop();
	}

	void Start()
    {
        tarZLevel = rb.transform.position.z;
        curZLevel = rb.transform.position.z;

        animHashes.Init();

        if (!programmerAnimation)
            animator.enabled = false;

		audioSource = GetComponent<AudioSource>();
	}

    private void Update()
    {
        GroundDetection();

        //UnityEngine.Debug.Log("Current collectible is: " + FinishLine.curCollectible);

        //UnityEngine.Debug.Log("followerAmount value is: " + followerAmount);

        //UnityEngine.Debug.Log("Completed is: " + FinishLine.completed);

        PlayerInput();

       
    }

    private void FixedUpdate()
    {
        ZTrackUpdate();

        physics.prevVelocity[1] = physics.prevVelocity[0];
        physics.prevVelocity[0] = rb.velocity;
    }


    //Input
    void PlayerInput()
    {
        //2D Movement
        Vector2 inputDir = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        if (!tunnel.inTunnel)
        {
            if (movement.disabledMovementTimer <= 0)
            {
                if (!swing.swinging)
                {
                    if (dash.dashDelayTimer <= 0)
                        Movement(inputDir);

                    DashController(inputDir);

                    JumpController();
                }

                    SwingController();
            }
            else
            {
                movement.disabledMovementTimer -= Time.deltaTime;
                swing.swinging = false;
                swing.LR.enabled = false;
                rb.useGravity = true;
            }
            if (movement.launchDelayTimer > 0)
                movement.launchDelayTimer -= Time.deltaTime;
        }
        else
            TunnelMovement(inputDir);
    }

    //Movement
    void Movement(Vector2 inputDir)
    {
        Vector3 moveDirV3 = new Vector3(inputDir.x * movement.moveSpeed, 0, 0);

        float tempMaxSpeed = movement.maxSpeed;
        if (dash.sprintActive)
        {
            moveDirV3 *= dash.sprintMultiplier;
            tempMaxSpeed *= dash.sprintMultiplier;
        }

        float velocityOpposition = swing.velocityOppositionAfterSwing.Evaluate(Time.fixedTime - swing.lastSwingTime);
        moveDirV3.x -= rb.velocity.x * velocityOpposition;

        animator.SetFloat("Movement", Mathf.Abs(inputDir.x) < 0.01f ? 0.0f : 1.0f);

        rb.AddForce(moveDirV3);

        Vector3 velocity = new Vector3(Mathf.Clamp(rb.velocity.x, -tempMaxSpeed, tempMaxSpeed), rb.velocity.y, rb.velocity.z);
        rb.velocity = velocity;

        if (inputDir.x > 0.1f)
        {
            artContainer.localRotation = Quaternion.Slerp(artContainer.localRotation, Quaternion.LookRotation(Vector3.right), 1 - Mathf.Pow(0.1f, Time.deltaTime));
        }
        else if (inputDir.x < -0.1f)
        {
            artContainer.localRotation = Quaternion.Slerp(artContainer.localRotation, Quaternion.LookRotation(Vector3.left), 1 - Mathf.Pow(0.1f, Time.deltaTime));
        }
        else
        {
            artContainer.localRotation = Quaternion.Slerp(artContainer.localRotation, Quaternion.LookRotation(Vector3.back), 1 - Mathf.Pow(0.1f, Time.deltaTime));
        }
    }

    void TunnelMovement(Vector2 inputDir)
    {
        dash.dashesRemaining = dash.maxDashes;
        if (inputDir.magnitude > 0.1f)
            tunnel.tunnelMoveDir = Vector3.Normalize(new Vector3(Mathf.Lerp(tunnel.tunnelMoveDir.x,inputDir.x,Time.deltaTime * tunnel.turnSpeed), Mathf.Lerp(tunnel.tunnelMoveDir.y, inputDir.y, Time.deltaTime * tunnel.turnSpeed), 0));
        rb.AddForce(tunnel.tunnelMoveDir * tunnel.tunnelSpeed * 10);
        rb.velocity = Vector3.ClampMagnitude(rb.velocity,tunnel.tunnelSpeed);
    }

    //Jumping
    void JumpController()
    {
        if (jump.jumpDelayTimer > 0)
        {
            jump.jumpDelayTimer -= Time.deltaTime;
        }
        else
        {
            if (physics.onGround)
            {
                jump.jumpsRemaining = jump.maxJumps;
                
            }
            bool canJump = true;
            if (jump.onlyJumpOnGround && !physics.onGround)
                canJump = false;
            if (Input.GetButtonDown("Jump") && canJump)
                JumpPress();
        }
        
        if (Input.GetButton("Jump"))
            JumpCharge();
        if (Input.GetButtonUp("Jump"))
            JumpRelease();
    }
    void JumpPress()
    {
        if (jump.jumpsRemaining > 0)
        {
            //Big Jump
            rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.z);
            rb.AddForce(jump.basePower * rb.transform.up, ForceMode.Impulse);

            //Jump Limiters
            jump.jumpDelayTimer = jump.jumpDelay;
            jump.holdTimer = jump.holdMax;
            jump.canHold = true;
            jump.jumpsRemaining--;

			PlaySoundInList(jump.jumpSounds);

			//Visual Cues
			if (programmerAnimation)
			{
                animator.SetTrigger(animHashes.jump);
                animator.ResetTrigger(animHashes.land);
            }
                
        }
    }
    void JumpCharge()
    {
        //This is for making jumps bigger
        if (jump.canHold)
        {
            if (jump.holdTimer < jump.holdMax - jump.holdIgnore)
                rb.AddForce(jump.holdPower * rb.transform.up, ForceMode.Force);
            jump.holdTimer -= Time.deltaTime;
            if (jump.holdTimer <= 0)
                jump.canHold = false;
        }
    }
    void JumpRelease()
    {
        jump.canHold = false;
    }

    //Dashing
    void DashController(Vector2 inputDir)
    {
        if (dash.dashDelayTimer > 0)
            dash.dashDelayTimer -= Time.deltaTime;
        else
            mr.material.SetColor("_Color", Color.white);
        if (dash.dashOnGround == dashEnum.sprint)
        {
            if (physics.onGround)
            {
                //dash.dashDelayTimer = 0;
                dash.dashesRemaining = dash.maxDashes;
                for (int i = 0; i < dash.maxDashes; i++)
                {
                    dash.dashCounterHolder.GetChild(i).gameObject.SetActive(true);
                }

            }
            else
            {
                dash.sprintActive = false;
                if (Input.GetButtonDown("Dash"))
                    DashPress(inputDir);
            }


            if (Input.GetButton("Dash"))
                DashCharge();
            else
                dash.sprintActive = false;
        }
        else
        {
            if (physics.onGround)
            {
                //dash.dashDelayTimer = 0;
                if (dash.dashDelayTimer <= 0)
                {
                    dash.dashesRemaining = dash.maxDashes;
                    for (int i = 0; i < dash.maxDashes; i++)
                    {
                        dash.dashCounterHolder.GetChild(i).gameObject.SetActive(true);
                    }
                }

            }

            if (Input.GetButtonDown("Dash"))
                DashPress(inputDir);
        }

        if (Input.GetButtonUp("Dash"))
            DashRelease();
    }
    void DashPress(Vector2 moveDir)
    {
        if (dash.direction == directionEnum.horizontal)
            moveDir.y = 0;
        if (dash.direction == directionEnum.vertical)
            moveDir.x = 0;
        if (dash.dashesRemaining > 0 && dash.dashDelayTimer <= 0 && moveDir != Vector2.zero)
        {
			PlaySoundInList(dash.dashSounds);

			//Force PUUUUUSH
			rb.velocity = Vector3.zero;
            Vector3 forceDir = Vector3.Normalize(new Vector3(moveDir.x, moveDir.y, 0));
            
            rb.AddForce(forceDir * dash.dashPower, ForceMode.Impulse);

            //Dash Limiters
            dash.dashesRemaining--;
            dash.dashDelayTimer = dash.dashDelay;

            //Visual Cues
            mr.material.SetColor("_Color", dash.dashColor);
            for (int i = 0; i < dash.maxDashes; i++)
            {
                if (dash.dashesRemaining == i)
                    dash.dashCounterHolder.GetChild(i).gameObject.SetActive(false);
            }
        }
    }
    void DashCharge()
    {
        if (physics.onGround)
            dash.sprintActive = true;
    }

    void DashRelease()
    {
        
    }

    //Swing
    void SwingController()
    {
        if (swing.swinging)
        {
            Vector3 dir = swing.swingPivot.position - rb.position;
            if (swing.swingDir == 1)
                dir = Vector3.Normalize(new Vector3(dir.y, -dir.x, 0));
            else
                dir = Vector3.Normalize(new Vector3(-dir.y, dir.x, 0));
            UnityEngine.Debug.Log(dir);
            rb.AddForce(dir * swing.swingSpeed * 10);
            rb.velocity = Vector3.ClampMagnitude(rb.velocity, swing.swingSpeed);
            rb.transform.position = swing.swingPivot.position + (Vector3.Normalize(rb.transform.position - swing.swingPivot.position) * swing.swingDist);

            if (Input.GetButtonUp("Jump"))
                SwingRelease();
            swing.LR.enabled = true;
            swing.LR.SetPosition(1, swing.swingPivot.position - rb.position);
        }
        else
        {
            swing.LR.enabled = false;
            if (swing.swingPivot!= null && !physics.onGround)
            {
                if (Input.GetButtonDown("Jump"))
                    SwingPress();
            }
        }
    }
    void SwingPress()
    {
		PlaySoundInList(swing.swingSounds);
		rb.useGravity = false;
        swing.swinging = true;
        Vector3 dir = swing.swingPivot.position - rb.position;
            Vector3 cw = Vector3.Normalize(new Vector3(dir.y, -dir.x, 0));
            Vector3 ccw = Vector3.Normalize(new Vector3(-dir.y, dir.x, 0));
        dir = Vector3.Normalize(rb.velocity);
        if (Vector3.Distance(cw, dir) < Vector3.Distance(ccw, dir))
            swing.swingDir = 1;
        else
            swing.swingDir = -1;

        swing.swingDist = Mathf.Max(Vector3.Distance(swing.swingPivot.transform.position, rb.position), swing.minSwingDist);

        dash.dashDelayTimer = 0;
        jump.jumpDelayTimer = 0;
        dash.dashesRemaining = dash.maxDashes;
        jump.jumpsRemaining = jump.maxJumps;
        for (int i = 0; i < dash.maxDashes; i++)
        {
            dash.dashCounterHolder.GetChild(i).gameObject.SetActive(true);
        }
        mr.material.SetColor("_Color", Color.white);
    }
    void SwingCharge()
    {
        
    }

    void SwingRelease()
    {
		PlaySoundInList(swing.releaseSounds);
		swing.swinging = false;
        swing.LR.enabled = false;
        rb.useGravity = true;

        Vector3 launchPower = Vector3.Normalize(rb.velocity) * swing.launchForce;
        rb.velocity = Vector3.zero;
        rb.AddForce(launchPower, ForceMode.Impulse);

        swing.lastSwingTime = Time.fixedTime;
        //DisableInteraction(0.15f);
    }

    //Z Track
    void ZTrackUpdate()
    {
        curZLevel = Mathf.MoveTowards(curZLevel, tarZLevel, Time.deltaTime * physics.zLevelChangeRate);
        transform.position = new Vector3(transform.position.x, transform.position.y, curZLevel);

        curZLevel = transform.position.z;
    }

    public void ChangeTargetZLevel (float z)
    {
        tarZLevel = z;
    }
    public void ChangeTargetZLevelSpeed(float z)
    {
        physics.zLevelChangeRate = z;
    }

    //Physics
    void GroundDetection()
    {
        RaycastHit[] hits = Physics.SphereCastAll(rb.transform.position, physics.radius, Vector3.down, physics.groundDetectionDist, physics.groundLayers);
        bool tempOnGround = false;
        bool isGroundDiggable = false;
        foreach (var item in hits)
        {
            switch (item.transform.tag)
            {
                case "Ground":
                    if (rb.velocity.y <= 0.2f)
					{
                        tempOnGround = true;
                        if (item.transform.parent)
						{
                            isGroundDiggable |= item.transform.parent.gameObject.CompareTag("Diggable");
						}
					}
                    break;
                default:
                    break;
            }
        }
        

		bool prevOnGround = physics.onGround;
        physics.onGround = tempOnGround;

		if (prevOnGround != physics.onGround && rb.velocity.y < 0.0f)
		{
             PlaySoundInList(physics.landSounds);
             animator.SetTrigger(animHashes.land);
        }

        if (physics.onGround && !tunnel.inTunnel && !isGroundDiggable)
		{
            UnityEngine.Debug.Log("Grounded pos: " + rb.position);
            physics.lastGroundedPos = rb.position;
		}
    }

    public void ResetToLastGroundedPosition()
	{
        rb.position = physics.lastGroundedPos;
        rb.velocity = Vector3.zero;
	}

	public void DisableInteraction (float timer)
    {
        movement.disabledMovementTimer = timer;
    }

    public void Launch (Vector3 force, float timer)
    {
        if (movement.launchDelayTimer <= 0)
        {
            rb.velocity = Vector3.zero;
            rb.AddForce(force, ForceMode.Impulse);
            DisableInteraction(timer);
            movement.launchDelayTimer = movement.launchDelay;
            dash.dashDelayTimer = 0;
            jump.jumpDelayTimer = 0;

			PlaySoundInList(movement.launchSounds);

            animator.SetTrigger(animHashes.jump);
            animator.ResetTrigger(animHashes.land);
        }
    }

    public void CollisionEnter(Collision collision)
    {
        if (dash.dashDelayTimer > 0)
        {
            if (collision.collider.tag == "DashBreakable")
            {
                collision.collider.gameObject.SetActive(false);
                rb.velocity = physics.prevVelocity[1];
            }
            else
            {
                Vector3 normal = Vector3.zero;
                foreach (var item in collision.contacts)
                {
                    normal += item.normal;
                }
                normal /= collision.contacts.Length;
                Vector3 force = Vector3.Reflect(physics.prevVelocity[1], normal) * dash.bounceMultiplier;
                rb.velocity = Vector3.zero;
                rb.AddForce(force, ForceMode.Impulse);
            }
        }
    }

    public void TriggerStay(Collider other)
    {
        if (other.tag == "Swing")
        {
            swing.swingPivot = other.transform;
        }
    }

    public void TriggerExit(Collider other)
    {
        if (other.tag == "Swing")
        {
            if (other.transform == swing.swingPivot && swing.swinging == false)
            {
                swing.swingPivot = null;
            }
        }
    }

    public void TunnelActivate(bool activate)
    {
        if (activate)
        {
            if (!tunnel.inTunnel)
            {
                tunnel.inTunnel = true;
                tunnel.tunnelMoveDir = Vector3.Normalize(new Vector3(rb.velocity.x, rb.velocity.y, 0));
                rb.useGravity = false;
                rb.velocity = Vector3.zero;
                dash.dashDelayTimer = 0;
                jump.jumpDelayTimer = 0;
                dash.dashesRemaining = dash.maxDashes;
                jump.jumpsRemaining = jump.maxJumps;
                for (int i = 0; i < dash.maxDashes; i++)
                {
                    dash.dashCounterHolder.GetChild(i).gameObject.SetActive(true);
                }
                mr.material.SetColor("_Color", Color.white);

				PlaySoundLooping(tunnel.digSound);
			}
        }
        else
        {
            tunnel.inTunnel = false;
            Vector3 launchPower = Vector3.Normalize(rb.velocity) * tunnel.launchForce;
            rb.velocity = Vector3.zero;
            rb.AddForce(launchPower, ForceMode.Impulse);
            DisableInteraction(0.15f);
            rb.useGravity = true;
			StopSoundLooping();
		}
    }
}
