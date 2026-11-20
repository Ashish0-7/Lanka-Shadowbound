extends Node
class_name LankaAudioManager

const SFX_ROOT := "res://assets/audio/sfx/"
const MUSIC_ROOT := "res://assets/audio/music/"

var sfx: Dictionary = {}
var music_player: AudioStreamPlayer

func _ready() -> void:
	_load_audio()
	_create_music_player()
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.player_died.connect(_on_player_died)
	GameEvents.shrink_ability_updated.connect(_on_shrink_updated)
	GameEvents.objective_updated.connect(_on_objective_updated)
	GameEvents.stealth_alert_level_changed.connect(_on_stealth_changed)
	GameEvents.encounter_feedback.connect(_on_encounter_feedback)

func _load_audio() -> void:
	for name in [
		"ui_select", "ui_start", "attack", "hurt", "shrink",
		"objective", "alert", "boss", "dialogue_hero",
		"dialogue_female", "dialogue_reverent", "dialogue_monster",
		"footstep", "water", "fire", "telegraph", "victory",
		"defeat", "transition",
		"hiss", "bite", "whoosh", "roar", "slam", "shadow", "grab", "impact"
	]:
		var path: String = SFX_ROOT + "sfx_" + name + ".wav"
		var exists: bool = ResourceLoader.exists(path)
		if exists:
			var stream: AudioStream = load(path)
			sfx[name] = stream

func _create_music_player() -> void:
	var path: String = MUSIC_ROOT + "mus_main_theme_loop.wav"
	if not ResourceLoader.exists(path):
		return
	music_player = AudioStreamPlayer.new()
	music_player.name = "MainTheme"
	var stream: AudioStream = load(path)
	# The WAV import has looping disabled and .import files are not tracked, so loop here.
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	music_player.stream = stream
	music_player.volume_db = -12.0
	music_player.bus = "Master"
	add_child(music_player)

const MAX_VOICES_PER_SFX := 3
var _voices: Dictionary = {}

func play_sfx(name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not sfx.has(name):
		return
	# Cap overlapping copies of one sound so rapid repeats never pile into a wall of noise.
	var active: Array = _voices.get(name, []).filter(func(p): return is_instance_valid(p))
	if active.size() >= MAX_VOICES_PER_SFX:
		active.pop_front().queue_free()
	var player := AudioStreamPlayer.new()
	player.stream = sfx[name]
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = "Master"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	active.append(player)
	_voices[name] = active

## Plays a sound with slight random pitch/volume so repeated hits never sound identical.
func play_sfx_varied(name: String, volume_db: float = 0.0, pitch_scale: float = 1.0, variation: float = 0.08) -> void:
	play_sfx(name, volume_db + randf_range(-1.5, 1.0), pitch_scale * randf_range(1.0 - variation, 1.0 + variation))

## Plays several sounds at once as one layered hit, e.g. ["whoosh", "slam", "impact"].
func play_layered(names: Array, volume_db: float = 0.0) -> void:
	for layer in names:
		play_sfx_varied(layer, volume_db)

func play_dialogue_blip(blip_id: String) -> void:
	match blip_id:
		"hero":
			play_sfx("dialogue_hero", -4.0)
		"female_melodic":
			play_sfx("dialogue_female", -4.0)
		"reverent":
			play_sfx("dialogue_reverent", -5.0)
		"monster":
			play_sfx("dialogue_monster", -3.0)

func stop_music() -> void:
	if music_player and music_player.playing:
		music_player.stop()

## Story beat: the music rises, holds, and settles back to its normal level.
func swell(peak_db: float = -4.0, rise: float = 0.8, fall: float = 2.6) -> void:
	if music_player == null:
		return
	play_music()
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", peak_db, rise).set_trans(Tween.TRANS_SINE)
	tween.tween_property(music_player, "volume_db", -12.0, fall).set_trans(Tween.TRANS_SINE)

func play_music() -> void:
	if music_player and not music_player.playing:
		music_player.play()

var _previous_health: int = 100

func _on_player_health_changed(current: int, _max_hp: int) -> void:
	if current < _previous_health:
		play_sfx("hurt", -2.0)
	_previous_health = current

func _on_player_died() -> void:
	play_sfx("hurt", 2.0, 0.72)

var _was_shrunk: bool = false

func _on_shrink_updated(is_active: bool, _cooldown_remaining: float, _cooldown_max: float, _duration_remaining: float, _duration_max: float) -> void:
	if is_active and not _was_shrunk:
		play_sfx("shrink", -2.0)
	_was_shrunk = is_active

func _on_objective_updated(_text: String, is_complete: bool) -> void:
	if is_complete:
		play_sfx("objective", -2.0)

var _was_detected: bool = false

func _on_stealth_changed(_alert_level: float, is_detected: bool) -> void:
	if is_detected and not _was_detected:
		play_sfx("alert", -1.0)
	_was_detected = is_detected

var _last_boss_sting_ms: int = -100000

func _on_encounter_feedback(text: String) -> void:
	# Encounters now play their own layered SFX, so the generic sting is rate-limited.
	if not ("Lankini" in text or "Surasa" in text or "Simhika" in text):
		return
	if Time.get_ticks_msec() - _last_boss_sting_ms < 4000:
		return
	_last_boss_sting_ms = Time.get_ticks_msec()
	play_sfx("boss", -4.0, 0.9)
