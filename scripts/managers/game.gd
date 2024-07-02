extends Node

signal on_pre_process()
signal on_time_scale_changed(value: float)

@export var current_player: Player = null

@export var paused: bool = false:
    set(value):
        paused = value
        if value:
            get_tree().paused = true
        else:
            get_tree().paused = false
        
@export var scene_paused: bool = false:
    set(value):
        scene_paused = value
        if value:
            active_gameplay_scene.pause()
        else:
            active_gameplay_scene.resume()

@export var time_scale: float = 1.0:
    set(value):
        if time_scale == value:
            return
        time_scale = value
        Engine.time_scale = time_scale
        on_time_scale_changed.emit(time_scale)

@export var active_gameplay_scene: GameplaySceneComponent = null

func _enter_tree() -> void:
    process_priority = -999

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color.from_string("0cf1ff", Color.BLACK))

func _process(_delta: float) -> void:
    on_pre_process.emit()
