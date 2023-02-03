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

        public float dashDelay = 0.2f;
        [HideInInspector]
        public float dashDelayTimer = 0;
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
    }

    public Rigidbody rb;

    private float curZLevel = 0;
    public float tarZLevel = 0;


    void Start()
    {
        tarZLevel = rb.transform.position.z;
        curZLevel = rb.transform.position.z;

        if (!programmerAnimation)
            animator.enabled = false;
    }
    void FixedUpdate()
    {

    }

    private void Update()
    {
        ZTrackUpdate();
        GroundDetection();

        PlayerInput();
    }

    //Input
    void PlayerInput()
    {
        //2D Movement
        Vector2 inputDir = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        Movement(inputDir);

        DashController(inputDir);

        JumpController();
        
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
        rb.velocity = new Vector3(Mathf.Clamp(rb.velocity.x, -tempMaxSpeed, tempMaxSpeed),rb.velocity.y,rb.velocity.z);
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
            rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.z);
            rb.AddForce(jump.basePower * rb.transform.up, ForceMode.Impulse);
            jump.jumpDelayTimer = jump.jumpDelay;
            jump.holdTimer = jump.holdMax;
            jump.canHold = true;
            jump.jumpsRemaining--;
            if (programmerAnimation)
                animator.Play("Jump");
        }
    }

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
        if (physics.onGround)
        {
            dash.dashesRemaining = dash.maxDashes;
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
        if (dash.dashesRemaining > 0)
        {
            Vector3 forceDir = new Vector3(moveDir.x, moveDir.y, 0);
            rb.AddForce(forceDir * dash.dashPower, ForceMode.Impulse);
            dash.dashesRemaining--;
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
}
