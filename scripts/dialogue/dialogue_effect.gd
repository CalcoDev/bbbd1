class_name DialogueInteractionEffect
extends InteractionEffect

@export_multiline var text: String = ""

func on_use() -> void:
    super()
    DialogueManager.instance.play_dialogue(text)