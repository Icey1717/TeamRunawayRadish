using System.Collections;
using System.Collections.Generic;
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
    [System.Serializable]
    public class MovementVar
    {
        public float moveSpeed;
        public float maxSpeed;
        public float velocityOpposition;
        [HideInInspector]
        public float disabledMovementTimer = 0;
        [Tooltip("How Long Before The Player Can Be Launched By Other Objects Again")]
        public float launchDelay = 0.25f;
        [HideInInspector]
        public float launchDelayTimer = 0;
    }
    public JumpVar jump;
    [System.Serializable]
    public class JumpVar
    {
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
        
    }

    public DashVar dash;
    [System.Serializable]
    public class DashVar
    {
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

       
    }

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
    }

    public Rigidbody rb;
    public MeshRenderer mr;

    private float curZLevel = 0;
    public float tarZLevel = 0;


    void Start()
    {
        tarZLevel = rb.transform.position.z;
        curZLevel = rb.transform.position.z;

        if (!programmerAnimation)
            animator.enabled = false;
    }

    private void Update()
    {
        GroundDetection();

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

        if (movement.disabledMovementTimer <= 0)
        {
            if (dash.dashDelayTimer <= 0)
                Movement(inputDir);

            DashController(inputDir);

            JumpController();
        }
        else
            movement.disabledMovementTimer -= Time.deltaTime;
        if (movement.launchDelayTimer > 0)
            movement.launchDelayTimer -= Time.deltaTime;
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

        moveDirV3.x -= rb.velocity.x * movement.velocityOpposition;

        rb.AddForce(moveDirV3);
        rb.velocity = new Vector3(Mathf.Clamp(rb.velocity.x, -tempMaxSpeed, tempMaxSpeed), rb.velocity.y, rb.velocity.z);
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
            if (Input.GetButtonDown("Jump"))
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

            //Visual Cues
            if (programmerAnimation)
                animator.Play("Jump");
        }
    }

    //This is for making jumps bigger
    void JumpCharge()
    {
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

        if (Input.GetButtonUp("Dash"))
            DashRelease();
    }
    void DashPress(Vector2 moveDir)
    {
        if (dash.dashesRemaining > 0 && dash.dashDelayTimer <= 0 && moveDir != Vector2.zero)
        {
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
        foreach (var item in hits)
        {
            switch (item.transform.tag)
            {
                case "Ground":
                    if (rb.velocity.y <= 0.2f)
                        tempOnGround = true;
                    break;
                default:
                    break;
            }
        }
        physics.onGround = tempOnGround;
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
            
        }
    }

    public void CollisionEnter(Collision collision)
    {
        if (dash.dashDelayTimer > 0)
        {
            Vector3 normal = Vector3.zero;
            foreach (var item in collision.contacts)
            {
                normal += item.normal;
            }
            normal /= collision.contacts.Length;
            Vector3 force = Vector3.Reflect(physics.prevVelocity[1],normal) * dash.bounceMultiplier;
            rb.velocity = Vector3.zero;
            rb.AddForce(force, ForceMode.Impulse);
        }
    }
}
