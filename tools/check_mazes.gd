extends SceneTree
## Validates MazeLayouts: row sizes, solvable without crevices, boss areas clear.
## Run: godot --headless --path . -s tools/check_mazes.gd

const COLS := 20
const ROWS := 11
const SPEED := 120.0  # Hanuman's walk speed, px/s
const MazeLayouts := preload("res://scripts/world/maze_layouts.gd")

func _init() -> void:
	var ok := true
	for chapter in MazeLayouts.LAYOUTS:
		ok = _check(chapter, MazeLayouts.LAYOUTS[chapter]) and ok
	print("ALL MAZES OK" if ok else "MAZE CHECK FAILED")
	quit(0 if ok else 1)

func _check(chapter: int, rows: Array) -> bool:
	var ok := true
	if rows.size() != ROWS:
		print("ch%d: expected %d rows, got %d" % [chapter, ROWS, rows.size()]); return false
	var start := Vector2i(-1, -1)
	var goals: Array[Vector2i] = []
	for y in ROWS:
		if rows[y].length() != COLS:
			print("ch%d row %d: length %d" % [chapter, y, rows[y].length()]); ok = false
		for x in mini(COLS, rows[y].length()):
			var ch: String = rows[y][x]
			if ch == "S": start = Vector2i(x, y)
			if ch == "E" or ch == "T": goals.append(Vector2i(x, y))
	if chapter == 2:
		for r: Rect2i in MazeLayouts.KEEP_CLEAR[2]:
			goals.append(r.position + r.size / 2)
	for r: Rect2i in MazeLayouts.KEEP_CLEAR.get(chapter, []):
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				if not _walkable(rows[y][x], false):
					print("ch%d: keep-clear cell (%d,%d) is '%s'" % [chapter, x, y, rows[y][x]]); ok = false
	var plain := _bfs(rows, start, goals, false)
	var shrunk := _bfs(rows, start, goals, true)
	var dead_ends := _count_dead_ends(rows)
	if plain < 0:
		print("ch%d: goal NOT reachable without crevices" % chapter); ok = false
	print("ch%d: shortest path %d cells (~%.0f s), with crevices %d cells, dead ends %d" % [chapter, plain, plain * 32.0 / SPEED, shrunk, dead_ends])
	return ok

func _walkable(ch: String, shrunk: bool) -> bool:
	return ch in [".", "S", "E", "G", "T", "M"] or (shrunk and ch == "c")

func _bfs(rows: Array, start: Vector2i, goals: Array[Vector2i], shrunk: bool) -> int:
	var dist := {start: 0}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		if cell in goals:
			return dist[cell]
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = cell + d
			if n.x < 0 or n.y < 0 or n.x >= COLS or n.y >= ROWS or dist.has(n):
				continue
			if _walkable(rows[n.y][n.x], shrunk):
				dist[n] = dist[cell] + 1
				queue.append(n)
	return -1

func _count_dead_ends(rows: Array) -> int:
	var count := 0
	for y in ROWS:
		for x in COLS:
			if not _walkable(rows[y][x], false):
				continue
			var exits := 0
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = Vector2i(x, y) + d
				if n.x >= 0 and n.y >= 0 and n.x < COLS and n.y < ROWS and _walkable(rows[n.y][n.x], false):
					exits += 1
			if exits == 1:
				count += 1
	return count
