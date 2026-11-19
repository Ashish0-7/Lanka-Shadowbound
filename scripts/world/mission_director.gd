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

var chapter := 1
var boss_health := 0
var dialogue_seen := false
var hazard_cooldown := 0.0
var guard_alert := 0.0
var surasa_boss: BossSprite
var simhika_boss: BossSprite
var lankini_boss: BossSprite

func _ready() -> void:
	z_index = -10
	player.connect("attack_performed", Callable(self, "_on_player_attack"))
	dialogue.dialogue_completed.connect(_on_dialogue_completed)
	get_parent().get_node("PauseMenu").restart_level_requested.connect(func(): _start_chapter(chapter))
	_create_bosses()
	_start_chapter(1)

func _create_bosses() -> void:
	surasa_boss = BossSprite.new()
	surasa_boss.boss_name = "surasa"
	surasa_boss.name = "Surasa"
	surasa_boss.position = Vector2(350, 180)
	surasa_boss.scale = Vector2(1.35, 1.35)
	surasa_boss.z_index = 1
	add_child(surasa_boss)

	simhika_boss = BossSprite.new()
	simhika_boss.boss_name = "simhika"
	simhika_boss.name = "Simhika"
	simhika_boss.position = Vector2(490, 180)
	simhika_boss.scale = Vector2(1.35, 1.35)
	simhika_boss.z_index = 1
	add_child(simhika_boss)

	lankini_boss = BossSprite.new()
	lankini_boss.boss_name = "lankini"
	lankini_boss.name = "Lankini"
	lankini_boss.position = Vector2(500, 180)
	lankini_boss.scale = Vector2(1.5, 1.5)
	lankini_boss.z_index = 1
	add_child(lankini_boss)

func _process(delta: float) -> void:
	hazard_cooldown = maxf(0.0, hazard_cooldown - delta)
	match chapter:
		1: _update_ocean(delta)
		2: _update_gates(delta)
		3: _update_night(delta)
		4: _update_vatika()
		5: _update_escape(delta)
	queue_redraw()

func _start_chapter(number: int) -> void:
	chapter = number
	boss_health = 0
	dialogue_seen = false
	guard_alert = 0.0
	player.global_position = Vector2(50, 180)
	player.restore_health()
	map_overlay.visible = number == 3
	map_overlay.clear_reveal()
	_hide_bosses()
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("telegraph", -5.0)
	if number == 1:
		surasa_boss.visible = true
		surasa_boss.set_state("idle")
		simhika_boss.visible = true
		simhika_boss.set_state("idle")
	elif number == 2:
		lankini_boss.visible = true
		lankini_boss.set_state("idle")
	GameEvents.objective_updated.emit(LEVEL_OBJECTIVES[number], false)
	notification.notify("CHAPTER %d" % number, LEVEL_NAMES[number], LEVEL_OBJECTIVES[number])
	if number == 1:
		tutorial.show_preset("shrink", 5.0)
	elif number == 2:
		boss_health = 6
		tutorial.show_preset("combat", 4.0)
	elif number == 3:
		tutorial.show_preset("stealth", 4.0)
	elif number == 5:
		GameEvents.encounter_feedback.emit("Hanuman's tail burns—run!")

func _hide_bosses() -> void:
	surasa_boss.visible = false
	simhika_boss.visible = false
	lankini_boss.visible = false

func _advance_chapter() -> void:
	GameEvents.objective_updated.emit("Complete", true)
	if chapter < 5:
		_start_chapter(chapter + 1)
	else:
		_show_ending()

func _update_ocean(_delta: float) -> void:
	if player.global_position.x > 310 and player.global_position.x < 410:
		surasa_boss.play_once("special" if player.is_shrunk() else "attack", 0.7)
	elif player.global_position.x > 450:
		simhika_boss.play_once("special", 0.7)
	else:
		surasa_boss.set_state("idle")
		simhika_boss.set_state("idle")
	if player.global_position.x > 310 and player.global_position.x < 410 and not player.is_shrunk():
		_warn_or_damage("Surasa's jaws close! Use [SHIFT] to shrink.")
	if player.global_position.x > 600:
		_advance_chapter()

func _update_gates(delta: float) -> void:
	var boss := Vector2(500, 180)
	if boss_health > 0 and player.global_position.distance_to(boss) < 110.0 and hazard_cooldown <= 0.0:
		player.take_damage(8)
		hazard_cooldown = 1.2
		lankini_boss.play_once("attack", 0.75)
		GameEvents.encounter_feedback.emit("Lankini strikes—move in, strike, retreat!")
	if boss_health <= 0:
		lankini_boss.set_state("defeat")
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
	if chapter != 2 or boss_health <= 0:
		return
	if origin.distance_to(Vector2(500, 180)) <= player.attack_range:
		boss_health -= 1
		lankini_boss.play_once("hurt", 0.55)
		GameEvents.encounter_feedback.emit("Lankini staggered! %d strikes remain." % boss_health)
		if boss_health <= 0:
			notification.notify("VICTORY", "LANKINI DEFEATED", "The gates of Lanka stand open.", true)
			if has_node("/root/AudioManager"):
				get_node("/root/AudioManager").play_sfx("victory", -2.0)

func _on_dialogue_completed() -> void:
	if chapter == 4:
		notification.notify("OBJECTIVE COMPLETE", "RAMA'S RING DELIVERED", "Sita has renewed hope.", true)

func _warn_or_damage(message: String) -> void:
	if hazard_cooldown > 0.0:
		return
	player.take_damage(12)
	hazard_cooldown = 1.0
	GameEvents.encounter_feedback.emit(message)
	if player.health <= 0:
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("defeat", -1.0)
		_start_chapter(chapter)

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
	draw_rect(Rect2(0, 0, 640, 360), background)
	for x in range(20, 620, 60):
		draw_circle(Vector2(x, 140 + sin(float(x)) * 18.0), 9.0, Color("#fce27c") if chapter == 4 else Color("#3b4876"))
	if chapter == 1:
		draw_circle(Vector2(350, 180), 38.0, Color("#6e1724"))
		draw_string(ThemeDB.fallback_font, Vector2(318, 182), "SURASA", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	if chapter == 2 and boss_health > 0:
		draw_circle(Vector2(500, 180), 22.0, Color("#ba2535"))
		draw_string(ThemeDB.fallback_font, Vector2(450, 150), "LANKINI  %d/6" % boss_health, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	if chapter == 3:
		draw_circle(Vector2(325, 180), 14.0, Color("#f7b945"))
		draw_string(ThemeDB.fallback_font, Vector2(300, 158), "GUARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	if chapter == 5:
		for x in range(190, 520, 60):
			draw_circle(Vector2(x, 215), 12.0, Color("#eb7e28"))
