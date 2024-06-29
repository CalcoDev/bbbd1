@tool
class_name InteractionComponent
extends Area2D

signal on_interacted(interactor: InteractorComponent)

# static var POINTS: Array[InteractionComponent] = []

# enum InteractionType {
#     Area,
#     Point
# }

# @export var interaction_type: InteractionType = InteractionType.Point:
#     set(value):
#         interaction_type = value
#         notify_property_list_changed()

# @export var interaction_radius: float = 5.0
enum InteractionDisplayType {
    None,
    Spin,
    Point
}

@export var top_lvl: bool = true
@export var display_type: InteractionDisplayType:
    set(value):
        # if value == InteractionDisplayType.Point:
            # var node = Node2D.new()
            # add_child(node)
            # node.name = "DisplayPoint"
            # node.global_position = global_position
            # node.set_owner(get_tree().get_edited_scene_root())
        # elif display_type == InteractionDisplayType.Point and value != InteractionDisplayType.Point:
            # for child in get_children():
            #     if child.name.contains("DisplayPoint"):
            #         child.queue_free()
        display_type = value
        notify_property_list_changed()
        
@export var display_point: Node2D = null

@export_group("Effects")
@export var effects: Array[InteractionEffect]

func interact(interactor: InteractorComponent) -> void:
    on_interacted.emit(interactor)
    for effect in effects:
        effect.on_use()

func display_interaction():
    match display_type:
        InteractionDisplayType.Spin:
            get_tree().create_tween().tween_property(get_parent(), "rotation", PI, 0.15)
        InteractionDisplayType.Point:
            get_tree().create_tween().tween_property(display_point, "scale", Vector2.ONE, 0.15)

func hide_interaction():
    match display_type:
        InteractionDisplayType.Spin:
            get_tree().create_tween().tween_property(get_parent(), "rotation", 0, 0.15)
        InteractionDisplayType.Point:
            get_tree().create_tween().tween_property(display_point, "scale", Vector2.ZERO, 0.15)

func _enter_tree() -> void:
    if Engine.is_editor_hint():
        return
    if top_lvl:
        var pos = global_position
        top_level = true
        global_position = pos

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    # match interaction_type:
    #     InteractionType.Area:
    collision_layer = InteractorComponent.INTERACTION_LAYER
    collision_mask = InteractorComponent.INTERACTOR_LAYER
    hide_interaction()
        # InteractionType.Point:
        #     POINTS.append(self)

# func _exit_tree() -> void:
#     match interaction_type:
#         InteractionType.Area:
#             pass
#         InteractionType.Point:
#             POINTS.remove_at(POINTS.find(self))

func _validate_property(property: Dictionary) -> void:
    if display_type != InteractionDisplayType.Point:
        if property.name == "display_point":
            property.usage = PROPERTY_USAGE_NO_EDITOR
#     match interaction_type:
#         InteractionType.Area:
#             if property.name == "interaction_radius":
#                 property.usage = PROPERTY_USAGE_NO_EDITOR
#         InteractionType.Point:
#             if property.name == "interaction_area":
#                 property.usage = PROPERTY_USAGE_NO_EDITOR
