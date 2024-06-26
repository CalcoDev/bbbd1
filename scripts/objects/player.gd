class_name Player
extends CharacterBody2D

@export_group("Refrences")

@export_group("Movement")
@export_subgroup("Walking")
@export var move_speed: float = 300.0
@export var move_accel: float = 1000.0
@export var move_turn: float = 1000.0
@export var move_decel: float = 2000.0

@export_subgroup("Gravity")
@export var gravity: float = 1000.0
@export var max_fall_speed: float = 500.0

@export_subgroup("Jumping")
@export var jump_speed: float = 500.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# States
var was_grounded: bool = false
var is_grounded: bool = false
var is_jumping: bool = false

# Input
var inp_horiz: float = 0.0
var inp_jump_pressed: bool = false
var inp_jump_released: bool = false

# Timers
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var vel: Vector2 = Vector2.ZERO

func _ready() -> void:
	Game.current_player = self

func _on_body_entered(body: Node) -> void:
	print("Player collided with ", body)

func _process(delta: float) -> void:
	gather_input()

	# Gravity
	coyote_timer = max(0.0, coyote_timer - delta)

	was_grounded = is_grounded
	is_grounded = is_on_floor()

	if was_grounded and not is_grounded:
		coyote_timer = coyote_time
	elif not was_grounded and is_grounded:
		is_jumping = false

	if not is_grounded:
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

	# Jumping
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	if inp_jump_pressed:
		jump_buffer_timer = jump_buffer_time
	
	if jump_buffer_timer > 0.0 and (is_grounded or coyote_timer > 0.0):
		velocity.y = -jump_speed
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		is_jumping = true
	
	if is_jumping and inp_jump_released and velocity.y < 0.0:
		velocity.y *= 0.5

	# Horizontal movement
	if abs(inp_horiz) > 0.01:
		if sign(inp_horiz) != sign(velocity.x):
			velocity.x = move_toward(velocity.x, move_speed * inp_horiz, move_turn * delta)
		else:
			velocity.x = move_toward(velocity.x, move_speed * inp_horiz, move_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_decel * delta)

	# Apply movement
	move_and_slide()

func gather_input():
	inp_horiz = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
	inp_jump_pressed = Input.is_action_just_pressed("JUMP")
	inp_jump_released = Input.is_action_just_released("JUMP")