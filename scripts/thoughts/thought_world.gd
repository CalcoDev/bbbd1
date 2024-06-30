class_name ThoughtWorld
extends Node2D

static var instance: ThoughtWorld = null

var is_arrow: bool = false
var arrow_from: ThoughtNode = null

var connections: Array = []

func _enter_tree() -> void:
	if instance != null and is_instance_valid(instance):
		push_warning("WARNING: Thought World instance already exists and is still valid!")
	instance = self

func _process(_delta: float) -> void:
	var remove_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var should_queue_redraw = false
	for idx in range(len(connections) - 1, -1, -1):
		var connection = connections[idx]
		if intersect_line_point(connection[0].global_position, connection[1].global_position, 2, get_global_mouse_position()):
			if remove_held:
				connections.remove_at(idx)
				should_queue_redraw = true
			else:
				if not connection[2]:
					should_queue_redraw = true
				connection[2] = true
		else:
			if connection[2]:
				should_queue_redraw = true
			connection[2] = false

	if should_queue_redraw:
		queue_redraw()
		
func intersect_line_point(s: Vector2, e: Vector2, thickness: float, p: Vector2):
	var line = (e - s)
	var line_len = line.length()

	if s.distance_to(p) < 5 or e.distance_to(p) < 5:
		return false

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
	for connection in connections:
		if connection[0] == arrow_from and connection[1] == node:
			return
	connections.append([arrow_from, node, false])
	queue_redraw()