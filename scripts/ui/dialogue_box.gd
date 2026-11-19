class_name DialogueBox
extends Control

## DialogueBox: Narrative conversation box for Lanka Shadowbound.
## Features speaker portrait, gold nameplate, typewriter text reveal, and advance prompt.
## Supports fast-forward on press, auto-advance, and audio blip dispatch.

signal line_started(line_index: int)
signal line_finished(line_index: int)
signal dialogue_completed()

@onready var portrait_rect: TextureRect = %PortraitRect
@onready var speaker_name_label: Label = %SpeakerNameLabel
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var advance_prompt: Label = %AdvancePrompt
@onready var dialogue_panel: PanelContainer = %DialoguePanel

# Dialogue playback state
var current_sequence: Array[Dictionary] = []
var current_line_index: int = 0
var is_active: bool = false
var is_typing: bool = false
var char_timer: float = 0.0
var total_chars: int = 0
var pulse_tween: Tween

func _ready() -> void:
	hide()
	advance_prompt.visible = false

func _process(delta: float) -> void:
	if not is_typing:
		return
		
	char_timer += delta
	if char_timer >= UIConstants.DIALOGUE_CHAR_INTERVAL:
		char_timer = 0.0
		dialogue_text.visible_characters += 1
		if dialogue_text.visible_characters >= total_chars:
			_finish_typing()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if is_typing:
			_instant_reveal()
		else:
			advance_line()
		get_viewport().set_input_as_handled()

## Starts displaying a sequence of dialogue lines.
## sequence: Array of Dictionaries with {speaker_name, portrait_path, text, [blip_sound], [auto_advance_time]}
func start_dialogue(sequence: Array[Dictionary]) -> void:
	if sequence.is_empty():
		return
	current_sequence = sequence
	current_line_index = 0
	is_active = true
	show()
	_display_current_line()

func _display_current_line() -> void:
	if current_line_index >= current_sequence.size():
		_finish_dialogue()
		return

	var line: Dictionary = current_sequence[current_line_index]
	speaker_name_label.text = line.get("speaker_name", "???")
	
	# Load and set portrait texture
	var portrait_path: String = line.get("portrait_path", "")
	if not portrait_path.is_empty() and ResourceLoader.exists(portrait_path):
		portrait_rect.texture = load(portrait_path)
		portrait_rect.visible = true
	else:
		portrait_rect.visible = false

	# Setup typewriter effect
	var full_text: String = line.get("text", "")
	dialogue_text.text = full_text
	total_chars = full_text.length()
	dialogue_text.visible_characters = 0
	char_timer = 0.0
	is_typing = true
	
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	advance_prompt.visible = false
	
	line_started.emit(current_line_index)

func _finish_typing() -> void:
	is_typing = false
	dialogue_text.visible_characters = total_chars
	_start_advance_pulse()
	line_finished.emit(current_line_index)
	
	# Handle auto-advance if configured
	var auto_time: float = current_sequence[current_line_index].get("auto_advance_time", 0.0)
	if auto_time > 0.0:
		var auto_timer: SceneTreeTimer = get_tree().create_timer(auto_time)
		auto_timer.timeout.connect(func(): if is_active and not is_typing: advance_line())

func _instant_reveal() -> void:
	_finish_typing()

func advance_line() -> void:
	current_line_index += 1
	if current_line_index < current_sequence.size():
		_display_current_line()
	else:
		_finish_dialogue()

func _start_advance_pulse() -> void:
	advance_prompt.visible = true
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(advance_prompt, "modulate:a", 0.3, 0.4)
	pulse_tween.tween_property(advance_prompt, "modulate:a", 1.0, 0.4)

func _finish_dialogue() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	is_active = false
	is_typing = false
	hide()
	dialogue_completed.emit()

# ==============================================================================
# BUILT-IN NARRATIVE SEQUENCES (Mandodari & Sita)
# ==============================================================================

## Level 3: Lanka at Night - Hanuman slips into Ravana's palace chambers.
func play_mandodari_misunderstanding_scene() -> void:
	var sequence: Array[Dictionary] = [
		{
			"speaker_name": "Hanuman",
			"portrait_path": "res://assets/ui/portraits/portrait_hanuman.png",
			"text": "Through the silent gilded corridors of the ten-headed king... could that be Her?",
			"blip_sound": "hero"
		},
		{
			"speaker_name": "Mandodari (Sleeping)",
			"portrait_path": "res://assets/ui/portraits/portrait_mandodari.png",
			"text": "[Adorned in celestial gems, sleeping upon ivory cushions with queenly radiance...]",
			"blip_sound": "female_melodic"
		},
		{
			"speaker_name": "Hanuman",
			"portrait_path": "res://assets/ui/portraits/portrait_hanuman.png",
			"text": "My heart leaped—is this Mother Sita? Such celestial grace, such unblemished splendour!",
			"blip_sound": "hero"
		},
		{
			"speaker_name": "Hanuman",
			"portrait_path": "res://assets/ui/portraits/portrait_hanuman.png",
			"text": "No... Sita Devi would never sleep so peacefully in the den of Ravana. Her heart belongs solely to Rama. This must be Mandodari, queen of Lanka. I must search on.",
			"blip_sound": "hero"
		}
	]
	start_dialogue(sequence)

## Level 4: Ashoka Vatika - Meeting Mother Sita and presenting Rama's signet ring.
func play_sita_ring_handover_scene() -> void:
	var sequence: Array[Dictionary] = [
		{
			"speaker_name": "Hanuman",
			"portrait_path": "res://assets/ui/portraits/portrait_hanuman.png",
			"text": "Mother Sita! Do not fear. I am Hanuman, the humble messenger of Prince Rama.",
			"blip_sound": "hero"
		},
		{
			"speaker_name": "Sita",
			"portrait_path": "res://assets/ui/portraits/portrait_sita.png",
			"text": "A vanara in this guarded grove? Are you an illusion conjured by Ravana to torment my spirit?",
			"blip_sound": "female_melodic"
		},
		{
			"speaker_name": "Hanuman",
			"portrait_path": "res://assets/ui/portraits/portrait_hanuman.png",
			"text": "Behold, Mother! I bring Lord Rama's signet ring, inscribed with His holy name, given to me as sacred proof.",
			"blip_sound": "hero"
		},
		{
			"speaker_name": "Sita",
			"portrait_path": "res://assets/ui/portraits/portrait_sita.png",
			"text": "[Tears fall upon the golden ring] Rama's ring! It is truly His! My lord has not forgotten me... grief departs as dawn breaks upon my despair.",
			"blip_sound": "reverent"
		},
		{
			"speaker_name": "Hanuman",
			"portrait_path": "res://assets/ui/portraits/portrait_hanuman.png",
			"text": "Rama's army will soon bridge the ocean, Mother. Lanka's walls will crumble. Take courage!",
			"blip_sound": "hero"
		}
	]
	start_dialogue(sequence)
