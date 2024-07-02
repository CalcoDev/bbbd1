class_name Player
extends CharacterBody2D

@export_group("Refrences")
@export var sprite: AnimatedSprite2D = null
@export var _interactor: InteractorComponent = null

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

# Whether the player jumped and hasn't touched the ground since
var was_jumping: bool = false
# Whether the player jumped and hasn't yet reached the apex point
var is_jumping: bool = false

var is_falling: bool = false

# The velocity before calling move_and_slide()
var unmodified_velocity: Vector2 = Vector2.ZERO

# Input
var inp_horiz: float = 0.0
var inp_jump_pressed: bool = false
var inp_jump_released: bool = false
var inp_down: bool = false
var inp_interact: bool = false

# Timers
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Animation
var anim_played_jump_down: bool = false
var anim_played_jump_up: bool = false

func _ready() -> void:
	Game.current_player = self

func _process(delta: float) -> void:
	gather_input()

	# Thought world
	if Input.is_action_just_pressed("THOUGHT_WORLD") and ThoughtWorldCls.instance.time_changed != Time.get_ticks_msec():
		ThoughtWorldCls.instance.toggle_during_gameplay()

	# Gravity
	coyote_timer = max(0.0, coyote_timer - delta)

	was_grounded = is_grounded
	is_grounded = is_on_floor()

	if was_grounded and not is_grounded:
		coyote_timer = coyote_time
	elif not was_grounded and is_grounded:
		was_jumping = false
		is_jumping = false

	if not is_grounded:
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

	# Jumping
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	if inp_jump_pressed:
		jump_buffer_timer = jump_buffer_time
	
	if inp_down and jump_buffer_timer > 0.0 and is_grounded:
		global_position.y += 1
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	if jump_buffer_timer > 0.0 and (is_grounded or coyote_timer > 0.0):
		velocity.y = -jump_speed
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		is_jumping = true
		was_jumping = true

		anim_played_jump_down = false
		anim_played_jump_up = false
	
	if is_jumping and inp_jump_released and velocity.y < 0.0:
		velocity.y *= 0.5
	
	if not is_grounded:
		if velocity.y > 0.0:
			is_falling = true
			if is_jumping:
				is_jumping = false
	else:
		is_falling = false

	# Horizontal movement
	if abs(inp_horiz) > 0.01:
		if sign(inp_horiz) != sign(velocity.x):
			velocity.x = move_toward(velocity.x, move_speed * inp_horiz, move_turn * delta)
		else:
			velocity.x = move_toward(velocity.x, move_speed * inp_horiz, move_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_decel * delta)

	# Interactions
	if inp_interact:
		_interactor.try_to_interact()

	# Animations
	if inp_horiz < 0 and not sprite.flip_h:
		sprite.flip_h = true
	elif inp_horiz > 0 and sprite.flip_h:
		sprite.flip_h = false
		
	if is_grounded:
		if sprite.animation == "land" and sprite.frame_progress < 1.0:
			pass
		elif not was_grounded and unmodified_velocity.y > 0:
			sprite.play("land")
		elif abs(inp_horiz) > 0.01:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		if is_jumping and not anim_played_jump_up:
			sprite.play("jump_up")
			anim_played_jump_up = true
		if is_falling:
			if was_jumping and not anim_played_jump_down:
				sprite.play("jump_down")
				anim_played_jump_down = true
			elif sprite.animation != "jump_down":
				sprite.play("fall")

	# Apply movement
	unmodified_velocity = velocity
	move_and_slide()

func gather_input():
	inp_horiz = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
	inp_jump_pressed = Input.is_action_just_pressed("JUMP")
	inp_jump_released = Input.is_action_just_released("JUMP")
	inp_down = Input.is_action_pressed("DOWN")
	inp_interact = Input.is_action_just_pressed("INTERACT")
