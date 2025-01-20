extends CharacterBody2D

# Constants
const MAX_SPEED = 450.0
const ACCELERATION = 2500.0  # Acceleration factor for smoother movement
const DECELERATION = 1700.0  # Deceleration factor when stopping
const JUMP_VELOCITY = -600.0
const GRAVITY = 1300.0
const BOUNCE_FORCE = -200.0  # Force applied when bouncing off enemies
const CAMERA_SMOOTHNESS = 0.1  # Lower values = smoother camera follow
const MAX_JUMPS = 2  # Maximum number of jumps (double jump)
const KNOCKBACK_FORCE_X = 2000.0  # Horizontal knockback force
const KNOCKBACK_FORCE_Y = -1500.0  # Vertical knockback force
const INVULNERABILITY_DURATION = 1.0  # Duration of invulnerability after damage

# Variables
var coins = GlobalvALS.coinsG
var lives = GlobalvALS.lives
var is_invulnerable = false  # Temporarily avoid damage after hitting an enemy
var jump_count = 0  # Tracks the number of jumps
var current_speed = 0.0  # Tracks the current horizontal speed
@onready var camera_2d = $"../Camera2D"

func _init():
	GlobalvALS.coinsG = 0
	GlobalvALS.lives = 3

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle horizontal movement with acceleration and deceleration
	var direction = Input.get_axis("Left", "Right")
	if direction != 0:
		current_speed = lerp(current_speed, float(direction * MAX_SPEED), ACCELERATION * delta / MAX_SPEED)
	else:
		current_speed = lerp(current_speed, 0.0, DECELERATION * delta / MAX_SPEED)
	velocity.x = current_speed

	# Flip the sprite based on movement direction
	if direction != 0:
		$Sprite2D.flip_h = direction < 0

	# Handle jumping and double jump
	if Input.is_action_just_pressed("Jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		$Jump.play()
		jump_count += 1

	# Reset jump count when on the floor
	if is_on_floor():
		jump_count = 0

	# Play animations based on state
	_update_animations(direction)

	# Smooth camera follow
	_update_camera()

	# Move the player
	move_and_slide()

func _update_animations(direction):
	if not is_on_floor():
		$Sprite2D.play("Jump")
	elif direction != 0:
		$Sprite2D.play("Walk")
	else:
		$Sprite2D.play("Idle")

func _update_camera():
	if camera_2d:
		var target_position = position
		camera_2d.position = camera_2d.position.lerp(target_position, CAMERA_SMOOTHNESS)

func _on_enemy_collision(enemy: CharacterBody2D):
	# Check if the player is above the enemy
	if position.y < enemy.position.y:
		# Bounce off the enemy and stomp it
		velocity.y = BOUNCE_FORCE
		enemy.call("_on_stomped")  # Trigger the enemy's death logic
	else:
		pass
		# Take damage if colliding from the sides or below
		#_take_damage(enemy)


func _take_damage(body):
	if body.is_in_group("Enemies"):
		if is_invulnerable:
			return
		
		# Apply knockback
		_apply_knockback(body)
		
		# Reduce lives and handle death
		GlobalvALS.lives -= 1
		$Hurt.play()
		if GlobalvALS.lives <= 0:
			queue_free()

		# Activate invulnerability
		_start_invulnerability()

func _apply_knockback(body):
	var knockback_direction = (position - body.position).normalized()
	velocity.x = knockback_direction.x * KNOCKBACK_FORCE_X
	velocity.y = KNOCKBACK_FORCE_Y

func _start_invulnerability():
	is_invulnerable = true
	await get_tree().create_timer(INVULNERABILITY_DURATION).timeout
	is_invulnerable = false
