class_name ObjectiveNotification
extends Control

## ObjectiveNotification: Top-screen animated banner for quest & mission milestones.
## Displays new objectives, chapter progression, and completion banners.
## Queues multiple rapid notifications safely. Follows docs/VISUAL_IDENTITY.md.

signal notification_started(title: String)
signal notification_finished()

@onready var banner_panel: PanelContainer = %BannerPanel
@onready var category_label: Label = %CategoryLabel
@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var icon_label: Label = %IconLabel

var notification_queue: Array[Dictionary] = []
var is_displaying: bool = false
var active_tween: Tween

const TARGET_Y: float = 16.0
const HIDDEN_Y: float = -70.0

func _ready() -> void:
	banner_panel.position.y = HIDDEN_Y
	banner_panel.modulate.a = 0.0
	hide()

## Posts a notification banner to the screen.
## category: e.g. "NEW OBJECTIVE", "OBJECTIVE COMPLETED", "CHAPTER ADVANCEMENT"
## title: Headline text
## description: Subtitle detail
## is_completion: If true, formats with Lush Jade green celebration palette
func notify(category: String, title: String, description: String = "", is_completion: bool = false) -> void:
	var item: Dictionary = {
		"category": category,
		"title": title,
		"description": description,
		"is_completion": is_completion
	}
	notification_queue.append(item)
	
	if not is_displaying:
		_process_next_notification()

func _process_next_notification() -> void:
	if notification_queue.is_empty():
		is_displaying = false
		hide()
		notification_finished.emit()
		return
		
	is_displaying = true
	var item: Dictionary = notification_queue.pop_front()
	show()
	
	category_label.text = item["category"]
	title_label.text = item["title"]
	desc_label.text = item["description"]
	desc_label.visible = not item["description"].is_empty()
	
	if item["is_completion"]:
		icon_label.text = "✔"
		icon_label.modulate = UIConstants.COLOR_LUSH_JADE
		category_label.modulate = UIConstants.COLOR_LUSH_JADE
		title_label.modulate = UIConstants.COLOR_DIVINE_GOLD
	else:
		icon_label.text = "✦"
		icon_label.modulate = UIConstants.COLOR_DIVINE_GOLD
		category_label.modulate = UIConstants.COLOR_CELESTIAL_CYAN
		title_label.modulate = UIConstants.COLOR_IVORY_LIGHT

	notification_started.emit(item["title"])
	_animate_banner()

func _animate_banner() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	banner_panel.position.y = HIDDEN_Y
	banner_panel.modulate.a = 0.0
	
	active_tween = create_tween()
	# Slide in and fade
	active_tween.set_parallel(true)
	active_tween.tween_property(banner_panel, "position:y", TARGET_Y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(banner_panel, "modulate:a", 1.0, 0.25)
	active_tween.set_parallel(false)
	
	# Display hold duration
	active_tween.tween_interval(UIConstants.NOTIFICATION_DISPLAY_DURATION)
	
	# Slide out and fade
	active_tween.set_parallel(true)
	active_tween.tween_property(banner_panel, "position:y", HIDDEN_Y, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	active_tween.tween_property(banner_panel, "modulate:a", 0.0, 0.25)
	active_tween.set_parallel(false)
	
	# Next queued notification
	active_tween.tween_callback(_process_next_notification)
