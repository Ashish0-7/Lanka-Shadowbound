class_name CinematicOverlay
extends CanvasLayer

## CinematicOverlay: presentation layer for short in-engine cutscenes and boss fights.
## Lives on its own CanvasLayer so camera zoom/shake never move it.
##   await letterbox(true)                         – black bars in/out
##   await title_card(kicker, title, subtitle)     – centred chapter card
##   await boss_intro(name, epithet)               – boss name slam-in
##   show_boss_bar(name, max) / set_boss_health(hp) / hide_boss_bar()
## Sequencing (when to call these) belongs to level flow, not this node.

const BAR_HEIGHT := 34.0
const THEME := preload("res://assets/ui/main_theme.tres")

var _root: Control
var _top_bar: ColorRect
var _bottom_bar: ColorRect
var _card: VBoxContainer
var _card_kicker: Label
var _card_title: Label
var _card_subtitle: Label
var _intro: VBoxContainer
var _intro_name: Label
var _intro_epithet: Label
var _boss_bar: BossHealthBar

func _ready() -> void:
	layer = 50
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = THEME
	add_child(_root)
	_top_bar = _make_bar(true)
	_bottom_bar = _make_bar(false)
	_build_title_card()
	_build_boss_intro()
	_boss_bar = BossHealthBar.new()
	_root.add_child(_boss_bar)
	get_viewport().size_changed.connect(_layout)
	_layout()

## The game fills any screen (stretch aspect "expand"), so lay out from the real view size.
func _screen() -> Vector2:
	return get_viewport().get_visible_rect().size

func _layout() -> void:
	var s := _screen()
	_boss_bar.position = Vector2((s.x - BossHealthBar.BAR_SIZE.x) * 0.5 - 6.0, 14.0)
	for bar in [_top_bar, _bottom_bar]:
		bar.size = Vector2(s.x, BAR_HEIGHT)
	_top_bar.position.y = 0.0 if _letterboxed else -BAR_HEIGHT
	_bottom_bar.position.y = s.y - (BAR_HEIGHT if _letterboxed else 0.0)
	_card.size = Vector2(s.x, 120)
	_intro.position = Vector2(24, s.y - BAR_HEIGHT - 66)

func _make_bar(top: bool) -> ColorRect:
	var bar := ColorRect.new()
	bar.color = UIConstants.COLOR_VOID_BLACK
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.position = Vector2(0, -BAR_HEIGHT if top else 360.0)
	_root.add_child(bar)
	return bar

func _make_label(font_size: int, color: Color, outline: int = 0) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if outline > 0:
		label.add_theme_constant_override("outline_size", outline)
		label.add_theme_color_override("font_outline_color", UIConstants.COLOR_VOID_BLACK)
	return label

func _build_title_card() -> void:
	_card = VBoxContainer.new()
	_card.alignment = BoxContainer.ALIGNMENT_CENTER
	_card.add_theme_constant_override("separation", 4)
	_card.position = Vector2(0, 110)
	_card_kicker = _make_label(UIConstants.FONT_SIZE_HUD, UIConstants.COLOR_SEAFOAM_TEAL, 2)
	_card_title = _make_label(UIConstants.FONT_SIZE_TITLE + 6, UIConstants.COLOR_DIVINE_GOLD, 4)
	_card_subtitle = _make_label(UIConstants.FONT_SIZE_BODY, UIConstants.COLOR_PARCHMENT_CREAM, 2)
	var rule := ColorRect.new()
	rule.color = UIConstants.COLOR_GOLDEN_EMBER
	rule.custom_minimum_size = Vector2(180, 1)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	for node in [_card_kicker, _card_title, rule, _card_subtitle]:
		_card.add_child(node)
	_card.modulate.a = 0.0
	_card.visible = false
	_root.add_child(_card)

func _build_boss_intro() -> void:
	_intro = VBoxContainer.new()
	_intro.add_theme_constant_override("separation", 0)
	_intro.size = Vector2(300, 60)
	_intro_name = _make_label(UIConstants.FONT_SIZE_TITLE + 10, UIConstants.COLOR_RUBY_BLOOD, 5)
	_intro_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_intro_epithet = _make_label(UIConstants.FONT_SIZE_BODY, UIConstants.COLOR_DIVINE_GOLD, 2)
	_intro_epithet.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_intro.add_child(_intro_name)
	_intro.add_child(_intro_epithet)
	_intro.visible = false
	_root.add_child(_intro)

var _letterboxed: bool = false

func is_letterboxed() -> bool:
	return _letterboxed

## Slides the cinematic bars in (true) or out (false). Await it to wait for the motion.
func letterbox(enabled: bool, seconds: float = 0.35) -> void:
	_letterboxed = enabled
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_top_bar, "position:y", 0.0 if enabled else -BAR_HEIGHT, seconds)
	tween.tween_property(_bottom_bar, "position:y", _screen().y - (BAR_HEIGHT if enabled else 0.0), seconds)
	await tween.finished

## Centred chapter card: kicker line, large title, gold rule, subtitle. Returns when gone.
func title_card(kicker: String, title: String, subtitle: String, hold: float = 1.8) -> void:
	_card_kicker.text = kicker
	_card_title.text = title
	_card_subtitle.text = subtitle
	_card.visible = true
	_card.modulate.a = 0.0
	var rest_y := _screen().y * 0.5 - 70.0
	_card.position.y = rest_y + 8.0
	var tween := create_tween()
	tween.tween_property(_card, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(_card, "position:y", rest_y, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hold)
	tween.tween_property(_card, "modulate:a", 0.0, 0.35)
	await tween.finished
	_card.visible = false

## Boss name slams in from the left above the bottom bar. Returns when gone.
func boss_intro(boss_name: String, epithet: String, hold: float = 1.5) -> void:
	_intro_name.text = boss_name
	_intro_epithet.text = epithet
	_intro.visible = true
	_intro.modulate.a = 0.0
	_intro.position.x = -60.0
	_intro.scale = Vector2(1.15, 1.15)
	var tween := create_tween()
	tween.tween_property(_intro, "position:x", 24.0, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_intro, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(_intro, "scale", Vector2.ONE, 0.22)
	tween.tween_interval(hold)
	tween.tween_property(_intro, "modulate:a", 0.0, 0.3)
	await tween.finished
	_intro.visible = false

## Full-screen flash plus a huge golden shout that punches in and fades ("JAI SHRI RAM!").
func shout(text: String, hold: float = 0.9) -> void:
	var flash := ColorRect.new()
	flash.color = Color(1.0, 0.96, 0.8, 0.85)
	flash.size = _screen()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(flash)
	var label := _make_label(UIConstants.FONT_SIZE_TITLE + 14, UIConstants.COLOR_DIVINE_GOLD, 6)
	label.text = text
	label.size = Vector2(_screen().x, 60)
	label.position = Vector2(0, _screen().y * 0.5 - 40.0)
	label.pivot_offset = label.size * 0.5
	label.scale = Vector2(2.2, 2.2)
	_root.add_child(label)
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.35)
	tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hold)
	tween.tween_property(label, "modulate:a", 0.0, 0.35)
	await tween.finished
	flash.queue_free()
	label.queue_free()

func show_boss_bar(boss_name: String, max_health: int) -> void:
	_boss_bar.present(boss_name, max_health)

func set_boss_health(health: int) -> void:
	_boss_bar.set_health(health)

func hide_boss_bar() -> void:
	_boss_bar.dismiss()
