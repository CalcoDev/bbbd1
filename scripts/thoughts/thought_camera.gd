class_name ThoughtCamera
extends Camera2D

@export var zoom_sensitivity: float = 0.05
@export var min_zoom: float = 0.02
@export var max_zoom: float = 2.0

var prev_mouse_pos: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
    var mouse_pos = get_viewport().get_mouse_position()
    var mwheel_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)

    if mwheel_held:
        var dmouse = mouse_pos - prev_mouse_pos
        global_position -= dmouse / zoom.x
    
    var neg = Input.is_action_just_pressed("THOUGHT_ZOOM_NEG") as int
    var pos = Input.is_action_just_pressed("THOUGHT_ZOOM_POS") as int
    var mwheel_scroll = pos - neg
    var z = zoom.x + zoom_sensitivity * sign(mwheel_scroll)
    zoom += Vector2.ONE * clamp(z, min_zoom, max_zoom)

    # if abs(mwheel_scroll) > 0:
    #     global_position = get_global_mouse_position()
    
    prev_mouse_pos = mouse_pos
