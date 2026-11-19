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
	
	# Attempt automatic binding to EventBus autoload if present
	_bind_to_event_bus()

func _bind_to_event_bus() -> void:
	if not has_node("/root/EventBus"):
		return
		
	var bus: Node = get_node("/root/EventBus")
	
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

# ==============================================================================
# STATE CONSUMER APIS (Called by EventBus or Mock Harness)
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
