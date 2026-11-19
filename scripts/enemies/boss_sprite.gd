class_name BossSprite
extends Sprite2D

@export var boss_name: String = "lankini"
@export var frames_per_second: float = 8.0
@export var loop_special: bool = false

var _frames: Dictionary = {}
var _state: String = "idle"
var _frame: int = 0
var _elapsed: float = 0.0
var _state_timer: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	_load_frames()
	set_state("idle")

func _process(delta: float) -> void:
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
	set_state(state, duration)
