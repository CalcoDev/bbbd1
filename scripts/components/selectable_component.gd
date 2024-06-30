class_name SelectableComponent
extends Area2D

signal on_mouse_enter()
signal on_mouse_exit()
signal on_mouse_down(event: InputEventMouseButton)
signal on_mouse_up(event: InputEventMouseButton)

signal on_drag_begin()
signal on_drag_end()

func _ready() -> void:
    input_event.connect(_on_input_event)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton:
        if event.pressed:
            on_mouse_down.emit(event)
            if event.button_index == MOUSE_BUTTON_LEFT:
                on_drag_begin.emit()
        else:
            on_mouse_up.emit(event)
            if event.button_index == MOUSE_BUTTON_LEFT:
                on_drag_end.emit()

func _on_mouse_entered() -> void:
    on_mouse_enter.emit()

func _on_mouse_exited() -> void:
    on_mouse_exit.emit()