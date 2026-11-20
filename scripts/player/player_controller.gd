extends CharacterBody2D
## Canonical prototype controller; Member 2 can extend this after coordination.

@export var move_speed: float = 120.0
@export var max_health: int = 100
@export var attack_range: float = 62.0

## Emitted on the IMPACT frame of a swing (after anticipation), not on the key press.
signal attack_performed(origin: Vector2)
## Emitted when a swing begins, for presentation. combo_step is 1, 2, or 3 (heavy finisher).
signal attack_started(facing: String, combo_step: int)

## Anticipation before the hit lands; the heavy third swing winds up longer.
const ATTACK_WINDUP := 0.08
const HEAVY_WINDUP := 0.16
const ATTACK_POSE_TIME := 0.3
const HEAVY_POSE_TIME := 0.42
const COMBO_WINDOW := 0.55
var _pending_hit: float = -1.0
var _combo_step: int = 0
var _combo_timer: float = 0.0

## Hold [J] to charge, release to unleash a 360° gada spin that hits everything around Hanuman.
signal charge_ready()
signal spin_performed(origin: Vector2)
const SPIN_CHARGE := 0.45
var charge_time: float = 0.0
var _charged: bool = false

## "Jai Shri Ram!" giant form: larger, invulnerable, devastating swings.
const GIANT_SCALE := 1.8
var giant_remaining: float = 0.0

## Divine flight: double-tap [SPACE] to soar in a horizontal pose. Faster, and above ground
## dangers (fire, imp bites, ground slams); walls still block him.
signal flight_changed(active: bool)
const FLIGHT_DURATION := 2.2
const FLIGHT_COOLDOWN := 4.0
const FLIGHT_SPEED := 1.9
const DOUBLE_TAP_MS := 320
var flight_remaining: float = 0.0
var flight_cooldown: float = 0.0
## Horizontal heading while flying: 1 = right, -1 = left.
var flight_dir: int = 1
var _last_space_ms: int = -10000

var health: int
var shrink_remaining: float = 0.0
var shrink_cooldown: float = 0.0
const SHRINK_DURATION := 3.0
const SHRINK_COOLDOWN := 5.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var idle_textures: Dictionary = {
	"down": preload("res://assets/characters/hanuman/char_hanuman_idle_down.png"),
	"left": preload("res://assets/characters/hanuman/char_hanuman_idle_left.png"),
	"right": preload("res://assets/characters/hanuman/char_hanuman_idle_right.png"),
	"up": preload("res://assets/characters/hanuman/char_hanuman_idle_up.png"),
}
@onready var walk_textures: Dictionary = {
	"down": _load_walk_textures("down"),
	"left": _load_walk_textures("left"),
	"right": _load_walk_textures("right"),
	"up": _load_walk_textures("up"),
}
@onready var strike_textures: Dictionary = {
	"down": preload("res://assets/characters/hanuman/char_hanuman_walk_down_05.png"),
	"left": preload("res://assets/characters/hanuman/char_hanuman_walk_left_05.png"),
	"right": preload("res://assets/characters/hanuman/char_hanuman_walk_right_05.png"),
	"up": preload("res://assets/characters/hanuman/char_hanuman_walk_up_05.png"),
}
var animation_timer: float = 0.0
var attack_timer: float = 0.0
var facing: String = "down"
var footstep_timer: float = 0.0

func _load_walk_textures(direction: String) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for frame in range(1, 9):
		textures.append(load("res://assets/characters/hanuman/char_hanuman_walk_%s_%02d.png" % [direction, frame]))
	return textures

## Playable world bounds; the level sets this when a chapter loads.
var world_rect := Rect2(0, 0, 640, 360)

## Maze crevices live on this physics layer; Hanuman only collides with them at full size.
const CREVICE_LAYER := 2

func _ready() -> void:
	set_collision_mask_value(CREVICE_LAYER, true)
	health = max_health
	GameEvents.player_health_changed.emit(health, max_health)
	GameEvents.shrink_ability_updated.emit(false, 0.0, SHRINK_COOLDOWN, 0.0, SHRINK_DURATION)

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed_mult := 0.72 if is_shrunk() else (FLIGHT_SPEED if is_flying() else 1.0)
	if is_flying() and absf(input_direction.x) > 0.1:
		flight_dir = 1 if input_direction.x > 0.0 else -1
	velocity = input_direction * (move_speed * speed_mult)
	set_collision_mask_value(CREVICE_LAYER, not is_shrunk())
	move_and_slide()
	global_position = global_position.clamp(world_rect.position + Vector2(10, 14), world_rect.end - Vector2(10, 14))
	_update_flight(delta)
	_update_shrink(delta)
	_update_attack(delta)
	_update_charge(delta)
	giant_remaining = maxf(0.0, giant_remaining - delta)
	_update_sprite(delta, input_direction)
	if is_giant():
		sprite.scale = Vector2.ONE * GIANT_SCALE

func _unhandled_input(event: InputEvent) -> void:
	# Double-tap SPACE → divine flight. (Dialogue and story cards consume Space first.)
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE:
		var now := Time.get_ticks_msec()
		if now - _last_space_ms <= DOUBLE_TAP_MS:
			_last_space_ms = -10000
			try_fly()
		else:
			_last_space_ms = now
	if event.is_action_released("attack"):
		if _charged:
			attack_timer = 0.4
			spin_performed.emit(global_position)
		_charged = false
		charge_time = 0.0
	if event.is_action_pressed("ability") and shrink_cooldown <= 0.0 and not is_giant():
		shrink_remaining = SHRINK_DURATION
		shrink_cooldown = SHRINK_COOLDOWN
		GameEvents.shrink_ability_updated.emit(true, 0.0, SHRINK_COOLDOWN, shrink_remaining, SHRINK_DURATION)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("attack") and _pending_hit < 0.0 and not is_flying():
		# Presses during anticipation are ignored; presses soon after a hit chain the combo.
		_combo_step = (_combo_step % 3) + 1 if _combo_timer > 0.0 else 1
		var heavy := _combo_step == 3
		_pending_hit = HEAVY_WINDUP if heavy else ATTACK_WINDUP
		attack_timer = HEAVY_POSE_TIME if heavy else ATTACK_POSE_TIME
		_combo_timer = attack_timer + COMBO_WINDOW
		attack_started.emit(facing, _combo_step)
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx_varied("attack", -4.0, 0.9 if heavy else 1.0)
		get_viewport().set_input_as_handled()

func _update_attack(delta: float) -> void:
	_combo_timer = maxf(0.0, _combo_timer - delta)
	if _pending_hit < 0.0:
		return
	_pending_hit -= delta
	if _pending_hit <= 0.0:
		_pending_hit = -1.0
		attack_performed.emit(global_position)

## Starts a flight if it is off cooldown (not while shrunk or giant). Returns true on take-off.
func try_fly() -> bool:
	if is_flying() or flight_cooldown > 0.0 or is_shrunk() or is_giant():
		return false
	flight_remaining = FLIGHT_DURATION
	flight_cooldown = FLIGHT_COOLDOWN
	flight_dir = -1 if facing == "left" else 1
	flight_changed.emit(true)
	return true

func is_flying() -> bool:
	return flight_remaining > 0.0

func _update_flight(delta: float) -> void:
	if flight_remaining > 0.0:
		flight_remaining = maxf(0.0, flight_remaining - delta)
		if flight_remaining <= 0.0:
			flight_changed.emit(false)
	elif flight_cooldown > 0.0:
		flight_cooldown = maxf(0.0, flight_cooldown - delta)

func _update_charge(delta: float) -> void:
	if not Input.is_action_pressed("attack") or is_flying():
		charge_time = 0.0
		_charged = false
		return
	charge_time += delta
	if charge_time >= SPIN_CHARGE and not _charged:
		_charged = true
		charge_ready.emit()

func is_giant() -> bool:
	return giant_remaining > 0.0

func activate_giant(seconds: float) -> void:
	giant_remaining = seconds
	shrink_remaining = 0.0

func _update_sprite(delta: float, input_direction: Vector2) -> void:
	if is_flying():
		# Flying pose: the side-on stride frame; the presentation turns him horizontal.
		facing = "left" if flight_dir < 0 else "right"
		sprite.texture = strike_textures[facing]
		sprite.scale = Vector2.ONE
		return
	if attack_timer > 0.0:
		attack_timer = maxf(0.0, attack_timer - delta)
		sprite.texture = strike_textures[facing]
		sprite.scale = Vector2(0.5, 0.5) if is_shrunk() else Vector2.ONE
	elif is_shrunk():
		sprite.texture = idle_textures[facing]
		sprite.scale = Vector2(0.5, 0.5)
	else:
		sprite.scale = Vector2.ONE
		sprite.flip_h = false
		if absf(input_direction.x) > absf(input_direction.y):
			facing = "left" if input_direction.x < 0.0 else "right"
		elif input_direction.y < 0.0:
			facing = "up"
		elif input_direction.y > 0.0:
			facing = "down"
		if input_direction != Vector2.ZERO:
			animation_timer += delta
			var frame: int = mini(int(animation_timer * 8.0) % 8, 7)
			var walk_frames: Array = walk_textures[facing]
			sprite.texture = walk_frames[frame]
			footstep_timer -= delta
			if footstep_timer <= 0.0:
				footstep_timer = 0.24
				if has_node("/root/AudioManager"):
					get_node("/root/AudioManager").play_sfx("footstep", -11.0, 0.92)
		else:
			animation_timer = 0.0
			sprite.texture = idle_textures[facing]

func _update_shrink(delta: float) -> void:
	if shrink_remaining > 0.0:
		shrink_remaining = maxf(0.0, shrink_remaining - delta)
		GameEvents.shrink_ability_updated.emit(shrink_remaining > 0.0, shrink_cooldown, SHRINK_COOLDOWN, shrink_remaining, SHRINK_DURATION)
	elif shrink_cooldown > 0.0:
		shrink_cooldown = maxf(0.0, shrink_cooldown - delta)
		GameEvents.shrink_ability_updated.emit(false, shrink_cooldown, SHRINK_COOLDOWN, 0.0, SHRINK_DURATION)

func is_shrunk() -> bool:
	return shrink_remaining > 0.0

func take_damage(amount: int) -> void:
	if is_giant():
		return
	health = maxi(0, health - amount)
	GameEvents.player_health_changed.emit(health, max_health)
	if health <= 0:
		GameEvents.player_died.emit()

func restore_health() -> void:
	health = max_health
	GameEvents.player_health_changed.emit(health, max_health)
