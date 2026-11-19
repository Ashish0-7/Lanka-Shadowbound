extends SceneTree
## Regenerates the procedural boss-telegraph SFX into assets/audio/sfx/.
## Run: godot --headless --path . -s tools/gen_boss_sfx.gd
const RATE := 22050
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.seed = 7041
	_save("hiss", _hiss())
	_save("bite", _bite())
	_save("whoosh", _whoosh())
	_save("roar", _roar())
	_save("slam", _slam())
	_save("shadow", _shadow())
	_save("grab", _grab())
	_save("impact", _impact())
	quit()

func _save(name: String, samples: PackedFloat32Array) -> void:
	var peak := 0.0
	for s in samples: peak = maxf(peak, absf(s))
	var gain := 0.89 / maxf(peak, 0.0001)
	var data := PackedByteArray(); data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i] * gain, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	wav.save_to_wav(ProjectSettings.globalize_path("res://assets/audio/sfx/sfx_%s.wav" % name))
	print("wrote sfx_%s.wav (%.2fs)" % [name, samples.size() / float(RATE)])

func _buf(seconds: float) -> PackedFloat32Array:
	var b := PackedFloat32Array(); b.resize(int(seconds * RATE)); return b

func _noise() -> float:
	return rng.randf_range(-1.0, 1.0)

## Surasa wind-up: breathy high hiss with a serpent tremolo, swelling in.
func _hiss() -> PackedFloat32Array:
	var b := _buf(0.75); var lp := 0.0
	for i in b.size():
		var t := i / float(RATE); var n := _noise()
		lp += (n - lp) * 0.35
		var env := minf(t / 0.45, 1.0) * minf((0.75 - t) / 0.08, 1.0)
		b[i] = (n - lp) * env * (0.7 + 0.3 * sin(TAU * 22.0 * t))
	return b

## Surasa bite: sharp jaw snap (click + noise crack) over a short low thump.
func _bite() -> PackedFloat32Array:
	var b := _buf(0.32); var lp := 0.0; var phase := 0.0
	for i in b.size():
		var t := i / float(RATE); var n := _noise()
		lp += (n - lp) * 0.5
		phase += TAU * lerpf(160.0, 55.0, minf(t / 0.2, 1.0)) / RATE
		b[i] = lp * exp(-t * 38.0) * 0.9 + sin(phase) * exp(-t * 14.0) * 0.8 + (1.0 if i < 40 else 0.0) * 0.6
	return b

## Generic swing whoosh: band-limited noise sweeping up then down.
func _whoosh() -> PackedFloat32Array:
	var b := _buf(0.3); var lp1 := 0.0; var lp2 := 0.0
	for i in b.size():
		var t := i / float(RATE); var n := _noise()
		var k := lerpf(0.05, 0.4, sin(PI * t / 0.3))
		lp1 += (n - lp1) * k; lp2 += (lp1 - lp2) * k
		b[i] = (lp1 - lp2) * sin(PI * t / 0.3)
	return b

## Lankini wind-up: low growling roar (detuned saws with vibrato and grit).
func _roar() -> PackedFloat32Array:
	var b := _buf(0.9); var p1 := 0.0; var p2 := 0.0; var lp := 0.0
	for i in b.size():
		var t := i / float(RATE)
		var f := 78.0 + 10.0 * sin(TAU * 6.0 * t) + 18.0 * minf(t / 0.5, 1.0)
		p1 = fposmod(p1 + f / RATE, 1.0); p2 = fposmod(p2 + f * 1.013 / RATE, 1.0)
		var saw := (p1 * 2.0 - 1.0) + (p2 * 2.0 - 1.0)
		lp += (saw + _noise() * 0.5 - lp) * 0.12
		b[i] = lp * minf(t / 0.12, 1.0) * minf((0.9 - t) / 0.25, 1.0)
	return b

## Ground slam: noise crack, then a deep pitch-dropping boom.
func _slam() -> PackedFloat32Array:
	var b := _buf(0.8); var phase := 0.0; var lp := 0.0
	for i in b.size():
		var t := i / float(RATE); var n := _noise()
		lp += (n - lp) * 0.2
		phase += TAU * lerpf(95.0, 32.0, minf(t / 0.5, 1.0)) / RATE
		b[i] = sin(phase) * exp(-t * 4.5) + lp * exp(-t * 18.0) * 0.9
	return b

## Simhika wind-up: dark sub pulse under a swelling murky noise bed.
func _shadow() -> PackedFloat32Array:
	var b := _buf(0.95); var lp := 0.0; var phase := 0.0
	for i in b.size():
		var t := i / float(RATE); var n := _noise()
		lp += (n - lp) * 0.03
		phase += TAU * (52.0 + 6.0 * sin(TAU * 3.0 * t)) / RATE
		var env := minf(t / 0.7, 1.0) * minf((0.95 - t) / 0.1, 1.0)
		b[i] = (sin(phase) * 0.8 + lp * 6.0) * env * (0.75 + 0.25 * sin(TAU * 9.0 * t))
	return b

## Shadow grab: whip-like snap then a dragging low rumble.
func _grab() -> PackedFloat32Array:
	var b := _buf(0.45); var lp := 0.0; var phase := 0.0
	for i in b.size():
		var t := i / float(RATE); var n := _noise()
		lp += (n - lp) * 0.08
		phase += TAU * lerpf(220.0, 60.0, minf(t / 0.08, 1.0)) / RATE
		b[i] = sin(phase) * exp(-t * 30.0) * 0.7 + lp * 4.0 * exp(-t * 6.0)
	return b

## Hit impact: short punchy body thump with a bright transient.
func _impact() -> PackedFloat32Array:
	var b := _buf(0.22); var phase := 0.0
	for i in b.size():
		var t := i / float(RATE)
		phase += TAU * lerpf(180.0, 70.0, minf(t / 0.1, 1.0)) / RATE
		b[i] = sin(phase) * exp(-t * 20.0) + _noise() * exp(-t * 60.0) * 0.8
	return b
