extends CharacterBody2D

# Constants
const SPEED = 100.0
const GRAVITY = 1200.0
const DEATH_DURATION = 0.5  # Time before the enemy disappears after being stomped

# Variables
var direction = -1  # Initial movement direction (-1 = left, 1 = right)
var is_dead = false

func _ready():
	# Ensure RayCast2D is set up correctly
	$RayCast2D.enabled = true

func _physics_process(delta):
	# Skip movement logic if the enemy is dead
	if is_dead:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Move the enemy
	velocity.x = direction * SPEED

	# Detect collisions and change direction
	var collision_info = move_and_slide()
	if is_on_wall() or !_is_safe_to_move():
		direction *= -1  # Reverse direction when hitting a wall or near an edge

	move_and_slide()

func _is_safe_to_move() -> bool:
	# Adjust RayCast2D position to match the direction of movement
	$RayCast2D.position.x = direction * 10
	$RayCast2D.force_raycast_update()

	# Check if the RayCast2D is colliding with a floor
	return $RayCast2D.is_colliding()

func _on_stomped():
	# Logic for when the enemy is stomped
	is_dead = true
	#$Sprite2D.scale.y = 0.5  # Flatten the sprite to simulate being stomped
	#$Sprite2D.scale.x = 1.2
	velocity = Vector2.ZERO  # Stop movement

	# Wait for the death duration before removing the enemy
	#await get_tree().create_timer(DEATH_DURATION).timeout
	$AnimationPlayer.play("Die")
	$AudioStreamPlayer2D.play()
	await $AnimationPlayer.animation_finished
	queue_free()  # Remove the enemy from the game

func _on_player_collision():
	# Logic for when the player touches the enemy
	if player_is_above():  # Replace with a condition to check if the player is above
		_on_stomped()
	else:
		emit_signal("player_damaged")  # Damage the player (connect this signal to player logic)

func player_is_above() -> bool:
	# Replace with your own logic to check if the player is above the enemy
	return get_global_mouse_position().y < global_position.y
