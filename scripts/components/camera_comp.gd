class_name CameraComp
extends Camera2D

@export_group("Camera Settings")
@export var target: Node2D = null;

@export var should_follow: bool = true
@export var follow_speed: float = 1.0;

@export var follow_offset: Vector2 = Vector2.ZERO

@export var offset_by_speed: bool = true
@export var speed_target: float = 200
@export var speed_max_offset: float = 30

var _prev_target_pos: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	var diff = target.global_position - _prev_target_pos
	var speed_offset = (diff / delta) / speed_target * speed_max_offset
	speed_offset.y = 0
	_prev_target_pos = target.global_position

	if should_follow:
		global_position = global_position.lerp(target.global_position + follow_offset + speed_offset, delta * follow_speed)