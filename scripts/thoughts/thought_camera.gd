class_name ThoughtCamera
extends Node2D

@export var parallax: Array[Node2D] = []
@export var parallax_effect: Array[float] = []
var _parallax_offsets: Array[Vector2] = []

@export var canvas: CanvasLayer = null

@export var zoom_sensitivity: float = 0.05
@export var min_zoom: float = 0.02
@export var max_zoom: float = 2.0

var prev_mouse_pos: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
    for i in len(parallax):
        _parallax_offsets.append(parallax[i].global_position)

func _process(_delta: float) -> void:
    var mouse_pos = get_viewport().get_mouse_position()
    var mwheel_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)

    if mwheel_held:
        var dmouse = mouse_pos - prev_mouse_pos
        canvas.offset += dmouse
    
    for i in len(parallax):
        parallax[i].global_position = _parallax_offsets[i] + (canvas.offset - Vector2(320, 180) / 2 - _parallax_offsets[i]) * (1 - parallax_effect[i])
        # base pos + (curr pos - base pos) * (1 - multiple)
    
    var neg = Input.is_action_just_pressed("THOUGHT_ZOOM_NEG") as int
    var pos = Input.is_action_just_pressed("THOUGHT_ZOOM_POS") as int
    var mwheel_scroll = pos - neg
    var z = zoom_sensitivity * sign(mwheel_scroll)
    # zoom += Vector2.ONE * z
    # zoom.x = clamp(zoom.x, min_zoom, max_zoom)
    # zoom.y = clamp(zoom.y, min_zoom, max_zoom)
    
    canvas.scale += Vector2.ONE * z
    canvas.scale.x = clamp(canvas.scale.x, min_zoom, max_zoom)
    canvas.scale.y = clamp(canvas.scale.y, min_zoom, max_zoom)
    
    prev_mouse_pos = mouse_pos
    # canvas.offset = -global_position
    # canvas.scale = zoom