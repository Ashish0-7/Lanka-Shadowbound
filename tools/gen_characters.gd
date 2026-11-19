extends SceneTree
## Paints the NPC sprites (Sita, Rakshasa guard, Mandodari) and dialogue portraits.
## Characters are composed from shaded shapes (light from the top-left, 4-tone ramps like
## Hanuman's sprites), then a selective dark outline is added and hand-placed details
## (eyes, jewellery, sindoor) are stamped on top. 24×32 frames match Hanuman's sprites.
## Run: godot --headless --path . -s tools/gen_characters.gd   (PREVIEW=<dir> for a sheet)

## Canvas size: 24×32 for characters, switched to 16×16 while painting minions.
var W := 24
var H := 32

## Minion variants per chapter: body ramp, accent ramp.
const MINIONS := {
	"sea": ["seaimp", "ivory"],     # Ch1: sea imps with a fin crest
	"gate": ["impred", "steel"],    # Ch2: gate imps with tiny spears
	"shadow": ["shade", "glow"],    # Ch3: shadow imps with lantern eyes
	"thorn": ["thorn", "border"],   # Ch4: thorn sprites with red buds
}

const RAMPS := {
	"skin":    ["#8a4f37", "#c98a62", "#e8b48a", "#f8d8b4"],
	"hair":    ["#0c0708", "#1e1214", "#35232a", "#523a40"],
	"sari":    ["#b0600e", "#e3931a", "#f7c04a", "#fde59a"],
	"border":  ["#5e1220", "#a8262f", "#d43c3c", "#ee7a6a"],
	"gold":    ["#8a5a10", "#c8901a", "#ffd84a", "#fff3b0"],
	"rskin":   ["#16262b", "#2a454b", "#43686a", "#6e9a92"],
	"bronze":  ["#4a2e10", "#875620", "#c08a3a", "#f0c070"],
	"cloth":   ["#4a0d18", "#7e1a2a", "#b02a40", "#d8566a"],
	"royal":   ["#3a0a1e", "#6a1434", "#a0244e", "#d8507a"],
	"wood":    ["#2a160a", "#5a3218", "#7e4a24", "#a46a3a"],
	"steel":   ["#4a4e5e", "#8c92a6", "#c8ccd8", "#f4f6fa"],
	"ivory":   ["#6e6248", "#a89a7c", "#dccfae", "#f6efdc"],
	"glow":    ["#c86a10", "#f7a830", "#ffd86a", "#fff6c8"],
	"seaimp":  ["#0f2a3a", "#1f5a6e", "#3a8fa0", "#8bc1b8"],
	"impred":  ["#3a0a12", "#7e1a2a", "#c03a3a", "#ee7a6a"],
	"shade":   ["#241a48", "#4a3a8a", "#7a68c8", "#b4a8f0"],
	"thorn":   ["#2a5a20", "#4e9a32", "#86cc4a", "#c8f07a"],
}

var mat: PackedStringArray
var shade: PackedFloat32Array
var detail: Dictionary = {}

func _init() -> void:
	var out_dir := "res://assets/characters/npcs/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var sheet: Array[Image] = []
	for mood in ["sad", "blink", "joy"]:
		var img := _sita(mood)
		img.save_png(ProjectSettings.globalize_path(out_dir + "char_sita_seated_%s.png" % mood))
		sheet.append(img)
	for frame in 2:
		var img := _guard(frame)
		img.save_png(ProjectSettings.globalize_path(out_dir + "char_guard_rakshasa_%02d.png" % (frame + 1)))
		sheet.append(img)
	var queen := _mandodari()
	queen.save_png(ProjectSettings.globalize_path(out_dir + "char_mandodari_idle.png"))
	sheet.append(queen)
	# Dialogue portraits: 2× bust crops so every speaker is framed the same way.
	var hanuman := Image.load_from_file("res://assets/characters/hanuman/char_hanuman_idle_down.png")
	var portraits := {
		"portrait_sita": _bust(sheet[0], 0),
		"portrait_mandodari": _bust(queen, 0),
		"portrait_hanuman": _bust(hanuman, 0),
	}
	for name in portraits:
		portraits[name].save_png(ProjectSettings.globalize_path("res://assets/ui/portraits/%s.png" % name))
		sheet.append(portraits[name])
	# Minions: 16×16, walk ×2 + wind-up, one variant per chapter.
	var minion_dir := "res://assets/characters/enemies/minions/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(minion_dir))
	W = 16
	H = 16
	for variant in MINIONS:
		for pose in ["walk1", "walk2", "windup"]:
			var img := _minion(variant, pose)
			img.save_png(ProjectSettings.globalize_path(minion_dir + "minion_%s_%s.png" % [variant, pose]))
			sheet.append(img)
	W = 24
	H = 32
	if OS.has_environment("PREVIEW"):
		_save_preview(sheet, OS.get_environment("PREVIEW"))
	print("characters written")
	quit()

# --- Canvas -----------------------------------------------------------------------------

func _clear() -> void:
	mat = PackedStringArray(); mat.resize(W * H)
	shade = PackedFloat32Array(); shade.resize(W * H)
	detail = {}

func _put(x: int, y: int, m: String, l: float) -> void:
	if x < 0 or y < 0 or x >= W or y >= H:
		return
	mat[y * W + x] = m
	shade[y * W + x] = l

## Filled ellipse shaded as a lit dome (light from the upper left).
func _ellipse(cx: float, cy: float, rx: float, ry: float, m: String, bias: float = 0.0) -> void:
	for y in range(floori(cy - ry), ceili(cy + ry) + 1):
		for x in range(floori(cx - rx), ceili(cx + rx) + 1):
			var nx := (x + 0.5 - cx) / rx
			var ny := (y + 0.5 - cy) / ry
			if nx * nx + ny * ny <= 1.0:
				_put(x, y, m, clampf(0.62 - nx * 0.42 - ny * 0.38 + bias, 0.0, 1.0))

func _rect(x0: int, y0: int, w: int, h: int, m: String, bias: float = 0.0) -> void:
	for y in range(y0, y0 + h):
		for x in range(x0, x0 + w):
			var nx := (x - x0 + 0.5) / maxf(w, 1) * 2.0 - 1.0
			_put(x, y, m, clampf(0.58 - nx * 0.35 + bias, 0.0, 1.0))

## Recolours already-painted pixels of `from` inside a rect (e.g. a sari's hem border).
func _recolor(x0: int, y0: int, w: int, h: int, from: String, to: String) -> void:
	for y in range(y0, y0 + h):
		for x in range(x0, x0 + w):
			if x >= 0 and y >= 0 and x < W and y < H and mat[y * W + x] == from:
				mat[y * W + x] = to

## A 1–2 px painted line (pallu drape, spear shaft, horn).
func _line(a: Vector2, b: Vector2, m: String, width: int = 1, l: float = 0.6) -> void:
	var steps := int(maxf(absf(b.x - a.x), absf(b.y - a.y))) + 1
	for i in steps + 1:
		var p := a.lerp(b, float(i) / steps)
		for wx in width:
			_put(floori(p.x) + wx, floori(p.y), m, l - wx * 0.25)

func _dot(x: int, y: int, color: String) -> void:
	detail[Vector2i(x, y)] = Color(color)

func _render() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	for y in H:
		for x in W:
			var m := mat[y * W + x]
			if m == "":
				continue
			var ramp: Array = RAMPS[m]
			var l := shade[y * W + x]
			var idx := 0 if l < 0.3 else (1 if l < 0.55 else (2 if l < 0.82 else 3))
			img.set_pixel(x, y, Color(ramp[idx]))
	# Selective outline: transparent pixels touching the figure take a dark, warm edge.
	var outline := img.duplicate()
	for y in H:
		for x in W:
			if img.get_pixel(x, y).a > 0.0:
				continue
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = Vector2i(x, y) + d
				if n.x >= 0 and n.y >= 0 and n.x < W and n.y < H and img.get_pixelv(n).a > 0.0:
					outline.set_pixel(x, y, Color("#1a0c10"))
					break
	for p in detail:
		outline.set_pixelv(p, detail[p])
	return outline

func _bust(sprite: Image, top: int) -> Image:
	var crop := sprite.get_region(Rect2i(0, top, 24, 24))
	crop.resize(48, 48, Image.INTERPOLATE_NEAREST)
	return crop

# --- Sita, seated beneath the Ashoka tree ---------------------------------------------------

func _sita(mood: String) -> Image:
	_clear()
	_ellipse(12, 10, 6.6, 7.2, "hair", -0.15)                 # hair mass behind the head
	_ellipse(12, 27.2, 10.2, 4.6, "sari")                     # folded legs / lap
	_recolor(0, 29, W, 3, "sari", "border")                   # hem border
	for px in [5, 8, 11, 14, 17]:                            # sari pleats
		_line(Vector2(px, 25), Vector2(px + 1, 28), "sari", 1, 0.2)
	_ellipse(12, 19.5, 5.2, 5.6, "sari", 0.05)                # torso
	_line(Vector2(15.5, 14), Vector2(8.5, 24), "border", 2)  # pallu over the shoulder
	_ellipse(7.6, 20, 1.8, 4.0, "skin")                       # arms
	_ellipse(16.4, 20, 1.8, 4.0, "skin", -0.1)
	_ellipse(12, 23.6, 2.8, 1.5, "skin", 0.1)                 # hands folded in the lap
	_rect(11, 13, 2, 2, "skin", -0.2)                         # neck
	_ellipse(17.4, 18, 1.5, 5.2, "hair")                      # braid over the shoulder
	_ellipse(12, 9.6, 4.6, 5.1, "skin", 0.05)                 # face
	_ellipse(12, 5.8, 5.3, 2.8, "hair", 0.1)                  # hair over the forehead
	_put(7, 9, "hair", 0.4); _put(16, 9, "hair", 0.3)
	_put(7, 10, "hair", 0.4); _put(16, 10, "hair", 0.3)
	var img_details := {
		Vector2i(12, 4): "#c81c2c", Vector2i(12, 5): "#c81c2c",   # sindoor in the parting
		Vector2i(12, 6): "#ffd84a",                               # maang tikka
		Vector2i(12, 8): "#c81c2c",                               # bindi
		Vector2i(7, 11): "#ffd84a", Vector2i(16, 11): "#ffd84a",  # earrings
		Vector2i(10, 14): "#ffd84a", Vector2i(11, 15): "#ffd84a", Vector2i(12, 15): "#fff3b0", Vector2i(13, 14): "#ffd84a",
		Vector2i(8, 23): "#ffd84a", Vector2i(16, 23): "#ffd84a",  # bangles
		Vector2i(17, 7): "#f2f2e8", Vector2i(16, 6): "#e86a82",   # jasmine and a blossom in her hair
	}
	for p in img_details:
		_dot(p.x, p.y, img_details[p])
	match mood:
		"sad":
			_dot(10, 10, "#2a120c"); _dot(14, 10, "#2a120c")
			_dot(9, 9, "#3a2d52"); _dot(15, 9, "#3a2d52")       # brows angled up in sorrow
			_dot(10, 11, "#c98a62"); _dot(14, 11, "#c98a62")
			_dot(13, 12, "#9fd0e8")                             # a tear
			_dot(12, 12, "#b8434a")
		"blink":
			_dot(10, 10, "#8a4f37"); _dot(9, 10, "#8a4f37"); _dot(14, 10, "#8a4f37"); _dot(15, 10, "#8a4f37")
			_dot(12, 12, "#b8434a")
		"joy":
			_dot(10, 9, "#2a120c"); _dot(14, 9, "#2a120c")
			_dot(10, 10, "#ffffff"); _dot(14, 10, "#ffffff")     # bright, open eyes
			_dot(11, 12, "#b8434a"); _dot(12, 12, "#b8434a"); _dot(13, 12, "#b8434a")
			_dot(11, 23, "#ffd84a"); _dot(12, 22, "#fff3b0"); _dot(13, 23, "#ffd84a")  # Rama's ring
			_dot(12, 21, "#ffffff")
	return _render()

# --- Rakshasa palace guard -----------------------------------------------------------------

func _guard(frame: int) -> Image:
	_clear()
	_line(Vector2(20, 3), Vector2(20, 31), "wood", 1, 0.5)   # spear shaft
	_ellipse(12, 7.5, 6.4, 5.0, "hair", -0.1)                 # wild hair
	_line(Vector2(7, 5), Vector2(5, 1), "ivory", 2, 0.8)      # horns
	_line(Vector2(16, 5), Vector2(18, 1), "ivory", 2, 0.7)
	_rect(9, 25, 3, 5, "rskin", -0.05)                        # legs
	_rect(13, 25, 3, 5, "rskin", -0.15)
	_ellipse(10.2, 30.4, 2.3, 1.2, "bronze")                  # sandals
	_ellipse(14.2, 30.4, 2.3, 1.2, "bronze")
	_ellipse(12, 23, 5.2, 3.6, "cloth")                       # loincloth
	_ellipse(12, 17.5, 6.0, 5.0, "rskin")                     # broad torso
	_ellipse(12, 16.8, 4.2, 3.2, "bronze", 0.05)              # chest plate
	_rect(7, 20, 10, 2, "gold", 0.05)                         # belt
	_ellipse(5.4, 18, 2.1, 4.6, "rskin", 0.05)                # arms
	_ellipse(18.6, 16.5, 2.1, 4.4, "rskin", -0.15)
	_ellipse(19.4, 13, 1.6, 1.4, "rskin", -0.1)               # hand gripping the spear
	_ellipse(12, 10, 4.6, 4.4, "rskin", 0.05)                 # head
	# Spear tip and the hanging lantern.
	for p in [Vector2i(20, 0), Vector2i(19, 1), Vector2i(20, 1), Vector2i(21, 1), Vector2i(19, 2), Vector2i(20, 2), Vector2i(21, 2)]:
		_put(p.x, p.y, "steel", 0.85 if p.x <= 20 else 0.4)
	_rect(3, 23, 4, 5, "glow", 0.2 if frame == 0 else 0.45)
	_rect(4, 22, 2, 1, "bronze", 0.3)
	_rect(3, 28, 4, 1, "bronze", 0.1)
	var marks := {
		Vector2i(10, 10): "#ff3b2f", Vector2i(14, 10): "#ff3b2f",  # glowing eyes
		Vector2i(9, 9): "#0e0a14", Vector2i(10, 9): "#0e0a14", Vector2i(14, 9): "#0e0a14", Vector2i(15, 9): "#0e0a14",
		Vector2i(11, 12): "#0e0a14", Vector2i(12, 12): "#0e0a14", Vector2i(13, 12): "#0e0a14",
		Vector2i(10, 13): "#f4efe0", Vector2i(14, 13): "#f4efe0",  # fangs
		Vector2i(12, 15): "#ffd84a", Vector2i(12, 16): "#f0c070",  # amulet
		Vector2i(5, 21): "#43686a", Vector2i(5, 22): "#2a160a",    # hand and lantern hook
		Vector2i(4, 25): "#fff6c8" if frame == 0 else "#ffd86a", Vector2i(5, 25): "#fff6c8",
	}
	for p in marks:
		_dot(p.x, p.y, marks[p])
	return _render()

# --- Queen Mandodari -----------------------------------------------------------------------

func _mandodari() -> Image:
	_clear()
	_ellipse(12, 9.5, 6.2, 6.8, "hair", -0.1)                 # hair
	_ellipse(16.5, 6, 2.6, 2.4, "hair")                       # bun
	_ellipse(12, 25.5, 7.0, 6.4, "royal")                     # flowing skirt
	_recolor(0, 29, W, 3, "royal", "gold")                    # gold hem
	_ellipse(12, 18.5, 4.8, 4.8, "royal", 0.05)               # bodice
	_line(Vector2(15, 14), Vector2(9, 25), "gold", 2, 0.55)  # gold pallu
	_ellipse(7.2, 19, 1.7, 4.2, "skin")                       # arms
	_ellipse(16.8, 19, 1.7, 4.2, "skin", -0.1)
	_rect(11, 13, 2, 2, "skin", -0.2)                         # neck
	_ellipse(12, 9.6, 4.5, 5.0, "skin", 0.05)                 # face
	_ellipse(12, 5.8, 5.0, 2.5, "hair", 0.1)
	_rect(9, 2, 6, 2, "gold", 0.1)                            # crown band
	for x in [9, 12, 14]:
		_put(x, 1, "gold", 0.9)
	_put(12, 0, "gold", 0.95)
	var marks := {
		Vector2i(12, 2): "#c81c2c", Vector2i(10, 3): "#2fa070", Vector2i(14, 3): "#2fa070",  # crown jewels
		Vector2i(12, 8): "#c81c2c",                                                           # bindi
		Vector2i(10, 10): "#2a120c", Vector2i(14, 10): "#2a120c",                             # serene eyes
		Vector2i(9, 9): "#1f1830", Vector2i(15, 9): "#1f1830",
		Vector2i(11, 12): "#a0244e", Vector2i(12, 12): "#a0244e",
		Vector2i(7, 11): "#ffd84a", Vector2i(16, 11): "#ffd84a",
		Vector2i(10, 14): "#ffd84a", Vector2i(11, 15): "#fff3b0", Vector2i(12, 15): "#ffd84a", Vector2i(13, 15): "#fff3b0", Vector2i(14, 14): "#ffd84a",
		Vector2i(7, 22): "#ffd84a", Vector2i(17, 22): "#ffd84a",
	}
	for p in marks:
		_dot(p.x, p.y, marks[p])
	return _render()

# --- Minions (16×16 imps) -------------------------------------------------------------------

func _minion(variant: String, pose: String) -> Image:
	_clear()
	var body: String = MINIONS[variant][0]
	var accent: String = MINIONS[variant][1]
	var squash := 1.0 if pose == "windup" else 0.0
	var step := 1 if pose == "walk2" else 0
	_ellipse(5.5 - step * 0.5, 14.2, 1.8, 1.2, body, -0.2)   # feet
	_ellipse(10.5 + step * 0.5, 14.2, 1.8, 1.2, body, -0.25)
	_ellipse(8, 9.5 + squash, 5.4 + squash * 0.6, 4.6 - squash * 0.6, body)  # round body-head
	_ellipse(3.2, 10.5, 1.3, 1.8, body, -0.1)                 # little arms
	_ellipse(12.8, 10.5, 1.3, 1.8, body, -0.2)
	match variant:
		"sea":
			for i in 4:
				_put(6 + i, 4 - (i % 2), accent, 0.7)            # fin crest
			_put(5, 5, accent, 0.5); _put(10, 5, accent, 0.4)
		"gate":
			_put(4, 4, accent, 0.8); _put(3, 3, accent, 0.9)   # horns
			_put(11, 4, accent, 0.6); _put(12, 3, accent, 0.7)
			_line(Vector2(14, 5), Vector2(14, 13), "wood", 1, 0.5)  # tiny spear
			_put(14, 4, accent, 0.9); _put(14, 3, accent, 0.95)
		"shadow":
			_put(4, 5, body, 0.5); _put(3, 4, body, 0.6)       # pointed ears
			_put(11, 5, body, 0.4); _put(12, 4, body, 0.5)
		"thorn":
			_put(7, 4, "thorn", 0.8); _put(8, 3, "thorn", 0.9); _put(9, 4, "thorn", 0.7)  # leaf sprout
			_put(4, 7, accent, 0.6); _put(12, 8, accent, 0.5); _put(8, 12, accent, 0.5)   # red buds
	var eye := "#ff3b2f" if pose == "windup" else ("#fff6c8" if variant == "shadow" else "#fbf4e2")
	var y := 9 + int(squash)
	_dot(6, y, eye); _dot(10, y, eye)
	_dot(6, y + 1, "#0e0a14"); _dot(10, y + 1, "#0e0a14")
	if pose == "windup":
		_dot(7, y + 3, "#0e0a14"); _dot(8, y + 3, "#0e0a14"); _dot(9, y + 3, "#0e0a14")  # mouth open
		_dot(7, y + 2, "#f4efe0"); _dot(9, y + 2, "#f4efe0")                            # fangs
	else:
		_dot(8, y + 3, "#0e0a14")
	return _render()

func _save_preview(images: Array[Image], dir: String) -> void:
	var sheet := Image.create(images.size() * 52, 52, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#1f2244"))
	for i in images.size():
		var img: Image = images[i]
		sheet.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(i * 52 + 2, 2))
	sheet.resize(sheet.get_width() * 4, sheet.get_height() * 4, Image.INTERPOLATE_NEAREST)
	sheet.save_png(dir + "/characters_preview.png")
