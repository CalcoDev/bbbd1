class_name ScaledTimeAnimatedSprite
extends AnimatedSprite2D

@export var use_unscaled_time: bool = false:
    set(value):
        use_unscaled_time = value
        _handle_time_scale_change(Game.time_scale)

func _enter_tree() -> void:
    Game.on_time_scale_changed.connect(_handle_time_scale_change)

func _handle_time_scale_change(value: float):
    if use_unscaled_time:
        speed_scale = 1.0 / value