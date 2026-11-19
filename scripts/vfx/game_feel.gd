class_name GameFeel
extends RefCounted

## GameFeel: presentation-only screen feedback (camera shake and hit-stop).
## Gameplay owners call these at impact moments; this class never changes game state.
## Usage: GameFeel.shake(self, 4.0)   GameFeel.hitstop(self, 0.08)

## Small shake ≈ 2, normal hit ≈ 3–4, boss heavy attack ≈ 6–8 (pixels at 640×360).
static func shake(context: Node, strength: float = 3.0, duration: float = 0.2) -> void:
	if not is_instance_valid(context) or not context.is_inside_tree():
		return
	var cam := context.get_viewport().get_camera_2d()
	if cam == null:
		return
	var previous: Tween = cam.get_meta("shake_tween") if cam.has_meta("shake_tween") else null
	if previous and previous.is_valid():
		previous.kill()
	var tween := cam.create_tween()
	cam.set_meta("shake_tween", tween)
	var steps := maxi(2, int(duration / 0.03))
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * falloff
		tween.tween_property(cam, "offset", jitter.round(), 0.03)
	tween.tween_property(cam, "offset", Vector2.ZERO, 0.03)

## Briefly freezes time so a powerful hit lands with weight. Keep it short (0.04–0.12 s).
static func hitstop(context: Node, duration: float = 0.07, time_scale: float = 0.05) -> void:
	if not is_instance_valid(context) or not context.is_inside_tree():
		return
	Engine.time_scale = time_scale
	# ignore_time_scale = true, so the timer runs in real time while the game is frozen.
	await context.get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
