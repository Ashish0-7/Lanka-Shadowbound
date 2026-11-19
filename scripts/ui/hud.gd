class_name HUD
extends Control

## HUD: In-game Head-Up Display for Lanka Shadowbound.
## Strictly CONSUMES gameplay state. Never authoritative over health or abilities.
## Follows docs/VISUAL_IDENTITY.md (Lanka 24 palette, high-contrast, non-color-reliant).

# UI Elements
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var ability_badge: PanelContainer = %AbilityBadge
@onready var ability_status_label: Label = %AbilityStatusLabel
@onready var ability_timer_bar: ProgressBar = %AbilityTimerBar
@onready var ability_key_hint: Label = %AbilityKeyHint
@onready var objective_panel: PanelContainer = %ObjectivePanel
@onready var objective_label: Label = %ObjectiveLabel
@onready var objective_icon: Label = %ObjectiveIcon
@onready var stealth_panel: PanelContainer = %StealthPanel
@onready var stealth_label: Label = %StealthLabel
@onready var stealth_bar: ProgressBar = %StealthBar

# Mock/Stub State toggle (for testing without backend systems)
@export var enable_mock_mode: bool = false

func _ready() -> void:
	# Initialize default visual display
	set_health(100, 100)
	set_shrink_ability(false, 0.0, 5.0, 0.0, 3.0)
	set_objective("Reach the shores of Lanka across the great ocean.", false)
	set_stealth_alert(0.0, false)
	
	# Bind only to the approved display-facing autoload if it is present.
	_bind_to_game_events()

func _bind_to_game_events() -> void:
	if not has_node("/root/GameEvents"):
		return
		
	var bus: Node = get_node("/root/GameEvents")
	
	# Health contracts (Owned by Member 2 - Combat/Player)
	if bus.has_signal("player_health_changed"):
		bus.connect("player_health_changed", Callable(self, "set_health"))
	if bus.has_signal("player_died"):
		bus.connect("player_died", Callable(self, "_on_player_died"))
		
	# Ability contracts (Owned by Member 2 - Abilities)
	if bus.has_signal("shrink_ability_updated"):
		bus.connect("shrink_ability_updated", Callable(self, "set_shrink_ability"))
		
	# Objective contracts (Owned by Member 1 / Member 4)
	if bus.has_signal("objective_updated"):
		bus.connect("objective_updated", Callable(self, "set_objective"))
		
	# Stealth alert contracts (Owned by Member 4 - Stealth/AI)
	if bus.has_signal("stealth_alert_level_changed"):
		bus.connect("stealth_alert_level_changed", Callable(self, "set_stealth_alert"))

	if bus.has_signal("devotion_changed"):
		_build_devotion_bar()
		bus.connect("devotion_changed", Callable(self, "set_devotion"))

	# Encounter call-outs ("Surasa's jaws open — shrink!", "Lankini staggered!")
	if bus.has_signal("encounter_feedback"):
		_build_feedback_toast()
		bus.connect("encounter_feedback", Callable(self, "show_feedback"))

# ==============================================================================
# DEVOTION METER  (fills from kills and boss hits; full → [Q] Jai Shri Ram)
# ==============================================================================

var _devotion_panel: PanelContainer
var _devotion_bar: ProgressBar
var _devotion_label: Label
var _devotion_full := false

func _build_devotion_bar() -> void:
	_devotion_panel = PanelContainer.new()
	_devotion_panel.name = "DevotionPanel"
	_devotion_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_devotion_panel.position = Vector2(10, 114)
	_devotion_panel.custom_minimum_size = Vector2(166, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.12, 0.82)
	style.border_color = UIConstants.COLOR_DIVINE_GOLD
	style.set_border_width_all(1)
	style.set_content_margin_all(4)
	_devotion_panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	_devotion_label = Label.new()
	_devotion_label.text = "DEVOTION"
	_devotion_label.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_SMALL)
	_devotion_label.add_theme_color_override("font_color", UIConstants.COLOR_GOLDEN_EMBER)
	_devotion_bar = ProgressBar.new()
	_devotion_bar.show_percentage = false
	_devotion_bar.custom_minimum_size = Vector2(156, 5)
	var bg := StyleBoxFlat.new()
	bg.bg_color = UIConstants.COLOR_MIDNIGHT_INDIGO
	var fill := StyleBoxFlat.new()
	fill.bg_color = UIConstants.COLOR_GOLDEN_EMBER
	_devotion_bar.add_theme_stylebox_override("background", bg)
	_devotion_bar.add_theme_stylebox_override("fill", fill)
	box.add_child(_devotion_label)
	box.add_child(_devotion_bar)
	_devotion_panel.add_child(box)
	add_child(_devotion_panel)
	set_devotion(0.0, 100.0)

func set_devotion(value: float, max_value: float) -> void:
	if _devotion_bar == null:
		return
	_devotion_bar.max_value = max_value
	_devotion_bar.value = value
	_devotion_full = value >= max_value
	_devotion_label.text = "[Q]  JAI SHRI RAM!" if _devotion_full else "DEVOTION"

func _process(_delta: float) -> void:
	if _devotion_panel and _devotion_full:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 8.0)
		_devotion_panel.modulate = Color.WHITE.lerp(Color(1.4, 1.25, 0.8), pulse)
		_devotion_label.add_theme_color_override("font_color", UIConstants.COLOR_DIVINE_GOLD.lerp(Color.WHITE, pulse))
	elif _devotion_panel:
		_devotion_panel.modulate = Color.WHITE
		_devotion_label.add_theme_color_override("font_color", UIConstants.COLOR_GOLDEN_EMBER)

# ==============================================================================
# ENCOUNTER FEEDBACK TOAST
# ==============================================================================

var _feedback_panel: PanelContainer
var _feedback_label: Label
var _feedback_tween: Tween

func _build_feedback_toast() -> void:
	_feedback_panel = PanelContainer.new()
	_feedback_panel.name = "FeedbackToast"
	_feedback_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.12, 0.82)
	style.border_color = UIConstants.COLOR_DIVINE_GOLD
	style.set_border_width_all(1)
	style.set_content_margin_all(5)
	style.content_margin_left = 10
	style.content_margin_right = 10
	_feedback_panel.add_theme_stylebox_override("panel", style)
	_feedback_label = Label.new()
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.add_theme_font_size_override("font_size", 10)
	_feedback_label.add_theme_color_override("font_color", UIConstants.COLOR_IVORY_LIGHT)
	_feedback_panel.add_child(_feedback_label)
	add_child(_feedback_panel)
	_feedback_panel.modulate.a = 0.0
	_feedback_panel.visible = false

## Shows a short centred call-out just above the tutorial strip, replacing any current one.
func show_feedback(text: String) -> void:
	if _feedback_panel == null:
		return
	_feedback_label.text = text
	_feedback_panel.visible = true
	_feedback_panel.reset_size()
	var panel_size := _feedback_panel.get_combined_minimum_size()
	_feedback_panel.position = Vector2((size.x - panel_size.x) * 0.5, 258.0)
	if _feedback_tween and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(_feedback_panel, "modulate:a", 1.0, 0.12)
	_feedback_tween.tween_interval(2.2)
	_feedback_tween.tween_property(_feedback_panel, "modulate:a", 0.0, 0.4)
	_feedback_tween.tween_callback(func(): _feedback_panel.visible = false)

# ==============================================================================
# STATE CONSUMER APIS (Called by GameEvents or Mock Harness)
# ==============================================================================

## Updates the health bar and text readout.
## current: Current player HP
## max_hp: Maximum player HP
func set_health(current: int, max_hp: int) -> void:
	var clamped_hp: int = maxi(0, current)
	var safe_max: int = maxi(1, max_hp)
	health_bar.max_value = safe_max
	health_bar.value = clamped_hp
	health_label.text = "HP: %d / %d" % [clamped_hp, safe_max]
	
	# Low health visual warning (non-color-reliant: adds warning marker)
	var hp_ratio: float = float(clamped_hp) / float(safe_max)
	if hp_ratio <= 0.25 and clamped_hp > 0:
		health_label.text = "⚠ HP: %d / %d" % [clamped_hp, safe_max]
		health_bar.modulate = Color(1.0, 0.7, 0.7, 1.0)
	else:
		health_bar.modulate = Color.WHITE

func _on_player_died() -> void:
	health_bar.value = 0
	health_label.text = "DEFEATED"
	health_bar.modulate = Color(0.6, 0.6, 0.6, 1.0)

## Updates the shrink ability indicator and cooldown/active timer.
## is_active: True when Hanuman is currently in shrunken form
## cooldown_remaining: Seconds remaining before ability can be used again
## cooldown_max: Total duration of cooldown
## duration_remaining: Seconds remaining in shrunken form
## duration_max: Total duration of shrunken form
func set_shrink_ability(is_active: bool, cooldown_remaining: float, cooldown_max: float, duration_remaining: float = 0.0, duration_max: float = 3.0) -> void:
	if is_active:
		ability_status_label.text = "ACTIVE (SHRUNK)"
		ability_status_label.modulate = UIConstants.COLOR_SURYA_ORANGE
		ability_timer_bar.visible = true
		ability_timer_bar.max_value = duration_max
		ability_timer_bar.value = duration_remaining
		ability_key_hint.text = "%.1fs" % duration_remaining
	elif cooldown_remaining > 0.0:
		ability_status_label.text = "RECHARGING"
		ability_status_label.modulate = UIConstants.COLOR_GRANITE_HIGHLIGHT
		ability_timer_bar.visible = true
		ability_timer_bar.max_value = cooldown_max
		ability_timer_bar.value = cooldown_max - cooldown_remaining
		ability_key_hint.text = "%.1fs" % cooldown_remaining
	else:
		ability_status_label.text = "SHRINK READY"
		ability_status_label.modulate = UIConstants.COLOR_DIVINE_GOLD
		ability_timer_bar.visible = false
		ability_key_hint.text = "[SHIFT]"

## Updates the objective panel.
## text: Descriptive objective instruction
## is_complete: When true, displays completion checkmark
func set_objective(text: String, is_complete: bool = false) -> void:
	objective_label.text = text
	if is_complete:
		objective_icon.text = "[✔]"
		objective_icon.modulate = UIConstants.COLOR_LUSH_JADE
		objective_label.modulate = UIConstants.COLOR_LUSH_JADE
	else:
		objective_icon.text = "[•]"
		objective_icon.modulate = UIConstants.COLOR_DIVINE_GOLD
		objective_label.modulate = UIConstants.COLOR_PARCHMENT_CREAM

## Updates stealth alert meter (Level 3 Lanka at Night).
## alert_level: Normalized float 0.0 (Hidden) to 1.0 (Alerted)
## is_detected: True if enemy has initiated combat / caught Hanuman
func set_stealth_alert(alert_level: float, is_detected: bool = false) -> void:
	stealth_bar.value = clampf(alert_level, 0.0, 1.0)
	if is_detected:
		stealth_panel.visible = true
		stealth_label.text = "DETECTED!"
		stealth_label.modulate = UIConstants.COLOR_RUBY_BLOOD
	elif alert_level > 0.05:
		stealth_panel.visible = true
		if alert_level > 0.65:
			stealth_label.text = "SUSPICIOUS (HIGH)"
			stealth_label.modulate = UIConstants.COLOR_GOLDEN_EMBER
		else:
			stealth_label.text = "UNNOTICED"
			stealth_label.modulate = UIConstants.COLOR_CELESTIAL_CYAN
	else:
		# Auto-hide stealth gauge when completely hidden in non-stealth zones
		stealth_panel.visible = false
