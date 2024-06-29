class_name DialogueManager
extends Node

static var instance: DialogueManager = null

@export_group("Reference")
@export var anim: AnimationPlayer = null
@export var text_display: RichTextLabel = null
@export var dialogue_box: Control = null

@export var is_hidden: bool = false:
	set(value):
		if is_hidden == value:
			return
		is_hidden = value
		if value:
			hide()
		else:
			display()

func display() -> void:
	if not is_hidden:
		return
	is_hidden = false
	# dialogue_box.visible = true
	anim.play("dialogue_enter")
	await anim.animation_finished

func hide() -> void:
	if is_hidden:
		return
	is_hidden = true
	# dialogue_box.visible = false
	anim.play("dialogue_exit")
	await anim.animation_finished

func play_text(text: String) -> void:
	display()
	var coro = Coro.new(play_text_coroutine, true)
	await coro.run({"text": text, "cps": 10})
	await await_player_input("DIALOGUE_NEXT")
	hide()

func await_player_input(action):
	while true:
		await Game.on_pre_process
		if Input.is_action_just_pressed(action):
			break

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
	hide()