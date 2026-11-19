extends Node2D
## Shared one-screen greybox builder for the five chapter layout scenes.

signal exit_reached

const WORLD_SIZE := Vector2(1280, 720)
const WALL := 24.0

@export var ground_color := Color("193d58")
@export var accent_color := Color("347d92")
@export var obstacle_points: Array[Vector2] = []

func _ready() -> void:
	_build_world()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), ground_color)
	for y in range(32, 720, 64):
		draw_line(Vector2(24, y), Vector2(1256, y), accent_color.darkened(0.45), 2.0)
	for point in obstacle_points:
		draw_rect(Rect2(point - Vector2(36, 24), Vector2(72, 48)), accent_color)

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
