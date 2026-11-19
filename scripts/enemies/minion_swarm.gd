class_name MinionSwarm
extends Node2D

## MinionSwarm: small imps that live in the maze in clusters. When Hanuman comes near they
## chase him along the maze grid, telegraph (red eyes + hop), then nip for small damage.
## Any hit kills them; the charged spin clears a whole cluster at once.

signal minions_killed(count: int, at: Vector2)
signal player_nipped(damage: int, from: Vector2)

const MINION_DIR := "res://assets/characters/enemies/minions/"
const VARIANT := {1: "sea", 2: "gate", 3: "shadow", 4: "thorn"}
## Clusters per chapter: [cell, how many]. Kept away from the start and boss arenas.
const CLUSTERS := {
	1: [[Vector2i(6, 10), 3], [Vector2i(15, 10), 3]],
	2: [[Vector2i(4, 8), 3], [Vector2i(8, 6), 3]],
	3: [[Vector2i(4, 9), 2], [Vector2i(14, 10), 3], [Vector2i(14, 4), 2]],
	4: [[Vector2i(4, 9), 3], [Vector2i(9, 6), 3], [Vector2i(15, 8), 3], [Vector2i(10, 4), 2]],
}
const SPEED := 58.0
const AGGRO_RANGE := 150.0
const NIP_RANGE := 15.0
const WINDUP := 0.45
const NIP_DAMAGE := 5

var maze: LevelMaze
var player: Node2D
var _minions: Array[Dictionary] = []
var _frames_cache: Dictionary = {}

## Spawns this chapter's clusters (none for chapters without an entry).
func spawn(chapter: int) -> void:
	clear()
	if not CLUSTERS.has(chapter):
		return
	var variant: String = VARIANT[chapter]
	var frames := _frames(variant)
	for cluster in CLUSTERS[chapter]:
		var centre := maze.cell_center(cluster[0])
		for i in cluster[1]:
			var sprite := AnimatedSprite2D.new()
			sprite.sprite_frames = frames
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.z_index = 1
			sprite.play("walk")
			sprite.frame = i % 2
			var offset := Vector2.from_angle(i * TAU / maxf(cluster[1], 1)) * 8.0
			sprite.position = centre + offset
			add_child(sprite)
			_minions.append({"sprite": sprite, "home": centre + offset, "state": "idle",
				"timer": randf_range(0.0, 1.0), "path": [], "repath": 0.0, "cooldown": 0.0,
				"jitter": offset * 0.5})

func clear() -> void:
	for m in _minions:
		m["sprite"].queue_free()
	_minions.clear()

func alive_count() -> int:
	return _minions.size()

func _frames(variant: String) -> SpriteFrames:
	if _frames_cache.has(variant):
		return _frames_cache[variant]
	var frames := SpriteFrames.new()
	frames.rename_animation("default", "walk")
	frames.set_animation_speed("walk", 6.0)
	for pose in ["walk1", "walk2"]:
		frames.add_frame("walk", load(MINION_DIR + "minion_%s_%s.png" % [variant, pose]))
	frames.add_animation("windup")
	frames.add_frame("windup", load(MINION_DIR + "minion_%s_windup.png" % variant))
	_frames_cache[variant] = frames
	return frames

# --- Behaviour ---------------------------------------------------------------------------

func update(delta: float) -> void:
	for m in _minions:
		var sprite: AnimatedSprite2D = m["sprite"]
		m["cooldown"] = maxf(0.0, m["cooldown"] - delta)
		var to_player: Vector2 = player.global_position - sprite.position
		match m["state"]:
			"idle":
				m["timer"] += delta
				sprite.offset.y = -absf(sin(m["timer"] * 3.0)) * 1.5
				if to_player.length() < AGGRO_RANGE and maze.has_line_of_sight(sprite.position, player.global_position):
					m["state"] = "chase"
			"chase":
				sprite.offset.y = 0.0
				if to_player.length() < NIP_RANGE and m["cooldown"] <= 0.0:
					m["state"] = "windup"
					m["timer"] = WINDUP
					sprite.play("windup")
				elif to_player.length() > AGGRO_RANGE * 1.8:
					m["state"] = "idle"
				else:
					_move_along_maze(m, delta)
					sprite.flip_h = to_player.x < 0.0
			"windup":
				# Telegraph: red-eyed frame, a little hop and a flash before the nip.
				m["timer"] -= delta
				var k: float = 1.0 - m["timer"] / WINDUP
				sprite.offset.y = -sin(k * PI) * 3.0
				sprite.modulate = Color.WHITE.lerp(Color(1.0, 0.4, 0.35), 0.5 + 0.5 * sin(k * 20.0))
				if m["timer"] <= 0.0:
					sprite.modulate = Color.WHITE
					sprite.offset.y = 0.0
					sprite.play("walk")
					m["state"] = "chase"
					m["cooldown"] = 1.1
					if to_player.length() < NIP_RANGE + 6.0:
						player_nipped.emit(NIP_DAMAGE, sprite.position)

func _move_along_maze(m: Dictionary, delta: float) -> void:
	var sprite: AnimatedSprite2D = m["sprite"]
	m["repath"] -= delta
	if m["repath"] <= 0.0 or (m["path"] as Array).is_empty():
		m["path"] = _path(maze.cell_at(sprite.position), maze.cell_at(player.global_position))
		m["repath"] = 0.35
	var target: Vector2 = player.global_position
	var path: Array = m["path"]
	if path.size() > 1:
		target = maze.cell_center(path[0]) + m["jitter"]
		if sprite.position.distance_to(target) < 3.0:
			path.pop_front()
	sprite.position = sprite.position.move_toward(target, SPEED * delta)

## Breadth-first path over walkable maze cells (excludes the start cell).
func _path(from: Vector2i, to: Vector2i) -> Array:
	var prev := {from: from}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		if cell == to:
			var route := []
			while cell != from:
				route.push_front(cell)
				cell = prev[cell]
			return route
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = cell + d
			if not prev.has(n) and not maze.kind_at(n) in ["#", "X", "c"]:
				prev[n] = cell
				queue.append(n)
				if prev.size() > 160:
					return []
	return []

# --- Taking hits ---------------------------------------------------------------------------

## Kills every minion within `radius` of `origin`. Returns how many died.
func hit_area(origin: Vector2, radius: float) -> int:
	var killed := 0
	var centre := Vector2.ZERO
	for m in _minions.duplicate():
		var sprite: AnimatedSprite2D = m["sprite"]
		if sprite.position.distance_to(origin) <= radius:
			centre += sprite.position
			_poof(sprite.position)
			sprite.queue_free()
			_minions.erase(m)
			killed += 1
	if killed > 0:
		minions_killed.emit(killed, centre / killed)
	return killed

func kill_all() -> int:
	return hit_area(Vector2(320, 180), 2000.0)

func _poof(at: Vector2) -> void:
	VFXImpact.sparks(get_parent(), at, Color(0.95, 0.9, 1.0), 6)
	VFXImpact.shockwave(get_parent(), at + Vector2(0, 4), 14.0, Color(0.8, 0.75, 0.9), 0.5)
