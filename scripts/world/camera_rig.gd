class_name CameraRig
extends Camera2D

## CameraRig: Hanuman's camera. Smooth follow with look-ahead in the direction of travel,
## blended with cinematic focus (GameFeel.focus/release) and shake (GameFeel.shake), and
## always clamped so the view never shows anything outside the level.
## GameFeel talks to it only through metadata: focus_point, focus_zoom, focus_weight, shake_offset.

const LOOK_AHEAD := 40.0
const FOLLOW_SPEED := 6.0

var world := Rect2(0, 0, 640, 360)
var _look := Vector2.ZERO
var _pos := Vector2.ZERO

func _ready() -> void:
	# Detached from the player's transform: the rig decides where to look every physics frame.
	top_level = true
	position_smoothing_enabled = false
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	snap()

## Sets the level bounds and jumps straight to the player (no long scroll across the map).
func set_world(rect: Rect2) -> void:
	world = rect
	limit_left = int(rect.position.x)
	limit_top = int(rect.position.y)
	limit_right = int(rect.end.x)
	limit_bottom = int(rect.end.y)
	snap()

func snap() -> void:
	_look = Vector2.ZERO
	_pos = _clamped((get_parent() as Node2D).global_position)
	global_position = _pos
	reset_smoothing()

func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	if body == null:
		return
	var velocity := body.velocity
	var look_target := velocity.normalized() * LOOK_AHEAD if velocity.length() > 10.0 else Vector2.ZERO
	_look = _look.lerp(look_target, minf(1.0, delta * 2.0))
	_pos = _pos.lerp(body.global_position + _look, 1.0 - exp(-FOLLOW_SPEED * delta))
	var weight: float = get_meta("focus_weight", 0.0)
	zoom = Vector2.ONE * lerpf(1.0, get_meta("focus_zoom", 1.0), weight)
	var framed := _pos.lerp(get_meta("focus_point", _pos), weight)
	global_position = _clamped(framed) + get_meta("shake_offset", Vector2.ZERO)
	offset = Vector2.ZERO

## Keeps the whole view inside the level. A level smaller than the view is centred.
func _clamped(point: Vector2) -> Vector2:
	var half := get_viewport_rect().size * 0.5 / zoom
	var lo := world.position + half
	var hi := world.end - half
	if lo.x > hi.x:
		lo.x = world.get_center().x
		hi.x = lo.x
	if lo.y > hi.y:
		lo.y = world.get_center().y
		hi.y = lo.y
	return point.clamp(lo, hi)
