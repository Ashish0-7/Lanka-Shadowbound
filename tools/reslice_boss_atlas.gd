extends SceneTree
## Re-slices boss atlases (5 rows of poses) into 64x64 transparent frames by content.
## Run: BOSSES=surasa,simhika,lankini WRITE=1 SHOT=<preview dir> godot --headless --path . -s tools/reslice_boss_atlas.gd
## Re-slices a 5-row boss atlas on a black background into 64x64 transparent frames.
const ROWS := 5
const OUT := 64
const BG_MAX := 0.045
var preview := OS.get_environment("SHOT")
var write := OS.get_environment("WRITE") == "1"

func _init():
	for n in OS.get_environment("BOSSES").split(","):
		_process_boss(n)
	quit()

func _is_bg(c: Color) -> bool:
	return c.a < 0.1 or maxf(c.r, maxf(c.g, c.b)) < BG_MAX

func _process_boss(n: String) -> void:
	var a := Image.load_from_file("res://assets/characters/enemies/boss_%s/boss_%s_atlas.png" % [n, n])
	a.convert(Image.FORMAT_RGBA8)
	var w := a.get_width(); var h := a.get_height()
	# Flood-fill background from every row band edge so dark outlines inside sprites survive.
	var bg := PackedByteArray(); bg.resize(w * h)
	var stack: Array[int] = []
	for x in w:
		for y in [0, h - 1]: stack.append(y * w + x)
	for y in h:
		for x in [0, w - 1]: stack.append(y * w + x)
	while not stack.is_empty():
		var i: int = stack.pop_back()
		if bg[i] == 1: continue
		var x := i % w; var y := i / w
		if not _is_bg(a.get_pixel(x, y)): continue
		bg[i] = 1
		if x > 0: stack.append(i - 1)
		if x < w - 1: stack.append(i + 1)
		if y > 0: stack.append(i - w)
		if y < h - 1: stack.append(i + w)
	# Also clear enclosed pure-black pockets.
	for i in w * h:
		var c := a.get_pixel(i % w, i / w)
		if bg[i] == 1 or maxf(c.r, maxf(c.g, c.b)) < 0.012:
			a.set_pixel(i % w, i / w, Color(0, 0, 0, 0))
	var band_h := float(h) / ROWS
	var rows: Array = []
	for r in ROWS:
		var y0 := int(r * band_h); var y1 := int((r + 1) * band_h)
		var occ := PackedInt32Array(); occ.resize(w)
		for x in w:
			var cnt := 0
			for y in range(y0, y1):
				if a.get_pixel(x, y).a > 0.5: cnt += 1
			occ[x] = cnt
		# Split on empty column runs.
		var segs: Array = []
		var start := -1; var gap := 0
		for x in w:
			if occ[x] > 1:
				if start < 0: start = x
				gap = 0
			elif start >= 0:
				gap += 1
				if gap >= 3:
					segs.append(Vector2i(start, x - gap)); start = -1; gap = 0
		if start >= 0: segs.append(Vector2i(start, w - 1))
		# Merge slivers (effect fragments, stray pixels) into their nearest neighbour.
		var merged := true
		while merged:
			merged = false
			for k in segs.size():
				var s: Vector2i = segs[k]
				if s.y - s.x < 45 and segs.size() > 1:
					var j := k - 1 if k > 0 else k + 1
					if k > 0 and k < segs.size() - 1:
						var dl: int = s.x - segs[k - 1].y
						var dr: int = segs[k + 1].x - s.y
						j = k - 1 if dl <= dr else k + 1
					var o: Vector2i = segs[j]
					segs[mini(j, k)] = Vector2i(mini(o.x, s.x), maxi(o.y, s.y))
					segs.remove_at(maxi(j, k))
					merged = true
					break
		var split_segs: Array = []
		for s in segs:
			if s.y - s.x > 220:
				var sw: int = s.y - s.x
				var best: int = s.x + sw / 2
				for x in range(s.x + sw / 4, s.y - sw / 4):
					if occ[x] < occ[best]: best = x
				split_segs.append(Vector2i(s.x, best))
				split_segs.append(Vector2i(best + 1, s.y))
			else:
				split_segs.append(s)
		segs = split_segs
		var frames: Array = []
		for s in segs:
			frames.append(_make_frame(a, s, y0, y1, band_h))
		print(n, " row ", r, ": ", segs.size(), " poses ", segs)
		rows.append(frames)
	var states := {
		"idle": rows[0], "walk": rows[1], "attack": rows[2], "special": rows[3],
		"hurt": rows[4].slice(0, rows[4].size() - 3), "defeat": rows[4].slice(rows[4].size() - 3),
	}
	if n == "lankini":
		states = {"idle": rows[0], "walk": rows[1], "attack": rows[2], "special": rows[2], "hurt": rows[3].slice(0, 7), "defeat": rows[4]}
	var sheet := Image.create(OUT * 8, OUT * 6, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.09, 0.25, 0.37))
	var sy := 0
	for st in ["idle", "walk", "attack", "special", "hurt", "defeat"]:
		var src: Array = states[st]
		for f in 8:
			var img: Image = src[mini(int(f * src.size() / 8.0), src.size() - 1)]
			sheet.blend_rect(img, Rect2i(0, 0, OUT, OUT), Vector2i(f * OUT, sy * OUT))
			if write:
				img.save_png(ProjectSettings.globalize_path("res://assets/characters/enemies/boss_%s/boss_%s_%s_%02d.png" % [n, n, st, f + 1]))
		sy += 1
	sheet.resize(sheet.get_width() * 2, sheet.get_height() * 2, Image.INTERPOLATE_NEAREST)
	sheet.save_png(preview + "/%s_resliced.png" % n)

func _make_frame(a: Image, s: Vector2i, y0: int, y1: int, band_h: float) -> Image:
	# Fixed scale per boss (band height -> 64px) keeps size consistent across frames.
	var src_size := int(ceil(band_h))
	var cx := 0.0; var total := 0.0
	for x in range(s.x, s.y + 1):
		for y in range(y0, y1, 2):
			if a.get_pixel(x, y).a > 0.5: cx += x; total += 1
	var center := int(cx / maxf(total, 1.0))
	var crop := Image.create(src_size, src_size, false, Image.FORMAT_RGBA8)
	var left := center - src_size / 2
	for x in src_size:
		var ax := left + x
		if ax < s.x - 30 or ax > s.y + 30 or ax < 0 or ax >= a.get_width(): continue
		for y in range(y0, mini(y1, y0 + src_size)):
			crop.set_pixel(x, y - y0 + (src_size - (y1 - y0)), a.get_pixel(ax, y))
	crop.resize(OUT, OUT, Image.INTERPOLATE_LANCZOS)
	for y in OUT:
		for x in OUT:
			var c := crop.get_pixel(x, y)
			if c.a < 0.5:
				crop.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				crop.set_pixel(x, y, Color(c.r / c.a if c.a < 1.0 else c.r, c.g / c.a if c.a < 1.0 else c.g, c.b / c.a if c.a < 1.0 else c.b, 1.0).clamp())
	return crop
