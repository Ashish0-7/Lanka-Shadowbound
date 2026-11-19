class_name TutorialHint
extends Control

## TutorialHint: Non-intrusive contextual hint popup for player onboarding.
## Teaches core traversal, shrink mechanics, stealth, and combat inputs.
## Follows docs/VISUAL_IDENTITY.md specifications.

signal hint_shown(title: String)
signal hint_dismissed()

@onready var hint_panel: PanelContainer = %HintPanel
@onready var title_badge: Label = %TitleBadge
@onready var key_badge: Label = %KeyBadge
@onready var desc_label: Label = %DescLabel
@onready var dismiss_label: Label = %DismissLabel

var active_tween: Tween
var auto_dismiss_timer: SceneTreeTimer
var is_active: bool = false

# Preset tutorial hints for Lanka Shadowbound
const HINT_PRESETS: Dictionary = {
	"leap": {
		"title": "TRAVERSAL",
		"key": "[SPACE]",
		"desc": "Leap across ocean surges and chasms. Hold longer for greater leap height."
	},
	"shrink": {
		"title": "DIVINE SIDDHI",
		"key": "[SHIFT]",
		"desc": "Shrink your form to slip through Surasa's fangs and narrow crevices."
	},
	"stealth": {
		"title": "SHADOW INFILTRATION",
		"key": "[C / CROUCH]",
		"desc": "Crouch in palace shadows. Keep clear of the Rakshasa guards' lantern light."
	},
	"combat": {
		"title": "STRIKE",
		"key": "[J / ATTACK]",
		"desc": "Strike with Hanuman's mace. Leave the glowing ring before it lands, then hit back."
	}
}

func _ready() -> void:
	hint_panel.modulate.a = 0.0
	hint_panel.position.y = 20.0
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("ui_accept"):
		hide_hint()
		get_viewport().set_input_as_handled()

## Displays a custom tutorial hint popup.
func show_hint(title: String, input_key: String, description: String, auto_dismiss_seconds: float = 6.0) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	title_badge.text = title
	key_badge.text = input_key
	desc_label.text = description
	is_active = true
	show()
	
	hint_panel.modulate.a = 0.0
	hint_panel.position.y = 20.0
	
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(hint_panel, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(hint_panel, "modulate:a", 1.0, 0.2)
	active_tween.set_parallel(false)
	
	hint_shown.emit(title)
	
	if auto_dismiss_seconds > 0.0:
		auto_dismiss_timer = get_tree().create_timer(auto_dismiss_seconds)
		auto_dismiss_timer.timeout.connect(func(): if is_active: hide_hint())

## Displays a pre-configured tutorial hint preset ("leap", "shrink", "stealth", "combat").
func show_preset(preset_key: String, auto_dismiss_seconds: float = 6.0) -> void:
	if not HINT_PRESETS.has(preset_key):
		return
	var data: Dictionary = HINT_PRESETS[preset_key]
	show_hint(data["title"], data["key"], data["desc"], auto_dismiss_seconds)

## Smoothly dismisses the tutorial hint.
func hide_hint() -> void:
	if not is_active:
		return
	is_active = false
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(hint_panel, "position:y", 20.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	active_tween.tween_property(hint_panel, "modulate:a", 0.0, 0.15)
	active_tween.set_parallel(false)
	active_tween.tween_callback(func():
		hide()
		hint_dismissed.emit()
	)
