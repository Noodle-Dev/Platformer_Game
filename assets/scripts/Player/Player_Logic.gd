extends CharacterBody2D

# Constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1200.0
const BOUNCE_FORCE = -200.0  # Force applied when bouncing off enemies

# Variables
var is_invulnerable = false  # Temporarily avoid damage after hitting an enemy

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle movement input
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Flip the sprite based on movement direction
	if direction != 0:
		$Sprite2D.flip_h = direction < 0

	# Handle jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
		_take_damage()

func _take_damage():
	if is_invulnerable:
		return  # Ignore damage if invulnerable

	is_invulnerable = true
	# Handle damage logic (e.g., reduce health, play animation, etc.)
	print("Player took damage!")

	# Temporary invulnerability timer
	await get_tree().create_timer(1.0).timeout
	is_invulnerable = false
