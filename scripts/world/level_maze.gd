class_name LevelMaze
extends Node2D

## LevelMaze: builds a chapter's maze from MazeLayouts — collision walls, themed wall art,
## exit beacons — and answers spatial questions (start, exits, markers, line of sight).
## Walls use physics layer 1; crevices use layer 2, which Hanuman ignores while shrunk.

const CELL := 32
const ORIGIN_Y := 4
const COLS := 20
const ROWS := 11
const CREVICE_LAYER := 2

var theme := "ocean"
var _rows: Array = []
var _walls: StaticBody2D
var _crevices: StaticBody2D

func _ready() -> void:
	_walls = StaticBody2D.new()
	_walls.name = "Walls"
	add_child(_walls)
	_crevices = StaticBody2D.new()
	_crevices.name = "Crevices"
	_crevices.collision_layer = 0
	_crevices.set_collision_layer_value(CREVICE_LAYER, true)
	add_child(_crevices)

## Rebuilds collisions and art for a chapter. Chapters without a layout get no maze.
func build(chapter: int) -> void:
	theme = ["", "ocean", "gates", "palace", "ashoka", "rooftops"][clampi(chapter, 0, 5)]
	_rows = MazeLayouts.LAYOUTS.get(chapter, [])
	for body in [_walls, _crevices]:
		for shape in body.get_children():
			shape.free()
	for y in _rows.size():
		_add_runs(y, ["#", "X"], _walls)
		_add_runs(y, ["c"], _crevices)
	queue_redraw()

## Merges horizontal runs of matching cells into single rectangle shapes.
func _add_runs(y: int, kinds: Array, body: StaticBody2D) -> void:
	var row: String = _rows[y]
	var x := 0
	while x < row.length():
		if not row[x] in kinds:
			x += 1
			continue
		var start := x
		while x < row.length() and row[x] in kinds:
			x += 1
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2((x - start) * CELL, CELL)
		shape.shape = rect
		shape.position = Vector2(start * CELL, ORIGIN_Y + y * CELL) + rect.size * 0.5
		body.add_child(shape)

# --- Queries ---------------------------------------------------------------------------

func has_layout() -> bool:
	return not _rows.is_empty()

func cell_at(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x / CELL), floori((point.y - ORIGIN_Y) / CELL))

func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL + CELL * 0.5, ORIGIN_Y + cell.y * CELL + CELL * 0.5)

func kind_at(cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= _rows.size() or cell.x < 0 or cell.x >= String(_rows[cell.y]).length():
		return "X"
	return _rows[cell.y][cell.x]

func is_crevice(point: Vector2) -> bool:
	return kind_at(cell_at(point)) == "c"

func is_exit(point: Vector2) -> bool:
	return kind_at(cell_at(point)) == "E"

## Centre of the first cell marked `marker` (S, G, T, …), or `fallback` if absent.
func marker_position(marker: String, fallback: Vector2 = Vector2(50, 180)) -> Vector2:
	for y in _rows.size():
		var x: int = String(_rows[y]).find(marker)
		if x >= 0:
			return cell_center(Vector2i(x, y))
	return fallback

## True when no wall (#, X) or crevice blocks the straight line between two points.
func has_line_of_sight(from: Vector2, to: Vector2) -> bool:
	var steps := int(from.distance_to(to) / 6.0)
	for i in range(1, steps):
		if kind_at(cell_at(from.lerp(to, float(i) / steps))) in ["#", "X", "c"]:
			return false
	return true

# --- Drawing ---------------------------------------------------------------------------

func _process(_delta: float) -> void:
	if has_layout():
		queue_redraw()

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for y in _rows.size():
		for x in String(_rows[y]).length():
			var kind: String = _rows[y][x]
			var cell := Vector2i(x, y)
			match kind:
				"#": _draw_wall(cell, t)
				"c": _draw_crevice(cell, t)
				"E": _draw_exit(cell, t)

func _is_solid(cell: Vector2i) -> bool:
	return kind_at(cell) in ["#", "c"]

## Walls read as raised blocks: a lit top face, plus a darker front face where the floor
## is visible below. Each theme only changes palette and surface detail.
func _draw_wall(cell: Vector2i, t: float) -> void:
	var r := Rect2(cell.x * CELL, ORIGIN_Y + cell.y * CELL, CELL, CELL)
	var open_below := not _is_solid(cell + Vector2i.DOWN) and kind_at(cell + Vector2i.DOWN) != "X"
	var front := 9.0 if open_below else 0.0
	var top := Rect2(r.position, Vector2(CELL, CELL - front))
	var face := Rect2(r.position + Vector2(0, CELL - front), Vector2(CELL, front))
	var seed_v := cell.x * 7 + cell.y * 13
	match theme:
		"ocean":
			# Reef rock: a lumpy boulder cluster with a lit crown, ringed by lapping foam.
			var c := r.get_center()
			var foam := 0.35 + 0.3 * sin(t * 2.5 + seed_v)
			draw_circle(c + Vector2(0, 3), 17.0, Color(0.9, 0.97, 1.0, foam * 0.5))
			draw_circle(c + Vector2(-5, 3), 12.0, Color("#1c1a24"))
			draw_circle(c + Vector2(6, 4), 11.0, Color("#1c1a24"))
			draw_circle(c + Vector2(-5, 0), 11.0, Color("#2c2834"))
			draw_circle(c + Vector2(6, 1), 10.0, Color("#2c2834"))
			draw_circle(c + Vector2(0, -4), 10.0, Color("#585266"))
			draw_circle(c + Vector2(-3, -7), 5.0, Color("#8c869e"))
			draw_rect(Rect2(c + Vector2(4, -6), Vector2(3, 2)), Color("#8c869e"))
			if (seed_v % 4) == 0:
				draw_rect(Rect2(c + Vector2(-9, 4), Vector2(3, 2)), Color("#2d5e3c"))
		"gates":
			draw_rect(top, Color("#d4c19c"))
			for row in 3:
				var yy := top.position.y + 2 + row * 8
				if yy > top.end.y - 2:
					break
				draw_line(Vector2(top.position.x, yy), Vector2(top.end.x, yy), Color("#917756"), 1.0)
				var shift := 8.0 if (row + cell.x) % 2 == 0 else 0.0
				for bx in [shift, shift + 16.0]:
					draw_line(Vector2(top.position.x + bx, yy), Vector2(top.position.x + bx, minf(yy + 8, top.end.y)), Color("#917756"), 1.0)
			draw_rect(Rect2(top.position, Vector2(CELL, 2)), Color("#fce27c"))
			if open_below:
				draw_rect(face, Color("#917756"))
				draw_rect(Rect2(face.position, Vector2(CELL, 1)), Color("#522b16"))
		"palace":
			draw_rect(top, Color("#5b80a6"))
			draw_rect(top.grow(-3), Color("#3b4876"))
			draw_rect(Rect2(top.position, Vector2(CELL, 2)), Color("#8bc1b8"))
			draw_rect(Rect2(top.position + Vector2(CELL * 0.5 - 1, 4), Vector2(2, maxf(0.0, top.size.y - 8))), Color("#26294a"))
			if open_below:
				draw_rect(face, Color("#26294a"))
				draw_rect(Rect2(face.position, Vector2(CELL, 1)), Color("#f7b945", 0.7))
				if seed_v % 3 == 0:
					# Wall lamp: flickering flame with a warm glow on the floor below.
					var flick := 0.75 + 0.25 * sin(t * 11.0 + seed_v)
					var lamp := face.position + Vector2(CELL * 0.5, 4)
					draw_circle(lamp + Vector2(0, 14), 14.0, Color(0.97, 0.72, 0.27, 0.10 * flick))
					draw_circle(lamp, 2.5 * flick, Color("#f7b945"))
					draw_circle(lamp, 1.2, Color("#fbf4e2"))
		"ashoka":
			draw_rect(r.grow(-2), Color("#1c3024"))
			for i in 5:
				var p := top.position + Vector2(6 + (seed_v * (i + 3)) % 20, 5 + (seed_v * (i + 5)) % maxi(4, int(top.size.y) - 8))
				draw_circle(p, 7.0, Color("#2d5e3c"))
			for i in 3:
				var p := top.position + Vector2(5 + (seed_v * (i + 2)) % 22, 4 + (seed_v * (i + 7)) % maxi(4, int(top.size.y) - 6))
				draw_circle(p, 3.0, Color("#5ca361"))
			for i in 2:
				var p := top.position + Vector2(4 + (seed_v * (i + 11)) % 24, 4 + (seed_v * (i + 13)) % maxi(4, int(top.size.y) - 6))
				draw_rect(Rect2(p, Vector2(2, 2)), Color("#e86a82") if i == 0 else Color("#eb7e28"))
			if open_below:
				draw_rect(face, Color("#142319"))
		_:
			draw_rect(r, Color("#585266"))

func _draw_crevice(cell: Vector2i, t: float) -> void:
	_draw_wall(cell, t)
	# A narrow golden slit: "only something very small fits through here".
	var r := Rect2(cell.x * CELL, ORIGIN_Y + cell.y * CELL, CELL, CELL)
	var glow := 0.55 + 0.35 * sin(t * 4.0)
	# Walls above/below mean you pass left↔right, so the slit runs horizontally (and vice versa).
	var passes_sideways := _is_solid(cell + Vector2i.UP) or _is_solid(cell + Vector2i.DOWN)
	var slit := Rect2(r.position + Vector2(2, 14), Vector2(CELL - 4, 4)) if passes_sideways \
		else Rect2(r.position + Vector2(14, 2), Vector2(4, CELL - 4))
	draw_rect(slit, Color(0.04, 0.03, 0.08))
	draw_rect(slit.grow(1), Color(0.99, 0.89, 0.49, 0.5 * glow), false, 1.0)

func _draw_exit(cell: Vector2i, t: float) -> void:
	var r := Rect2(cell.x * CELL, ORIGIN_Y + cell.y * CELL, CELL, CELL)
	var pulse := 0.5 + 0.5 * sin(t * 3.0)
	draw_rect(r, Color(0.99, 0.89, 0.49, 0.10 + 0.10 * pulse))
	for i in 3:
		var a := Color(0.99, 0.89, 0.49, (0.7 - i * 0.2) * (0.6 + 0.4 * pulse))
		var cx := r.position.x + 10 + i * 6 + pulse * 2
		draw_line(Vector2(cx, r.get_center().y - 5), Vector2(cx + 5, r.get_center().y), a, 2.0)
		draw_line(Vector2(cx + 5, r.get_center().y), Vector2(cx, r.get_center().y + 5), a, 2.0)
