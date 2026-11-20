extends SceneTree
## Validates MazeLayouts: equal row lengths, goal reachable without crevices, every lotus and
## imp cluster reachable, and a rough route time.
## Run: godot --headless --path . -s tools/check_mazes.gd

const SPEED := 120.0  # Hanuman's walk speed, px/s
const MazeLayouts := preload("res://scripts/world/maze_layouts.gd")
const WALKABLE := [".", "S", "E", "G", "T", "M", "o", "m", "h", "1", "2", "3"]

func _init() -> void:
	var ok := true
	for chapter in MazeLayouts.LAYOUTS:
		ok = _check(chapter, MazeLayouts.LAYOUTS[chapter]) and ok
	print("ALL MAZES OK" if ok else "MAZE CHECK FAILED")
	quit(0 if ok else 1)

func _check(chapter: int, rows: Array) -> bool:
	var ok := true
	var width: int = String(rows[0]).length()
	var start := Vector2i(-1, -1)
	var goals: Array[Vector2i] = []
	var must_reach: Array[Vector2i] = []
	for y in rows.size():
		if String(rows[y]).length() != width:
			print("ch%d row %d: length %d (expected %d)" % [chapter, y, String(rows[y]).length(), width]); ok = false
		for x in String(rows[y]).length():
			var ch: String = rows[y][x]
			if ch == "S": start = Vector2i(x, y)
			if ch in ["E", "T", "3"]: goals.append(Vector2i(x, y))
			if ch in ["o", "m"]: must_reach.append(Vector2i(x, y))
	var dist := _bfs(rows, start, false)
	var best := -1
	for g in goals:
		if dist.has(g) and (best < 0 or dist[g] < best):
			best = dist[g]
	if best < 0:
		print("ch%d: goal NOT reachable without crevices" % chapter); ok = false
	var shrunk := _bfs(rows, start, true)
	for p in must_reach:
		if not shrunk.has(p):
			print("ch%d: %s at %s is unreachable" % [chapter, rows[p.y][p.x], p]); ok = false
	print("ch%d: %dx%d cells (%.1f x %.1f screens), shortest route %d cells (~%.0f s)" % [
		chapter, width, rows.size(), width * 32 / 640.0, rows.size() * 32 / 360.0, best, best * 32.0 / SPEED])
	return ok

func _bfs(rows: Array, start: Vector2i, shrunk: bool) -> Dictionary:
	var dist := {start: 0}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = cell + d
			if n.y < 0 or n.y >= rows.size() or n.x < 0 or n.x >= String(rows[n.y]).length() or dist.has(n):
				continue
			var ch: String = rows[n.y][n.x]
			if ch in WALKABLE or (shrunk and ch == "c"):
				dist[n] = dist[cell] + 1
				queue.append(n)
	return dist
