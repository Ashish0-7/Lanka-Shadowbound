extends "res://scripts/world/layout_base.gd"

signal sita_interaction_requested
var _player_in_talk_zone := false
var _handover_started := false
var _dialogue_box: DialogueBox

func _ready() -> void:
	ground_color = Color("24402d")
	accent_color = Color("6d9b4e")
	environment_style = "vatika"
	obstacle_points = [Vector2(280, 200), Vector2(280, 520), Vector2(520, 200), Vector2(520, 520), Vector2(790, 200), Vector2(790, 520), Vector2(1040, 360)]
	super._ready()
	var ui_layer := CanvasLayer.new()
	add_child(ui_layer)
	_dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate() as DialogueBox
	ui_layer.add_child(_dialogue_box)
	_add_sita()

func _add_sita() -> void:
	var sita := Node2D.new()
	sita.name = "Sita"
	sita.position = Vector2(1100, 360)
	var character := Sprite2D.new()
	character.texture = preload("res://assets/characters/npcs/char_sita_24x32.png")
	character.position = Vector2(0, -4)
	sita.add_child(character)
	var zone := Area2D.new()
	zone.name = "TalkZone"
	zone.collision_layer = 0
	zone.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 52
	shape.shape = circle
	zone.add_child(shape)
	zone.body_entered.connect(_on_sita_body_entered)
	zone.body_exited.connect(_on_sita_body_exited)
	sita.add_child(zone)
	add_child(sita)

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_talk_zone and not _handover_started and event.is_action_pressed("interact"):
		_handover_started = true
		sita_interaction_requested.emit()
		_dialogue_box.play_sita_ring_handover_scene()
		get_viewport().set_input_as_handled()

func _on_sita_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_talk_zone = true

func _on_sita_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_talk_zone = false
