class_name DialogueManager
extends Control

static var instance: DialogueManager = null

@export_group("Reference")
@export var anim: AnimationPlayer = null
@export var text_display: RichTextLabel = null
@export var dialogue_box: Control = null

@export var speaker_container: MarginContainer = null
@export var speaker_tex: TextureRect = null

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
var current_speaker: Speaker = null:
	set(value):
		if current_speaker == value:
			return
		current_speaker = value
		if current_speaker == null:
			if speaker_container.visible:
				speaker_container.visible = false
		else:
			if not speaker_container.visible:
				speaker_container.visible = true
			speaker_tex.texture = current_speaker.icon
var speed: float = 7.5

static var SPEAKERS_REGISTER: Dictionary = {}:
	get:
		assert(SPEAKERS_INIT, "ERROR: Tried accessing speakers register without it being initialised.")
		return SPEAKERS_REGISTER

static var SPEAKERS_INIT: bool = false

func _enter_tree() -> void:
	if instance != null:
		push_warning("WARNING: Dialogue Manager instantiated twice!")
		queue_free()
		return
	instance = self
	visible = true
	hide_box()

	if not SPEAKERS_INIT:
		SPEAKERS_INIT = true
		var dir_q = []
		var speakers_dir = DirAccess.open("res://resources/dialogue/speakers")
		dir_q.append([speakers_dir, "res://resources/dialogue/speakers"])
		while len(dir_q) > 0:
			var dir = dir_q[0][0]
			var path = dir_q[0][1]
			dir_q.remove_at(0)
			dir.list_dir_begin()
			var file_path = dir.get_next()
			while file_path != "":
				var full_path = path + "/" + file_path
				if dir.current_is_dir():
					dir_q.append([DirAccess.open(full_path), full_path])
					file_path = dir.get_next()
					continue
				var res = ResourceLoader.load(full_path)
				if res is Speaker:
					SPEAKERS_REGISTER[res.name] = res
				file_path = dir.get_next()

func _process(_delta: float) -> void:
	if not is_hidden and visible and speaker_container.visible:
		speaker_container.custom_minimum_size.x = speaker_container.size.y - 10

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
			Dialogue.Token.SPEAKER:
				current_speaker = token.value
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
