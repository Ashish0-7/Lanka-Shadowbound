class_name MockTransitionHarness
extends Node

## MockTransitionHarness: Test bed for screen fades and chapter title cards.
## Allows designers and developers to review chapter introductions for all 5 levels.

@onready var transition: LevelTransition = $LevelTransition

func _ready() -> void:
	print("MockTransitionHarness ready. Press [1-5] for chapter title cards, [F] for screen fade.")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_1:
			transition.play_level_title_card(1)
		KEY_2:
			transition.play_level_title_card(2)
		KEY_3:
			transition.play_level_title_card(3)
		KEY_4:
			transition.play_level_title_card(4)
		KEY_5:
			transition.play_level_title_card(5)
		KEY_F:
			transition.fade_out(0.4)
			var timer: SceneTreeTimer = get_tree().create_timer(0.6)
			timer.timeout.connect(func(): transition.fade_in(0.4))
