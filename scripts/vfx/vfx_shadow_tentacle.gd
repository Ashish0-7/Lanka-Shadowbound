class_name VFXShadowTentacle
extends Node2D

## VFXShadowTentacle: Simhika's grasping shadow appendages for Level 1 encounter.
## Member 2 owns hit detection logic. This component owns ONLY the visual display.
## Presents warning pulse before activation and grabs shadow animation.

signal tentacle_fully_extended()
signal tentacle_retracted()

@export var tentacle_count: int = 3
@export var extend_duration: float = 0.4
@export var hold_duration: float = 1.2
@export var retract_duration: float = 0.25

var tentacles: Array[Line2D] = []
var active_tween: Tween
var is_extended: bool = false

# Target positions for tentacle tips (set by encounter spawner / Member 2)
var target_positions: Array[Vector2] = []

func _ready() -> void:
	_build_tentacles()

func _build_tentacles() -> void:
	for _i in range(tentacle_count):
		var line := Line2D.new()
		line.width = 4.0
		line.default_color = UIConstants.COLOR_MIDNIGHT_INDIGO
		line.texture_mode = Line2D.LINE_TEXTURE_NONE
		line.antialiased = false
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.points = [Vector2.ZERO, Vector2.ZERO]
		line.visible = false
		add_child(line)
		tentacles.append(line)

## Extends tentacles toward given world positions (warning display before hitbox activates).
func extend_toward(positions: Array[Vector2]) -> void:
	target_positions = positions
	is_extended = true
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	active_tween = create_tween().set_parallel(true)
	
	for i in range(mini(tentacle_count, positions.size())):
		var line := tentacles[i]
		line.visible = true
		line.modulate = UIConstants.COLOR_DEEP_MOSS
		line.modulate.a = 0.0
		line.points = [Vector2.ZERO, Vector2.ZERO]
		
		var t := i  # capture
		# Assign the whole points array: points[1] = ... would only edit a temporary copy.
		var grow := func(prog: float) -> void:
			tentacles[t].modulate.a = minf(prog * 2.5, 1.0)
			tentacles[t].points = PackedVector2Array([Vector2.ZERO, target_positions[t] * prog])
		active_tween.tween_method(grow, 0.0, 1.0, extend_duration)
	
	active_tween.set_parallel(false)
	active_tween.tween_interval(hold_duration)
	active_tween.tween_callback(_retract)
	active_tween.tween_callback(tentacle_fully_extended.emit)

func _retract() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween().set_parallel(true)
	for i in range(tentacles.size()):
		active_tween.tween_property(tentacles[i], "modulate:a", 0.0, retract_duration)
	active_tween.set_parallel(false)
	active_tween.tween_callback(func():
		for line in tentacles:
			line.visible = false
		is_extended = false
		tentacle_retracted.emit()
	)

## Pulsing idle shadow glow (before attack is triggered)
func play_warning_pulse() -> void:
	var tween := create_tween().set_loops(3)
	for line in tentacles:
		line.visible = true
		line.modulate = UIConstants.COLOR_VOID_BLACK
		tween.tween_property(line, "modulate:a", 0.6, 0.2)
		tween.tween_property(line, "modulate:a", 0.0, 0.2)
