class_name ThoughtNode
extends Node2D

@export_group("References")
@export var anim: AnimationPlayer = null
@export var area: SelectableComponent = null
@export var center: AnimatedSprite2D = null
@export var halos: Array[AnimatedSprite2D] = []
@export var label: RichTextLabel = null
@export var preview: Sprite2D = null

var is_moving: bool = false
var mouse_offset = Vector2.ZERO

var is_arrow: bool = false

var should_reset_anim: bool = false

var is_open: bool = false
var is_mouse_inside: bool = false

func _ready() -> void:
	area.on_mouse_enter.connect(on_mouse_enter)
	area.on_mouse_exit.connect(on_mouse_exit)
	area.on_mouse_down.connect(on_mouse_down)
	area.on_mouse_up.connect(on_mouse_up)

	anim.play("info_exit")
	should_reset_anim = false
	is_open = false

func _process(_delta: float) -> void:
	if is_moving:
		global_position = get_global_mouse_position() + mouse_offset
		ThoughtWorldCls.instance.handle_is_moving()
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
	is_mouse_inside = true
	if is_open:
		return
	
	center.modulate = Color.RED
	anim.play("info_enter")
	should_reset_anim = true
	is_open = true
	ThoughtWorldCls.instance.hovered_node = self
	ThoughtWorldCls.instance.hovered_node_real = self

func on_mouse_exit() -> void:
	is_mouse_inside = false
	if not is_arrow and not is_moving and not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		center.modulate = Color.WHITE
		anim.play("info_exit")
		should_reset_anim = false
		is_open = false
		ThoughtWorldCls.instance.hovered_node = null
		ThoughtWorldCls.instance.hovered_node_real = null

func on_mouse_down(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_offset = global_position - get_global_mouse_position()
		start_move()
	elif event.button_index == MOUSE_BUTTON_LEFT:
		start_arrow()
		ThoughtWorldCls.instance.handle_start_arrow(self)
	
func on_mouse_up(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		stop_move()
	# NOTE(calco): Not called here because we will call it outside usually
	elif event.button_index == MOUSE_BUTTON_LEFT:
		ThoughtWorldCls.instance.handle_stop_arrow(self)

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
	# if should_reset_anim:
	# 	anim.play("info_exit")
	# 	should_reset_anim = false
