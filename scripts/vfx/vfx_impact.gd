class_name VFXImpact
extends Node2D

## VFXImpact: one-shot impact effects that free themselves.
## VFXImpact.shockwave(parent, pos, 80)   – expanding ground ring + dust (heavy slams)
## VFXImpact.sparks(parent, pos, color)   – burst of sparks (hits, bites, blocks)

var _kind: String = "sparks"
var _color: Color = Color.WHITE
var _max_radius: float = 60.0
var _squash: float = 0.5
var _life: float = 0.0
var _duration: float = 0.45
var _particles: Array[Dictionary] = []

static func shockwave(parent: Node, at: Vector2, max_radius: float = 80.0, color: Color = Color(1.0, 0.85, 0.6), squash: float = 0.5) -> VFXImpact:
	var fx := VFXImpact.new()
	fx._kind = "shockwave"
	fx._color = color
	fx._max_radius = max_radius
	fx._squash = squash
	fx._duration = 0.5
	fx._spawn_particles(14, max_radius * 2.2, Color(0.75, 0.68, 0.55))
	parent.add_child(fx)
	fx.global_position = at
	return fx

static func sparks(parent: Node, at: Vector2, color: Color = Color(1.0, 0.9, 0.5), count: int = 10) -> VFXImpact:
	var fx := VFXImpact.new()
	fx._kind = "sparks"
	fx._color = color
	fx._duration = 0.35
	fx._spawn_particles(count, 150.0, color)
	parent.add_child(fx)
	fx.global_position = at
	return fx

func _spawn_particles(count: int, speed: float, color: Color) -> void:
	for i in count:
		var angle := randf() * TAU
		var velocity := Vector2.from_angle(angle) * speed * randf_range(0.4, 1.0)
		if _kind == "shockwave":
			velocity.y *= _squash
		_particles.append({"pos": Vector2.ZERO, "vel": velocity, "color": color, "size": randf_range(1.0, 2.5)})

func _process(delta: float) -> void:
	_life += delta
	if _life >= _duration:
		queue_free()
		return
	for p in _particles:
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.9
	queue_redraw()

func _draw() -> void:
	var t := _life / _duration
	var fade := 1.0 - t
	if _kind == "shockwave":
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, _squash))
		var r := _max_radius * (1.0 - pow(1.0 - t, 3.0))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(_color, fade), 3.0 * fade + 1.0)
		draw_arc(Vector2.ZERO, r * 0.7, 0.0, TAU, 40, Color(_color, fade * 0.4), 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_circle(Vector2.ZERO, 10.0 * (1.0 - t), Color(1.0, 1.0, 1.0, fade * 0.8))
	for p in _particles:
		draw_rect(Rect2(p["pos"] - Vector2.ONE * p["size"] * 0.5, Vector2.ONE * p["size"]), Color(p["color"], fade))
