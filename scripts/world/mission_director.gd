class_name MissionDirector
extends Node2D

## Compact five-chapter vertical slice. It owns only level flow and temporary
## encounter state; player state remains on Hanuman and UI consumes GameEvents.

const LEVEL_NAMES := ["", "CROSSING THE OCEAN", "THE GATES OF LANKA", "LANKA AT NIGHT", "ASHOKA VATIKA", "THE ESCAPE"]
const LEVEL_OBJECTIVES := ["", "Shrink with [SHIFT] to pass Surasa, then cross the sea.", "Strike Lankini with [J] when you are close.", "Search the palace and avoid the guards' sight.", "Find Sita and present Rama's ring.", "Run across the burning rooftops and reach the ocean."]

@onready var player = get_parent().get_node("Hanuman")
@onready var dialogue: DialogueBox = get_parent().get_node("DialogueBox")
@onready var notification: ObjectiveNotification = get_parent().get_node("ObjectiveNotification")
@onready var tutorial: TutorialHint = get_parent().get_node("TutorialHint")
@onready var map_overlay: MapRevealOverlay = get_parent().get_node("MapRevealOverlay")
@onready var overlay: CinematicOverlay = get_parent().get_node("CinematicOverlay")
## World-space UI hidden while a cinematic plays (it would zoom with the camera otherwise).
@onready var gameplay_ui: Array[CanvasItem] = [
	get_parent().get_node("HUD"), tutorial, notification, get_parent().get_node("InteractionPrompt"),
]

const CHAPTER_TAGLINES := ["", "Hanuman leaps across the ocean in search of Sita.", "Lankini guards the gates of the golden city.", "Slip through the sleeping palace unseen.", "In the grove of Ashoka, Sita waits.", "Lanka burns. Race for the sea!"]

var chapter := 1
var dialogue_seen := false
var hazard_cooldown := 0.0
var guard_alert := 0.0
var encounters: BossEncounters
var cinematic_playing := false
var _knockback_tween: Tween
var _intros_seen: Dictionary = {}
## Bumped on every chapter (re)start so a running cinematic can tell it was superseded.
var _flow_token := 0

func _ready() -> void:
	z_index = -10
	player.connect("attack_performed", Callable(self, "_on_player_attack"))
	dialogue.dialogue_completed.connect(_on_dialogue_completed)
	get_parent().get_node("PauseMenu").restart_level_requested.connect(func(): _start_chapter(chapter))
	encounters = BossEncounters.new()
	encounters.name = "BossEncounters"
	add_child(encounters)
	encounters.setup(self, player)
	encounters.lankini_defeated.connect(_on_lankini_defeated)
	encounters.lankini_health_changed.connect(overlay.set_boss_health)
	# main.tscn boots straight into play (the menu is not in the flow yet), so start music here.
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_music()
	_start_chapter(1)

func _process(delta: float) -> void:
	hazard_cooldown = maxf(0.0, hazard_cooldown - delta)
	queue_redraw()
	if cinematic_playing:
		return
	match chapter:
		1: _update_ocean(delta)
		2: _update_gates(delta)
		3: _update_night(delta)
		4: _update_vatika()
		5: _update_escape(delta)

func _start_chapter(number: int) -> void:
	chapter = number
	dialogue_seen = false
	guard_alert = 0.0
	if _knockback_tween and _knockback_tween.is_valid():
		_knockback_tween.kill()
	player.global_position = Vector2(50, 180)
	player.restore_health()
	map_overlay.visible = number == 3
	map_overlay.clear_reveal()
	encounters.reset_for_chapter(number)
	overlay.hide_boss_bar()
	_flow_token += 1
	if cinematic_playing:
		_set_cinematic(false)
		GameFeel.release(self, 0.01)
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("telegraph", -5.0)
	_run_chapter_intro(number, _flow_token)

## First visit: letterboxed title card, then a boss intro where the chapter has one.
## Restarts after a defeat skip straight back into play so retries stay quick.
func _run_chapter_intro(number: int, token: int) -> void:
	if not _intros_seen.has(number):
		_intros_seen[number] = true
		_set_cinematic(true)
		overlay.letterbox(true)
		var kicker := "LANKA SHADOWBOUND  -  CHAPTER %d" % number if number == 1 else "CHAPTER %d" % number
		await overlay.title_card(kicker, LEVEL_NAMES[number], CHAPTER_TAGLINES[number], 1.6)
		if token != _flow_token:
			return
		if number == 1:
			await _intro_boss(encounters.surasa, "SURASA", "Mother of Serpents", "hiss", Color(1.0, 0.35, 0.3))
		elif number == 2:
			await _intro_boss(encounters.lankini, "LANKINI", "Guardian of the Golden City", "roar", Color(1.0, 0.5, 0.25))
		if token != _flow_token:
			return
		_set_cinematic(false)
	if overlay.is_letterboxed():
		overlay.letterbox(false)
	_begin_chapter_play(number)

## Camera pushes in on the boss, she winds up and slams, her name card lands, camera returns.
func _intro_boss(boss: BossSprite, boss_name: String, epithet: String, sound: String, tint: Color) -> void:
	await GameFeel.focus(self, boss.global_position, 1.45, 0.6)
	boss.windup(0.8, tint)
	boss.play_segment("attack", 0, 2, 0.8, 0.3)
	_play_sfx(sound, -2.0)
	await get_tree().create_timer(0.8).timeout
	GameFeel.shake(self, 5.0, 0.35)
	VFXImpact.shockwave(encounters, boss.global_position + Vector2(0, 30), 70.0, tint, 0.55)
	_play_sfx("slam", -5.0)
	await overlay.boss_intro(boss_name, epithet, 1.2)
	await GameFeel.release(self, 0.5)

func _set_cinematic(enabled: bool) -> void:
	cinematic_playing = enabled
	player.velocity = Vector2.ZERO
	player.set_physics_process(not enabled)
	player.set_process_unhandled_input(not enabled)
	for ui in gameplay_ui:
		ui.modulate.a = 0.0 if enabled else 1.0

func _play_sfx(sound: String, volume_db: float = 0.0) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx_varied(sound, volume_db)

func _begin_chapter_play(number: int) -> void:
	GameEvents.objective_updated.emit(LEVEL_OBJECTIVES[number], false)
	if number == 2:
		overlay.show_boss_bar("LANKINI", BossEncounters.LANKINI_MAX_HEALTH)
	if number == 1:
		tutorial.show_preset("shrink", 5.0)
	elif number == 2:
		tutorial.show_preset("combat", 4.0)
	elif number == 3:
		tutorial.show_preset("stealth", 4.0)
	elif number == 5:
		GameEvents.encounter_feedback.emit("Hanuman's tail burns—run!")

func _advance_chapter() -> void:
	GameEvents.objective_updated.emit("Complete", true)
	if chapter < 5:
		_start_chapter(chapter + 1)
	else:
		_show_ending()

func _update_ocean(delta: float) -> void:
	encounters.update_ocean(delta)
	if player.global_position.x > 600:
		_advance_chapter()

func _update_gates(delta: float) -> void:
	encounters.update_gates(delta)

## Victory outro: bars in, camera pushes in on Lankini falling, victory card, then move on.
func _on_lankini_defeated() -> void:
	var token := _flow_token
	overlay.hide_boss_bar()
	_set_cinematic(true)
	overlay.letterbox(true)
	await GameFeel.focus(self, encounters.lankini.global_position, 1.55, 0.7)
	if token != _flow_token:
		return
	_play_sfx("victory", -2.0)
	await overlay.title_card("VICTORY", "LANKINI DEFEATED", "The gates of Lanka stand open.", 1.2)
	if token != _flow_token:
		return
	await GameFeel.release(self, 0.4)
	if token != _flow_token:
		return
	# Bars stay down: the next chapter's intro continues the cinematic.
	_set_cinematic(false)
	_advance_chapter()

func _update_night(delta: float) -> void:
	var cell := Vector2i(int(player.global_position.x / 32.0), int(player.global_position.y / 30.0))
	GameEvents.reveal_map_cell(cell)
	var guard := Vector2(325, 180)
	var distance: float = player.global_position.distance_to(guard)
	guard_alert = move_toward(guard_alert, 1.0 if distance < 105.0 else 0.0, delta * 0.8)
	GameEvents.stealth_alert_level_changed.emit(guard_alert, guard_alert > 0.92)
	if guard_alert > 0.92:
		_warn_or_damage("A guard has spotted you—retreat into shadow.")
	if player.global_position.x > 240 and not dialogue_seen:
		dialogue_seen = true
		dialogue.play_mandodari_misunderstanding_scene()
	if dialogue_seen and not dialogue.is_active and player.global_position.x > 580:
		_advance_chapter()

func _update_vatika() -> void:
	if player.global_position.x > 310 and not dialogue_seen:
		dialogue_seen = true
		dialogue.play_sita_ring_handover_scene()
	if dialogue_seen and not dialogue.is_active and player.global_position.x > 410:
		_advance_chapter()

func _update_escape(_delta: float) -> void:
	if player.global_position.x > 180 and player.global_position.x < 520 and hazard_cooldown <= 0.0:
		player.take_damage(7)
		hazard_cooldown = 1.0
		GameEvents.encounter_feedback.emit("Flames scorch the rooftops—keep moving!")
	if player.global_position.x > 580:
		_advance_chapter()

func _on_player_attack(origin: Vector2) -> void:
	encounters.on_player_attack(chapter, origin, player.attack_range)

func _on_dialogue_completed() -> void:
	if chapter == 4:
		notification.notify("OBJECTIVE COMPLETE", "RAMA'S RING DELIVERED", "Sita has renewed hope.", true)

func _warn_or_damage(message: String) -> void:
	if hazard_cooldown > 0.0:
		return
	hazard_cooldown = 1.0
	hurt_player(12, player.global_position, 0.0, message)

## Single entry point for hurting Hanuman: damage, flash, knockback away from `source`,
## shake, feedback text, and a chapter restart on defeat.
func hurt_player(amount: int, source: Vector2, knockback: float, message: String = "") -> void:
	player.take_damage(amount)
	VFXHitFlash.damage_flash(player)
	GameFeel.shake(self, 4.0, 0.2)
	if message != "":
		GameEvents.encounter_feedback.emit(message)
	if player.health <= 0:
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("defeat", -1.0)
		_start_chapter(chapter)
		return
	var direction: Vector2 = (player.global_position - source).normalized()
	if knockback > 0.0 and direction != Vector2.ZERO:
		var target: Vector2 = (player.global_position + direction * knockback).clamp(Vector2(16, 16), Vector2(624, 344))
		if _knockback_tween and _knockback_tween.is_valid():
			_knockback_tween.kill()
		_knockback_tween = create_tween()
		_knockback_tween.tween_property(player, "global_position", target, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _show_ending() -> void:
	set_process(false)
	GameEvents.objective_updated.emit("Journey complete", true)
	notification.notify("MISSION COMPLETE", "LANKA SHADOWBOUND", "Hanuman returns across the ocean with hope for Rama and Sita.", true)
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("victory", -2.0)

func _draw() -> void:
	var backgrounds: Array[Color] = [
		Color("#16405e"), Color("#422938"), Color("#12172e"),
		Color("#264b31"), Color("#54231c")
	]
	var background: Color = backgrounds[chapter - 1]
	if chapter == 1:
		_draw_ocean()
		return
	draw_rect(Rect2(0, 0, 640, 360), background)
	for x in range(20, 620, 60):
		draw_circle(Vector2(x, 140 + sin(float(x)) * 18.0), 9.0, Color("#fce27c") if chapter == 4 else Color("#3b4876"))
	if chapter == 3:
		draw_circle(Vector2(325, 180), 14.0, Color("#f7b945"))
		draw_string(ThemeDB.fallback_font, Vector2(300, 158), "GUARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	if chapter == 5:
		for x in range(190, 520, 60):
			draw_circle(Vector2(x, 215), 12.0, Color("#eb7e28"))

## Chapter 1 backdrop: dusk sky, Lanka on the far horizon (the goal), animated sea,
## a whirlpool under Surasa and Simhika's shadow pool. Procedural until painted art lands.
func _draw_ocean() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var sky_top := Color("#0b1c33")
	var sky_low := Color("#3a5f86")
	for i in 14:
		draw_rect(Rect2(0, i * 8, 640, 8), sky_top.lerp(sky_low, i / 13.0))
	draw_rect(Rect2(0, 108, 640, 6), Color("#e8a04a").darkened(0.15))
	# Lanka silhouette on the right horizon.
	var lanka := Color("#14142a")
	draw_rect(Rect2(540, 96, 100, 16), lanka)
	for tower in [[552, 82, 10], [572, 70, 12], [596, 62, 14], [622, 76, 10]]:
		draw_rect(Rect2(tower[0], tower[1], tower[2], 112 - tower[1]), lanka)
		draw_colored_polygon(PackedVector2Array([
			Vector2(tower[0] - 2, tower[1]), Vector2(tower[0] + tower[2] / 2.0, tower[1] - 10),
			Vector2(tower[0] + tower[2] + 2, tower[1])]), lanka)
		draw_rect(Rect2(tower[0] + tower[2] / 2.0 - 1, tower[1] + 8, 2, 3), Color("#f7c55a"))
	# Sea: lighter near the horizon, deeper toward the viewer.
	var sea_far := Color("#2c6c8e")
	var sea_near := Color("#0f3150")
	for i in 31:
		draw_rect(Rect2(0, 114 + i * 8, 640, 8), sea_far.lerp(sea_near, i / 30.0))
	for row in 11:
		var y := 124.0 + row * 22.0
		var dir := 1.0 if row % 2 == 0 else -1.0
		var length := 8.0 + row * 1.5
		var offset := fposmod(t * (10.0 + row * 2.0) * dir + row * 37.0, 48.0)
		for k in range(-1, 15):
			var x := k * 48.0 + offset
			draw_line(Vector2(x, y), Vector2(x + length, y), Color(0.55, 0.8, 0.9, 0.35 + 0.02 * row), 1.0)
	# Surasa's whirlpool and Simhika's shadow pool, centred under each boss.
	draw_set_transform(Vector2(350, 214), 0.0, Vector2(1.0, 0.32))
	for ring in 4:
		var r := 30.0 + ring * 10.0 + sin(t * 2.0 + ring) * 2.0
		draw_arc(Vector2.ZERO, r, t * 1.5 + ring, t * 1.5 + ring + TAU * 0.8, 32, Color(0.75, 0.9, 1.0, 0.45 - ring * 0.08), 2.0)
	draw_set_transform(Vector2(490, 216), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 46.0 + sin(t * 1.7) * 3.0, Color(0.12, 0.02, 0.18, 0.75))
	draw_circle(Vector2.ZERO, 30.0, Color(0.28, 0.06, 0.36, 0.55))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
