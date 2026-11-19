class_name FloatingText
extends Node2D

## FloatingText: a short call-out ("TRIPLE!", "+10") that pops, rises and fades in the world.
## FloatingText.spawn(parent, position, "PENTA SMASH!", Color.GOLD, 16)

const THEME := preload("res://assets/ui/main_theme.tres")

var _text: String
var _color: Color
var _size: int
var _life := 0.0
const DURATION := 1.1

static func spawn(parent: Node, at: Vector2, text: String, color: Color = Color(1.0, 0.86, 0.42), font_size: int = 12) -> FloatingText:
	var label := FloatingText.new()
	label._text = text
	label._color = color
	label._size = font_size
	label.z_index = 5
	parent.add_child(label)
	label.global_position = at
	return label

func _process(delta: float) -> void:
	_life += delta
	if _life >= DURATION:
		queue_free()
		return
	position.y -= delta * 22.0
	queue_redraw()

func _draw() -> void:
	var font: Font = THEME.default_font
	var pop := 1.0 + maxf(0.0, 0.35 - _life) * 1.4
	var alpha := clampf((DURATION - _life) / 0.35, 0.0, 1.0)
	var size := int(_size * pop)
	var width := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var at := Vector2(-width * 0.5, 0)
	for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 1)]:
		draw_string(font, at + o, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.04, 0.03, 0.08, alpha))
	draw_string(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(_color, alpha))
