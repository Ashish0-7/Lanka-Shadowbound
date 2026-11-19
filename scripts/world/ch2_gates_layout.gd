extends "res://scripts/world/layout_base.gd"

func _ready() -> void:
	ground_color = Color("483323")
	accent_color = Color("bd8b4b")
	obstacle_points = [Vector2(250, 180), Vector2(250, 540), Vector2(480, 180), Vector2(480, 540), Vector2(800, 180), Vector2(800, 540), Vector2(1050, 180), Vector2(1050, 540)]
	super._ready()
