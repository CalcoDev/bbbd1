class_name DialogueInteractionEffect
extends InteractionEffect

@export_multiline var text: String = ""

func on_use() -> void:
    super()
    print("... said ", text)