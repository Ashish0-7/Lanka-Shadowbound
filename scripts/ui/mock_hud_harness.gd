class_name MockHUDHarness
extends Node

## MockHUDHarness: Simulates player, combat, and stealth signals for testing the HUD.
## Demonstrates HUD consumption behavior in isolation.

@onready var hud: HUD = $HUD

var current_hp: int = 100
var max_hp: int = 100
var stealth_cycle: int = 0
var objective_cycle: int = 0

var objectives: Array[String] = [
	"Reach the shores of Lanka across the great ocean.",
	"Evade Surasa by shrinking your form at the opportune instant.",
	"Defeat Simhika's shadow grasp.",
	"Objective Complete!"
]

func _ready() -> void:
	print("MockHUDHarness initialized. Use keys [1-5] to test HUD updates.")

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return
		
	match event.keycode:
		KEY_1: # Damage
			current_hp = maxi(0, current_hp - 20)
			hud.set_health(current_hp, max_hp)
		KEY_2: # Heal
			current_hp = mini(max_hp, current_hp + 20)
			hud.set_health(current_hp, max_hp)
		KEY_3: # Trigger Shrink
			_simulate_shrink_sequence()
		KEY_4: # Cycle Objective
			objective_cycle = (objective_cycle + 1) % objectives.size()
			var is_done = (objective_cycle == objectives.size() - 1)
			hud.set_objective(objectives[objective_cycle], is_done)
		KEY_5: # Cycle Stealth
			stealth_cycle = (stealth_cycle + 1) % 4
			match stealth_cycle:
				0: hud.set_stealth_alert(0.0, false)
				1: hud.set_stealth_alert(0.35, false)
				2: hud.set_stealth_alert(0.80, false)
				3: hud.set_stealth_alert(1.0, true)

func _simulate_shrink_sequence() -> void:
	# Active duration (3 seconds)
	hud.set_shrink_ability(true, 0.0, 5.0, 3.0, 3.0)
	var tween = create_tween()
	tween.tween_method(func(val: float): hud.set_shrink_ability(true, 0.0, 5.0, val, 3.0), 3.0, 0.0, 3.0)
	# Cooldown duration (5 seconds)
	tween.tween_callback(func(): hud.set_shrink_ability(false, 5.0, 5.0, 0.0, 3.0))
	tween.tween_method(func(cd: float): hud.set_shrink_ability(false, cd, 5.0, 0.0, 3.0), 5.0, 0.0, 5.0)
	# Ready
	tween.tween_callback(func(): hud.set_shrink_ability(false, 0.0, 5.0, 0.0, 3.0))
