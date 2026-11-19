extends "res://scripts/world/layout_base.gd"

func _ready() -> void:
	ground_color = Color("401f2a")
	accent_color = Color("d45d37")
	obstacle_points = [Vector2(260, 200), Vector2(430, 500), Vector2(610, 180), Vector2(790, 520), Vector2(970, 190), Vector2(1120, 500)]
	super._ready()
