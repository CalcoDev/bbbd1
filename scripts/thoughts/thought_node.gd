class_name ThoughtNode
extends Node2D

@export_group("References")
@export var area: SelectableComponent = null
@export var center: AnimatedSprite2D = null
@export var halos: Array[AnimatedSprite2D] = []
@export var label: RichTextLabel = null
@export var preview: Sprite2D = null

var is_moving: bool = false
var mouse_offset = Vector2.ZERO

var is_arrow: bool = false

func _ready() -> void:
	area.on_mouse_enter.connect(on_mouse_enter)
	area.on_mouse_exit.connect(on_mouse_exit)
	area.on_mouse_down.connect(on_mouse_down)
	area.on_mouse_up.connect(on_mouse_up)

func _process(_delta: float) -> void:
	if is_moving:
		global_position = get_global_mouse_position() + mouse_offset
		ThoughtWorld.instance.handle_is_moving()
	if is_arrow:
		queue_redraw()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			stop_arrow()

func _draw() -> void:
	if is_arrow:
		var start = Vector2.ZERO
		var end = get_global_mouse_position() - global_position
		draw_line(start, end, Color.WHITE, 2, false)

func on_mouse_enter() -> void:
	center.modulate = Color.RED

func on_mouse_exit() -> void:
	center.modulate = Color.WHITE

func on_mouse_down(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_offset = global_position - get_global_mouse_position()
		start_move()
	elif event.button_index == MOUSE_BUTTON_LEFT:
		start_arrow()
		ThoughtWorld.instance.handle_start_arrow(self)
	
func on_mouse_up(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		stop_move()
	# NOTE(calco): Not called here because we will call it outside usually
	elif event.button_index == MOUSE_BUTTON_LEFT:
		ThoughtWorld.instance.handle_stop_arrow(self)

func start_move():
	is_moving = true

func stop_move():
	is_moving = false
	mouse_offset = Vector2.ZERO

func start_arrow():
	is_arrow = true

func stop_arrow():
	is_arrow = false
	queue_redraw()
	# get_tree().create_timer(0.1).timeout.connect(func(): queue_redraw())
