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
	start_button.mouse_entered.connect(_on_button_hover)
	quit_button.mouse_entered.connect(_on_button_hover)
	# Grab initial focus for gamepad and keyboard navigation
	start_button.grab_focus()

func _on_button_hover() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_select", -6.0, 1.08)

func _on_start_pressed() -> void:
	start_game_requested.emit()
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_start", -2.0)
		get_node("/root/AudioManager").play_music()

func _on_quit_pressed() -> void:
	quit_game_requested.emit()
	get_tree().quit()
