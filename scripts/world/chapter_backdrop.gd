class_name ChapterBackdrop
extends Node2D

## ChapterBackdrop: painted, lightly animated scenery for each chapter (sky band above y=100,
## floor below). Procedural and palette-locked (docs/VISUAL_IDENTITY.md). Display only.

const HORIZON := 100.0
const W := 640.0
const H := 360.0

var chapter := 1
var maze: LevelMaze
## Chapter 3: guard post and current alert (0..1), for the vision overlay.
var guard_position := Vector2.ZERO
var guard_radius := 105.0
var guard_alert := 0.0
## Chapter 4: where Sita sits beneath the Ashoka tree.
var sita_position := Vector2.ZERO
var sita_found := false

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	match chapter:
		1: _paint_ocean(t)
		2: _paint_gates(t)
		3: _paint_palace(t)
		4: _paint_grove(t)
		5: _paint_rooftops(t)

# --- Shared helpers -------------------------------------------------------------------------

func _sky(top: Color, bottom: Color, height: float = HORIZON) -> void:
	var bands := int(height / 4.0)
	for i in bands:
		draw_rect(Rect2(0, i * 4, W, 4), top.lerp(bottom, float(i) / maxf(bands - 1, 1)))

func _stars(count: int, t: float) -> void:
	for i in count:
		var p := Vector2(fposmod(i * 97.3, W), fposmod(i * 37.9, HORIZON - 30.0) + 4.0)
		var twinkle := 0.4 + 0.6 * absf(sin(t * (0.8 + i % 5 * 0.3) + i))
		draw_rect(Rect2(p, Vector2.ONE), Color(0.98, 0.96, 0.89, twinkle))

func _moon(at: Vector2, radius: float) -> void:
	draw_circle(at, radius * 2.6, Color(0.98, 0.96, 0.89, 0.05))
	draw_circle(at, radius * 1.6, Color(0.98, 0.96, 0.89, 0.08))
	draw_circle(at, radius, Color("#fbf4e2"))
	draw_circle(at + Vector2(-radius * 0.3, -radius * 0.2), radius * 0.25, Color("#d4c19c"))
	draw_circle(at + Vector2(radius * 0.35, radius * 0.3), radius * 0.18, Color("#d4c19c"))

func _dome(base_center: Vector2, width: float, height: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		points.append(base_center + Vector2(cos(a) * width * 0.5, sin(a) * height))
	draw_colored_polygon(points, color)
	draw_line(base_center + Vector2(0, -height), base_center + Vector2(0, -height - 6), color, 2.0)

# --- Chapter 1: Crossing the Ocean ----------------------------------------------------------

func _paint_ocean(t: float) -> void:
	_sky(Color("#0b1c33"), Color("#3a5f86"), HORIZON - 4)
	_stars(18, t)
	draw_rect(Rect2(0, HORIZON - 4, W, 4), Color("#e8a04a").darkened(0.15))
	var lanka := Color("#14142a")
	draw_rect(Rect2(540, HORIZON - 16, 100, 12), lanka)
	for tower in [[552, 70, 10], [572, 58, 12], [596, 50, 14], [622, 64, 10]]:
		draw_rect(Rect2(tower[0], tower[1], tower[2], HORIZON - 4 - tower[1]), lanka)
		draw_colored_polygon(PackedVector2Array([
			Vector2(tower[0] - 2, tower[1]), Vector2(tower[0] + tower[2] / 2.0, tower[1] - 10),
			Vector2(tower[0] + tower[2] + 2, tower[1])]), lanka)
		draw_rect(Rect2(tower[0] + tower[2] / 2.0 - 1, tower[1] + 8, 2, 3), Color("#f7c55a"))
	var sea_far := Color("#2c6c8e")
	var sea_near := Color("#0f3150")
	for i in 33:
		draw_rect(Rect2(0, HORIZON + i * 8, W, 8), sea_far.lerp(sea_near, i / 32.0))
	for row in 12:
		var y := HORIZON + 8.0 + row * 22.0
		var dir := 1.0 if row % 2 == 0 else -1.0
		var length := 8.0 + row * 1.5
		var offset := fposmod(t * (10.0 + row * 2.0) * dir + row * 37.0, 48.0)
		for k in range(-1, 15):
			var x := k * 48.0 + offset
			draw_line(Vector2(x, y), Vector2(x + length, y), Color(0.55, 0.8, 0.9, 0.3 + 0.02 * row), 1.0)
	draw_set_transform(Vector2(350, 214), 0.0, Vector2(1.0, 0.32))
	for ring in 4:
		var r := 30.0 + ring * 10.0 + sin(t * 2.0 + ring) * 2.0
		draw_arc(Vector2.ZERO, r, t * 1.5 + ring, t * 1.5 + ring + TAU * 0.8, 32, Color(0.75, 0.9, 1.0, 0.45 - ring * 0.08), 2.0)
	draw_set_transform(Vector2(490, 216), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 46.0 + sin(t * 1.7) * 3.0, Color(0.12, 0.02, 0.18, 0.75))
	draw_circle(Vector2.ZERO, 30.0, Color(0.28, 0.06, 0.36, 0.55))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Chapter 2: The Gates of Lanka ----------------------------------------------------------

func _paint_gates(t: float) -> void:
	_sky(Color("#26294a"), Color("#eb7e28"))
	# Low sun behind the gate.
	draw_circle(Vector2(320, 64), 40.0, Color(0.99, 0.89, 0.49, 0.12))
	draw_circle(Vector2(320, 64), 24.0, Color("#fce27c"))
	# The golden wall of Lanka with crenellations, towers, and the great gate.
	var wall := Color("#b54e18")
	var wall_top := Color("#f7b945")
	draw_rect(Rect2(0, 62, W, HORIZON - 62), wall)
	for x in range(0, int(W), 16):
		draw_rect(Rect2(x, 56, 9, 7), wall)
		draw_rect(Rect2(x, 56, 9, 2), wall_top)
	for x in range(0, int(W), 24):
		draw_line(Vector2(x, 70), Vector2(x, HORIZON), Color("#522b16"), 1.0)
	for tower_x in [40.0, 170.0, 470.0, 600.0]:
		draw_rect(Rect2(tower_x - 16, 30, 32, HORIZON - 30), wall.darkened(0.15))
		draw_rect(Rect2(tower_x - 16, 30, 32, 2), wall_top)
		_dome(Vector2(tower_x, 30), 30.0, 16.0, wall_top)
		draw_rect(Rect2(tower_x - 3, 46, 6, 10), Color("#26294a"))
	# Gate: tall arch with a gold frame, glowing seam between the doors.
	draw_rect(Rect2(272, 30, 96, HORIZON - 30), wall.darkened(0.25))
	_dome(Vector2(320, 30), 100.0, 22.0, wall_top)
	draw_rect(Rect2(290, 46, 60, HORIZON - 46), Color("#16172e"))
	draw_rect(Rect2(290, 46, 60, HORIZON - 46), wall_top, false, 2.0)
	draw_line(Vector2(320, 48), Vector2(320, HORIZON), Color(0.99, 0.89, 0.49, 0.5 + 0.3 * sin(t * 2.0)), 2.0)
	# Flagstone courtyard.
	for row in range(0, 17):
		var y := HORIZON + row * 16.0
		var shift := 16.0 if row % 2 else 0.0
		for col in range(-1, 21):
			var x := col * 32.0 + shift
			var shade := 0.04 * float((col * 7 + row * 3) % 4)
			draw_rect(Rect2(x + 1, y + 1, 30, 14), Color("#585266").lerp(Color("#917756"), 0.35 + shade))
	draw_rect(Rect2(0, HORIZON, W, H - HORIZON), Color(0.71, 0.31, 0.09, 0.06))
	# Lankini's arena inlay.
	draw_set_transform(Vector2(500, 214), 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2.ZERO, 92.0, Color("#522b16", 0.35))
	draw_arc(Vector2.ZERO, 92.0, 0, TAU, 48, Color("#f7b945", 0.6), 2.0)
	draw_arc(Vector2.ZERO, 60.0, 0, TAU, 40, Color("#f7b945", 0.35), 1.0)
	for i in 8:
		var a := i * TAU / 8.0
		draw_line(Vector2.from_angle(a) * 60.0, Vector2.from_angle(a) * 92.0, Color("#f7b945", 0.35), 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Chapter 3: Lanka at Night --------------------------------------------------------------

func _paint_palace(t: float) -> void:
	_sky(Color("#0a0814"), Color("#26294a"))
	_stars(40, t)
	_moon(Vector2(250, 30), 11.0)
	var skyline := Color("#16172e")
	draw_rect(Rect2(0, 78, W, HORIZON - 78), skyline)
	for d in [[60.0, 60.0, 30.0], [150.0, 40.0, 20.0], [330.0, 80.0, 38.0], [470.0, 46.0, 22.0], [580.0, 64.0, 30.0]]:
		draw_rect(Rect2(d[0] - d[1] * 0.45, 78 - d[2] * 0.4, d[1] * 0.9, d[2] * 0.4 + 2), skyline)
		_dome(Vector2(d[0], 78 - d[2] * 0.4), d[1], d[2], skyline)
	for i in 22:
		var p := Vector2(fposmod(i * 61.7, W), 82 + fposmod(i * 13.3, 14))
		var lit := 0.6 + 0.4 * sin(t * 0.7 + i * 2.1)
		draw_rect(Rect2(p, Vector2(2, 3)), Color(0.97, 0.73, 0.27, lit))
	# Marble checker floor washed in moonlight (kept darker than the walls for contrast).
	for row in range(0, 17):
		for col in range(0, 40):
			var dark := (row + col) % 2 == 0
			draw_rect(Rect2(col * 16, HORIZON + row * 16, 16, 16), Color("#10111f") if dark else Color("#181a33"))
	draw_rect(Rect2(0, HORIZON, W, H - HORIZON), Color(0.36, 0.5, 0.65, 0.04))
	_paint_guard_vision(t)
	if guard_position != Vector2.ZERO:
		# The guard's lantern: a warm pool of light that makes him easy to spot.
		var flick := 0.85 + 0.15 * sin(t * 13.0)
		draw_circle(guard_position + Vector2(-6, 6), 26.0 * flick, Color(0.97, 0.72, 0.27, 0.10))
		draw_circle(guard_position + Vector2(-6, 6), 14.0 * flick, Color(0.97, 0.72, 0.27, 0.16))

## Tints exactly the floor cells the guard can see: walls cast real shadows, so cover is obvious.
func _paint_guard_vision(t: float) -> void:
	if maze == null or guard_position == Vector2.ZERO:
		return
	var center_cell := maze.cell_at(guard_position)
	var reach := int(ceil(guard_radius / LevelMaze.CELL))
	var tint := Color(1.0, 0.85, 0.3).lerp(Color(1.0, 0.2, 0.15), guard_alert)
	var pulse := 0.12 + 0.06 * sin(t * (3.0 + guard_alert * 10.0)) + guard_alert * 0.12
	for dy in range(-reach, reach + 1):
		for dx in range(-reach, reach + 1):
			var cell := center_cell + Vector2i(dx, dy)
			var centre := maze.cell_center(cell)
			if centre.distance_to(guard_position) > guard_radius or maze.kind_at(cell) in ["#", "X", "c"]:
				continue
			if maze.has_line_of_sight(guard_position, centre):
				var r := Rect2(cell.x * LevelMaze.CELL, LevelMaze.ORIGIN_Y + cell.y * LevelMaze.CELL, LevelMaze.CELL, LevelMaze.CELL)
				draw_rect(r.grow(-1), Color(tint, pulse))

# --- Chapter 4: Ashoka Vatika ---------------------------------------------------------------

func _paint_grove(t: float) -> void:
	_sky(Color("#0a0814"), Color("#1c3024"))
	_stars(30, t)
	_moon(Vector2(90, 34), 12.0)
	# Tree line along the horizon.
	for i in 22:
		var x := i * 31.0 - 10.0
		var r := 14.0 + (i * 7) % 9
		draw_circle(Vector2(x, HORIZON - 6), r, Color("#142319"))
	draw_rect(Rect2(0, HORIZON - 8, W, 8), Color("#142319"))
	# Grass with tufts and tiny blossoms.
	draw_rect(Rect2(0, HORIZON, W, H - HORIZON), Color("#1c3024"))
	for i in 160:
		var p := Vector2(fposmod(i * 53.1, W), HORIZON + fposmod(i * 29.7, H - HORIZON))
		draw_rect(Rect2(p, Vector2(2, 1)), Color("#2d5e3c"))
		if i % 9 == 0:
			draw_rect(Rect2(p + Vector2(1, -1), Vector2(1, 1)), Color("#e86a82"))
		elif i % 13 == 0:
			draw_rect(Rect2(p + Vector2(1, -1), Vector2(1, 1)), Color("#fce27c"))
	draw_rect(Rect2(0, HORIZON, W, H - HORIZON), Color(0.36, 0.5, 0.65, 0.04))
	if sita_position != Vector2.ZERO:
		_paint_ashoka_tree_and_sita(t)
	# Fireflies drifting over the hedges.
	for i in 16:
		var base := Vector2(fposmod(i * 83.0, W), HORIZON + 20 + fposmod(i * 47.0, H - HORIZON - 40))
		var p := base + Vector2(sin(t * 0.6 + i) * 18.0, cos(t * 0.8 + i * 1.7) * 10.0)
		var glow := 0.5 + 0.5 * sin(t * 3.0 + i * 1.3)
		draw_circle(p, 3.0, Color(0.99, 0.89, 0.49, 0.12 * glow))
		draw_rect(Rect2(p, Vector2.ONE), Color(0.99, 0.89, 0.49, 0.5 + 0.5 * glow))

func _paint_ashoka_tree_and_sita(t: float) -> void:
	var base := sita_position + Vector2(0, -6)
	# Trunk and canopy with red-orange Ashoka blossoms.
	draw_rect(Rect2(base.x - 4, base.y - 38, 8, 30), Color("#522b16"))
	for c in [[-18.0, -48.0, 18.0], [14.0, -50.0, 17.0], [0.0, -62.0, 20.0], [-4.0, -40.0, 15.0]]:
		draw_circle(base + Vector2(c[0], c[1]), c[2], Color("#2d5e3c"))
	for i in 18:
		var p := base + Vector2(fposmod(i * 11.3, 44.0) - 22.0, -fposmod(i * 7.7, 34.0) - 34.0)
		draw_rect(Rect2(p, Vector2(2, 2)), Color("#ba2535") if i % 2 else Color("#eb7e28"))
	# Soft divine light around Sita.
	var glow := 0.5 + 0.5 * sin(t * 1.6)
	draw_circle(sita_position, 22.0, Color(0.99, 0.89, 0.49, 0.08 + 0.06 * glow + (0.1 if sita_found else 0.0)))

# --- Chapter 5: The Escape ------------------------------------------------------------------

func _paint_rooftops(t: float) -> void:
	_sky(Color("#2c2834"), Color("#eb7e28"))
	# Smoke plumes drifting up from the burning city.
	for i in 7:
		var x := 40.0 + i * 92.0
		for k in 4:
			var rise := fposmod(t * 8.0 + k * 22.0 + i * 13.0, 90.0)
			draw_circle(Vector2(x + sin(t * 0.5 + k) * 8.0, 90 - rise), 10.0 + rise * 0.15, Color(0.17, 0.16, 0.2, 0.35 * (1.0 - rise / 90.0)))
	# Burning skyline.
	var city := Color("#16172e")
	for b in [[0.0, 70.0, 40.0], [60.0, 50.0, 60.0], [150.0, 74.0, 50.0], [230.0, 44.0, 70.0], [330.0, 66.0, 44.0], [400.0, 52.0, 66.0], [490.0, 72.0, 40.0], [560.0, 48.0, 80.0]]:
		draw_rect(Rect2(b[0], b[1], b[2], HORIZON - b[1]), city)
		for f in 3:
			var fx: float = b[0] + 8 + f * (b[2] - 16) / 2.0
			var h := 8.0 + 5.0 * sin(t * 9.0 + fx)
			draw_colored_polygon(PackedVector2Array([Vector2(fx - 5, b[1]), Vector2(fx, b[1] - h), Vector2(fx + 5, b[1])]), Color("#eb7e28"))
			draw_colored_polygon(PackedVector2Array([Vector2(fx - 2, b[1]), Vector2(fx, b[1] - h * 0.55), Vector2(fx + 2, b[1])]), Color("#fce27c"))
	# Clay roof tiles with ridge beams.
	draw_rect(Rect2(0, HORIZON, W, H - HORIZON), Color("#522b16"))
	for row in range(0, 22):
		var y := HORIZON + row * 12.0
		var shift := 8.0 if row % 2 else 0.0
		for col in range(-1, 41):
			var x := col * 16.0 + shift
			draw_rect(Rect2(x + 1, y, 14, 10), Color("#b54e18"))
			draw_rect(Rect2(x + 1, y, 14, 2), Color("#eb7e28", 0.6))
	for ridge_y in [HORIZON + 86.0, HORIZON + 182.0]:
		draw_rect(Rect2(0, ridge_y, W, 5), Color("#2c2834"))
	# The sea at the escape edge.
	draw_rect(Rect2(600, HORIZON, 40, H - HORIZON), Color("#0f3150"))
	for y in range(int(HORIZON) + 6, int(H), 14):
		draw_line(Vector2(604, y), Vector2(618, y), Color(0.55, 0.8, 0.9, 0.5), 1.0)
	# Flames across the burning stretch (x 180–520) and rising embers.
	for i in 26:
		var p := Vector2(190 + fposmod(i * 71.3, 330.0), HORIZON + 14 + fposmod(i * 43.9, H - HORIZON - 28))
		var h := 12.0 + 6.0 * sin(t * 10.0 + i * 1.9)
		draw_circle(p + Vector2(0, 2), 9.0, Color(0.92, 0.49, 0.16, 0.18))
		draw_colored_polygon(PackedVector2Array([p + Vector2(-6, 4), p + Vector2(0, -h), p + Vector2(6, 4)]), Color("#eb7e28"))
		draw_colored_polygon(PackedVector2Array([p + Vector2(-3, 4), p + Vector2(0, -h * 0.55), p + Vector2(3, 4)]), Color("#fce27c"))
	for i in 30:
		var rise := fposmod(t * 40.0 + i * 17.0, 260.0)
		var p := Vector2(180 + fposmod(i * 37.0, 350.0) + sin(t + i) * 6.0, H - rise)
		draw_rect(Rect2(p, Vector2(1, 1)), Color(0.99, 0.75, 0.3, 1.0 - rise / 260.0))
