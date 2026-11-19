class_name LevelTransition
extends CanvasLayer

## LevelTransition: Presentation controller for screen fades and chapter title cards.
## Runs on high CanvasLayer (100) to overlay all gameplay and HUD elements.
## Provides non-intrusive presentation hooks for Member 1's scene transition system.

signal fade_out_completed()
signal fade_in_completed()
signal title_card_completed()

@onready var curtain: ColorRect = %Curtain
@onready var title_card_container: CenterContainer = %TitleCardContainer
@onready var chapter_label: Label = %ChapterLabel
@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel

var active_tween: Tween
var is_transitioning: bool = false

# Canonical five-level metadata for Lanka Shadowbound
const LEVEL_METADATA: Dictionary = {
	1: {
		"chapter": "CHAPTER I",
		"title": "CROSSING THE OCEAN",
		"subtitle": "The Leap across the Raging Sea • Trials of Surasa & Simhika"
	},
	2: {
		"chapter": "CHAPTER II",
		"title": "THE GATES OF LANKA",
		"subtitle": "Threshold of the Golden Fortress • The Guardian Lankini"
	},
	3: {
		"chapter": "CHAPTER III",
		"title": "LANKA AT NIGHT",
		"subtitle": "Infiltration of the Royal Chambers • The Mandodari Dilemma"
	},
	4: {
		"chapter": "CHAPTER IV",
		"title": "ASHOKA VATIKA",
		"subtitle": "The Sacred Grove of Solace • Rama's Signet Ring"
	},
	5: {
		"chapter": "CHAPTER V",
		"title": "THE ESCAPE",
		"subtitle": "Flames Across the Rooftops • Daring Flight to Safety"
	}
}

func _ready() -> void:
	layer = 100
	curtain.color = UIConstants.COLOR_VOID_BLACK
	curtain.modulate.a = 0.0
	title_card_container.modulate.a = 0.0
	curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Fades screen to black. Emits fade_out_completed when screen is fully black.
func fade_out(duration: float = UIConstants.FADE_TRANSITION_DURATION) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	is_transitioning = true
	curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	
	active_tween = create_tween()
	active_tween.tween_property(curtain, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_tween.tween_callback(func():
		fade_out_completed.emit()
	)

## Fades screen from black back to clear gameplay. Emits fade_in_completed.
func fade_in(duration: float = UIConstants.FADE_TRANSITION_DURATION) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.tween_property(curtain, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	active_tween.tween_callback(func():
		curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		is_transitioning = false
		fade_in_completed.emit()
	)

## Plays a full chapter title card presentation sequence.
func play_title_card(chapter_text: String, title_text: String, subtitle_text: String = "", hold_seconds: float = 2.0) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	is_transitioning = true
	curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	chapter_label.text = chapter_text
	title_label.text = title_text
	subtitle_label.text = subtitle_text
	subtitle_label.visible = not subtitle_text.is_empty()
	
	title_card_container.modulate.a = 0.0
	
	active_tween = create_tween()
	# Step 1: Fade to black
	active_tween.tween_property(curtain, "modulate:a", 1.0, 0.4)
	# Step 2: Fade in Title Card text
	active_tween.tween_property(title_card_container, "modulate:a", 1.0, 0.5)
	# Step 3: Hold on screen
	active_tween.tween_interval(hold_seconds)
	# Step 4: Fade out Title Card text
	active_tween.tween_property(title_card_container, "modulate:a", 0.0, 0.4)
	# Step 5: Fade curtain to transparent gameplay
	active_tween.tween_property(curtain, "modulate:a", 0.0, 0.4)
	# Step 6: Conclude
	active_tween.tween_callback(func():
		curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		is_transitioning = false
		title_card_completed.emit()
	)

## Convenient shortcut to play one of the 5 canonical level title cards (1 to 5).
func play_level_title_card(level_number: int, hold_seconds: float = 2.0) -> void:
	if not LEVEL_METADATA.has(level_number):
		return
	var meta: Dictionary = LEVEL_METADATA[level_number]
	play_title_card(meta["chapter"], meta["title"], meta["subtitle"], hold_seconds)
