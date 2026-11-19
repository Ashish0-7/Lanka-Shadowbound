class_name BossSprite
extends Sprite2D

## Boss animation + presentation. Owns visuals only; encounter logic decides WHEN to call:
##   windup(seconds, tint)            – glowing, trembling anticipation before an attack
##   play_segment(state, a, b, secs)  – play frames a..b of a row (e.g. anticipation vs. strike)
##   lunge(direction, px)             – quick body thrust for the strike/impact frame
##   recoil(away_from)                – hurt reaction: flash, knockback, hurt frames

@export var boss_name: String = "lankini"
@export var frames_per_second: float = 8.0
@export var loop_special: bool = false

var _frames: Dictionary = {}
var _state: String = "idle"
var _frame: int = 0
var _elapsed: float = 0.0
var _state_timer: float = 0.0

var _segment_active: bool = false
var _segment_first: int = 0
var _segment_last: int = 0
var _segment_duration: float = 0.0
var _segment_hold: float = 0.0
var _segment_elapsed: float = 0.0

var _windup_left: float = 0.0
var _windup_total: float = 0.0
var _windup_tint: Color = Color.WHITE
var _move_tween: Tween

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	_load_frames()
	set_state("idle")

func _process(delta: float) -> void:
	_update_windup(delta)
	if _segment_active:
		_update_segment(delta)
		return
	_elapsed += delta
	_state_timer = maxf(0.0, _state_timer - delta)
	if _elapsed < (1.0 / frames_per_second):
		return

	_elapsed = fmod(_elapsed, 1.0 / frames_per_second)
	var state_frames: Array = _frames.get(_state, _frames.get("idle", []))
	if state_frames.is_empty():
		return

	if _state in ["attack", "hurt", "special"] and not loop_special:
		_frame = mini(_frame + 1, state_frames.size() - 1)
	elif _state == "defeat":
		_frame = mini(_frame + 1, state_frames.size() - 1)
	else:
		_frame = (_frame + 1) % state_frames.size()
	texture = state_frames[_frame]

	if _state in ["attack", "hurt", "special"] and _state_timer <= 0.0:
		set_state("idle")

func _load_frames() -> void:
	for state in ["idle", "walk", "attack", "special", "hurt", "defeat"]:
		var frame_list: Array[Texture2D] = []
		for frame in range(1, 9):
			var path := "res://assets/characters/enemies/boss_%s/boss_%s_%s_%02d.png" % [boss_name, boss_name, state, frame]
			var loaded := load(path)
			if loaded is Texture2D:
				frame_list.append(loaded)
		_frames[state] = frame_list

func set_state(state: String, duration: float = 0.0) -> void:
	if not _frames.has(state):
		state = "idle"
	_segment_active = false
	if state == _state and duration > 0.0:
		_state_timer = maxf(_state_timer, duration)
		return
	if state == _state:
		return
	_state = state
	_frame = 0
	_elapsed = 0.0
	_state_timer = duration
	var state_frames: Array = _frames.get(state, [])
	if not state_frames.is_empty():
		texture = state_frames[0]

func play_once(state: String, duration: float = 0.65) -> void:
	if _segment_active:
		return
	set_state(state, duration)

## Plays frames first..last (0-based) of a row over `duration`, holds the last frame for
## `hold` seconds, then returns to idle. Lets one atlas row serve as anticipation + strike.
func play_segment(state: String, first: int, last: int, duration: float, hold: float = 0.15) -> void:
	set_state(state)
	var count: int = _frames.get(_state, []).size()
	if count == 0:
		return
	_segment_first = clampi(first, 0, count - 1)
	_segment_last = clampi(last, _segment_first, count - 1)
	_segment_duration = maxf(duration, 0.01)
	_segment_hold = hold
	_segment_elapsed = 0.0
	_segment_active = true
	texture = _frames[_state][_segment_first]

func _update_segment(delta: float) -> void:
	_segment_elapsed += delta
	var span := _segment_last - _segment_first + 1
	var progress := minf(_segment_elapsed / _segment_duration, 0.999)
	_frame = _segment_first + int(progress * span)
	texture = _frames[_state][_frame]
	if _segment_elapsed >= _segment_duration + _segment_hold:
		_segment_active = false
		set_state("idle")

## Anticipation: pulsing tint that speeds up plus a growing tremble.
func windup(seconds: float, tint: Color = Color(1.0, 0.35, 0.3)) -> void:
	_windup_total = maxf(seconds, 0.01)
	_windup_left = _windup_total
	_windup_tint = tint

func cancel_windup() -> void:
	_windup_left = 0.0
	modulate = Color.WHITE
	offset = Vector2.ZERO

func _update_windup(delta: float) -> void:
	if _windup_left <= 0.0:
		return
	_windup_left = maxf(0.0, _windup_left - delta)
	var progress := 1.0 - _windup_left / _windup_total
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * (8.0 + progress * 22.0))
	modulate = Color.WHITE.lerp(_windup_tint, (0.35 + 0.5 * progress) * pulse)
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5)) * progress * 1.5
	if _windup_left <= 0.0:
		modulate = Color.WHITE
		offset = Vector2.ZERO

## Strike thrust toward `direction` by `distance` screen pixels, then settle back.
func lunge(direction: Vector2, distance: float = 12.0, out_time: float = 0.08, back_time: float = 0.35) -> void:
	_tween_offset(direction.normalized() * distance, out_time, back_time)

## Hurt reaction: flash, knock away from the hit source, play hurt frames.
func recoil(away_from: Vector2, distance: float = 8.0) -> void:
	cancel_windup()
	set_state("hurt", 0.45)
	VFXHitFlash.flash(self, Color(1.0, 0.45, 0.45), 0.1, 2)
	var direction := (global_position - away_from).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	_tween_offset(direction * distance, 0.05, 0.3)

func _tween_offset(target_screen: Vector2, out_time: float, back_time: float) -> void:
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	# offset is in texture pixels, so divide by scale to move the intended screen distance.
	var local_target := target_screen / Vector2(maxf(scale.x, 0.01), maxf(scale.y, 0.01))
	_move_tween = create_tween()
	_move_tween.tween_property(self, "offset", local_target, out_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(self, "offset", Vector2.ZERO, back_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
