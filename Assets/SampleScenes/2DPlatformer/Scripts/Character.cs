using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : MonoBehaviour {

    public ParticleSystem particle;

    // Object components
    Rigidbody2D _rb2d;
    Collider2D _collider;
    SpriteRenderer _renderer;
    Animator _animator;

    // Constantes
    public float speed = 0.2f;
    public float jumpHeight = 2f;
    public float gravity = 10f;
    public float friction = 1f;

    // Variaveis
    public float movingDirection;
    public bool isJumping;
    public bool isGrounded;

    // Animation
    bool isWalking = false;

    void Start() {
        // Inicializa os componentes
        _rb2d = GetComponent<Rigidbody2D>();
        _collider = GetComponent<Collider2D>();
        _renderer = GetComponent<SpriteRenderer>();
        _animator = GetComponent<Animator>();

        // Setting up stuff
        _rb2d.gravityScale = this.gravity;
        _rb2d.sharedMaterial = new PhysicsMaterial2D() { friction = this.friction, bounciness = 0 };
    }

    void Update() {
        HandleInput();
        HandleAnimation();
    }

    void HandleInput() {
        float dirX = Input.GetAxis("Horizontal");
        bool jumping = Input.GetButton("Jump");

        this.movingDirection = dirX;
        this.isJumping = jumping;
    }

    void HandleAnimation() {
        if (this.movingDirection < 0)
            this._renderer.flipX = true;
        else if (this.movingDirection > 0)
            this._renderer.flipX = false;

        if (this.movingDirection != 0 && !this.isWalking) {
            this._animator.Play("walk");
            this.isWalking = true;
        } else if (this.movingDirection == 0 && this.isWalking) {
            this._animator.Play("idle");
            this.isWalking = false;
        }
    }

    void FixedUpdate() {
        // Horizontal Movement
        Vector2 newVelocity = _rb2d.velocity;
        newVelocity.x = this.movingDirection * speed;

        // Check for ground
        Vector2 bottomCenter = new Vector2(_collider.bounds.center.x, _collider.bounds.min.y);
        Debug.DrawLine(bottomCenter, bottomCenter + (Vector2.down * 3f/16f), Color.magenta);
        this.isGrounded = Physics2D.Raycast(bottomCenter, Vector2.down, 3f / 16f, 1 << LayerMask.NameToLayer("Ground"));

        // Jump
        if (this.isJumping && this.isGrounded) {
            newVelocity.y = Mathf.Sqrt(2 * this.gravity * this.jumpHeight);
            particle.Play();
            particle.transform.SetParent(null);
        }

        if (Input.GetButtonDown("Fire1")) {
            newVelocity.y = Mathf.Sqrt(2 * this.gravity * this.jumpHeight);
            newVelocity.x = 24;
            particle.Play();
            particle.transform.SetParent(null);
        }

        // Updates velocity
        this._rb2d.velocity = newVelocity;
    }

}
