class_name MockInteractionHarness
extends Node2D

## MockInteractionHarness: Interactive test bed for prompts and objective notifications.
## Demonstrates floating target tracking and notification queuing.

@onready var prompt: InteractionPrompt = $CanvasLayer/InteractionPrompt
@onready var notification: ObjectiveNotification = $CanvasLayer/ObjectiveNotification
@onready var dummy_target: Node2D = $DummyInteractable

func _ready() -> void:
	print("MockInteractionHarness ready. Press [1-5] to test prompts and notifications.")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_1:
			prompt.show_prompt("[E]", "Speak with Mother Sita", dummy_target)
		KEY_2:
			prompt.show_prompt("[SPACE]", "Leap across ocean surge", dummy_target)
		KEY_3:
			prompt.hide_prompt()
		KEY_4:
			notification.notify(
				"NEW OBJECTIVE",
				"Infiltrate Lanka at Night",
				"Slip past palace watchmen and discover Sita's location.",
				false
			)
		KEY_5:
			notification.notify(
				"OBJECTIVE COMPLETED",
				"Sita's Solace Restored",
				"The signet ring of Lord Rama has been reverently delivered.",
				true
			)
