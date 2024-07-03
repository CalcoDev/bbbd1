class_name ThoughtWorldCls
extends Node2D

@export var canvas: CanvasLayer = null
@export var camera: ThoughtCamera = null

static var instance: ThoughtWorldCls = null

var is_arrow: bool = false
var arrow_from: ThoughtNode = null

var connections: Array = []

var hovered_node: ThoughtNode = null

var hovered_node_real: ThoughtNode = null

var time_changed = 0

func _enter_tree() -> void:
	if instance != null and is_instance_valid(instance):
		push_warning("WARNING: Thought World instance already exists and is still valid!")
	instance = self

	toggle_visibily()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("THOUGHT_WORLD") and Game.active_gameplay_scene != null:
		toggle_during_gameplay()
	
	var remove_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and arrow_from == null and hovered_node == null
	var should_queue_redraw = false
	for idx in range(len(connections) - 1, -1, -1):
		var connection = connections[idx]
		if intersect_line_point(connection[0].global_position, connection[1].global_position, 2, get_global_mouse_position()):
			if remove_held:
				connections.remove_at(idx)
				should_queue_redraw = true
			else:
				if hovered_node == null:
					if not connection[2]:
						should_queue_redraw = true
					connection[2] = true
				else:
					if connection[2]:
						should_queue_redraw = true
					connection[2] = false
		else:
			if connection[2]:
				should_queue_redraw = true
			connection[2] = false
	if should_queue_redraw:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not canvas.visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not hovered_node_real == null:
				if not hovered_node.is_mouse_inside:
					hovered_node.on_mouse_exit()
				hovered_node = null
			if arrow_from != null and hovered_node_real == null:
				if not arrow_from.is_mouse_inside:
					arrow_from.on_mouse_exit()
				arrow_from = null

func intersect_line_point(s: Vector2, e: Vector2, thickness: float, p: Vector2):
	var line = (e - s)
	var line_len = line.length()

	if line_len == 0:
		var d = (p - s).length()
		if d < thickness:
			return true
	
	var unit = line.normalized()
	var point_vec = (p - s)
	var projection_len = point_vec.x * unit.x + point_vec.y * unit.y
	projection_len = max(0, min(line_len, projection_len))
	var closest_point = Vector2(
		s.x + projection_len * unit.x,
		s.y + projection_len * unit.y
	)
	var dist = (p - closest_point).length()
	if dist < thickness:
		return true
	return false

func _draw() -> void:
	for connection in connections:
		var start = connection[0].global_position - global_position
		var end = connection[1].global_position - global_position
		var col = Color.RED if connection[2] else Color.WHITE
		draw_line(start, end, col, 2)

func handle_is_moving() -> void:
	queue_redraw()

func handle_start_arrow(node: ThoughtNode) -> void:
	is_arrow = true
	arrow_from = node

func handle_stop_arrow(node: ThoughtNode) -> void:
	if arrow_from == node:
		return
	if node != null:
		for connection in connections:
			if connection[0] == arrow_from and connection[1] == node:
				return
		connections.append([arrow_from, node, false])
	arrow_from.on_mouse_exit()
	hovered_node = node

	# arrow_from.anim.play("info_exit")
	# arrow_from.should_reset_anim = false

	arrow_from = null
	queue_redraw()

func toggle_visibily():
	canvas.visible = !canvas.visible
	$"../BackgroundLayer".visible = !$"../BackgroundLayer".visible
	time_changed = Time.get_ticks_msec()

func toggle_during_gameplay():
	toggle_visibily()
	if canvas.visible:
		Game.time_scale = 0.1
		process_mode = PROCESS_MODE_ALWAYS
		camera.prev_mouse_pos = get_viewport().get_mouse_position()
	else:
		Game.time_scale = 1.0
		handle_stop_arrow(null)
		process_mode = PROCESS_MODE_DISABLED
		for child in get_children():
			if child is ThoughtNode:
				child.stop()
