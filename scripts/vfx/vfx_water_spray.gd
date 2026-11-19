class_name VFXWaterSpray
extends CPUParticles2D

## VFXWaterSpray: Ocean water impact spray for Level 1 (Crossing the Ocean).
## Attach to ocean platforms or Hanuman's feet collision trigger.
## Palette: Seafoam Teal, Celestial Cyan, Midnight Indigo.

func _ready() -> void:
	_configure_particles()

func _configure_particles() -> void:
	# Emission settings
	amount = 32
	lifetime = 0.6
	one_shot = true
	explosiveness = 0.9
	preprocess = 0.0
	emitting = false
	
	# Shape: horizontal line spray at water surface
	emission_shape = CPUParticles2D.EMISSION_SHAPE_LINE
	emission_rect_extents = Vector2(8.0, 1.0)
	
	# Direction: upward and outward spray
	direction = Vector2(0, -1)
	spread = 60.0
	gravity = Vector2(0, 200)
	
	# Velocity
	initial_velocity_min = 60.0
	initial_velocity_max = 120.0
	
	# Scale
	scale_amount_min = 1.0
	scale_amount_max = 2.5
	scale_amount_curve = null
	
	# Color gradient: Cyan → Teal → Transparent
	color = UIConstants.COLOR_SEAFOAM_TEAL
	
	# Hue and randomization for natural look
	hue_variation_min = -0.04
	hue_variation_max = 0.04

## Triggers a one-shot water impact spray at this node's position.
func play() -> void:
	restart()
	emitting = true
