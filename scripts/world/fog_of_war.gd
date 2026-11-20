class_name FogOfWar
extends Node2D

## FogOfWar: gameplay visibility for night chapters (the camera decides what is on screen;
## this decides what Hanuman can actually see).
##   • Cells within sight radius AND line of sight are clear.
##   • Explored cells stay dimly remembered; unexplored cells are near-black.
##   • Lamps and guard lanterns light the cells around them — visible from far away
##     whenever Hanuman has line of sight to the light.
##   • Imps hidden in darkness nearby show glinting red eyes, so threats are never invisible.
## Drawn above the world but below Hanuman; only on-screen cells are drawn.

var maze: LevelMaze
var player: Node2D
var swarm: MinionSwarm
var guards: Array[Vector2] = []

var enabled := false
var sight_radius := 4.5 * LevelMaze.CELL
var light_reach := 12 * LevelMaze.CELL
var unexplored_alpha := 0.96
var remembered_alpha := 0.6
var fog_color := Color("#05040c")

var _cols := 0
var _rows := 0
var _alpha := PackedFloat32Array()
var _explored := PackedByteArray()
var _visible := PackedByteArray()
var _timer := 0.0

## enabled: fog on/off. sight_cells: Hanuman's sight radius in cells.
func configure(on: bool, sight_cells: float = 4.5, remembered: float = 0.6, color: Color = Color("#05040c")) -> void:
	enabled = on
	sight_radius = sight_cells * LevelMaze.CELL
	remembered_alpha = remembered
	fog_color = color
	_cols = maze.cols
	_rows = maze.rows
	var n := _cols * _rows
	_alpha.resize(n)
	_alpha.fill(unexplored_alpha)
	_explored.resize(n)
	_explored.fill(0)
	_visible.resize(n)
	_visible.fill(0)
	_timer = 0.0
	visible = on
	if on:
		_recompute()
		# Start with the immediate surroundings already revealed (no fade-in at spawn).
		for i in n:
			if _visible[i] == 1:
				_alpha[i] = 0.0

func is_cell_visible(cell: Vector2i) -> bool:
	if not enabled:
		return true
	return _in(cell) and _visible[cell.y * _cols + cell.x] == 1

func _in(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < _cols and cell.y < _rows

func _process(delta: float) -> void:
	if not enabled:
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = 0.08
		_recompute()
	var area := _view_cells()
	var fade := minf(1.0, delta * 7.0)
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var i := y * _cols + x
			var target := 0.0 if _visible[i] == 1 else (remembered_alpha if _explored[i] == 1 else unexplored_alpha)
			_alpha[i] = lerpf(_alpha[i], target, fade)
	queue_redraw()

func _recompute() -> void:
	_visible.fill(0)
	var origin: Vector2 = player.global_position
	_reveal_around(origin, sight_radius, origin)
	# Light sources: lit areas are visible from afar if Hanuman can see the light itself.
	var lights: Array[Vector2] = maze.lamp_positions().duplicate()
	for g in guards:
		lights.append(g)
	for light in lights:
		if light.distance_to(origin) <= light_reach and _can_see(origin, maze.cell_at(light)):
			_reveal_around(light, 2.2 * LevelMaze.CELL, light)

## Marks cells within `radius` of `center` that `eye` can see as visible and explored.
func _reveal_around(center: Vector2, radius: float, eye: Vector2) -> void:
	var c := maze.cell_at(center)
	var reach := int(ceil(radius / LevelMaze.CELL))
	for dy in range(-reach, reach + 1):
		for dx in range(-reach, reach + 1):
			var cell := c + Vector2i(dx, dy)
			if not _in(cell) or maze.cell_center(cell).distance_to(center) > radius:
				continue
			if _can_see(eye, cell):
				var i := cell.y * _cols + cell.x
				_visible[i] = 1
				_explored[i] = 1

## Line of sight from a point to a cell. Opaque cells block the view of what lies behind
## them, but the opaque cell itself (a wall face) is still seen.
func _can_see(eye: Vector2, cell: Vector2i) -> bool:
	var target := maze.cell_center(cell)
	var start := maze.cell_at(eye)
	var steps := int(eye.distance_to(target) / 8.0)
	for i in range(1, steps):
		var c := maze.cell_at(eye.lerp(target, float(i) / steps))
		if c == cell:
			return true
		if c != start and maze.is_opaque(c):
			return false
	return true

func _view_cells() -> Rect2i:
	var view := get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
	var a := maze.cell_at(view.position) - Vector2i(1, 1)
	var b := maze.cell_at(view.end) + Vector2i(2, 2)
	a = a.clamp(Vector2i.ZERO, Vector2i(_cols, _rows))
	b = b.clamp(Vector2i.ZERO, Vector2i(_cols, _rows))
	return Rect2i(a, b - a)

func _a(x: int, y: int, fallback: float) -> float:
	if x < 0 or y < 0 or x >= _cols or y >= _rows:
		return fallback
	return _alpha[y * _cols + x]

func _draw() -> void:
	if not enabled:
		return
	var area := _view_cells()
	var half := LevelMaze.CELL * 0.5
	# Each cell is drawn as four quarters blended with its neighbours, softening the edges.
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var own := _alpha[y * _cols + x]
			var base := Vector2(x * LevelMaze.CELL, LevelMaze.ORIGIN_Y + y * LevelMaze.CELL)
			for q in 4:
				var sx := -1 if q % 2 == 0 else 1
				var sy := -1 if q < 2 else 1
				var a := (own * 2.0 + _a(x + sx, y, own) + _a(x, y + sy, own)) / 4.0
				if a < 0.01:
					continue
				draw_rect(Rect2(base + Vector2(half if sx > 0 else 0.0, half if sy > 0 else 0.0), Vector2(half, half)), Color(fog_color, a))
	_draw_threat_glints()

## Imps lurking in darkness near Hanuman betray themselves with blinking red eyes.
func _draw_threat_glints() -> void:
	if swarm == null:
		return
	var t := Time.get_ticks_msec() / 1000.0
	for m in swarm._minions:
		var sprite: Node2D = m["sprite"]
		var cell := maze.cell_at(sprite.position)
		if is_cell_visible(cell) or sprite.position.distance_to(player.global_position) > 7 * LevelMaze.CELL:
			continue
		if fmod(t + sprite.position.x * 0.01, 2.2) < 0.15:
			continue
		var a := 0.55 + 0.35 * sin(t * 4.0 + sprite.position.y)
		draw_rect(Rect2(sprite.position + Vector2(-3, -1), Vector2(2, 1)), Color(1.0, 0.25, 0.2, a))
		draw_rect(Rect2(sprite.position + Vector2(2, -1), Vector2(2, 1)), Color(1.0, 0.25, 0.2, a))
