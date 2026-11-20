class_name StoryCards
extends CanvasLayer

## StoryCards: full-screen storybook for the opening and the ending. Each card is a painted
## illustration (drawn in code, palette-locked, using the real Hanuman sprite where he appears),
## a typed narration line, a music swell and a sound cue.
##   await story.play(cards)      cards: [{art, text, sfx, hold, big}]
##   await story.results(stats)   final results card; returns when the player continues
## Enter/Space/J advances (or finishes typing); Esc skips the whole sequence.

const THEME := preload("res://assets/ui/main_theme.tres")
const HANUMAN_LEAP := preload("res://assets/characters/hanuman/char_hanuman_walk_right_05.png")
const HANUMAN_KNEEL := preload("res://assets/characters/hanuman/char_hanuman_idle_left.png")
const RAMA_HD := preload("res://assets/characters/story/story_rama.png")
const SITA_HD := preload("res://assets/characters/story/story_sita.png")
const RAVANA_HD := preload("res://assets/characters/story/story_ravana.png")
const CANVAS := Vector2(320, 160)

var _root: Control
var _art: Control
var _frame: Control
var _text: Label
var _prompt: Label
var _scene := ""
var _t0 := 0.0
var _advance := false
var _skip_all := false
var _stats: Dictionary = {}
var _scale := 1.0

func _ready() -> void:
	layer = 60
	visible = false
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.theme = THEME
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var bg := ColorRect.new()
	bg.color = UIConstants.COLOR_VOID_BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bg)
	# The illustration canvas clips to the framed panel, so nothing spills past the border.
	_art = Control.new()
	_art.clip_contents = true
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.draw.connect(_paint)
	_root.add_child(_art)
	_frame = Control.new()
	_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.draw.connect(_paint_frame)
	_root.add_child(_frame)
	_text = Label.new()
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_color_override("font_color", UIConstants.COLOR_IVORY_LIGHT)
	_text.add_theme_constant_override("outline_size", 3)
	_text.add_theme_color_override("font_outline_color", UIConstants.COLOR_VOID_BLACK)
	_root.add_child(_text)
	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_prompt.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_SMALL)
	_prompt.add_theme_color_override("font_color", UIConstants.COLOR_GOLDEN_EMBER)
	_root.add_child(_prompt)

func _process(_delta: float) -> void:
	if visible:
		var panel := _panel()
		_art.position = panel.position
		_art.size = panel.size
		_art.queue_redraw()
		_frame.queue_redraw()
		_prompt.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 4.0)

func _screen() -> Vector2:
	return get_viewport().get_visible_rect().size

## Panel where the illustration is painted: 2:1, centred, leaving room for narration below.
func _panel() -> Rect2:
	var s := _screen()
	var w := minf(s.x - 40.0, (s.y - 110.0) * 2.0)
	return Rect2(Vector2((s.x - w) * 0.5, 18.0), Vector2(w, w * 0.5))

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if _scene == "results":
			get_tree().quit()
			return
		_skip_all = true
		_advance = true
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("attack"):
		if _text.visible_ratio < 1.0:
			_text.visible_ratio = 1.0
		else:
			_advance = true
	else:
		return
	get_viewport().set_input_as_handled()

func play(cards: Array) -> void:
	visible = true
	_skip_all = false
	_root.modulate.a = 1.0
	for card in cards:
		if _skip_all:
			break
		await _show(card)
	await _fade(0.0, 0.5)
	visible = false

func _show(card: Dictionary) -> void:
	_scene = card.get("art", "")
	_t0 = Time.get_ticks_msec() / 1000.0
	_advance = false
	var panel := _panel()
	var big: bool = card.get("big", false)
	_text.text = card.get("text", "")
	_text.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_TITLE + 14 if big else UIConstants.FONT_SIZE_BODY + 1)
	_text.add_theme_color_override("font_color", UIConstants.COLOR_DIVINE_GOLD if big else UIConstants.COLOR_IVORY_LIGHT)
	_text.size = Vector2(panel.size.x, 60)
	_text.position = Vector2(panel.position.x, panel.get_center().y - 30 if big else panel.end.y + 12)
	_prompt.text = "ENTER  >    ESC  skip"
	_prompt.size = Vector2(panel.size.x, 16)
	_prompt.position = Vector2(panel.position.x, _screen().y - 22)
	_text.visible_ratio = 0.0
	_art.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_art, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(_text, "visible_ratio", 1.0, maxf(0.6, _text.text.length() * 0.028))
	var audio := get_node_or_null("/root/AudioManager")
	if audio:
		audio.swell()
		if card.has("sfx"):
			audio.play_sfx(card["sfx"], -6.0)
	var hold: float = card.get("hold", 6.5)
	while not _advance and Time.get_ticks_msec() / 1000.0 - _t0 < hold:
		await get_tree().process_frame
	if tween.is_valid():
		tween.kill()
	_text.visible_ratio = 1.0
	var out := create_tween()
	out.tween_property(_art, "modulate:a", 0.0, 0.35)
	out.parallel().tween_property(_text, "modulate:a", 0.0, 0.35)
	await out.finished
	_text.modulate.a = 1.0

func _fade(to: float, seconds: float) -> void:
	var tween := create_tween()
	tween.tween_property(_root, "modulate:a", to, seconds)
	await tween.finished

## Results card: run stats and a star rating. Returns when the player presses Enter.
func results(stats: Dictionary) -> void:
	_stats = stats
	visible = true
	_root.modulate.a = 1.0
	_scene = "results"
	_t0 = Time.get_ticks_msec() / 1000.0
	_art.modulate.a = 1.0
	_text.text = ""
	_prompt.text = "ENTER  play again      ESC  quit"
	_prompt.size = Vector2(_panel().size.x, 16)
	_prompt.position = Vector2(_panel().position.x, _screen().y - 22)
	_advance = false
	_skip_all = false
	while not _advance:
		await get_tree().process_frame

# --- Painting ------------------------------------------------------------------------------

func _paint() -> void:
	var panel := _panel()
	var t := Time.get_ticks_msec() / 1000.0 - _t0
	var s := panel.size.x / CANVAS.x
	_scale = s
	_art.draw_set_transform(Vector2.ZERO, 0.0, Vector2(s, s))
	match _scene:
		"abduction": _abduction(t)
		"grief": _grief(t)
		"ring": _ring(t)
		"leap": _leap(t)
		"return": _return_leap(t)
		"chudamani": _chudamani(t)
		"jai": _jai(t)
		"results": _results(t)
	_art.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _paint_frame() -> void:
	if _scene == "results" or _art.modulate.a <= 0.01:
		return
	var panel := _panel()
	var a := _art.modulate.a
	_frame.draw_rect(panel.grow(2), Color(UIConstants.COLOR_GOLDEN_EMBER, a), false, 2.0)
	_frame.draw_rect(panel.grow(5), Color(UIConstants.COLOR_GOLDEN_EMBER, 0.35 * a), false, 1.0)

func _bands(top: Color, bottom: Color, y0: float, y1: float) -> void:
	var n := int((y1 - y0) / 4.0)
	for i in n:
		_art.draw_rect(Rect2(0, y0 + i * 4, CANVAS.x, 4), top.lerp(bottom, float(i) / maxf(n - 1, 1)))

func _waves(y0: float, y1: float, t: float, color: Color) -> void:
	var row := 0
	for y in range(int(y0) + 4, int(y1), 7):
		var off := fposmod(t * (8.0 + row * 2.0) * (1 if row % 2 == 0 else -1) + row * 19.0, 26.0)
		for k in range(-1, 14):
			_art.draw_line(Vector2(k * 26.0 + off, y), Vector2(k * 26.0 + off + 6 + row, y), color, 1.0)
		row += 1

## Draws a story character at full screen-pixel resolution (`px` screen pixels per art pixel),
## standing with its feet at `foot` (canvas units). Snapped to whole pixels so it stays crisp.
func _figure(tex: Texture2D, foot: Vector2, px: float = 1.0) -> void:
	var size := tex.get_size() * px / _scale
	var top_left := ((foot - Vector2(size.x * 0.5, size.y)) * _scale).round() / _scale
	_art.draw_texture_rect(tex, Rect2(top_left, size), false)

func _abduction(t: float) -> void:
	_bands(Color("#0a0814"), Color("#6e1724"), 0, 160)
	_art.draw_circle(Vector2(268, 30), 14, Color("#fbf4e2"))
	_art.draw_circle(Vector2(268, 30), 24, Color(0.98, 0.96, 0.89, 0.08))
	for i in 12:
		_art.draw_circle(Vector2(i * 30 - 5, 156), 16 + (i * 7) % 9, Color("#0e1a14"))
	var c := Vector2(156 + sin(t * 0.5) * 6.0, 118 + sin(t * 1.3) * 2.5)
	# Falling jewels trail behind the flying chariot.
	for i in 9:
		var fall := fposmod(t * 22.0 + i * 11.0, 60.0)
		_art.draw_rect(Rect2(c + Vector2(-60 - i * 9 - fall * 0.6, -10 + fall), Vector2(2, 2)), Color("#ffd84a", 1.0 - fall / 60.0))
	for i in 5:
		_art.draw_line(c + Vector2(80 + i * 6, -60 + i * 9), c + Vector2(104 + i * 10, -60 + i * 9), Color(1, 1, 1, 0.25), 1.0)
	# Ravana stands tall in the Pushpaka chariot; Sita, beside him, reaches back to the earth.
	_figure(RAVANA_HD, c + Vector2(30, 10), 2.0)
	_figure(SITA_HD, c + Vector2(-34, 12), 2.0)
	# The chariot hull in front of them: gold with a jewelled rail.
	_art.draw_colored_polygon(PackedVector2Array([c + Vector2(-90, 0), c + Vector2(90, 0), c + Vector2(72, 22), c + Vector2(-72, 22)]), Color("#c8901a"))
	_art.draw_colored_polygon(PackedVector2Array([c + Vector2(-90, 0), c + Vector2(90, 0), c + Vector2(86, 5), c + Vector2(-86, 5)]), Color("#ffd84a"))
	_art.draw_rect(Rect2(c + Vector2(-92, -3), Vector2(184, 4)), Color("#fff3b0"))
	for k in 11:
		_art.draw_rect(Rect2(c + Vector2(-76 + k * 15, 9), Vector2(4, 4)), Color("#c81c2c" if k % 2 else "#2fa070"))
	_art.draw_colored_polygon(PackedVector2Array([c + Vector2(90, 0), c + Vector2(104, -14), c + Vector2(98, 4)]), Color("#ffd84a"))

func _grief(t: float) -> void:
	# Close shot: Rama tall in the foreground, the sea and the gathering army behind him.
	_bands(Color("#2c2834"), Color("#eb7e28"), 0, 80)
	_art.draw_circle(Vector2(236, 80), 20, Color("#fce27c", 0.85))
	_art.draw_rect(Rect2(262, 68, 58, 12), Color("#2c2834", 0.7))
	_dome_at(Vector2(285, 68), 18, 10, Color("#2c2834", 0.7))
	_art.draw_rect(Rect2(0, 80, 320, 32), Color("#0f3150"))
	_waves(80, 112, t, Color(0.55, 0.8, 0.9, 0.4))
	_art.draw_rect(Rect2(0, 110, 320, 50), Color("#917756"))
	_art.draw_rect(Rect2(0, 110, 320, 2), Color("#d4c19c"))
	for i in 10:
		var v := Vector2(140 + i * 18, 116 + (i % 3) * 4)
		_art.draw_circle(v, 2.5, Color("#16172e"))
		_art.draw_rect(Rect2(v + Vector2(-2, 2), Vector2(4, 7)), Color("#16172e"))
		_art.draw_arc(v + Vector2(4, 8), 4.0, -1.5, 1.0, 6, Color("#16172e"), 1.0)
	_art.draw_circle(Vector2(78, 170), 40, Color("#585266"))
	_art.draw_circle(Vector2(70, 160), 26, Color("#8c869e"))
	_figure(RAMA_HD, Vector2(78, 154), 2.0)

func _ring(t: float) -> void:
	_bands(Color("#16172e"), Color("#3a1a10"), 0, 160)
	var c := Vector2(160, 82)
	for r in 6:
		_art.draw_circle(c, 70 - r * 10, Color(0.99, 0.85, 0.42, 0.03 + r * 0.012))
	# Rama's hand (left) offers the ring between finger and thumb; Hanuman's (right) reaches for it.
	_hand(Vector2(146, 84), false, Color("#3b6fb0"), Color("#5b8fd0"), Color("#ffd84a"))
	_hand(Vector2(176, 88), true, Color("#c55705"), Color("#f37b10"), Color("#851101"))
	var pulse := 0.5 + 0.5 * sin(t * 3.0)
	_art.draw_circle(c, 18 + pulse * 3, Color(1.0, 0.86, 0.42, 0.18))
	_art.draw_arc(c, 8, 0, TAU, 24, Color("#ffd84a"), 3.0)
	_art.draw_arc(c, 8, PI * 1.1, PI * 1.6, 8, Color("#fff3b0"), 1.5)
	_art.draw_circle(c + Vector2(0, -9), 2.6, Color("#c81c2c"))
	var spin := t * 1.5
	for k in 4:
		var d := Vector2.from_angle(spin + k * PI * 0.5) * (14 + pulse * 4)
		_art.draw_line(c + d * 0.7, c + d, Color(1, 1, 1, 0.8), 1.0)

## A forearm and hand reaching toward the centre. `mirror` = coming from the right.
## Rama's has a gold bangle; Hanuman's has fur strokes along the arm.
func _hand(tip: Vector2, mirror: bool, base: Color, lit: Color, accent: Color) -> void:
	var dir := -1.0 if mirror else 1.0
	var edge := 320.0 if mirror else 0.0
	_art.draw_colored_polygon(PackedVector2Array([Vector2(edge, tip.y - 18), tip + Vector2(-26 * dir, -9), tip + Vector2(-26 * dir, 9), Vector2(edge, tip.y + 22)]), base)
	_art.draw_colored_polygon(PackedVector2Array([Vector2(edge, tip.y - 18), tip + Vector2(-26 * dir, -9), tip + Vector2(-26 * dir, -4), Vector2(edge, tip.y - 8)]), lit)
	_art.draw_circle(tip + Vector2(-18 * dir, 0), 11.0, base)
	_art.draw_circle(tip + Vector2(-20 * dir, -4), 7.0, lit)
	for f in 3:
		var y := -6.0 + f * 5.0
		_art.draw_line(tip + Vector2(-12 * dir, y), tip + Vector2(-2 * dir, y + 1), base, 4.0)
		_art.draw_circle(tip + Vector2(-2 * dir, y + 1), 2.0, lit)
	_art.draw_line(tip + Vector2(-16 * dir, -9), tip + Vector2(-4 * dir, -10), base, 4.0)
	_art.draw_circle(tip + Vector2(-4 * dir, -10), 2.0, lit)
	if mirror:
		for k in 7:
			var x := tip.x + 24 + k * 16
			_art.draw_line(Vector2(x, tip.y - 6 + (k % 3) * 4), Vector2(x + 7, tip.y - 3 + (k % 3) * 4), accent, 1.0)
	else:
		_art.draw_rect(Rect2(tip.x - 54, tip.y - 12, 6, 26), accent)
		_art.draw_rect(Rect2(tip.x - 54, tip.y - 12, 2, 26), Color("#fff3b0"))

func _leap(t: float) -> void:
	_bands(Color("#3a5f86"), Color("#fce27c"), 0, 100)
	_art.draw_circle(Vector2(262, 98), 24, Color("#fff3b0", 0.9))
	_art.draw_rect(Rect2(278, 84, 42, 16), Color("#14142a", 0.8))
	_dome_at(Vector2(296, 84), 16, 9, Color("#14142a", 0.8))
	_art.draw_rect(Rect2(0, 100, 320, 60), Color("#1f5a7a"))
	_waves(100, 160, t, Color(0.75, 0.9, 1.0, 0.45))
	_art.draw_colored_polygon(PackedVector2Array([Vector2(0, 160), Vector2(0, 62), Vector2(26, 38), Vector2(44, 52), Vector2(62, 44), Vector2(100, 160)]), Color("#585266"))
	_art.draw_colored_polygon(PackedVector2Array([Vector2(26, 38), Vector2(44, 52), Vector2(34, 58)]), Color("#8c869e"))
	_arc_flight(t, Vector2(36, 34), Vector2(262, 70), Color(1.0, 0.86, 0.42), false)

func _return_leap(t: float) -> void:
	_bands(Color("#2c2834"), Color("#eb7e28"), 0, 100)
	for b in 6:
		var x := b * 20.0
		var top := 54.0 + (b * 13) % 22
		_art.draw_rect(Rect2(x, top, 16, 100 - top), Color("#16172e"))
		var h := 8.0 + 4.0 * sin(t * 9.0 + b)
		_art.draw_colored_polygon(PackedVector2Array([Vector2(x + 2, top), Vector2(x + 8, top - h), Vector2(x + 14, top)]), Color("#eb7e28"))
	for k in 5:
		var rise := fposmod(t * 10.0 + k * 18.0, 70.0)
		_art.draw_circle(Vector2(30 + k * 20, 60 - rise), 6 + rise * 0.12, Color(0.17, 0.16, 0.2, 0.4 * (1.0 - rise / 70.0)))
	_art.draw_rect(Rect2(0, 100, 320, 60), Color("#0f3150"))
	_waves(100, 160, t, Color(0.95, 0.6, 0.4, 0.35))
	_art.draw_colored_polygon(PackedVector2Array([Vector2(320, 160), Vector2(320, 84), Vector2(296, 70), Vector2(270, 100), Vector2(250, 160)]), Color("#2c2834"))
	_arc_flight(t, Vector2(84, 52), Vector2(286, 66), Color(0.95, 0.5, 0.15), true)

## Hanuman soaring along an arc with a glowing trail (fire trail on the return).
func _arc_flight(t: float, from: Vector2, to: Vector2, trail: Color, burning: bool) -> void:
	var p := clampf(t / 4.5, 0.0, 1.0)
	p = 1.0 - pow(1.0 - p, 2.0)
	var pos := func(k: float) -> Vector2: return from.lerp(to, k) - Vector2(0, sin(PI * k) * 46.0)
	for i in 14:
		var k := maxf(0.0, p - i * 0.02)
		_art.draw_circle(pos.call(k), 4.0 - i * 0.25, Color(trail, 0.5 - i * 0.035))
	var at: Vector2 = pos.call(p)
	if burning:
		for i in 3:
			_art.draw_circle(at + Vector2(-12 - i * 4, 6 + sin(t * 12.0 + i) * 2), 3.0 - i * 0.6, Color("#fce27c" if i == 0 else "#eb7e28"))
	_art.draw_texture(HANUMAN_LEAP, at - Vector2(12, 16))

func _chudamani(t: float) -> void:
	# The vanara camp at night: Rama stands; Hanuman kneels and offers Sita's chudamani.
	_bands(Color("#0a0814"), Color("#3a1a10"), 0, 140)
	for k in 30:
		_art.draw_rect(Rect2(fposmod(k * 47.3, 320.0), fposmod(k * 23.1, 70.0), 1, 1), Color(0.98, 0.96, 0.89, 0.6))
	_art.draw_rect(Rect2(0, 140, 320, 20), Color("#2c1e14"))
	_art.draw_rect(Rect2(0, 140, 320, 2), Color("#522b16"))
	var flick := 0.85 + 0.15 * sin(t * 9.0)
	_art.draw_circle(Vector2(282, 140), 34 * flick, Color(0.92, 0.49, 0.16, 0.12))
	_art.draw_colored_polygon(PackedVector2Array([Vector2(274, 142), Vector2(282, 124 - 4 * flick), Vector2(290, 142)]), Color("#eb7e28"))
	_art.draw_colored_polygon(PackedVector2Array([Vector2(278, 142), Vector2(282, 132 - 2 * flick), Vector2(286, 142)]), Color("#fce27c"))
	_figure(RAMA_HD, Vector2(100, 152), 2.0)
	_figure(HANUMAN_KNEEL, Vector2(200, 152), 3.0)
	var gem := Vector2(152, 92) + Vector2(0, sin(t * 1.4) * 1.5)
	var pulse := 0.5 + 0.5 * sin(t * 2.2)
	for r in 4:
		_art.draw_circle(gem, 30 - r * 6 + pulse * 2, Color(0.99, 0.85, 0.42, 0.04 + r * 0.03))
	# The chudamani: a gold hair-jewel with a ruby heart, emerald ring and pearl drops.
	_art.draw_circle(gem, 8, Color("#c8901a"))
	_art.draw_circle(gem, 6.5, Color("#ffd84a"))
	for k in 8:
		_art.draw_circle(gem + Vector2.from_angle(k * TAU / 8.0) * 5, 1.1, Color("#2fa070"))
	_art.draw_circle(gem, 2.6, Color("#c81c2c"))
	_art.draw_rect(Rect2(gem + Vector2(-1, -2), Vector2(1, 1)), Color("#ffb0b0"))
	for k in 3:
		_art.draw_circle(gem + Vector2(-4 + k * 4, 10 + (k % 2) * 2), 1.3, Color("#f6efdc"))

func _jai(t: float) -> void:
	_bands(Color("#6e1724"), Color("#eb7e28"), 0, 160)
	var c := Vector2(160, 80)
	for i in 18:
		var a := i * TAU / 18.0 + t * 0.15
		var col := Color("#fce27c", 0.35) if i % 2 == 0 else Color("#f7b945", 0.2)
		_art.draw_colored_polygon(PackedVector2Array([c, c + Vector2.from_angle(a - 0.09) * 240, c + Vector2.from_angle(a + 0.09) * 240]), col)
	_art.draw_circle(c, 34 + sin(t * 2.0) * 2, Color("#fff3b0", 0.6))

func _results(t: float) -> void:
	_bands(Color("#0a0814"), Color("#26294a"), 0, 160)
	_label("THE MISSION OF HANUMAN", Vector2(160, 18), 13, UIConstants.COLOR_DIVINE_GOLD)
	_art.draw_line(Vector2(90, 26), Vector2(230, 26), UIConstants.COLOR_GOLDEN_EMBER, 1.0)
	var rows := [
		["Time", "%d:%02d" % [int(_stats.get("seconds", 0)) / 60, int(_stats.get("seconds", 0)) % 60]],
		["Imps smashed", str(_stats.get("imps", 0))],
		["Secrets found", "%d / %d" % [_stats.get("secrets", 0), _stats.get("secrets_total", 0)]],
		["Jai Shri Ram!", str(_stats.get("jai", 0))],
		["Defeats", str(_stats.get("deaths", 0))],
	]
	for i in rows.size():
		var y := 46.0 + i * 15.0
		_text_at(Vector2(86, y), rows[i][0], 8, UIConstants.COLOR_PARCHMENT_CREAM, HORIZONTAL_ALIGNMENT_LEFT, 0.0)
		_text_at(Vector2(150, y), rows[i][1], 8, UIConstants.COLOR_IVORY_LIGHT, HORIZONTAL_ALIGNMENT_RIGHT, 84.0)
	var stars: int = _stats.get("stars", 1)
	for i in 3:
		var reveal := clampf((t - 0.4 - i * 0.35) * 3.0, 0.0, 1.0)
		_star(Vector2(130 + i * 30, 132), 10.0 * (0.6 + 0.4 * reveal), i < stars and reveal > 0.0)

func _label(text: String, center: Vector2, size: int, color: Color) -> void:
	_text_at(center, text, size, color, HORIZONTAL_ALIGNMENT_CENTER, 0.0)

## Draws text at true screen resolution (not upscaled from the 320×160 canvas, which would
## smear small pixel-font glyphs). Positions and sizes are given in canvas units.
func _text_at(canvas_pos: Vector2, text: String, canvas_size: int, color: Color, align: HorizontalAlignment, canvas_width: float) -> void:
	var font: Font = THEME.default_font
	var size := int(round(canvas_size * _scale))
	var pos := canvas_pos * _scale
	var width := canvas_width * _scale
	if align == HORIZONTAL_ALIGNMENT_CENTER:
		pos.x -= font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x * 0.5
		width = -1.0
	_art.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_art.draw_string(font, pos.round(), text, align if width > 0.0 else HORIZONTAL_ALIGNMENT_LEFT, width if width > 0.0 else -1.0, size, color)
	_art.draw_set_transform(Vector2.ZERO, 0.0, Vector2(_scale, _scale))

func _star(c: Vector2, r: float, lit: bool) -> void:
	var points := PackedVector2Array()
	for i in 10:
		var rad := r if i % 2 == 0 else r * 0.45
		points.append(c + Vector2.from_angle(-PI * 0.5 + i * PI / 5.0) * rad)
	_art.draw_colored_polygon(points, Color("#ffd84a") if lit else Color("#3a3550"))

func _dome_at(base: Vector2, width: float, height: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		points.append(base + Vector2(cos(a) * width * 0.5, sin(a) * height))
	_art.draw_colored_polygon(points, color)
