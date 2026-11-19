class_name TelegraphMarker
extends Node2D

## TelegraphMarker: ground warning for an incoming enemy attack.
## The drawn shape IS the danger area: gameplay should test hits with contains(),
## so what the player sees always matches what can hurt them.
## Flow: begin(windup_seconds) → fills up and pulses faster → trigger() flashes on impact.

enum Shape { ELLIPSE, RECT }

@export var shape: Shape = Shape.ELLIPSE
@export var radius: float = 40.0
@export var squash: float = 0.5
@export var rect_size: Vector2 = Vector2(100, 300)
@export var color: Color = Color(1.0, 0.25, 0.2)

var _duration: float = 1.0
var _progress: float = 0.0
var _active: bool = false
var _flash: float = 0.0

func _ready() -> void:
	visible = false

func begin(windup_seconds: float) -> void:
	_duration = maxf(windup_seconds, 0.01)
	_progress = 0.0
	_flash = 0.0
	_active = true
	visible = true

func trigger() -> void:
	_active = false
	_progress = 1.0
	_flash = 1.0
	visible = true

func cancel() -> void:
	_active = false
	_flash = 0.0
	visible = false

func is_warning() -> bool:
	return _active

## True if a global point lies inside the danger area.
func contains(global_point: Vector2) -> bool:
	var local := global_point - global_position
	if shape == Shape.RECT:
		return absf(local.x) <= rect_size.x * 0.5 and absf(local.y) <= rect_size.y * 0.5
	var ry := radius * squash
	return (local.x * local.x) / (radius * radius) + (local.y * local.y) / (ry * ry) <= 1.0

func _process(delta: float) -> void:
	if _active:
		_progress = minf(1.0, _progress + delta / _duration)
	elif _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 3.5)
		if _flash <= 0.0:
			visible = false
	if visible:
		queue_redraw()

func _draw() -> void:
	# Pulse speeds up as the strike approaches so the timing can be read without UI.
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * (6.0 + _progress * 18.0))
	var fill := Color(color, 0.18 + 0.2 * pulse * _progress)
	var edge := Color(color, 0.45 + 0.45 * pulse)
	if _flash > 0.0:
		fill = Color(1.0, 0.95, 0.85, 0.55 * _flash)
		edge = Color(1.0, 1.0, 1.0, _flash)
	if shape == Shape.RECT:
		var half := rect_size * 0.5
		var full := Rect2(-half, rect_size)
		# The fill grows inward from both edges, closing like jaws.
		var closing := half.x * (_progress if _flash <= 0.0 else 1.0)
		draw_rect(Rect2(-half.x, -half.y, closing, rect_size.y), fill)
		draw_rect(Rect2(half.x - closing, -half.y, closing, rect_size.y), fill)
		draw_rect(full, edge, false, 2.0)
		for y in range(int(-half.y) + 8, int(half.y), 24):
			draw_colored_polygon(PackedVector2Array([Vector2(-half.x, y), Vector2(-half.x + 7, y + 5), Vector2(-half.x, y + 10)]), edge)
			draw_colored_polygon(PackedVector2Array([Vector2(half.x, y), Vector2(half.x - 7, y + 5), Vector2(half.x, y + 10)]), edge)
		return
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, squash))
	draw_circle(Vector2.ZERO, radius * maxf(_progress, 0.08), fill)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, edge, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
