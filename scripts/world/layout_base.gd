extends Node2D
## Shared one-screen greybox builder for the five chapter layout scenes.

signal exit_reached

const WORLD_SIZE := Vector2(1280, 720)
const WALL := 24.0

@export var ground_color := Color("193d58")
@export var accent_color := Color("347d92")
@export var obstacle_points: Array[Vector2] = []
@export_enum("ocean", "gates", "palace", "vatika", "rooftops") var environment_style := "ocean"

func _ready() -> void:
	_build_world()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), ground_color)
	match environment_style:
		"ocean": _draw_ocean()
		"gates": _draw_gate_courtyard()
		"palace": _draw_palace()
		"vatika": _draw_garden()
		"rooftops": _draw_rooftops()
	_draw_obstacles()
	draw_rect(Rect2(Vector2(1237, 270), Vector2(26, 180)), accent_color.lightened(0.45))
	draw_rect(Rect2(Vector2(1232, 265), Vector2(36, 190)), Color.WHITE, false, 2.0)

func _draw_ocean() -> void:
	for y in range(40, 700, 48):
		for x in range(40, 1260, 64):
			var wave_y := float(y) + sin(float(x + y) * 0.025) * 5.0
			draw_line(Vector2(x, wave_y), Vector2(x + 28, wave_y - 3.0), accent_color.lightened(0.18), 3.0)
			draw_line(Vector2(x + 36, wave_y + 8.0), Vector2(x + 53, wave_y + 6.0), accent_color.darkened(0.12), 2.0)
	for x in range(100, 1260, 220):
		draw_circle(Vector2(x, 88 + fposmod(x * 17.0, 550.0)), 3.0, Color("a7e4d9"))

func _draw_gate_courtyard() -> void:
	for x in range(48, 1280, 64):
		for y in range(48, 720, 48):
			draw_rect(Rect2(Vector2(x, y), Vector2(62, 46)), accent_color.darkened(0.28), false, 1.0)
	for pillar_x in [1120.0, 1184.0]:
		draw_rect(Rect2(Vector2(pillar_x, 120), Vector2(34, 480)), Color("8c6037"))
		draw_rect(Rect2(Vector2(pillar_x - 7, 112), Vector2(48, 16)), Color("ddb36a"))
	draw_rect(Rect2(Vector2(1145, 265), Vector2(48, 190)), Color("342a34"))
	draw_arc(Vector2(1169, 270), 24.0, PI, TAU, 16, Color("ddb36a"), 7.0)

func _draw_palace() -> void:
	for x in range(32, 1280, 64):
		for y in range(32, 720, 64):
			draw_rect(Rect2(Vector2(x, y), Vector2(62, 62)), accent_color.darkened(0.48), false, 1.0)
	for room_x in [100.0, 500.0, 900.0]:
		draw_rect(Rect2(Vector2(room_x, 285), Vector2(250, 150)), Color("58304d"))
		draw_rect(Rect2(Vector2(room_x + 8, 293), Vector2(234, 134)), Color("8a4a65"), false, 3.0)
		draw_circle(Vector2(room_x + 125, 360), 5.0, Color("f6cb72"))
	for lamp_x in [225.0, 625.0, 1025.0]:
		draw_circle(Vector2(lamp_x, 90), 18.0, Color("e5a44f", 0.18))
		draw_circle(Vector2(lamp_x, 90), 6.0, Color("ffd681"))

func _draw_garden() -> void:
	for y in range(40, 720, 64):
		for x in range(40, 1280, 64):
			var tuft := Vector2(x + fposmod(float(x * 7 + y), 24.0), y + fposmod(float(y * 3 + x), 18.0))
			draw_line(tuft, tuft + Vector2(-3, -8), Color("91ad59"), 2.0)
			draw_line(tuft, tuft + Vector2(4, -6), Color("b2bd68"), 2.0)
	# Canopies and trunks sit beside the walking lane; their trunks remain decorative.
	for tree in [Vector2(150, 145), Vector2(370, 575), Vector2(665, 140), Vector2(900, 585), Vector2(1115, 150)]:
		_draw_tree(tree)
	for flower in [Vector2(225, 230), Vector2(445, 485), Vector2(745, 235), Vector2(985, 475), Vector2(1175, 520)]:
		draw_circle(flower, 4.0, Color("e5c866"))
		draw_circle(flower + Vector2(4, 1), 2.0, Color("f1e1a2"))
	# A pale stone path guides the player through the grove.
	for x in range(30, 1240, 56):
		draw_rect(Rect2(Vector2(x, 334 + sin(float(x) * 0.018) * 18.0), Vector2(42, 28)), Color("a4a078", 0.55))

func _draw_tree(center: Vector2) -> void:
	draw_rect(Rect2(center + Vector2(-7, 2), Vector2(14, 38)), Color("68472f"))
	draw_rect(Rect2(center + Vector2(-2, 5), Vector2(5, 30)), Color("94623b"))
	draw_circle(center + Vector2(-15, -8), 22.0, Color("315b3c"))
	draw_circle(center + Vector2(8, -15), 25.0, Color("3f7548"))
	draw_circle(center + Vector2(22, -4), 18.0, Color("4e824b"))
	draw_circle(center + Vector2(0, -4), 19.0, Color("5b8d50"))
	draw_circle(center + Vector2(-8, -18), 5.0, Color("88a85c"))

func _draw_rooftops() -> void:
	for y in range(36, 720, 40):
		draw_line(Vector2(24, y), Vector2(1256, y), accent_color.darkened(0.35), 3.0)
		for x in range(36 + (y % 2) * 16, 1260, 32):
			draw_line(Vector2(x, y), Vector2(x - 12, y + 18), accent_color.lightened(0.08), 2.0)
	for chimney in [Vector2(170, 125), Vector2(450, 585), Vector2(740, 110), Vector2(1015, 590)]:
		draw_rect(Rect2(chimney, Vector2(48, 68)), Color("492d35"))
		draw_rect(Rect2(chimney + Vector2(-5, -7), Vector2(58, 12)), Color("af5540"))
	for flame in [Vector2(335, 230), Vector2(640, 485), Vector2(890, 205), Vector2(1160, 485)]:
		draw_colored_polygon(PackedVector2Array([flame + Vector2(-10, 14), flame + Vector2(-4, -9), flame + Vector2(2, 3), flame + Vector2(8, -15), flame + Vector2(13, 14)]), Color("dc5932"))
		draw_colored_polygon(PackedVector2Array([flame + Vector2(-4, 13), flame + Vector2(1, 0), flame + Vector2(5, 12)]), Color("ffd16a"))

func _draw_obstacles() -> void:
	for point in obstacle_points:
		match environment_style:
			"ocean": _draw_rock(point)
			"gates": _draw_pillar(point)
			"palace": _draw_palace_obstacle(point)
			"vatika": _draw_shrub(point)
			"rooftops": _draw_chimney(point)

func _draw_rock(point: Vector2) -> void:
	draw_circle(point + Vector2(-18, 4), 18.0, Color("334554"))
	draw_circle(point + Vector2(3, -4), 24.0, Color("536674"))
	draw_circle(point + Vector2(21, 7), 15.0, Color("3f5361"))
	draw_arc(point + Vector2(-2, -7), 16.0, PI, TAU, 16, Color("8ba1a4"), 3.0)

func _draw_pillar(point: Vector2) -> void:
	draw_rect(Rect2(point - Vector2(24, 25), Vector2(48, 50)), Color("795433"))
	draw_rect(Rect2(point - Vector2(29, 25), Vector2(58, 9)), Color("d3a65f"))
	draw_rect(Rect2(point - Vector2(29, -16), Vector2(58, 9)), Color("d3a65f"))
	draw_line(point + Vector2(-8, -14), point + Vector2(-8, 15), Color("b5844c"), 3.0)

func _draw_palace_obstacle(point: Vector2) -> void:
	draw_rect(Rect2(point - Vector2(36, 24), Vector2(72, 48)), Color("705640"))
	draw_rect(Rect2(point - Vector2(31, 19), Vector2(62, 38)), Color("b18b5b"))
	draw_rect(Rect2(point - Vector2(25, 12), Vector2(12, 25)), Color("755441"))
	draw_rect(Rect2(point + Vector2(12, -12), Vector2(12, 25)), Color("755441"))

func _draw_shrub(point: Vector2) -> void:
	draw_circle(point + Vector2(-17, 5), 15.0, Color("365d3b"))
	draw_circle(point, 20.0, Color("4d7943"))
	draw_circle(point + Vector2(17, 5), 14.0, Color("5b8847"))
	draw_circle(point + Vector2(-5, -7), 4.0, Color("91ad59"))

func _draw_chimney(point: Vector2) -> void:
	draw_rect(Rect2(point - Vector2(28, 21), Vector2(56, 42)), Color("492d35"))
	draw_rect(Rect2(point - Vector2(34, 24), Vector2(68, 11)), Color("b8543b"))

func _build_world() -> void:
	for side in ["Top", "Bottom", "Left"]:
		var wall := StaticBody2D.new()
		wall.name = side + "Wall"
		match side:
			"Top": wall.position = Vector2(640, WALL / 2)
			"Bottom": wall.position = Vector2(640, 720 - WALL / 2)
			"Left": wall.position = Vector2(WALL / 2, 360)
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(1280, WALL) if side != "Left" else Vector2(WALL, 720)
		shape.shape = rect
		wall.add_child(shape)
		add_child(wall)
	for point in obstacle_points:
		var obstacle := StaticBody2D.new()
		obstacle.position = point
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(72, 48)
		shape.shape = rect
		obstacle.add_child(shape)
		add_child(obstacle)
	if environment_style == "vatika":
		for tree_position in [Vector2(150, 145), Vector2(370, 575), Vector2(665, 140), Vector2(900, 585), Vector2(1115, 150)]:
			var trunk := StaticBody2D.new()
			trunk.name = "TreeTrunk"
			trunk.position = tree_position + Vector2(0, 22)
			var trunk_collision := CollisionShape2D.new()
			var trunk_rect := RectangleShape2D.new()
			trunk_rect.size = Vector2(18, 34)
			trunk_collision.shape = trunk_rect
			trunk.add_child(trunk_collision)
			add_child(trunk)
	var start := Marker2D.new()
	start.name = "PlayerStart"
	start.position = Vector2(80, 360)
	add_child(start)
	var exit_area := Area2D.new()
	exit_area.name = "Exit"
	exit_area.position = Vector2(1250, 360)
	exit_area.collision_layer = 0
	exit_area.collision_mask = 1
	var exit_shape := CollisionShape2D.new()
	var exit_rect := RectangleShape2D.new()
	exit_rect.size = Vector2(36, 220)
	exit_shape.shape = exit_rect
	exit_area.add_child(exit_shape)
	exit_area.body_entered.connect(_on_exit_body_entered)
	add_child(exit_area)
	queue_redraw()

func _on_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		exit_reached.emit()
