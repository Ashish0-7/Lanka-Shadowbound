class_name HanumanPresentation
extends Node2D

## HanumanPresentation: visual + audio feel for Hanuman. Owns NO gameplay state.
## Listens to the controller's attack_started signal and GameEvents, and
## animates only Sprite2D.rotation / offset (the controller owns texture and scale).
##
## Swing = anticipation (lean back) → strike (lunge + golden gada arc) → impact flash → recovery.
## Combo: step 1 forward cut, step 2 return cut, step 3 heavy overhead finisher.

const ARC_COLOR := Color(1.0, 0.86, 0.42)
## Swing pivot: roughly Hanuman's shoulder, so the arc wraps around his body.
const ARC_CENTER := Vector2(0, -3)
const FACING_ANGLE := {"right": 0.0, "down": PI * 0.5, "left": PI, "up": -PI * 0.5}

var player: CharacterBody2D
var sprite: Sprite2D
var _shadow: Node2D
var _pose_tween: Tween

# Swing arc state (drawn in _draw).
var _arc_visible: bool = false
var _arc_from: float = 0.0
var _arc_to: float = 0.0
var _arc_progress: float = 0.0
var _arc_radius: float = 13.0
var _arc_fade: float = 1.0
var _arc_heavy: bool = false
var _impact_timer: float = 0.0
var _impact_point: Vector2 = Vector2.ZERO

var _previous_health: int = -1
var _was_shrunk: bool = false

func _ready() -> void:
	player = get_parent() as CharacterBody2D
	sprite = player.get_node("Sprite2D")
	z_index = 1
	_shadow = Node2D.new()
	_shadow.name = "GroundShadow"
	_shadow.z_index = -2
	_shadow.show_behind_parent = true
	_shadow.draw.connect(_draw_shadow)
	add_child(_shadow)
	player.attack_started.connect(_on_attack_started)
	GameEvents.player_health_changed.connect(_on_health_changed)
	GameEvents.shrink_ability_updated.connect(_on_shrink_updated)

func _process(delta: float) -> void:
	_impact_timer = maxf(0.0, _impact_timer - delta)
	_shadow.queue_redraw()
	queue_redraw()

# --- Attacks ----------------------------------------------------------------------------

func _on_attack_started(facing: String, combo_step: int) -> void:
	var heavy := combo_step == 3
	var base: float = FACING_ANGLE.get(facing, PI * 0.5)
	var side := -1.0 if facing == "left" else 1.0
	var sweep := 2.3 if heavy else 1.7
	# Step 2 sweeps back the other way so a combo visibly alternates.
	var direction := -1.0 if combo_step == 2 else 1.0
	_arc_from = base - sweep * 0.65 * direction
	_arc_to = base + sweep * 0.35 * direction
	_arc_radius = 26.0 if heavy else 20.0
	_arc_heavy = heavy
	_arc_visible = false
	_arc_fade = 1.0

	# The sweep starts SWEEP_TIME before the controller's hit, so the arc finishes on impact.
	const SWEEP_TIME := 0.06
	var hit_delay: float = player.HEAVY_WINDUP if heavy else player.ATTACK_WINDUP
	var windup: float = maxf(0.02, hit_delay - SWEEP_TIME)
	var lean := 0.22 if heavy else 0.12
	var reach := Vector2.from_angle(base) * (4.0 if heavy else 3.0)
	if _pose_tween and _pose_tween.is_valid():
		_pose_tween.kill()
	_pose_tween = create_tween()
	# Anticipation: lean away and draw back (heavy also rises for an overhead swing).
	_pose_tween.tween_property(sprite, "rotation", -lean * side, windup).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_pose_tween.parallel().tween_property(sprite, "offset", -reach * 0.5 + (Vector2(0, -3) if heavy else Vector2.ZERO), windup)
	# Strike: snap forward while the gada arc sweeps.
	_pose_tween.tween_callback(_begin_arc)
	_pose_tween.tween_property(sprite, "rotation", lean * 0.8 * side, SWEEP_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_pose_tween.parallel().tween_property(sprite, "offset", reach, SWEEP_TIME)
	_pose_tween.parallel().tween_property(self, "_arc_progress", 1.0, SWEEP_TIME)
	# Impact visuals come from the arc itself so they always line up with the sweep.
	_pose_tween.tween_callback(_show_impact)
	# Recovery: settle back to neutral.
	_pose_tween.tween_interval(0.05 if not heavy else 0.1)
	_pose_tween.tween_property(sprite, "rotation", 0.0, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pose_tween.parallel().tween_property(sprite, "offset", Vector2.ZERO, 0.16)
	_pose_tween.parallel().tween_property(self, "_arc_fade", 0.0, 0.14)

func _begin_arc() -> void:
	_arc_progress = 0.0
	_arc_visible = true
	_sfx("whoosh", -6.0 if not _arc_heavy else -2.0, 1.25 if not _arc_heavy else 0.85)

func _show_impact() -> void:
	_impact_point = ARC_CENTER + Vector2.from_angle(_arc_to) * _arc_radius
	_impact_timer = 0.12
	if _arc_heavy:
		VFXImpact.shockwave(get_parent().get_parent(), player.global_position + _impact_point + Vector2(0, 6), 38.0, ARC_COLOR, 0.5)
		GameFeel.shake(self, 3.0, 0.16)
		_sfx("impact", -5.0, 0.8)

# --- Reactions --------------------------------------------------------------------------

func _on_health_changed(current: int, _max_hp: int) -> void:
	if _previous_health >= 0 and current < _previous_health and current > 0:
		# Hurt recoil: jolt backwards and shake the body briefly.
		if _pose_tween and _pose_tween.is_valid():
			_pose_tween.kill()
		_arc_visible = false
		_pose_tween = create_tween()
		_pose_tween.tween_property(sprite, "rotation", -0.3, 0.05)
		_pose_tween.parallel().tween_property(sprite, "offset", Vector2(0, -2), 0.05)
		_pose_tween.tween_property(sprite, "rotation", 0.15, 0.08)
		_pose_tween.tween_property(sprite, "rotation", 0.0, 0.18).set_trans(Tween.TRANS_SINE)
		_pose_tween.parallel().tween_property(sprite, "offset", Vector2.ZERO, 0.18)
	_previous_health = current

func _on_shrink_updated(is_active: bool, _cd: float, _cd_max: float, _left: float, _total: float) -> void:
	if is_active and not _was_shrunk:
		VFXHitFlash.shrink_flash(sprite)
		VFXImpact.sparks(get_parent().get_parent(), player.global_position, Color(1.0, 0.85, 0.35), 12)
	elif not is_active and _was_shrunk:
		VFXImpact.sparks(get_parent().get_parent(), player.global_position, Color(1.0, 0.95, 0.7), 8)
	_was_shrunk = is_active

# --- Drawing ----------------------------------------------------------------------------

func _draw() -> void:
	if _arc_visible and _arc_fade > 0.01:
		var to := lerpf(_arc_from, _arc_to, _arc_progress)
		var width := 5.0 if _arc_heavy else 4.0
		# Layered crescent: faint wide trail, bright core, thin white edge, gada head at the tip.
		draw_arc(ARC_CENTER, _arc_radius, _arc_from, to, 20, Color(ARC_COLOR, 0.3 * _arc_fade), width + 4.0)
		draw_arc(ARC_CENTER, _arc_radius, lerpf(_arc_from, to, 0.3), to, 16, Color(ARC_COLOR, 0.9 * _arc_fade), width)
		draw_arc(ARC_CENTER, _arc_radius + width * 0.5, lerpf(_arc_from, to, 0.6), to, 10, Color(1, 1, 1, 0.85 * _arc_fade), 1.0)
		draw_circle(ARC_CENTER + Vector2.from_angle(to) * _arc_radius, width * 0.75, Color(1, 0.95, 0.8, _arc_fade))
	if _impact_timer > 0.0:
		var k := _impact_timer / 0.12
		var r := (7.0 if _arc_heavy else 4.0) * (1.6 - k)
		for i in 4:
			var a := i * PI * 0.5 + PI * 0.25
			draw_line(_impact_point, _impact_point + Vector2.from_angle(a) * r, Color(1, 1, 1, k), 1.0)
		draw_circle(_impact_point, r * 0.45, Color(1, 0.95, 0.75, k))

func _draw_shadow() -> void:
	var size := 0.5 if player.is_shrunk() else 1.0
	_shadow.draw_set_transform(Vector2(0, 15 * size), 0.0, Vector2(1.0, 0.35))
	_shadow.draw_circle(Vector2.ZERO, 8.0 * size, Color(0, 0, 0, 0.32))

func _sfx(sound: String, volume_db: float, pitch: float) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx_varied(sound, volume_db, pitch)
