class_name BossEncounters
extends Node2D

## Telegraphed boss encounters for Chapters 1–2: Surasa, Simhika and Lankini.
## Every attack runs wind-up → strike → recovery. Damage lands only on the strike frame and
## only inside the drawn TelegraphMarker, so every hit is readable and fair.
## Placeholder tuning for the vertical slice — Member 2 owns the final encounter rules.

signal lankini_defeated()
signal lankini_health_changed(health: int)

## Boss anchors come from the map markers 1 (Surasa), 2 (Simhika), 3 (Lankini).
var SURASA_POS := Vector2(350, 180)
var SIMHIKA_POS := Vector2(490, 180)
var LANKINI_POS := Vector2(500, 180)
var _world := Rect2(0, 0, 640, 384)
const LANKINI_MAX_HEALTH := 6
const FEET := Vector2(0, 14)

var director: Node
var player: Node2D

var surasa: BossSprite
var simhika: BossSprite
var lankini: BossSprite
var jaw_marker: TelegraphMarker
var shadow_marker: TelegraphMarker
var slam_marker: TelegraphMarker

# Surasa reacts fast (shrink on the cue); Simhika is slower but tracks you; Lankini hits hardest.
var surasa_attack := TelegraphedAttack.new(0.75, 0.3, 0.9)
var simhika_attack := TelegraphedAttack.new(1.0, 0.35, 1.3)
var lankini_attack := TelegraphedAttack.new(0.9, 0.3, 1.1)

var surasa_passed := false
var lankini_health := 0
var _hints_shown: Dictionary = {}

func setup(owner_director: Node, hanuman: Node2D) -> void:
	director = owner_director
	player = hanuman
	jaw_marker = _make_marker(TelegraphMarker.Shape.RECT, SURASA_POS + Vector2(10, 0), Color(1.0, 0.3, 0.25))
	jaw_marker.rect_size = Vector2(120, 330)
	shadow_marker = _make_marker(TelegraphMarker.Shape.ELLIPSE, SIMHIKA_POS, Color(0.65, 0.25, 0.95))
	shadow_marker.radius = 24.0
	slam_marker = _make_marker(TelegraphMarker.Shape.ELLIPSE, LANKINI_POS + Vector2(0, 30), Color(1.0, 0.45, 0.15))
	slam_marker.radius = 80.0
	slam_marker.squash = 0.6
	surasa = _make_boss("surasa", SURASA_POS, 1.35)
	simhika = _make_boss("simhika", SIMHIKA_POS, 1.35)
	lankini = _make_boss("lankini", LANKINI_POS, 1.35)
	surasa_attack.windup_started.connect(_on_surasa_windup)
	surasa_attack.struck.connect(_on_surasa_strike)
	simhika_attack.windup_started.connect(_on_simhika_windup)
	simhika_attack.struck.connect(_on_simhika_strike)
	lankini_attack.windup_started.connect(_on_lankini_windup)
	lankini_attack.struck.connect(_on_lankini_strike)

func _make_boss(boss_name: String, at: Vector2, boss_scale: float) -> BossSprite:
	var boss := BossSprite.new()
	boss.boss_name = boss_name
	boss.name = boss_name.capitalize()
	boss.position = at
	boss.scale = Vector2.ONE * boss_scale
	boss.z_index = 1
	boss.visible = false
	add_child(boss)
	return boss

func _make_marker(shape: TelegraphMarker.Shape, at: Vector2, color: Color) -> TelegraphMarker:
	var marker := TelegraphMarker.new()
	marker.shape = shape
	marker.color = color
	marker.position = at
	add_child(marker)
	return marker

## Places the bosses and their warning areas from the chapter map. Surasa's jaws span the
## whole map height, so she cannot be walked around.
func place_from_maze(maze: LevelMaze) -> void:
	_world = maze.world_rect()
	SURASA_POS = maze.marker_position("1", SURASA_POS)
	SIMHIKA_POS = maze.marker_position("2", SIMHIKA_POS)
	LANKINI_POS = maze.marker_position("3", LANKINI_POS)
	surasa.position = SURASA_POS
	simhika.position = SIMHIKA_POS
	lankini.position = LANKINI_POS
	jaw_marker.position = Vector2(SURASA_POS.x + 10, _world.get_center().y)
	jaw_marker.rect_size = Vector2(120, _world.size.y)
	slam_marker.position = LANKINI_POS + Vector2(0, 30)

## Called by the director whenever a chapter starts or restarts.
func reset_for_chapter(chapter: int) -> void:
	for attack in [surasa_attack, simhika_attack, lankini_attack]:
		attack.reset()
	for marker in [jaw_marker, shadow_marker, slam_marker]:
		marker.cancel()
	for boss in [surasa, simhika, lankini]:
		boss.cancel_windup()
		boss.set_state("idle")
		boss.visible = false
	surasa_passed = false
	lankini_health = 0
	if chapter == 1:
		surasa.visible = true
		simhika.visible = true
	elif chapter == 2:
		lankini.visible = true
		lankini_health = LANKINI_MAX_HEALTH
		lankini_health_changed.emit(lankini_health)

# --- Chapter 1: Surasa and Simhika ------------------------------------------------------

func update_ocean(delta: float) -> void:
	var x: float = player.global_position.x
	surasa_attack.update(delta)
	simhika_attack.update(delta)
	if not surasa_passed:
		if x > SURASA_POS.x - 88.0 and x < SURASA_POS.x + 75.0 and surasa_attack.is_ready():
			surasa_attack.start()
		if x > SURASA_POS.x + 75.0:
			_on_surasa_passed()
	elif absf(x - SIMHIKA_POS.x) < 120.0 and player.global_position.distance_to(SIMHIKA_POS) < 220.0 and simhika_attack.is_ready():
		simhika_attack.start()
	# Simhika's shadow follows Hanuman for most of the wind-up, then locks in place.
	if shadow_marker.is_warning() and simhika_attack.phase == TelegraphedAttack.Phase.WINDUP:
		if shadow_marker.get_meta("lock_at", 0.0) > Time.get_ticks_msec() / 1000.0:
			shadow_marker.global_position = player.global_position + FEET

func _on_surasa_windup() -> void:
	surasa.windup(surasa_attack.windup, Color(1.0, 0.35, 0.3))
	surasa.play_segment("attack", 0, 2, surasa_attack.windup, 0.0)
	jaw_marker.begin(surasa_attack.windup)
	_sfx("hiss", -4.0)
	_hint("surasa", "Surasa's jaws open — press [SHIFT] to shrink!")

func _on_surasa_strike() -> void:
	surasa.play_segment("attack", 6, 6, 0.3, 0.25)
	surasa.lunge(Vector2(-1, 0.2), 14.0)
	jaw_marker.trigger()
	_sfx("bite", -1.0)
	GameFeel.shake(self, 3.0, 0.18)
	if not jaw_marker.contains(player.global_position):
		return
	if player.is_shrunk():
		VFXImpact.sparks(self, player.global_position, Color(1.0, 0.85, 0.35), 8)
		_hint("slipped", "You slip between Surasa's fangs!")
	else:
		GameFeel.hitstop(self, 0.08)
		director.hurt_player(14, surasa.global_position, 30.0, "Surasa's jaws snap shut! Shrink on her cue.")

func _on_surasa_passed() -> void:
	surasa_passed = true
	surasa_attack.reset()
	jaw_marker.cancel()
	surasa.cancel_windup()
	surasa.set_state("idle")
	surasa.windup(0.9, Color(1.0, 0.9, 0.45))
	VFXImpact.sparks(self, player.global_position, Color(1.0, 0.85, 0.35), 16)
	_sfx("objective", -3.0)
	GameEvents.encounter_feedback.emit("Surasa smiles: \"Go with my blessing, son of Vayu.\"")

func _on_simhika_windup() -> void:
	simhika.windup(simhika_attack.windup, Color(0.7, 0.35, 1.0))
	simhika.play_segment("special", 4, 5, simhika_attack.windup, 0.0)
	shadow_marker.global_position = player.global_position + FEET
	shadow_marker.set_meta("lock_at", Time.get_ticks_msec() / 1000.0 + simhika_attack.windup * 0.55)
	shadow_marker.begin(simhika_attack.windup)
	_sfx("shadow", -3.0)
	_hint("simhika", "Simhika seizes your shadow — move off the dark circle!")

func _on_simhika_strike() -> void:
	simhika.play_segment("attack", 3, 4, 0.35, 0.2)
	simhika.lunge((shadow_marker.global_position - simhika.global_position), 10.0)
	shadow_marker.trigger()
	var tentacles := VFXShadowTentacle.new()
	tentacles.hold_duration = 0.25
	add_child(tentacles)
	tentacles.global_position = shadow_marker.global_position
	tentacles.extend_toward([Vector2(-14, -22), Vector2(0, -30), Vector2(14, -22)])
	tentacles.tentacle_retracted.connect(tentacles.queue_free)
	if shadow_marker.contains(player.global_position + FEET):
		_sfx("grab", 0.0)
		GameFeel.shake(self, 4.0, 0.22)
		GameFeel.hitstop(self, 0.06)
		var pull := (simhika.global_position - player.global_position).normalized()
		director.hurt_player(10, player.global_position - pull, 26.0, "Simhika drags your shadow! Strike her with [J].")
	else:
		_sfx("whoosh", -6.0, 0.8)

# --- Chapter 2: Lankini -----------------------------------------------------------------

func update_gates(delta: float) -> void:
	if lankini_health <= 0:
		return
	lankini_attack.update(delta)
	if lankini_attack.is_ready() and player.global_position.distance_to(LANKINI_POS) < 140.0:
		lankini_attack.start()

func _on_lankini_windup() -> void:
	lankini.windup(lankini_attack.windup, Color(1.0, 0.5, 0.25))
	lankini.play_segment("attack", 0, 2, lankini_attack.windup, 0.0)
	slam_marker.begin(lankini_attack.windup)
	_sfx("roar", -2.0)
	_hint("lankini", "Lankini raises her mace — get out of the ring, then strike!")

func _on_lankini_strike() -> void:
	lankini.play_segment("attack", 3, 7, 0.35, 0.3)
	lankini.lunge(Vector2.DOWN, 6.0, 0.05, 0.3)
	slam_marker.trigger()
	VFXImpact.shockwave(self, slam_marker.global_position, 92.0, Color(1.0, 0.75, 0.45), 0.6)
	_layered(["whoosh", "slam"], -1.0)
	GameFeel.shake(self, 7.0, 0.3)
	if slam_marker.contains(player.global_position + FEET) and not player.is_flying():
		GameFeel.hitstop(self, 0.1)
		director.hurt_player(12, LANKINI_POS, 38.0, "Lankini's slam sends you flying!")

## "Jai Shri Ram": every boss attack in progress is cancelled and they reel for `seconds`.
func stun_bosses(seconds: float) -> void:
	for attack in [surasa_attack, simhika_attack, lankini_attack]:
		if attack.is_ready():
			attack.phase = TelegraphedAttack.Phase.WINDUP
		attack.interrupt(seconds)
	for marker in [jaw_marker, shadow_marker, slam_marker]:
		marker.cancel()
	for boss in [surasa, simhika, lankini]:
		var defeated: bool = boss == lankini and lankini_health <= 0
		if boss.visible and not defeated:
			boss.cancel_windup()
			boss.set_state("hurt", seconds * 0.5)

# --- Hanuman's strikes ------------------------------------------------------------------

## Returns true if the strike connected with a boss.
func on_player_attack(chapter: int, origin: Vector2, attack_range: float) -> bool:
	if chapter == 1 and simhika.visible and origin.distance_to(SIMHIKA_POS) <= attack_range + 10.0:
		simhika_attack.interrupt(1.0)
		shadow_marker.cancel()
		simhika.recoil(origin)
		_hit_feedback(SIMHIKA_POS, 2.5)
		GameEvents.encounter_feedback.emit("Simhika reels from your strike!")
		return true
	if chapter != 2 or lankini_health <= 0 or origin.distance_to(LANKINI_POS) > attack_range:
		return false
	if lankini_attack.phase == TelegraphedAttack.Phase.WINDUP:
		# She is braced mid wind-up: the strike is blocked. Teaches dodge-then-punish.
		VFXImpact.sparks(self, LANKINI_POS + Vector2(-12, -6), Color(0.8, 0.85, 0.9), 6)
		_sfx("impact", -4.0, 1.6)
		_hint("guard", "Lankini blocks while winding up — dodge the slam, then strike!")
		return true
	lankini_health -= 1
	lankini_health_changed.emit(lankini_health)
	lankini.recoil(origin)
	_hit_feedback(LANKINI_POS, 3.0)
	if lankini_attack.phase == TelegraphedAttack.Phase.RECOVER:
		lankini_attack.interrupt(0.9)
	if lankini_health <= 0:
		_defeat_lankini()
	else:
		GameEvents.encounter_feedback.emit("Lankini staggered! %d strikes remain." % lankini_health)
	return true

func _defeat_lankini() -> void:
	lankini_attack.reset()
	slam_marker.cancel()
	lankini.cancel_windup()
	lankini.set_state("defeat")
	VFXImpact.shockwave(self, LANKINI_POS + Vector2(0, 30), 120.0, Color(1.0, 0.9, 0.6), 0.6)
	GameFeel.hitstop(self, 0.18)
	GameFeel.shake(self, 8.0, 0.45)
	_layered(["slam", "boss"], -1.0)
	lankini_defeated.emit()

func _hit_feedback(at: Vector2, shake: float) -> void:
	VFXImpact.sparks(self, at + Vector2(randf_range(-8, 8), randf_range(-14, 0)))
	_sfx("impact", -2.0)
	GameFeel.shake(self, shake, 0.15)
	GameFeel.hitstop(self, 0.05)

# --- Helpers ----------------------------------------------------------------------------

func _hint(key: String, text: String) -> void:
	if _hints_shown.has(key):
		return
	_hints_shown[key] = true
	GameEvents.encounter_feedback.emit(text)

func _sfx(sound: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx_varied(sound, volume_db, pitch)

func _layered(sounds: Array, volume_db: float = 0.0) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_layered(sounds, volume_db)
