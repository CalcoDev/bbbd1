class_name DialogueManager
extends Control

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
			hide_box()
		else:
			display_box()

# Stuff about current dialogue
var current_dialogue: Dialogue = null
var speed: float = 7.5

func display_box() -> void:
	if not is_hidden:
		return
	is_hidden = false
	anim.play("dialogue_enter")
	await anim.animation_finished

func hide_box() -> void:
	if is_hidden:
		return
	is_hidden = true
	# dialogue_box.visible = false
	anim.play("dialogue_exit")
	await anim.animation_finished

# NEW THINGS
func play_dialogue(text: String) -> void:
	current_dialogue = Dialogue.from_text(text)
	display_box()
	var coro = Coro.new(play_dialogue_coro, true)
	await coro.run()
	hide_box()

func play_dialogue_coro(coro: Coro) -> void:
	current_dialogue.restart_tokenizer()
	text_display.text = current_dialogue.get_string_till_nextpage()
	text_display.visible_characters = 0
	
	var token: Dialogue.Token
	var wait_frame = true
	var skipped_prev_string = false
	while true:
		if wait_frame:
			await Game.on_pre_process
			if not coro.should_cont:
				return
		
		token = current_dialogue.get_next_token()
		wait_frame = false

		match token.type:
			# TODO(calco): Work on this later
			# Dialogue.Token.SPEAKER:
			# 	_speaker = token.Value
			Dialogue.Token.SPEED:
				speed = token.value
			Dialogue.Token.WAIT:
				await get_tree().create_timer(token.value).timeout
				if not coro.should_cont:
					return
			Dialogue.Token.NEWPAGE:
				await await_player_input("DIALOGUE_NEXT")
				text_display.text = current_dialogue.get_string_till_nextpage()
				text_display.visible_characters = 0
				wait_frame = true
				skipped_prev_string = false
			Dialogue.Token.STRING:
				if skipped_prev_string:
					text_display.visible_characters += len(token.value)
					continue
				var ret = await Coro.first_of([play_dialogue_page_coro, [await_player_input, "DIALOGUE_SKIP", Coro.NO_CTX]], false, true)
				text_display.visible_characters = len(text_display.text)
				if ret.to_await == play_dialogue_page_coro:
					wait_frame = true
				else:
					skipped_prev_string = true
			Dialogue.Token.NEWLINE:
				text_display.visible_characters += 1
			Dialogue.Token.EOF:
				await await_player_input("DIALOGUE_NEXT")
				break
			Dialogue.Token.UNKNOWN:
				push_warning("WARNING: Dialogue Manager encountered a token it didn't know how to handle! Skipping over it ...")

func play_dialogue_page_coro(coro: Coro) -> void:
	var idx: float = 0.0
	var curr_char: int = 0
	while idx < len(text_display.text):
		await Game.on_pre_process
		if not coro.should_cont:
			return
		var tchar = mini(floori(idx + speed * get_process_delta_time()), len(text_display.text))
		if curr_char != tchar:
			var val = text_display.text.substr(curr_char, tchar - curr_char)
			text_display.visible_characters += len(val)
			curr_char = tchar
		idx += speed * get_process_delta_time()
# NEW THINGS END

func await_player_input(action):
	while true:
		await Game.on_pre_process
		if Input.is_action_just_pressed(action):
			break
		
func _enter_tree() -> void:
	if instance != null:
		push_warning("WARNING: Dialogue Manager instantiated twice!")
		queue_free()
		return
	instance = self
	visible = true
	hide_box()
