extends "res://scripts/world/layout_base.gd"

signal mandodari_reached
var _misunderstanding_triggered := false
var _dialogue_box: DialogueBox

func _ready() -> void:
	ground_color = Color("191a35")
	accent_color = Color("a07c52")
	environment_style = "palace"
	obstacle_points = [Vector2(310, 210), Vector2(310, 510), Vector2(660, 210), Vector2(660, 510), Vector2(1010, 210), Vector2(1010, 510)]
	super._ready()
	_add_partition(430.0)
	_add_partition(830.0)
	_add_dialogue_box()
	_add_mandodari()

func _draw() -> void:
	super._draw()
	for x in [430.0, 830.0]:
		draw_rect(Rect2(Vector2(x - 12, 24), Vector2(24, 240)), accent_color.darkened(0.2))
		draw_rect(Rect2(Vector2(x - 12, 456), Vector2(24, 240)), accent_color.darkened(0.2))

func _add_partition(x: float) -> void:
	for wall_y in [144.0, 576.0]:
		var wall := StaticBody2D.new()
		wall.position = Vector2(x, wall_y)
		var collision := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(24, 240)
		collision.shape = rect
		wall.add_child(collision)
		add_child(wall)

func _add_dialogue_box() -> void:
	var ui_layer := CanvasLayer.new()
	add_child(ui_layer)
	_dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate() as DialogueBox
	ui_layer.add_child(_dialogue_box)

func _add_mandodari() -> void:
	var npc := Node2D.new()
	npc.name = "Mandodari"
	npc.position = Vector2(1080, 360)
	var character := Sprite2D.new()
	character.texture = preload("res://assets/characters/npcs/char_mandodari_32x24.png")
	character.position = Vector2(0, -4)
	npc.add_child(character)
	var zone := Area2D.new()
	zone.name = "TalkZone"
	zone.collision_layer = 0
	zone.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 48
	shape.shape = circle
	zone.add_child(shape)
	zone.body_entered.connect(_on_mandodari_body_entered)
	npc.add_child(zone)
	add_child(npc)

func _on_mandodari_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _misunderstanding_triggered:
		_misunderstanding_triggered = true
		mandodari_reached.emit()
		_dialogue_box.play_mandodari_misunderstanding_scene()
