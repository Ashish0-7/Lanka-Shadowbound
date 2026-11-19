class_name GameFeel
extends RefCounted

## GameFeel: presentation-only screen feedback (camera shake, hit-stop, cinematic focus).
## Gameplay owners call these at impact moments; this class never changes game state.
## Usage: GameFeel.shake(self, 4.0)   GameFeel.hitstop(self, 0.08)
##        await GameFeel.focus(self, boss_position, 1.4)   await GameFeel.release(self)

## Small shake ≈ 2, normal hit ≈ 3–4, boss heavy attack ≈ 6–8 (pixels at 640×360).
## Shakes around the camera's current focus, so it never knocks a cinematic framing off.
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
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * falloff
		tween.tween_method(func(j: Vector2): cam.offset = _base(cam) + j, Vector2.ZERO, jitter.round(), 0.03)
	tween.tween_method(func(_j: Vector2): cam.offset = _base(cam), Vector2.ZERO, Vector2.ZERO, 0.03)

## Briefly freezes time so a powerful hit lands with weight. Keep it short (0.04–0.12 s).
static func hitstop(context: Node, duration: float = 0.07, time_scale: float = 0.05) -> void:
	if not is_instance_valid(context) or not context.is_inside_tree():
		return
	Engine.time_scale = time_scale
	# ignore_time_scale = true, so the timer runs in real time while the game is frozen.
	await context.get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

## Pans and zooms the active camera toward a world point (cinematic framing).
## Camera limits still apply, so framing stays inside the level.
static func focus(context: Node, world_point: Vector2, zoom: float = 1.4, seconds: float = 0.6) -> void:
	var cam := _camera(context)
	if cam == null:
		return
	cam.set_meta("focus_point", world_point)
	cam.set_meta("focus_zoom", zoom)
	await _blend_focus(cam, 0.0, 1.0, seconds)

## Returns the camera to following the player at normal zoom.
static func release(context: Node, seconds: float = 0.5) -> void:
	var cam := _camera(context)
	if cam == null:
		return
	if not cam.has_meta("focus_point"):
		cam.zoom = Vector2.ONE
		cam.set_meta("base_offset", Vector2.ZERO)
		cam.offset = Vector2.ZERO
		return
	await _blend_focus(cam, 1.0, 0.0, seconds)
	cam.remove_meta("focus_point")

static func _blend_focus(cam: Camera2D, from_weight: float, to_weight: float, seconds: float) -> void:
	var tween := cam.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(func(w: float): _apply_focus(cam, w), from_weight, to_weight, maxf(seconds, 0.01))
	await tween.finished

## Godot applies Camera2D.offset AFTER the limits clamp, so limits alone cannot stop a focus
## from showing the void outside the level. Recompute a clamped framing at every zoom step.
static func _apply_focus(cam: Camera2D, weight: float) -> void:
	if not is_instance_valid(cam):
		return
	var point: Vector2 = cam.get_meta("focus_point", Vector2.ZERO)
	var zoom: float = lerpf(1.0, cam.get_meta("focus_zoom", 1.0), weight)
	cam.zoom = Vector2.ONE * zoom
	var half := cam.get_viewport_rect().size * 0.5 / zoom
	var lo := Vector2(cam.limit_left, cam.limit_top) + half
	var hi := Vector2(cam.limit_right, cam.limit_bottom) - half
	var anchor := cam.get_parent() as Node2D
	var follow: Vector2 = (anchor.global_position if anchor else cam.global_position).clamp(lo, hi)
	var framed := (follow + (point.clamp(lo, hi) - follow) * weight) - follow
	cam.set_meta("base_offset", framed)
	cam.offset = framed

static func _base(cam: Camera2D) -> Vector2:
	return cam.get_meta("base_offset", Vector2.ZERO)

static func _camera(context: Node) -> Camera2D:
	if not is_instance_valid(context) or not context.is_inside_tree():
		return null
	return context.get_viewport().get_camera_2d()
