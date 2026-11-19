class_name MockTutorialHarness
extends Node

## MockTutorialHarness: Interactive preview harness for tutorial hints.
## Demonstrates all four primary onboarding presets.

@onready var tutorial: TutorialHint = $TutorialHint

func _ready() -> void:
	print("MockTutorialHarness ready. Press [1-4] to test tutorial hints.")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_1:
			tutorial.show_preset("leap")
		KEY_2:
			tutorial.show_preset("shrink")
		KEY_3:
			tutorial.show_preset("stealth")
		KEY_4:
			tutorial.show_preset("combat")
