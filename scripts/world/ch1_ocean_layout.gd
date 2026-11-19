extends "res://scripts/world/layout_base.gd"

func _ready() -> void:
	ground_color = Color("102e58")
	accent_color = Color("318aa8")
	environment_style = "ocean"
	obstacle_points = [Vector2(270, 180), Vector2(470, 520), Vector2(680, 220), Vector2(870, 500), Vector2(1060, 190)]
	super._ready()
