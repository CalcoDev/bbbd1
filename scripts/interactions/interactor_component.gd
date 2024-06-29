class_name InteractorComponent
extends Area2D

static var INTERACTOR_LAYER = 8
static var INTERACTION_LAYER = 16

func try_to_interact() -> bool:
	if _body_action == null:
		return false
	_body_action.interact(self)
	return true

# var _point_action: InteractionComponent = null
var _body_action: InteractionComponent = null
var _bodies: Dictionary = {}
var _min_dist: float = -1

func _ready() -> void:
	collision_layer = INTERACTOR_LAYER
	collision_mask = INTERACTION_LAYER

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# todo(calco): due to lack of me wanting to do better:
# func _process(delta: float) -> void:
# 	var min_dist = 99999.0
# 	for point in InteractionComponent.POINTS:
# 		var dist = point.global_position.distance_to(global_position)
# 		if dist < point.interaction_radius and dist < min_dist:
# 			_points_in_range.append(point)
# 			min_dist = dist

func _on_area_entered(area) -> void:
	if not area is InteractionComponent:
		return
	_bodies[area] = true
	var dist = area.global_position.distance_to(global_position)
	if _min_dist < 0 or dist < _min_dist:
		_min_dist = 0
		if _body_action != null:
			_body_action.hide_interaction()
		_body_action = area as InteractionComponent
		_body_action.display_interaction()

func _on_area_exited(area) -> void:
	if not area is InteractionComponent:
		return
	_bodies.erase(area)
	if _bodies.size() == 0:
		_min_dist = -1
		_body_action.hide_interaction()
		_body_action = null
