extends CharacterBody2D

# Constants
const SPEED = 450.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 1300.0
const BOUNCE_FORCE = -200.0  # Force applied when bouncing off enemies
const CAMERA_SMOOTHNESS = 0.1  # Lower values = smoother camera follow
const MAX_JUMPS = 2  # Maximum number of jumps (double jump)
const KNOCKBACK_FORCE_X = 1000.0  # Horizontal knockback force
const KNOCKBACK_FORCE_Y = -500.0  # Vertical knockback force
var coins = GlobalvALS.coinsG
var lives = GlobalvALS.lives

# Variables
var is_invulnerable = false  # Temporarily avoid damage after hitting an enemy
var jump_count = 0  # Tracks the number of jumps
@onready var camera_2d = $"../Camera2D"

func _init():
	GlobalvALS.coinsG = 0
	GlobalvALS.lives = 3

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle movement input
	var direction = Input.get_axis("Left", "Right")
	velocity.x = direction * SPEED

	# Flip the sprite based on movement direction
	if direction != 0:
		$Sprite2D.flip_h = direction < 0

	# Handle jumping and double jump
	if Input.is_action_just_pressed("Jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Reset jump count when on the floor
	if is_on_floor():
		jump_count = 0

	# Play animations based on state
	if not is_on_floor():
		$Sprite2D.play("Jump")
	elif direction != 0:
		$Sprite2D.play("Walk")
	else:
		$Sprite2D.play("Idle")

	# Update camera position to follow the player smoothly
	if camera_2d:
		var target_position = position
		camera_2d.position = camera_2d.position.lerp(target_position, CAMERA_SMOOTHNESS)

	# Move the player
	move_and_slide()

func _on_enemy_collision(enemy: CharacterBody2D):
	# Check if the player is above the enemy
	if position.y < enemy.position.y:
		# Bounce off the enemy and stomp it
		velocity.y = BOUNCE_FORCE
		enemy.call("_on_stomped")  # Trigger the enemy's death logic
	else:
		# Take damage if colliding from the sides or below
		_take_damage(enemy)

func _take_damage(body):
	if body.is_in_group("Enemies"):
		if is_invulnerable:
			return  
		
		# Apply knockback
		var knockback_direction = (position - body.position).normalized()
		velocity.x = knockback_direction.x * KNOCKBACK_FORCE_X
		velocity.y = KNOCKBACK_FORCE_Y
		GlobalvALS.lives -= 1
		if GlobalvALS.lives <= 0:
			queue_free()

		# Make player invulnerable for 1 second
		is_invulnerable = true
		await get_tree().create_timer(1.0).timeout
		is_invulnerable = false
