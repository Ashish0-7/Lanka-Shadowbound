class_name VFXFire
extends CPUParticles2D

## VFXFire: Reusable fire/flame particle effect for Level 5 (The Escape — Burning Lanka).
## Also used for torches in Level 2 (Gates) and burning Shimshapa in Level 4.
## Palette: Surya Orange, Golden Ember, Divine Gold, Maruti Saffron, Void Black (smoke).

enum FireMode { SMALL_TORCH, LARGE_BLAZE, EMBER_TRAIL }

@export var fire_mode: FireMode = FireMode.SMALL_TORCH

func _ready() -> void:
	_configure_for_mode(fire_mode)

func set_mode(mode: FireMode) -> void:
	fire_mode = mode
	_configure_for_mode(mode)

func _configure_for_mode(mode: FireMode) -> void:
	match mode:
		FireMode.SMALL_TORCH:
			amount = 20
			lifetime = 0.5
			initial_velocity_min = 20.0
			initial_velocity_max = 45.0
			spread = 20.0
			scale_amount_min = 1.0
			scale_amount_max = 2.0
			color = UIConstants.COLOR_SURYA_ORANGE
			
		FireMode.LARGE_BLAZE:
			amount = 64
			lifetime = 0.9
			initial_velocity_min = 40.0
			initial_velocity_max = 100.0
			spread = 30.0
			scale_amount_min = 2.0
			scale_amount_max = 5.0
			color = UIConstants.COLOR_GOLDEN_EMBER
			
		FireMode.EMBER_TRAIL:
			amount = 48
			lifetime = 1.4
			initial_velocity_min = 20.0
			initial_velocity_max = 80.0
			spread = 60.0
			scale_amount_min = 1.0
			scale_amount_max = 3.0
			color = UIConstants.COLOR_DIVINE_GOLD
	
	# Shared fire physics
	direction = Vector2(0, -1)
	gravity = Vector2(0, -20)
	hue_variation_min = -0.06
	hue_variation_max = 0.06
	emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
	emission_rect_extents = Vector2(4.0, 2.0) if mode == FireMode.SMALL_TORCH else Vector2(16.0, 4.0)
	emitting = true
