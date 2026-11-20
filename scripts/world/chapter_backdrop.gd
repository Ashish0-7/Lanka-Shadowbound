class_name ChapterBackdrop
extends Node2D

## ChapterBackdrop: painted scenery for each chapter, sized to the whole level (which is
## larger than the screen). The top band (y < HORIZON) is sky/skyline; below is the floor.
## Static scenery is drawn once per chapter; the animated layer (waves, fireflies, flames,
## guard vision) redraws every frame but only inside the camera view. Display only.

const HORIZON := 96.0

var chapter := 1
var maze: LevelMaze
var world := Rect2(0, 0, 640, 384)
## Positions supplied by the director for the current chapter.
var surasa_position := Vector2.ZERO
var simhika_position := Vector2.ZERO
var lankini_position := Vector2.ZERO
var guards: Array[Vector2] = []
var guard_radius := 105.0
var guard_alert := 0.0
var sita_position := Vector2.ZERO
var sita_found := false
var fire_zone := Rect2()

var _fx: Node2D

func _ready() -> void:
	_fx = Node2D.new()
	_fx.name = "AnimatedLayer"
	_fx.draw.connect(_draw_animated)
	add_child(_fx)

func _process(_delta: float) -> void:
	_fx.queue_redraw()

## Repaints the static scenery for the current chapter (call after changing chapter/positions).
func refresh() -> void:
	world = maze.world_rect() if maze and maze.has_layout() else Rect2(0, 0, 640, 384)
	queue_redraw()

func _view() -> Rect2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()

func _draw() -> void:
	match chapter:
		1: _static_ocean()
		2: _static_gates()
		3: _static_palace()
		4: _static_grove()
		5: _static_rooftops()

func _draw_animated() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var view := _view().grow(32)
	match chapter:
		1: _anim_ocean(t, view)
		2: _anim_gates(t)
		3: _anim_palace(t)
		4: _anim_grove(t, view)
		5: _anim_rooftops(t, view)

# --- Shared helpers ---------------------------------------------------------------------

func _sky(top: Color, bottom: Color) -> void:
	var bands := int(HORIZON / 4.0)
	for i in bands:
		draw_rect(Rect2(world.position.x, i * 4, world.size.x, 4), top.lerp(bottom, float(i) / (bands - 1)))

func _stars(count: int) -> void:
	for i in count:
		var p := Vector2(fposmod(i * 97.3, world.size.x), fposmod(i * 37.9, HORIZON - 30.0) + 4.0)
		draw_rect(Rect2(p, Vector2.ONE), Color(0.98, 0.96, 0.89, 0.4 + 0.6 * float(i % 3) / 2.0))

func _moon(at: Vector2, radius: float) -> void:
	draw_circle(at, radius * 2.6, Color(0.98, 0.96, 0.89, 0.05))
	draw_circle(at, radius * 1.6, Color(0.98, 0.96, 0.89, 0.08))
	draw_circle(at, radius, Color("#fbf4e2"))
	draw_circle(at + Vector2(-radius * 0.3, -radius * 0.2), radius * 0.25, Color("#d4c19c"))
	draw_circle(at + Vector2(radius * 0.35, radius * 0.3), radius * 0.18, Color("#d4c19c"))

func _dome(base_center: Vector2, width: float, height: float, color: Color, on: CanvasItem = self) -> void:
	var points := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		points.append(base_center + Vector2(cos(a) * width * 0.5, sin(a) * height))
	on.draw_colored_polygon(points, color)
	on.draw_line(base_center + Vector2(0, -height), base_center + Vector2(0, -height - 6), color, 2.0)

func _floor() -> Rect2:
	return Rect2(world.position.x, HORIZON, world.size.x, world.end.y - HORIZON)

# --- Chapter 1: Crossing the Ocean ------------------------------------------------------

func _static_ocean() -> void:
	_sky(Color("#0b1c33"), Color("#3a5f86"))
	_stars(int(world.size.x / 30.0))
	draw_rect(Rect2(world.position.x, HORIZON - 4, world.size.x, 4), Color("#e8a04a").darkened(0.15))
	# Lanka on the far horizon, at the end of the journey.
	var lanka := Color("#14142a")
	var lx := world.end.x - 110.0
	draw_rect(Rect2(lx - 10, HORIZON - 16, 120, 12), lanka)
	for tower in [[12.0, 70.0, 10.0], [32.0, 58.0, 12.0], [56.0, 50.0, 14.0], [82.0, 64.0, 10.0]]:
		var tx: float = lx + tower[0]
		draw_rect(Rect2(tx, tower[1], tower[2], HORIZON - 4 - tower[1]), lanka)
		draw_colored_polygon(PackedVector2Array([Vector2(tx - 2, tower[1]), Vector2(tx + tower[2] / 2.0, tower[1] - 10), Vector2(tx + tower[2] + 2, tower[1])]), lanka)
		draw_rect(Rect2(tx + tower[2] / 2.0 - 1, tower[1] + 8, 2, 3), Color("#f7c55a"))
	var sea := _floor()
	var bands := int(sea.size.y / 8.0) + 1
	for i in bands:
		draw_rect(Rect2(sea.position.x, sea.position.y + i * 8, sea.size.x, 8), Color("#2c6c8e").lerp(Color("#0f3150"), minf(1.0, i / 32.0)))

func _anim_ocean(t: float, view: Rect2) -> void:
	var y0 := maxf(HORIZON + 8.0, view.position.y)
	var first_row := int((y0 - HORIZON - 8.0) / 22.0)
	for row in range(first_row, first_row + int(view.size.y / 22.0) + 2):
		var y := HORIZON + 8.0 + row * 22.0
		if y > world.end.y:
			break
		var dir := 1.0 if row % 2 == 0 else -1.0
		var length := 8.0 + (row % 12) * 1.5
		var offset := fposmod(t * (10.0 + (row % 12) * 2.0) * dir + row * 37.0, 48.0)
		var k0 := int((view.position.x - 48.0) / 48.0)
		for k in range(k0, k0 + int(view.size.x / 48.0) + 3):
			var x := k * 48.0 + offset
			_fx.draw_line(Vector2(x, y), Vector2(x + length, y), Color(0.55, 0.8, 0.9, 0.34), 1.0)
	if surasa_position != Vector2.ZERO:
		_fx.draw_set_transform(surasa_position + Vector2(0, 34), 0.0, Vector2(1.0, 0.32))
		for ring in 4:
			var r := 30.0 + ring * 10.0 + sin(t * 2.0 + ring) * 2.0
			_fx.draw_arc(Vector2.ZERO, r, t * 1.5 + ring, t * 1.5 + ring + TAU * 0.8, 32, Color(0.75, 0.9, 1.0, 0.45 - ring * 0.08), 2.0)
	if simhika_position != Vector2.ZERO:
		_fx.draw_set_transform(simhika_position + Vector2(0, 36), 0.0, Vector2(1.0, 0.3))
		_fx.draw_circle(Vector2.ZERO, 46.0 + sin(t * 1.7) * 3.0, Color(0.12, 0.02, 0.18, 0.75))
		_fx.draw_circle(Vector2.ZERO, 30.0, Color(0.28, 0.06, 0.36, 0.55))
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Chapter 2: The Gates of Lanka -------------------------------------------------------

func _gate_x() -> float:
	return lankini_position.x if lankini_position != Vector2.ZERO else world.get_center().x

func _static_gates() -> void:
	_sky(Color("#26294a"), Color("#eb7e28"))
	var gx := _gate_x()
	draw_circle(Vector2(gx, 56), 40.0, Color(0.99, 0.89, 0.49, 0.12))
	draw_circle(Vector2(gx, 56), 24.0, Color("#fce27c"))
	var wall := Color("#b54e18")
	var wall_top := Color("#f7b945")
	draw_rect(Rect2(world.position.x, 58, world.size.x, HORIZON - 58), wall)
	for x in range(int(world.position.x), int(world.end.x), 16):
		draw_rect(Rect2(x, 52, 9, 7), wall)
		draw_rect(Rect2(x, 52, 9, 2), wall_top)
	for x in range(int(world.position.x), int(world.end.x), 24):
		draw_line(Vector2(x, 66), Vector2(x, HORIZON), Color("#522b16"), 1.0)
	for tower_x in range(int(world.position.x) + 60, int(world.end.x), 180):
		if absf(tower_x - gx) < 90:
			continue
		draw_rect(Rect2(tower_x - 16, 26, 32, HORIZON - 26), wall.darkened(0.15))
		draw_rect(Rect2(tower_x - 16, 26, 32, 2), wall_top)
		_dome(Vector2(tower_x, 26), 30.0, 16.0, wall_top)
		draw_rect(Rect2(tower_x - 3, 42, 6, 10), Color("#26294a"))
	draw_rect(Rect2(gx - 48, 26, 96, HORIZON - 26), wall.darkened(0.25))
	_dome(Vector2(gx, 26), 100.0, 22.0, wall_top)
	draw_rect(Rect2(gx - 30, 42, 60, HORIZON - 42), Color("#16172e"))
	draw_rect(Rect2(gx - 30, 42, 60, HORIZON - 42), wall_top, false, 2.0)
	# Flagstone courtyards.
	var f := _floor()
	for row in range(0, int(f.size.y / 16.0) + 1):
		var y := f.position.y + row * 16.0
		var shift := 16.0 if row % 2 else 0.0
		for col in range(-1, int(f.size.x / 32.0) + 1):
			var x := f.position.x + col * 32.0 + shift
			var shade := 0.04 * float((col * 7 + row * 3) % 4)
			draw_rect(Rect2(x + 1, y + 1, 30, 14), Color("#585266").lerp(Color("#917756"), 0.35 + shade))
	draw_rect(f, Color(0.71, 0.31, 0.09, 0.06))
	if lankini_position != Vector2.ZERO:
		draw_set_transform(lankini_position + Vector2(0, 34), 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, 92.0, Color("#522b16", 0.35))
		draw_arc(Vector2.ZERO, 92.0, 0, TAU, 48, Color("#f7b945", 0.6), 2.0)
		draw_arc(Vector2.ZERO, 60.0, 0, TAU, 40, Color("#f7b945", 0.35), 1.0)
		for i in 8:
			var a := i * TAU / 8.0
			draw_line(Vector2.from_angle(a) * 60.0, Vector2.from_angle(a) * 92.0, Color("#f7b945", 0.35), 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _anim_gates(t: float) -> void:
	var gx := _gate_x()
	_fx.draw_line(Vector2(gx, 44), Vector2(gx, HORIZON), Color(0.99, 0.89, 0.49, 0.5 + 0.3 * sin(t * 2.0)), 2.0)

# --- Chapter 3: Lanka at Night -----------------------------------------------------------

func _static_palace() -> void:
	_sky(Color("#0a0814"), Color("#26294a"))
	_stars(int(world.size.x / 16.0))
	_moon(Vector2(world.position.x + 250, 28), 11.0)
	var skyline := Color("#16172e")
	draw_rect(Rect2(world.position.x, 74, world.size.x, HORIZON - 74), skyline)
	var i := 0
	for x in range(int(world.position.x) + 50, int(world.end.x), 110):
		var w := 40.0 + (i * 23) % 44
		var h := 20.0 + (i * 17) % 20
		draw_rect(Rect2(x - w * 0.45, 74 - h * 0.4, w * 0.9, h * 0.4 + 2), skyline)
		_dome(Vector2(x, 74 - h * 0.4), w, h, skyline)
		i += 1
	for k in int(world.size.x / 30.0):
		var p := Vector2(fposmod(k * 61.7, world.size.x), 78 + fposmod(k * 13.3, 14))
		draw_rect(Rect2(p, Vector2(2, 3)), Color(0.97, 0.73, 0.27, 0.6 + 0.4 * float(k % 3) / 2.0))
	# Marble checker floor washed in moonlight.
	var f := _floor()
	for row in range(0, int(f.size.y / 16.0) + 1):
		for col in range(0, int(f.size.x / 16.0) + 1):
			var dark := (row + col) % 2 == 0
			draw_rect(Rect2(f.position.x + col * 16, f.position.y + row * 16, 16, 16), Color("#10111f") if dark else Color("#181a33"))
	draw_rect(f, Color(0.36, 0.5, 0.65, 0.04))

## Each guard tints exactly the floor cells he can see, plus a warm lantern pool.
func _anim_palace(t: float) -> void:
	if maze == null:
		return
	for guard in guards:
		var center_cell := maze.cell_at(guard)
		var reach := int(ceil(guard_radius / LevelMaze.CELL))
		var tint := Color(1.0, 0.85, 0.3).lerp(Color(1.0, 0.2, 0.15), guard_alert)
		var pulse := 0.12 + 0.06 * sin(t * (3.0 + guard_alert * 10.0)) + guard_alert * 0.12
		for dy in range(-reach, reach + 1):
			for dx in range(-reach, reach + 1):
				var cell := center_cell + Vector2i(dx, dy)
				var centre := maze.cell_center(cell)
				if centre.distance_to(guard) > guard_radius or maze.is_opaque(cell) or not maze.is_walkable(cell):
					continue
				if maze.has_line_of_sight(guard, centre):
					var r := Rect2(cell.x * LevelMaze.CELL, LevelMaze.ORIGIN_Y + cell.y * LevelMaze.CELL, LevelMaze.CELL, LevelMaze.CELL)
					_fx.draw_rect(r.grow(-1), Color(tint, pulse))
		var flick := 0.85 + 0.15 * sin(t * 13.0 + guard.x)
		_fx.draw_circle(guard + Vector2(-6, 6), 26.0 * flick, Color(0.97, 0.72, 0.27, 0.10))
		_fx.draw_circle(guard + Vector2(-6, 6), 14.0 * flick, Color(0.97, 0.72, 0.27, 0.16))

# --- Chapter 4: Ashoka Vatika --------------------------------------------------------------

func _static_grove() -> void:
	_sky(Color("#0a0814"), Color("#1c3024"))
	_stars(int(world.size.x / 20.0))
	_moon(Vector2(world.position.x + 90, 30), 12.0)
	for k in int(world.size.x / 31.0) + 2:
		var x := world.position.x + k * 31.0 - 10.0
		draw_circle(Vector2(x, HORIZON - 6), 14.0 + (k * 7) % 9, Color("#142319"))
	draw_rect(Rect2(world.position.x, HORIZON - 8, world.size.x, 8), Color("#142319"))
	var f := _floor()
	draw_rect(f, Color("#1c3024"))
	var tufts := int(f.size.x * f.size.y / 1100.0)
	for k in tufts:
		var p := Vector2(f.position.x + fposmod(k * 53.1, f.size.x), f.position.y + fposmod(k * 29.7, f.size.y))
		draw_rect(Rect2(p, Vector2(2, 1)), Color("#2d5e3c"))
		if k % 9 == 0:
			draw_rect(Rect2(p + Vector2(1, -1), Vector2(1, 1)), Color("#e86a82"))
		elif k % 13 == 0:
			draw_rect(Rect2(p + Vector2(1, -1), Vector2(1, 1)), Color("#fce27c"))
	draw_rect(f, Color(0.36, 0.5, 0.65, 0.04))
	if sita_position != Vector2.ZERO:
		var base := sita_position + Vector2(0, -6)
		draw_rect(Rect2(base.x - 4, base.y - 38, 8, 30), Color("#522b16"))
		for c in [[-18.0, -48.0, 18.0], [14.0, -50.0, 17.0], [0.0, -62.0, 20.0], [-4.0, -40.0, 15.0]]:
			draw_circle(base + Vector2(c[0], c[1]), c[2], Color("#2d5e3c"))
		for k in 18:
			var p := base + Vector2(fposmod(k * 11.3, 44.0) - 22.0, -fposmod(k * 7.7, 34.0) - 34.0)
			draw_rect(Rect2(p, Vector2(2, 2)), Color("#ba2535") if k % 2 else Color("#eb7e28"))

func _anim_grove(t: float, view: Rect2) -> void:
	if sita_position != Vector2.ZERO:
		var glow := 0.5 + 0.5 * sin(t * 1.6)
		_fx.draw_circle(sita_position, 22.0, Color(0.99, 0.89, 0.49, 0.08 + 0.06 * glow + (0.1 if sita_found else 0.0)))
	var count := int(world.size.x * world.size.y / 14000.0)
	for k in count:
		var base := Vector2(fposmod(k * 83.0, world.size.x), HORIZON + 20 + fposmod(k * 47.0, world.size.y - HORIZON - 40))
		var p := base + Vector2(sin(t * 0.6 + k) * 18.0, cos(t * 0.8 + k * 1.7) * 10.0)
		if not view.has_point(p):
			continue
		var g := 0.5 + 0.5 * sin(t * 3.0 + k * 1.3)
		_fx.draw_circle(p, 3.0, Color(0.99, 0.89, 0.49, 0.12 * g))
		_fx.draw_rect(Rect2(p, Vector2.ONE), Color(0.99, 0.89, 0.49, 0.5 + 0.5 * g))

# --- Chapter 5: The Escape ---------------------------------------------------------------

func _static_rooftops() -> void:
	_sky(Color("#2c2834"), Color("#eb7e28"))
	var city := Color("#16172e")
	var k := 0
	for x in range(int(world.position.x), int(world.end.x), 70):
		var top := 44.0 + (k * 13) % 30
		draw_rect(Rect2(x, top, 40 + (k * 11) % 30, HORIZON - top), city)
		k += 1
	var f := _floor()
	draw_rect(f, Color("#522b16"))
	for row in range(0, int(f.size.y / 12.0) + 1):
		var y := f.position.y + row * 12.0
		var shift := 8.0 if row % 2 else 0.0
		for col in range(-1, int(f.size.x / 16.0) + 1):
			var x := f.position.x + col * 16.0 + shift
			draw_rect(Rect2(x + 1, y, 14, 10), Color("#b54e18"))
			draw_rect(Rect2(x + 1, y, 14, 2), Color("#eb7e28", 0.6))
	for ridge_y in range(int(HORIZON) + 86, int(world.end.y), 96):
		draw_rect(Rect2(world.position.x, ridge_y, world.size.x, 5), Color("#2c2834"))
	draw_rect(Rect2(world.end.x - 40, HORIZON, 40, f.size.y), Color("#0f3150"))
	for y in range(int(HORIZON) + 6, int(world.end.y), 14):
		draw_line(Vector2(world.end.x - 36, y), Vector2(world.end.x - 22, y), Color(0.55, 0.8, 0.9, 0.5), 1.0)

func _anim_rooftops(t: float, view: Rect2) -> void:
	# Rooftop flames on the skyline and across the burning stretch, plus rising embers.
	var k := 0
	for x in range(int(world.position.x), int(world.end.x), 70):
		var top := 44.0 + (k * 13) % 30
		for fl in 3:
			var fx := x + 8.0 + fl * 12.0
			var h := 8.0 + 5.0 * sin(t * 9.0 + fx)
			_fx.draw_colored_polygon(PackedVector2Array([Vector2(fx - 5, top), Vector2(fx, top - h), Vector2(fx + 5, top)]), Color("#eb7e28"))
		k += 1
	if fire_zone.size.x <= 0.0:
		return
	var flames := int(fire_zone.size.x * fire_zone.size.y / 5000.0)
	for i in flames:
		var p := fire_zone.position + Vector2(fposmod(i * 71.3, fire_zone.size.x), fposmod(i * 43.9, fire_zone.size.y))
		if not view.has_point(p):
			continue
		var h := 12.0 + 6.0 * sin(t * 10.0 + i * 1.9)
		_fx.draw_circle(p + Vector2(0, 2), 9.0, Color(0.92, 0.49, 0.16, 0.18))
		_fx.draw_colored_polygon(PackedVector2Array([p + Vector2(-6, 4), p + Vector2(0, -h), p + Vector2(6, 4)]), Color("#eb7e28"))
		_fx.draw_colored_polygon(PackedVector2Array([p + Vector2(-3, 4), p + Vector2(0, -h * 0.55), p + Vector2(3, 4)]), Color("#fce27c"))
	for i in 40:
		var rise := fposmod(t * 40.0 + i * 17.0, 260.0)
		var p := Vector2(fire_zone.position.x + fposmod(i * 37.0, fire_zone.size.x) + sin(t + i) * 6.0, view.end.y - rise)
		_fx.draw_rect(Rect2(p, Vector2.ONE), Color(0.99, 0.75, 0.3, 1.0 - rise / 260.0))
