class_name InteractionPrompt
extends Control

## InteractionPrompt: Floating in-world prompt for interactables in Lanka Shadowbound.
## Displays keyboard/gamepad action icon and descriptive text.
## Can follow a target Node2D or remain anchored. Follows docs/VISUAL_IDENTITY.md.

signal prompt_activated()

@onready var panel: PanelContainer = %PromptPanel
@onready var key_badge: Label = %KeyBadge
@onready var action_label: Label = %ActionLabel

# World tracking
var target_node: Node2D = null
var world_offset: Vector2 = Vector2(0, -32)
var bob_time: float = 0.0
var is_active: bool = false

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if not is_active:
		return
		
	# Follow target node in screen space if provided
	if target_node and is_instance_valid(target_node):
		var screen_pos: Vector2 = target_node.get_global_transform_with_canvas().origin + world_offset
		global_position = screen_pos
		
	# Subtle 2-pixel bobbing animation for pixel art readability
	bob_time += delta * 4.0
	panel.position.y = sin(bob_time) * 2.0

## Displays the prompt with a key badge (e.g. "[E]") and description.
func show_prompt(key_text: String, description: String, follow_target: Node2D = null, offset: Vector2 = Vector2(0, -32)) -> void:
	key_badge.text = key_text
	action_label.text = description
	target_node = follow_target
	world_offset = offset
	bob_time = 0.0
	is_active = true
	show()
	
	# Small scale punch on appear
	scale = Vector2(0.8, 0.8)
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)

## Hides the prompt.
func hide_prompt() -> void:
	if not is_active:
		return
	is_active = false
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_callback(hide)
