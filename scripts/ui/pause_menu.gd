class_name PauseMenu
extends Control

## PauseMenu: In-game pause controller for Lanka Shadowbound.
## Runs in PROCESS_MODE_ALWAYS to listen for pause toggles while tree is paused.
## Keyboard and gamepad navigable.

signal resumed()
signal restart_level_requested()
signal quit_to_title_requested()

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if visible:
			resume()
		else:
			open_pause_menu()
		get_viewport().set_input_as_handled()

func open_pause_menu() -> void:
	get_tree().paused = true
	show()
	resume_button.grab_focus()

func resume() -> void:
	get_tree().paused = false
	hide()
	resumed.emit()

func _on_resume_pressed() -> void:
	resume()
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_select", -2.0)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	hide()
	restart_level_requested.emit()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	hide()
	quit_to_title_requested.emit()
