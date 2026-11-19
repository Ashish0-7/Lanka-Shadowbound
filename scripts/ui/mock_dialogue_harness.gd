class_name MockDialogueHarness
extends Node

## MockDialogueHarness: Test bed for the DialogueBox component.
## Lets designers and writers preview narrative sequences.

@onready var dialogue_box: DialogueBox = $DialogueBox

func _ready() -> void:
	print("MockDialogueHarness ready. Press [1] for Mandodari scene, [2] for Sita scene.")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_1:
			dialogue_box.play_mandodari_misunderstanding_scene()
		KEY_2:
			dialogue_box.play_sita_ring_handover_scene()
