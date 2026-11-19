extends AnimatedSprite2D
## Presentation-only animation driven by the canonical controller's velocity.

const IDLE_TEXTURE := preload("res://assets/characters/hanuman/char_hanuman_idle.png")
const RUN_TEXTURES := [
	preload("res://assets/characters/hanuman/char_hanuman_run_01.png"),
	preload("res://assets/characters/hanuman/char_hanuman_run_02.png"),
]

func _ready() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("idle")
	frames.add_frame("idle", IDLE_TEXTURE)
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 1.0)
	frames.add_animation("run")
	for texture in RUN_TEXTURES:
		frames.add_frame("run", texture)
	frames.set_animation_loop("run", true)
	frames.set_animation_speed("run", 8.0)
	sprite_frames = frames
	play("idle")

func _physics_process(_delta: float) -> void:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return
	if player.velocity.length_squared() > 4.0:
		if animation != "run":
			play("run")
		if absf(player.velocity.x) > 1.0:
			flip_h = player.velocity.x < 0.0
	elif animation != "idle":
		play("idle")
