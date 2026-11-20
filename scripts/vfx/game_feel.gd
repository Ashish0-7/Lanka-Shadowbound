class_name GameFeel
extends RefCounted

## GameFeel: presentation-only screen feedback (camera shake, hit-stop, cinematic focus).
## Gameplay owners call these at impact moments; this class never changes game state.
## It drives the CameraRig through metadata, so shake and focus never fight the follow camera.
## Usage: GameFeel.shake(self, 4.0)   GameFeel.hitstop(self, 0.08)
##        await GameFeel.focus(self, boss_position, 1.4)   await GameFeel.release(self)

## Small shake ≈ 2, normal hit ≈ 3–4, boss heavy attack ≈ 6–8 (pixels at 640×360).
static func shake(context: Node, strength: float = 3.0, duration: float = 0.2) -> void:
	var cam := _camera(context)
	if cam == null:
		return
	var previous: Tween = cam.get_meta("shake_tween") if cam.has_meta("shake_tween") else null
	if previous and previous.is_valid():
		previous.kill()
	var tween := cam.create_tween()
	cam.set_meta("shake_tween", tween)
	var steps := maxi(2, int(duration / 0.03))
	var apply := func(j: Vector2) -> void: cam.set_meta("shake_offset", j)
	var last := Vector2.ZERO
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var jitter := (Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * falloff).round()
		tween.tween_method(apply, last, jitter, 0.03)
		last = jitter
	tween.tween_method(apply, last, Vector2.ZERO, 0.03)

## Briefly freezes time so a powerful hit lands with weight. Keep it short (0.04–0.12 s).
static func hitstop(context: Node, duration: float = 0.07, time_scale: float = 0.05) -> void:
	if not is_instance_valid(context) or not context.is_inside_tree():
		return
	Engine.time_scale = time_scale
	# ignore_time_scale = true, so the timer runs in real time while the game is frozen.
	await context.get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

## Pans and zooms the camera toward a world point (cinematic framing). The rig keeps the
## framing inside the level, so a focus never shows the void past the map's edge.
static func focus(context: Node, world_point: Vector2, zoom: float = 1.4, seconds: float = 0.6) -> void:
	var cam := _camera(context)
	if cam == null:
		return
	cam.set_meta("focus_point", world_point)
	cam.set_meta("focus_zoom", zoom)
	await _blend(cam, 1.0, seconds)

## Returns the camera to following the player at normal zoom.
static func release(context: Node, seconds: float = 0.5) -> void:
	var cam := _camera(context)
	if cam == null:
		return
	await _blend(cam, 0.0, seconds)

static func _blend(cam: Camera2D, to_weight: float, seconds: float) -> void:
	var tween := cam.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var from: float = cam.get_meta("focus_weight", 0.0)
	tween.tween_method(func(w: float): cam.set_meta("focus_weight", w), from, to_weight, maxf(seconds, 0.01))
	await tween.finished

static func _camera(context: Node) -> Camera2D:
	if not is_instance_valid(context) or not context.is_inside_tree():
		return null
	return context.get_viewport().get_camera_2d()
