extends SceneTree
## Seeded level generator for MazeLayouts. Prints a ready-to-paste grid with markers placed.
##   MODE=rooms  halls + winding corridors + extra links (several routes) + secret rooms behind
##               hidden passages (h) holding a lotus (o). Used for the palace and the gates.
##   MODE=maze   long hedge labyrinth with a few loops and shrink-only crevices (c).
##   MODE=reef   open sea scattered with reef clusters.
## Run: MODE=rooms W=45 H=29 SEED=3 CHAPTER=3 godot --headless --path . -s tools/gen_level.gd

var rng := RandomNumberGenerator.new()
var W := 45
var H := 29
var grid: Array = []
var rooms: Array[Rect2i] = []
var secret_rooms: Array[Rect2i] = []
var region: Array = []
var region_count := 0

func _env(key: String, fallback: String) -> String:
	return OS.get_environment(key) if OS.has_environment(key) else fallback

func _init() -> void:
	rng.seed = int(_env("SEED", "1"))
	W = int(_env("W", "45"))
	H = int(_env("H", "29"))
	var mode := _env("MODE", "rooms")
	var chapter := int(_env("CHAPTER", "3"))
	_fill("#")
	for y in 3:
		for x in W:
			grid[y][x] = "X"
	match mode:
		"rooms": _rooms_and_corridors(int(_env("ROOMS", "14")), int(_env("LOOPS", "10")), int(_env("SECRETS", "2")))
		"maze": _labyrinth(int(_env("LOOPS", "8")), int(_env("CREVICES", "3")), int(_env("SECRETS", "1")))
		"reef": _reef(float(_env("DENSITY", "0.13")))
	_place_markers(chapter, mode)
	for y in H:
		print('\t\t"%s",' % "".join(PackedStringArray(grid[y])))
	quit()

func _fill(c: String) -> void:
	grid.clear()
	for y in H:
		var row: Array = []
		for x in W:
			row.append(c)
		grid.append(row)

func _at(p: Vector2i) -> String:
	if p.x < 0 or p.y < 0 or p.x >= W or p.y >= H:
		return "X"
	return grid[p.y][p.x]

func _put(p: Vector2i, c: String) -> void:
	grid[p.y][p.x] = c

func _open(p: Vector2i) -> bool:
	return not _at(p) in ["#", "X", "c", "h"]

# --- Rooms and corridors (after the classic "rooms and mazes" approach) -------------------

func _rooms_and_corridors(room_tries: int, loops: int, secrets: int) -> void:
	region = []
	for y in H:
		var row: Array = []
		row.resize(W)
		row.fill(-1)
		region.append(row)
	for i in room_tries * 6:
		if rooms.size() >= room_tries:
			break
		var w := rng.randi_range(2, 4) * 2 + 1
		var h := rng.randi_range(1, 3) * 2 + 1
		var x := rng.randi_range(0, (W - w - 1) / 2) * 2 + 1
		var y := rng.randi_range(2, (H - h - 1) / 2) * 2 + 1
		var r := Rect2i(x, y, w, h)
		if y < 3 or r.end.y > H - 1 or r.end.x > W - 1:
			continue
		var overlaps := false
		for o in rooms:
			if r.grow(1).intersects(o):
				overlaps = true
				break
		if overlaps:
			continue
		rooms.append(r)
		for yy in range(r.position.y, r.end.y):
			for xx in range(r.position.x, r.end.x):
				_carve(Vector2i(xx, yy), region_count)
		region_count += 1
	# Fill the remaining space with winding corridors.
	for y in range(3, H, 2):
		for x in range(1, W, 2):
			var p := Vector2i(x, y)
			if _at(p) == "#" and y >= 3:
				_grow_maze(p)
	_connect_regions(loops)
	_trim_dead_ends(0.7)
	_make_secret_rooms(secrets)

func _carve(p: Vector2i, r: int) -> void:
	_put(p, ".")
	if not region.is_empty():
		region[p.y][p.x] = r

func _grow_maze(start: Vector2i) -> void:
	var r := region_count
	region_count += 1
	var stack: Array[Vector2i] = [start]
	_carve(start, r)
	while not stack.is_empty():
		var cur: Vector2i = stack.back()
		var dirs: Array[Vector2i] = []
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var n: Vector2i = cur + d * 2
			if n.y >= 3 and n.x > 0 and n.y < H - 1 and n.x < W - 1 and _at(n) == "#":
				dirs.append(d)
		if dirs.is_empty():
			stack.pop_back()
			continue
		var d: Vector2i = dirs[rng.randi_range(0, dirs.size() - 1)]
		_carve(cur + d, r)
		_carve(cur + d * 2, r)
		stack.append(cur + d * 2)

## Joins every region into one, then adds extra openings so there are several routes.
func _connect_regions(loops: int) -> void:
	var connectors: Array = []
	for y in range(4, H - 1):
		for x in range(1, W - 1):
			var p := Vector2i(x, y)
			if _at(p) != "#":
				continue
			var regs := {}
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var r: int = region[p.y + d.y][p.x + d.x]
				if r >= 0:
					regs[r] = true
			if regs.size() >= 2:
				connectors.append([p, regs.keys()])
	var merged := {}
	for i in region_count:
		merged[i] = i
	var find := func(r: int) -> int:
		while merged[r] != r:
			r = merged[r]
		return r
	connectors.shuffle()
	for c in connectors:
		var roots := {}
		for r in c[1]:
			roots[find.call(r)] = true
		if roots.size() > 1:
			_put(c[0], ".")
			var keys := roots.keys()
			for k in keys:
				merged[k] = keys[0]
		elif loops > 0 and rng.randf() < 0.08:
			_put(c[0], ".")
			loops -= 1

func _trim_dead_ends(amount: float) -> void:
	var changed := true
	var passes := 0
	while changed and passes < 60:
		changed = false
		passes += 1
		for y in range(3, H):
			for x in W:
				var p := Vector2i(x, y)
				if not _open(p):
					continue
				var exits := 0
				for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					if _open(p + d):
						exits += 1
				if exits <= 1 and rng.randf() < amount:
					_put(p, "#")
					changed = true

## Seals small rooms behind a single hidden passage (h) and leaves a lotus inside.
func _make_secret_rooms(count: int) -> void:
	var candidates := rooms.duplicate()
	candidates.shuffle()
	for r: Rect2i in candidates:
		if count <= 0:
			break
		var doors: Array[Vector2i] = []
		for x in range(r.position.x, r.end.x):
			for p in [Vector2i(x, r.position.y - 1), Vector2i(x, r.end.y)]:
				if _open(p):
					doors.append(p)
		for y in range(r.position.y, r.end.y):
			for p in [Vector2i(r.position.x - 1, y), Vector2i(r.end.x, y)]:
				if _open(p):
					doors.append(p)
		if doors.size() < 1 or r.size.x * r.size.y > 25:
			continue
		for i in doors.size():
			_put(doors[i], "h" if i == 0 else "#")
		_put(r.get_center(), "o")
		secret_rooms.append(r)
		count -= 1

# --- Labyrinth ---------------------------------------------------------------------------

func _labyrinth(loops: int, crevices: int, secrets: int) -> void:
	region = []
	_grow_maze(Vector2i(1, 3))
	var tries := 0
	while (loops > 0 or crevices > 0) and tries < 4000:
		tries += 1
		var p := Vector2i(rng.randi_range(1, W - 2), rng.randi_range(4, H - 2))
		if _at(p) != "#":
			continue
		var horizontal := _open(p + Vector2i.LEFT) and _open(p + Vector2i.RIGHT) and not _open(p + Vector2i.UP) and not _open(p + Vector2i.DOWN)
		var vertical := _open(p + Vector2i.UP) and _open(p + Vector2i.DOWN) and not _open(p + Vector2i.LEFT) and not _open(p + Vector2i.RIGHT)
		if not (horizontal or vertical):
			continue
		if crevices > 0:
			_put(p, "c")
			crevices -= 1
		else:
			_put(p, ".")
			loops -= 1
	# Secret nook: a dead end sealed by a hidden passage with a lotus inside.
	for y in range(4, H - 1):
		for x in range(1, W - 1):
			if secrets <= 0:
				return
			var p := Vector2i(x, y)
			if not _open(p) or rng.randf() > 0.05:
				continue
			var exits: Array[Vector2i] = []
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if _open(p + d):
					exits.append(p + d)
			if exits.size() == 1:
				_put(exits[0], "h")
				_put(p, "o")
				secrets -= 1

# --- Reef --------------------------------------------------------------------------------

func _reef(density: float) -> void:
	for y in range(3, H):
		for x in W:
			_put(Vector2i(x, y), ".")
	var clusters := int(W * (H - 3) * density / 4.0)
	for i in clusters:
		var c := Vector2i(rng.randi_range(3, W - 4), rng.randi_range(4, H - 2))
		for k in rng.randi_range(2, 6):
			var p := c + Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
			if p.y >= 3 and p.y < H and p.x > 1 and p.x < W - 2:
				_put(p, "#")

# --- Markers -----------------------------------------------------------------------------

func _place_markers(chapter: int, mode: String) -> void:
	var mid := int((3 + H) / 2.0)
	var start := _nearest_open(Vector2i(0, mid))
	_put(start, "S")
	var dist := _distances(start)
	match chapter:
		1:
			# Surasa blocks the middle of the crossing, Simhika guards the last stretch.
			var sx := int(W * 0.45)
			for y in range(mid - 2, mid + 3):
				for x in range(sx - 2, sx + 3):
					_put(Vector2i(x, y), ".")
			_put(Vector2i(sx, mid), "1")
			var hx := int(W * 0.72)
			for y in range(mid - 2, mid + 3):
				for x in range(hx - 2, hx + 3):
					_put(Vector2i(x, y), ".")
			_put(Vector2i(hx, mid), "2")
			for y in range(3, H):
				_put(Vector2i(W - 1, y), "E")
		2:
			# Lankini's arena opens in front of the gate, top centre; the courtyards lead up to it.
			var gx := int(W / 2.0)
			for y in range(3, 9):
				for x in range(gx - 4, gx + 5):
					_put(Vector2i(x, y), ".")
			_put(Vector2i(gx, 5), "3")
			start = Vector2i(gx, H - 2)
			for y in H:
				for x in W:
					if grid[y][x] == "S":
						grid[y][x] = "."
			_put(_nearest_open(start), "S")
		3, 4:
			var far := _farthest(dist, chapter == 3)
			_put(far, "E" if chapter == 3 else "T")
	dist = _distances(_find("S"))
	# Guards in the larger halls (palace), the queen in a quiet chamber.
	if chapter == 3:
		var halls := rooms.filter(func(r): return not secret_rooms.has(r) and r.size.x * r.size.y >= 15)
		halls.sort_custom(func(a, b): return dist.get(a.get_center(), 0) < dist.get(b.get_center(), 0))
		for i in halls.size():
			var c: Vector2i = halls[i].get_center()
			if i == 1:
				_put(c, "M")
			elif i >= 2 and i % 2 == 0 and _count("G") < 4:
				_put(c, "G")
	# Imp clusters spread along the level, away from the start.
	var cluster_count: int = {1: 3, 2: 4, 3: 4, 4: 6}.get(chapter, 0)
	var placed: Array[Vector2i] = []
	var tries := 0
	while placed.size() < cluster_count and tries < 3000:
		tries += 1
		var p := Vector2i(rng.randi_range(1, W - 2), rng.randi_range(4, H - 2))
		if _at(p) != "." or dist.get(p, 0) < 10:
			continue
		var ok := true
		for q in placed:
			if q.distance_to(p) < 7:
				ok = false
		for m in ["1", "2", "3", "T", "M", "G"]:
			var mp := _find(m)
			if mp.x >= 0 and mp.distance_to(p) < 5:
				ok = false
		if ok:
			_put(p, "m")
			placed.append(p)

func _find(marker: String) -> Vector2i:
	for y in H:
		for x in W:
			if grid[y][x] == marker:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _count(marker: String) -> int:
	var n := 0
	for y in H:
		for x in W:
			if grid[y][x] == marker:
				n += 1
	return n

func _nearest_open(p: Vector2i) -> Vector2i:
	for r in 40:
		for dy in range(-r, r + 1):
			for dx in range(0, r + 1):
				var q := p + Vector2i(dx, dy)
				if q.y >= 3 and _at(q) == ".":
					return q
	return p

func _distances(from: Vector2i) -> Dictionary:
	var dist := {from: 0}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if not dist.has(n) and (_open(n) or _at(n) == "h"):
				dist[n] = dist[c] + 1
				queue.append(n)
	return dist

## Farthest reachable cell; for an exit, prefer cells on the map's right edge region.
func _farthest(dist: Dictionary, right_side: bool) -> Vector2i:
	var best := Vector2i.ZERO
	var best_d := -1
	for c in dist:
		if _at(c) != ".":
			continue
		if right_side and c.x < W - 4:
			continue
		if dist[c] > best_d:
			best_d = dist[c]
			best = c
	return best
