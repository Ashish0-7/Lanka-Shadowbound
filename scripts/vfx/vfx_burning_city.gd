class_name VFXBurningCity
extends Node2D

## VFXBurningCity: Composite burning Lanka effect for Level 5 (The Escape).
## Layers multiple fire columns, ember rains, and a heat-distortion-tinted sky overlay.
## Owned entirely by Member 3 — purely cosmetic, no damage/collision.

signal inferno_started()
signal inferno_stopped()

@onready var sky_tint: ColorRect = $SkyTint
@onready var ember_rain: CPUParticles2D = $EmberRain
@onready var fire_columns: Node2D = $FireColumns

var is_burning: bool = false
var sky_tween: Tween

func _ready() -> void:
	_configure_ember_rain()
	_configure_sky_tint()
	sky_tint.visible = false
	ember_rain.emitting = false

func _configure_sky_tint() -> void:
	sky_tint.color = UIConstants.COLOR_SURYA_ORANGE
	sky_tint.color.a = 0.0

func _configure_ember_rain() -> void:
	ember_rain.amount = 80
	ember_rain.lifetime = 2.0
	ember_rain.direction = Vector2(0.3, 1.0)
	ember_rain.spread = 15.0
	ember_rain.gravity = Vector2(10, 60)
	ember_rain.initial_velocity_min = 60.0
	ember_rain.initial_velocity_max = 160.0
	ember_rain.scale_amount_min = 1.0
	ember_rain.scale_amount_max = 3.0
	ember_rain.color = UIConstants.COLOR_GOLDEN_EMBER
	ember_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ember_rain.emission_rect_extents = Vector2(320.0, 2.0)

## Starts the burning city composite effect. Intensity 0.0 to 1.0.
func start_inferno(intensity: float = 1.0) -> void:
	is_burning = true
	sky_tint.visible = true
	ember_rain.emitting = true
	ember_rain.amount = int(clampf(intensity * 80.0, 20.0, 80.0))
	
	if sky_tween and sky_tween.is_valid():
		sky_tween.kill()
	sky_tween = create_tween()
	sky_tween.tween_property(sky_tint, "color:a", clampf(intensity * 0.35, 0.05, 0.35), 2.0)
	
	# Animate fire columns
	for child in fire_columns.get_children():
		if child.has_method("set_mode"):
			var mode = VFXFire.FireMode.LARGE_BLAZE if intensity > 0.5 else VFXFire.FireMode.SMALL_TORCH
			child.set_mode(mode)
		child.emitting = true
	
	inferno_started.emit()

## Douses the inferno (for escape completion sequence).
func stop_inferno() -> void:
	is_burning = false
	ember_rain.emitting = false
	
	if sky_tween and sky_tween.is_valid():
		sky_tween.kill()
	sky_tween = create_tween()
	sky_tween.tween_property(sky_tint, "color:a", 0.0, 1.5)
	sky_tween.tween_callback(func(): sky_tint.visible = false)
	
	for child in fire_columns.get_children():
		child.emitting = false
	
	inferno_stopped.emit()
