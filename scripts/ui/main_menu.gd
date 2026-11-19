class_name MainMenu
extends Control

## MainMenu: Title screen controller for Lanka Shadowbound.
## Keyboard and gamepad navigable. Consumes/emits transition events.

signal start_game_requested()
signal quit_game_requested()

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	# Grab initial focus for gamepad and keyboard navigation
	start_button.grab_focus()

func _on_start_pressed() -> void:
	start_game_requested.emit()

func _on_quit_pressed() -> void:
	quit_game_requested.emit()
	get_tree().quit()
