class_name BossHealthBar
extends Control

## BossHealthBar: top-centre boss bar with name, segmented fill, white "chip" trail that
## drains after each hit, and a flash on damage. Display only — the encounter owns health.

## Fits between the HUD's top-left and top-right panels (x ≈ 180–405).
const BAR_SIZE := Vector2(170, 8)

var _name: String = ""
var _max: int = 1
var _health: float = 1.0
var _shown_health: float = 1.0
var _chip: float = 1.0
var _flash: float = 0.0
var _chip_delay: float = 0.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(BAR_SIZE.x, 26)
	visible = false

func present(boss_name: String, max_health: int) -> void:
	_name = boss_name
	_max = maxi(1, max_health)
	_health = _max
	_shown_health = _max
	_chip = _max
	visible = true
	modulate.a = 0.0
	position.y = 4.0
	_restart_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	_tween.parallel().tween_property(self, "position:y", 14.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

var _tween: Tween

func _restart_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()

func set_health(value: int) -> void:
	if value < _health:
		_flash = 1.0
		_chip_delay = 0.35
	_health = clampf(value, 0.0, _max)

func dismiss() -> void:
	if not visible:
		return
	_restart_tween()
	_tween.tween_interval(0.4)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(func(): visible = false)

func _process(delta: float) -> void:
	if not visible:
		return
	_shown_health = move_toward(_shown_health, _health, delta * _max * 4.0)
	_chip_delay = maxf(0.0, _chip_delay - delta)
	if _chip_delay <= 0.0:
		_chip = move_toward(_chip, _health, delta * _max * 0.8)
	_flash = maxf(0.0, _flash - delta * 4.0)
	queue_redraw()

func _draw() -> void:
	var font := get_theme_default_font()
	draw_string(font, Vector2(0, 9), _name, HORIZONTAL_ALIGNMENT_CENTER, BAR_SIZE.x, UIConstants.FONT_SIZE_HUD, UIConstants.COLOR_DIVINE_GOLD)
	var bar := Rect2(Vector2(0, 14), BAR_SIZE)
	draw_rect(bar.grow(2), UIConstants.COLOR_VOID_BLACK)
	draw_rect(bar, UIConstants.COLOR_RAKSHASA_CRIMSON.darkened(0.5))
	draw_rect(Rect2(bar.position, Vector2(BAR_SIZE.x * _chip / _max, BAR_SIZE.y)), UIConstants.COLOR_IVORY_LIGHT)
	var fill := UIConstants.COLOR_RUBY_BLOOD.lerp(Color.WHITE, _flash * 0.7)
	draw_rect(Rect2(bar.position, Vector2(BAR_SIZE.x * _shown_health / _max, BAR_SIZE.y)), fill)
	draw_rect(Rect2(bar.position, Vector2(BAR_SIZE.x * _shown_health / _max, 2)), Color(1, 1, 1, 0.25))
	for i in range(1, _max):
		var x := BAR_SIZE.x * i / _max
		draw_line(Vector2(x, bar.position.y), Vector2(x, bar.end.y), UIConstants.COLOR_VOID_BLACK, 1.0)
	draw_rect(bar.grow(1), UIConstants.COLOR_GOLDEN_EMBER, false, 1.0)
