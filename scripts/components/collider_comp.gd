class_name ColliderComp
extends Area2D

@export var is_colliding = false
@export var was_colliding = false

@export var update_self = true

var _bodies: Dictionary = {}

func update():
    was_colliding = is_colliding
    is_colliding = _bodies.size() > 0

func _ready():
    body_entered.connect(_on_body_enter)
    body_exited.connect(_on_body_exit)

func _process(_delta: float) -> void:
    if update_self:
        update()

func _on_body_enter(body: Node) -> void:
    if not body is PhysicsBody2D and not body is TileMapLayer:
        return
    _bodies[body] = true

func _on_body_exit(body: Node) -> void:
    if not body is PhysicsBody2D and not body is TileMapLayer:
        return
    _bodies.erase(body)