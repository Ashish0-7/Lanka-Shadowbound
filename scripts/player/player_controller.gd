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

func _ready() -> void:
	health = max_health
	GameEvents.player_health_changed.emit(health, max_health)
	GameEvents.shrink_ability_updated.emit(false, 0.0, SHRINK_COOLDOWN, 0.0, SHRINK_DURATION)

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * (move_speed * (0.72 if is_shrunk() else 1.0))
	move_and_slide()
	global_position.x = clampf(global_position.x, 16.0, 624.0)
	global_position.y = clampf(global_position.y, 16.0, 344.0)
	_update_shrink(delta)
	_update_attack(delta)
	_update_sprite(delta, input_direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ability") and shrink_cooldown <= 0.0:
		shrink_remaining = SHRINK_DURATION
		shrink_cooldown = SHRINK_COOLDOWN
		GameEvents.shrink_ability_updated.emit(true, 0.0, SHRINK_COOLDOWN, shrink_remaining, SHRINK_DURATION)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("attack") and _pending_hit < 0.0:
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

func _update_sprite(delta: float, input_direction: Vector2) -> void:
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
	health = maxi(0, health - amount)
	GameEvents.player_health_changed.emit(health, max_health)
	if health <= 0:
		GameEvents.player_died.emit()

func restore_health() -> void:
	health = max_health
	GameEvents.player_health_changed.emit(health, max_health)
