extends SceneTree
## Prints a maze grid for MazeLayouts (paste the output in and place S/E/G/T by hand).
## Rooms sit on even columns and rows 4/6/8/10; walls between them are carved by a seeded
## recursive backtracker, then LOOPS extra walls are knocked out so there is more than one route.
## Run: SEED=7 X0=0 X1=19 LOOPS=4 godot --headless --path . -s tools/gen_maze.gd

const COLS := 20
const ROWS := 11
const ROOM_ROWS := [4, 6, 8, 10]

func _init() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(OS.get_environment("SEED") if OS.has_environment("SEED") else "1")
	var x0 := int(OS.get_environment("X0") if OS.has_environment("X0") else "0")
	var x1 := int(OS.get_environment("X1") if OS.has_environment("X1") else "19")
	var loops := int(OS.get_environment("LOOPS") if OS.has_environment("LOOPS") else "0")
	var grid: Array = []
	for y in ROWS:
		var row: Array = []
		for x in COLS:
			row.append("X" if y < 3 or (y == 3 and x < 6) else ("#" if x >= x0 and x <= x1 else "."))
		grid.append(row)
	var rooms: Array[Vector2i] = []
	for y in ROOM_ROWS:
		for x in range(x0 + (x0 % 2), x1 + 1, 2):
			rooms.append(Vector2i(x, y))
			grid[y][x] = "."
	# Recursive backtracker over the room lattice.
	var visited := {}
	var stack: Array[Vector2i] = [rooms[0]]
	visited[rooms[0]] = true
	while not stack.is_empty():
		var cur: Vector2i = stack.back()
		var options: Array[Vector2i] = []
		for d in [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]:
			var n: Vector2i = cur + d
			if rooms.has(n) and not visited.has(n):
				options.append(n)
		if options.is_empty():
			stack.pop_back()
			continue
		var next: Vector2i = options[rng.randi_range(0, options.size() - 1)]
		grid[(cur.y + next.y) / 2][(cur.x + next.x) / 2] = "."
		visited[next] = true
		stack.append(next)
	# Knock out extra walls between rooms to create loops.
	var tries := 0
	while loops > 0 and tries < 500:
		tries += 1
		var a: Vector2i = rooms[rng.randi_range(0, rooms.size() - 1)]
		var d: Vector2i = [Vector2i(2, 0), Vector2i(0, 2)][rng.randi_range(0, 1)]
		var b: Vector2i = a + d
		var mid: Vector2i = (a + b) / 2
		if rooms.has(b) and grid[mid.y][mid.x] == "#":
			grid[mid.y][mid.x] = "."
			loops -= 1
	for y in ROWS:
		print('\t\t"%s",' % "".join(PackedStringArray(grid[y])))
	quit()
