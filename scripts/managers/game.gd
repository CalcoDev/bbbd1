extends Node

signal on_pre_process()

@export var current_player: Player = null

func _enter_tree() -> void:
    process_priority = -999

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color.from_string("0cf1ff", Color.BLACK))

func _process(_delta: float) -> void:
    on_pre_process.emit()