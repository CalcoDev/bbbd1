# @tool
class_name InteractionComponent
extends Area2D

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
@export_group("Effects")
@export var effects: Array[InteractionEffect]

func interact() -> void:
    for effect in effects:
        effect.on_use()

func _ready() -> void:
    # match interaction_type:
    #     InteractionType.Area:
    collision_layer = InteractorComponent.INTERACTION_LAYER
    collision_mask = InteractorComponent.INTERACTOR_LAYER
        # InteractionType.Point:
        #     POINTS.append(self)

# func _exit_tree() -> void:
#     match interaction_type:
#         InteractionType.Area:
#             pass
#         InteractionType.Point:
#             POINTS.remove_at(POINTS.find(self))

# func _validate_property(property: Dictionary) -> void:
#     match interaction_type:
#         InteractionType.Area:
#             if property.name == "interaction_radius":
#                 property.usage = PROPERTY_USAGE_NO_EDITOR
#         InteractionType.Point:
#             if property.name == "interaction_area":
#                 property.usage = PROPERTY_USAGE_NO_EDITOR
