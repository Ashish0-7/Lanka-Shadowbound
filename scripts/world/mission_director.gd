class_name MissionDirector
extends Node2D

## Compact five-chapter vertical slice. It owns only level flow and temporary
## encounter state; player state remains on Hanuman and UI consumes GameEvents.

const LEVEL_NAMES := ["", "CROSSING THE OCEAN", "THE GATES OF LANKA", "LANKA AT NIGHT", "ASHOKA VATIKA", "THE ESCAPE"]
const LEVEL_OBJECTIVES := ["", "Shrink with [SHIFT] to pass Surasa, then cross the sea.", "Strike Lankini with [J] when you are close.", "Search the palace and avoid the guards' sight.", "Find Sita and present Rama's ring.", "Run across the burning rooftops and reach the ocean."]

@onready var player = get_parent().get_node("Hanuman")
@onready var dialogue: DialogueBox = get_parent().get_node("UI/DialogueBox")
@onready var notification: ObjectiveNotification = get_parent().get_node("UI/ObjectiveNotification")
@onready var tutorial: TutorialHint = get_parent().get_node("UI/TutorialHint")
@onready var map_overlay: MapRevealOverlay = get_parent().get_node("UI/MapRevealOverlay")
@onready var overlay: CinematicOverlay = get_parent().get_node("CinematicOverlay")
## World-space UI hidden while a cinematic plays (it would zoom with the camera otherwise).
@onready var gameplay_ui: Array[CanvasItem] = [
	get_parent().get_node("UI/HUD"), tutorial, notification, get_parent().get_node("UI/InteractionPrompt"),
]

const CHAPTER_TAGLINES := ["", "Hanuman leaps across the ocean in search of Sita.", "Lankini guards the gates of the golden city.", "Slip through the sleeping palace unseen.", "In the grove of Ashoka, Sita waits.", "Lanka burns. Race for the sea!"]

var chapter := 1
var dialogue_seen := false
var hazard_cooldown := 0.0
var guard_alert := 0.0
var encounters: BossEncounters
var maze: LevelMaze
var backdrop: ChapterBackdrop
const NPC_DIR := "res://assets/characters/npcs/"
var guard_sprites: Array[AnimatedSprite2D] = []
var guard_posts: Array[Vector2] = []
var mandodari_sprite: AnimatedSprite2D
var sita_sprite: AnimatedSprite2D
var fog: FogOfWar
@onready var camera: CameraRig = player.get_node("Camera2D")
## Chapter 5: the burning stretch of rooftops that scorches Hanuman.
var fire_zone := Rect2()
var sita_position := Vector2.ZERO
var cinematic_playing := false
var _knock_velocity := Vector2.ZERO
var _sita_farewell := -1.0
var swarm: MinionSwarm
## Devotion fills from kills and boss hits; full → [Q] "Jai Shri Ram!" giant form.
const DEVOTION_MAX := 100.0
const GIANT_SECONDS := 4.0
var devotion := 0.0
const CALLOUTS := {2: "DOUBLE!", 3: "TRIPLE!", 4: "QUAD SMASH!"}
var _intros_seen: Dictionary = {}
## Bumped on every chapter (re)start so a running cinematic can tell it was superseded.
var _flow_token := 0

func _ready() -> void:
	z_index = -10
	player.connect("attack_performed", Callable(self, "_on_player_attack"))
	dialogue.dialogue_completed.connect(_on_dialogue_completed)
	get_parent().get_node("UI/PauseMenu").restart_level_requested.connect(func(): _start_chapter(chapter))
	backdrop = ChapterBackdrop.new()
	backdrop.name = "Backdrop"
	backdrop.z_index = -1
	add_child(backdrop)
	maze = LevelMaze.new()
	maze.name = "Maze"
	add_child(maze)
	backdrop.maze = maze
	mandodari_sprite = _make_npc("Mandodari", {"idle": [[NPC_DIR + "char_mandodari_idle.png"], 1.0]})
	# Sita: sorrowful with an occasional blink, then joyful once Hanuman finds her.
	var sad := []
	for i in 14:
		sad.append(NPC_DIR + "char_sita_seated_sad.png")
	sad.append(NPC_DIR + "char_sita_seated_blink.png")
	sita_sprite = _make_npc("Sita", {"sad": [sad, 6.0], "joy": [[NPC_DIR + "char_sita_seated_joy.png"], 1.0]})
	encounters = BossEncounters.new()
	encounters.name = "BossEncounters"
	add_child(encounters)
	encounters.setup(self, player)
	swarm = MinionSwarm.new()
	swarm.name = "Minions"
	swarm.maze = maze
	swarm.player = player
	add_child(swarm)
	swarm.minions_killed.connect(_on_minions_killed)
	# Imps nip at the ground: a flying Hanuman is out of reach.
	swarm.player_nipped.connect(func(damage: int, from: Vector2): if not player.is_flying(): hurt_player(damage, from, 16.0))
	player.flight_changed.connect(_on_flight_changed)
	player.spin_performed.connect(_on_player_spin)
	fog = FogOfWar.new()
	fog.name = "FogOfWar"
	fog.z_index = 8
	fog.maze = maze
	fog.player = player
	fog.swarm = swarm
	add_child(fog)
	_add_devotion(0.0)
	encounters.lankini_defeated.connect(_on_lankini_defeated)
	encounters.lankini_health_changed.connect(overlay.set_boss_health)
	# main.tscn boots straight into play (the menu is not in the flow yet), so start music here.
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_music()
	# Deferred: the UI, cinematic overlay and story cards come after the director in main.tscn.
	call_deferred("_begin_game")

# --- Story frame: opening, run stats, ending ------------------------------------------------

const OPENING := [
	{"art": "abduction", "sfx": "telegraph", "text": "Ravana, the ten-headed king of Lanka, seized Sita from the forest and carried her away across the sea."},
	{"art": "grief", "sfx": "water", "text": "Rama searched for her in grief, while the vanara army gathered on the southern shore."},
	{"art": "ring", "sfx": "objective", "text": "To Hanuman, Rama gave his ring: \"Show this to Sita, so she knows I am coming for her.\""},
	{"art": "leap", "sfx": "transition", "text": "From the peak of Mount Mahendra, Hanuman leapt across the ocean towards Lanka."},
]
const ENDING := [
	{"art": "return", "sfx": "fire", "text": "With Lanka ablaze behind him, Hanuman leapt back across the ocean."},
	{"art": "chudamani", "sfx": "objective", "text": "He placed Sita's chudamani in Rama's hands: \"I have seen her, my Lord. She waits for you.\""},
	{"art": "jai", "sfx": "victory", "text": "JAI SHRI RAM!", "big": true, "hold": 3.5},
]

@onready var story: StoryCards = get_parent().get_node("StoryCards")
var run_seconds := 0.0
var imps_smashed := 0
var secrets_found := 0
var defeats := 0
var jai_count := 0
var _ending_started := false

func _begin_game() -> void:
	_set_cinematic(true)
	await story.play(OPENING)
	_set_cinematic(false)
	_start_chapter(1)

static func _count_secrets() -> int:
	var total := 0
	for chapter in MazeLayouts.LAYOUTS:
		for row in MazeLayouts.LAYOUTS[chapter]:
			total += String(row).count("o")
	return total

## The finale: the leap home, the chudamani, Jai Shri Ram, then the results card.
func _show_ending() -> void:
	if _ending_started:
		return
	_ending_started = true
	GameEvents.objective_updated.emit("Journey complete", true)
	_set_cinematic(true)
	await story.play(ENDING)
	var stars := 1
	if defeats <= 2:
		stars = 2
	if defeats == 0 and secrets_found * 2 >= _count_secrets():
		stars = 3
	await story.results({
		"seconds": run_seconds, "imps": imps_smashed, "secrets": secrets_found,
		"secrets_total": _count_secrets(), "jai": jai_count, "deaths": defeats, "stars": stars,
	})
	get_tree().reload_current_scene()

func _process(delta: float) -> void:
	hazard_cooldown = maxf(0.0, hazard_cooldown - delta)
	queue_redraw()
	if cinematic_playing:
		return
	run_seconds += delta
	swarm.update(delta)
	_collect_pickups()
	match chapter:
		1: _update_ocean(delta)
		2: _update_gates(delta)
		3: _update_night(delta)
		4: _update_vatika()
		5: _update_escape(delta)

## Lotus flowers hidden in secret rooms restore health and devotion.
func _collect_pickups() -> void:
	var cell := maze.cell_at(player.global_position)
	if maze.kind_at(cell) != "o":
		return
	maze.consume(cell)
	secrets_found += 1
	player.health = mini(player.max_health, player.health + 25)
	GameEvents.player_health_changed.emit(player.health, player.max_health)
	_add_devotion(15.0)
	VFXImpact.sparks(self, maze.cell_center(cell), Color(0.91, 0.42, 0.51), 14)
	FloatingText.spawn(self, maze.cell_center(cell) + Vector2(0, -14), "LOTUS +25", Color(0.99, 0.75, 0.82), 11)
	_play_sfx("objective", -4.0)

func _unhandled_key_input(event: InputEvent) -> void:
	# F11 toggles between fullscreen and a window.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)

func _start_chapter(number: int) -> void:
	chapter = number
	dialogue_seen = false
	guard_alert = 0.0
	_knock_velocity = Vector2.ZERO
	_sita_farewell = -1.0
	maze.build(number)
	var world := maze.world_rect()
	player.world_rect = world
	encounters.place_from_maze(maze)
	# Guards: one rakshasa per G marker.
	for g in guard_sprites:
		g.queue_free()
	guard_sprites.clear()
	guard_posts = maze.marker_positions("G")
	for post in guard_posts:
		var g := _make_npc("Guard", {"idle": [[NPC_DIR + "char_guard_rakshasa_01.png", NPC_DIR + "char_guard_rakshasa_02.png"], 5.0]})
		g.position = post
		g.visible = true
		guard_sprites.append(g)
	sita_position = maze.marker_position("T", Vector2.ZERO) if number == 4 else Vector2.ZERO
	fire_zone = Rect2(world.position.x + 180, ChapterBackdrop.HORIZON, world.size.x - 320, world.end.y - ChapterBackdrop.HORIZON) if number == 5 else Rect2()
	backdrop.chapter = number
	backdrop.guards = guard_posts
	backdrop.sita_position = sita_position
	backdrop.sita_found = false
	backdrop.surasa_position = encounters.SURASA_POS if number == 1 else Vector2.ZERO
	backdrop.simhika_position = encounters.SIMHIKA_POS if number == 1 else Vector2.ZERO
	backdrop.lankini_position = encounters.LANKINI_POS if number == 2 else Vector2.ZERO
	backdrop.fire_zone = fire_zone
	backdrop.refresh()
	sita_sprite.visible = sita_position != Vector2.ZERO
	sita_sprite.position = sita_position + Vector2(0, -6)
	sita_sprite.play("sad")
	var queen_at := maze.marker_position("M", Vector2.ZERO) if number == 3 else Vector2.ZERO
	mandodari_sprite.visible = queen_at != Vector2.ZERO
	mandodari_sprite.position = queen_at + Vector2(0, -4)
	player.global_position = maze.marker_position("S", Vector2(50, 180))
	player.restore_health()
	camera.set_world(world)
	# The old screen-space map overlay is replaced by the world-space fog of war.
	map_overlay.visible = false
	map_overlay.clear_reveal()
	fog.guards = guard_posts
	# Fog only where it fits the story: the night palace and the moonlit grove.
	match number:
		3: fog.configure(true, 4.5, 0.6, Color("#05040c"))
		4: fog.configure(true, 6.0, 0.45, Color("#030a06"))
		_: fog.configure(false)
	backdrop.guard_alert = 0.0
	GameEvents.stealth_alert_level_changed.emit(0.0, false)
	encounters.reset_for_chapter(number)
	swarm.spawn(number)
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

## Builds a pixel-art NPC from {animation: [[frame paths], fps]}. Hidden until a chapter places it.
func _make_npc(npc_name: String, animations: Dictionary) -> AnimatedSprite2D:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim in animations:
		frames.add_animation(anim)
		frames.set_animation_speed(anim, animations[anim][1])
		for path in animations[anim][0]:
			frames.add_frame(anim, load(path))
	var npc := AnimatedSprite2D.new()
	npc.name = npc_name
	npc.sprite_frames = frames
	npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.z_index = 1
	npc.visible = false
	npc.play(animations.keys()[0])
	add_child(npc)
	return npc

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
		GameEvents.encounter_feedback.emit("Hanuman's tail burns! Double-tap [SPACE] to fly over the flames!")

func _advance_chapter() -> void:
	GameEvents.objective_updated.emit("Complete", true)
	if chapter < 5:
		_start_chapter(chapter + 1)
	else:
		_show_ending()

func _update_ocean(delta: float) -> void:
	encounters.update_ocean(delta)
	if maze.is_exit(player.global_position):
		_advance_chapter()

## Knockback that respects maze walls, and crevice safety: Hanuman cannot grow back to full
## size while wedged inside a crevice (he would be stuck in the wall), so he stays small.
func _physics_process(delta: float) -> void:
	if _knock_velocity.length() > 5.0:
		player.move_and_collide(_knock_velocity * delta)
		_knock_velocity = _knock_velocity.lerp(Vector2.ZERO, minf(1.0, delta * 12.0))
	else:
		_knock_velocity = Vector2.ZERO
	if maze.is_crevice(player.global_position) and player.shrink_remaining < 0.15:
		player.shrink_remaining = 0.15

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
	# A guard only notices Hanuman when close AND with a clear line of sight: walls are cover.
	var seen := false
	for post in guard_posts:
		if player.global_position.distance_to(post) < backdrop.guard_radius and maze.has_line_of_sight(post, player.global_position):
			seen = true
	guard_alert = move_toward(guard_alert, 1.0 if seen else 0.0, delta * (0.9 if seen else 0.6))
	backdrop.guard_alert = guard_alert
	for g in guard_sprites:
		g.modulate = Color.WHITE.lerp(Color(1.0, 0.5, 0.45), guard_alert)
	GameEvents.stealth_alert_level_changed.emit(guard_alert, guard_alert > 0.92)
	if guard_alert > 0.92:
		_warn_or_damage("A guard has spotted you—retreat into shadow.")
	# Meeting the sleeping queen triggers Hanuman's mistake (fallback: well past her chamber).
	var queen: Vector2 = mandodari_sprite.position
	var near_queen: bool = player.global_position.distance_to(queen) < 48.0
	if not dialogue_seen and (near_queen or player.global_position.x > queen.x + 260.0):
		dialogue_seen = true
		dialogue.play_mandodari_misunderstanding_scene()
	if dialogue_seen and not dialogue.is_active and maze.is_exit(player.global_position):
		_advance_chapter()

## Reaching Sita at the heart of the grove plays the ring handover, then the chapter ends.
func _update_vatika() -> void:
	if not dialogue_seen and player.global_position.distance_to(sita_position) < 40.0:
		dialogue_seen = true
		backdrop.sita_found = true
		sita_sprite.play("joy")
		VFXImpact.sparks(self, sita_position, Color(0.99, 0.89, 0.49), 18)
		dialogue.play_sita_ring_handover_scene()
	if dialogue_seen and not dialogue.is_active:
		if _sita_farewell < 0.0:
			_sita_farewell = Time.get_ticks_msec() / 1000.0 + 1.5
		elif Time.get_ticks_msec() / 1000.0 > _sita_farewell:
			_advance_chapter()

func _update_escape(_delta: float) -> void:
	if fire_zone.has_point(player.global_position) and hazard_cooldown <= 0.0 and not player.is_flying():
		player.take_damage(7)
		hazard_cooldown = 1.0
		GameEvents.encounter_feedback.emit("Flames scorch the rooftops—keep moving!")
	if maze.is_exit(player.global_position):
		_advance_chapter()

const FACING_DIR := {"right": Vector2.RIGHT, "left": Vector2.LEFT, "up": Vector2.UP, "down": Vector2.DOWN}

## Normal swing: kills imps in a small area in front of Hanuman (much larger when giant).
func _on_player_attack(origin: Vector2) -> void:
	var reach := 50.0 if player.is_giant() else 26.0
	swarm.hit_area(origin + FACING_DIR.get(player.facing, Vector2.DOWN) * 14.0, reach)
	if encounters.on_player_attack(chapter, origin, player.attack_range):
		_add_devotion(8.0)

## Charged spin: clears every imp around Hanuman and counts as a hit on a boss in reach.
func _on_player_spin(origin: Vector2) -> void:
	var killed := swarm.hit_area(origin, 80.0 if player.is_giant() else 58.0)
	if killed > 0:
		GameFeel.hitstop(self, 0.07)
	if encounters.on_player_attack(chapter, origin, 70.0):
		_add_devotion(8.0)

func _on_minions_killed(count: int, at: Vector2) -> void:
	imps_smashed += count
	if not player.is_giant():
		_add_devotion(10.0 * count + (10.0 if count >= 3 else 0.0))
	_play_sfx("impact", -3.0)
	if count >= 5:
		FloatingText.spawn(self, at + Vector2(0, -14), "PENTA SMASH!", Color(1.0, 0.86, 0.42), 16)
		GameFeel.shake(self, 6.0, 0.25)
	elif CALLOUTS.has(count):
		FloatingText.spawn(self, at + Vector2(0, -14), CALLOUTS[count], Color(1.0, 0.86, 0.42), 13)
	else:
		FloatingText.spawn(self, at + Vector2(0, -10), "+%d" % (10 * count), Color(0.99, 0.95, 0.75), 9)
	# Fighting in the palace is noisy: the guard grows suspicious.
	if chapter == 3 and not guard_posts.is_empty():
		guard_alert = minf(0.9, guard_alert + 0.12 * count)

func _add_devotion(amount: float) -> void:
	devotion = clampf(devotion + amount, 0.0, DEVOTION_MAX)
	GameEvents.devotion_changed.emit(devotion, DEVOTION_MAX)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("devotion") and devotion >= DEVOTION_MAX and not cinematic_playing:
		get_viewport().set_input_as_handled()
		_jai_shri_ram()

## Full devotion: Hanuman roars "Jai Shri Ram!", grows giant, every imp on screen is
## destroyed and the bosses are stunned.
func _jai_shri_ram() -> void:
	jai_count += 1
	devotion = 0.0
	_add_devotion(0.0)
	player.activate_giant(GIANT_SECONDS)
	overlay.shout("JAI SHRI RAM!")
	swarm.kill_all()
	encounters.stun_bosses(2.5)
	VFXImpact.shockwave(self, player.global_position + Vector2(0, 8), 160.0, Color(1.0, 0.86, 0.42), 0.55)
	GameFeel.shake(self, 8.0, 0.45)
	GameFeel.hitstop(self, 0.12)
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_layered(["slam", "victory"], -1.0)

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
	if player.is_giant():
		return
	player.take_damage(amount)
	VFXHitFlash.damage_flash(player)
	GameFeel.shake(self, 4.0, 0.2)
	if message != "":
		GameEvents.encounter_feedback.emit(message)
	if player.health <= 0:
		defeats += 1
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("defeat", -1.0)
		_start_chapter(chapter)
		return
	var direction: Vector2 = (player.global_position - source).normalized()
	if knockback > 0.0 and direction != Vector2.ZERO:
		# Applied in _physics_process with collisions, so knockback never shoves him into a wall.
		_knock_velocity = direction * knockback * 12.0

var _flight_hint_shown := false

func _on_flight_changed(active: bool) -> void:
	if active and not _flight_hint_shown:
		_flight_hint_shown = true
		GameEvents.encounter_feedback.emit("Divine flight! Soar over fire, imps and shockwaves.")
