extends CharacterBody2D

# Constants
const MAX_SPEED = 450.0
const ACCELERATION = 2500.0
const DECELERATION = 1700.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 1300.0
const BOUNCE_FORCE = -200.0
const CAMERA_SMOOTHNESS = 0.1
const MAX_JUMPS = 2
const KNOCKBACK_FORCE_X = 2000.0
const KNOCKBACK_FORCE_Y = -1500.0
const INVULNERABILITY_DURATION = 1.0

# Variables
var coins = GlobalvALS.coinsG
var lives = GlobalvALS.lives
var is_invulnerable = false
var jump_count = 0
var current_speed = 0.0
var is_taunting = false  # Variable para saber si está haciendo un taunt

@onready var camera_2d = $"../Camera2D"

func _init():
	print("current scene")
	GlobalvALS.coinsG = 0
	GlobalvALS.lives = 3

func _physics_process(delta):
	if GlobalvALS.lives <= 0:
		get_tree().reload_current_scene()
	
	if is_taunting:
		return  # No moverse durante el taunt

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction = Input.get_axis("Left", "Right")
	if direction != 0:
		current_speed = lerp(current_speed, float(direction * MAX_SPEED), ACCELERATION * delta / MAX_SPEED)
	else:
		current_speed = lerp(current_speed, 0.0, DECELERATION * delta / MAX_SPEED)
	velocity.x = current_speed

	if direction != 0:
		$Sprite2D.flip_h = direction < 0

	if Input.is_action_just_pressed("Jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		$Jump.play()
		jump_count += 1

	if is_on_floor():
		jump_count = 0

	if Input.is_action_just_pressed("taunt"):
		_do_taunt()

	_update_animations(direction)
	_update_camera()
	move_and_slide()

func _update_animations(direction):
	if is_taunting:
		$Sprite2D.play("Taunt")
	elif not is_on_floor():
		$Sprite2D.play("Jump")
	elif direction != 0:
		$Sprite2D.play("Walk")
	else:
		$Sprite2D.play("Idle")

func _update_camera():
	if camera_2d:
		var target_position = position
		camera_2d.position = camera_2d.position.lerp(target_position, CAMERA_SMOOTHNESS)

func _do_taunt():
	if is_taunting:
		return
	is_taunting = true
	$Sprite2D.play("Taunt")
	$TauntSound.play()
	await get_tree().create_timer(0.29).timeout
	is_taunting = false

func _on_enemy_collision(enemy: CharacterBody2D):
	if position.y < enemy.position.y:
		velocity.y = BOUNCE_FORCE
		enemy.call("_on_stomped")
	else:
		pass

func _take_damage(body):
	if body.is_in_group("Enemies"):
		if is_invulnerable:
			return
		_apply_knockback(body)
		GlobalvALS.lives -= 1
		$Hurt.play()
		if GlobalvALS.lives <= 0:
			queue_free()
		_start_invulnerability()

func _apply_knockback(body):
	var knockback_direction = (position - body.position).normalized()
	velocity.x = knockback_direction.x * KNOCKBACK_FORCE_X
	velocity.y = KNOCKBACK_FORCE_Y

func _start_invulnerability():
	is_invulnerable = true
	await get_tree().create_timer(INVULNERABILITY_DURATION).timeout
	is_invulnerable = false
