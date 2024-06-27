extends Node

@export var current_player: Player = null

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color.from_string("0cf1ff", Color.BLACK))