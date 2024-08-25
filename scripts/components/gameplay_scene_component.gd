class_name GameplaySceneComponent
extends Node

# Effectively just a tag
@export var root: Node = null

func _ready() -> void:
    Game.active_gameplay_scene = self

func pause():
    root.process_mode = Node.PROCESS_MODE_DISABLED

func resume():
    root.process_mode = Node.PROCESS_MODE_INHERIT