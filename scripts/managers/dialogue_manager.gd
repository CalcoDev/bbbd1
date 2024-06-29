class_name DialogueManager
extends Node

static var instance: DialogueManager = null

@export var text_display: RichTextLabel = null
@export var dialogue_box: Control = null

@export var is_hidden: bool = true:
	set(value):
		is_hidden = value
		if value:
			hide()
		else:
			display()

func display() -> void:
	if not is_hidden:
		return
	
	dialogue_box.visible = true

func hide() -> void:
	if is_hidden:
		return
	
	dialogue_box.visible = false

func play_text(text: String) -> void:
	print("Started dialogue")
	var coro = Coro.new(play_text_coroutine, true)
	await coro.run({"text": text, "cps": 10})
	print("Ended dialogue")

func play_text_coroutine(coro: Coro, params: Dictionary) -> void:
	var text = params["text"]
	var cps = params["cps"]

	var visible_chars: float = 0.0

	text_display.text = text
	text_display.visible_characters = 0
	while text_display.visible_characters < len(text):
		await Game.on_pre_process
		if not coro.should_cont:
			return
		visible_chars += cps * get_process_delta_time()
		text_display.visible_characters = floori(visible_chars)
		
func _enter_tree() -> void:
	if instance != null:
		push_warning("WARNING: Dialogue Manager instantiated twice!")
		queue_free()
		return
	instance = self