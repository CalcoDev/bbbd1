@tool
class_name AreaCamera
extends Area2D

var camera: PhantomCamera2D = null
var old_priority = -1

func _ready() -> void:
    if not is_valid():
        push_error("ERROR: Camera missing!")
        return
    
    camera = get_child(1) as PhantomCamera2D
    
    body_entered.connect(area_body_entered)
    body_exited.connect(area_body_exited)

func area_body_entered(body) -> void:
    if body != Game.current_player:
        return
    old_priority = camera.priority
    camera.priority = 1

func area_body_exited(body) -> void:
    if body != Game.current_player:
        return
    camera.priority = old_priority

func _get_configuration_warnings() -> PackedStringArray:
    var warnings = []
    if not is_valid():
        warnings.append("[Area Camera]: Please a camera to this camera!")
        return warnings
    var ocamera = get_child(1) as PhantomCamera2D
    ocamera.limit_target = ocamera.get_path_to(get_child(0))
    print(ocamera.limit_target)
    return warnings

func is_valid() -> bool:
    if get_child_count() < 2:
        return false
    var ocamera = get_child(1)
    if ocamera is PhantomCamera2D or ocamera is Camera2D:
        return true
    return false