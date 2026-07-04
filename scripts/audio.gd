extends Node

const SAMPLE_RATE = 22050
const MAX_PLAYERS = 8

var streams = {}
var players = []

func _ready():
	generate_all()

func generate_all():
	streams["hit"] = _build("hit")
	streams["levelup"] = _build("levelup")
	streams["exp"] = _build("exp")
	streams["equip"] = _build("equip")
	streams["select"] = _build("select")
	streams["talk"] = _build("talk")
	streams["open_menu"] = _build("open_menu")
	streams["close_menu"] = _build("close_menu")

func play(sfx_type: String):
	if not streams.has(sfx_type):
		return
	if not _get_player():
		return
	var p = _get_player()
	p.stream = streams[sfx_type]
	p.volume_db = _sfx_db(GameState.settings.sfx_volume)
	p.play()

func _sfx_db(pct: int) -> float:
	return linear_to_db(clamp(pct, 0, 100) / 100.0)

func _get_player() -> AudioStreamPlayer:
	for p in players:
		if not p.playing:
			return p
	if players.size() >= MAX_PLAYERS:
		return null
	var new_p = AudioStreamPlayer.new()
	add_child(new_p)
	players.append(new_p)
	return new_p

# ---- waveform helpers ----

func _u8(val: float) -> int:
	return clampi(int((val + 1.0) * 127.5), 0, 255)

func _square(t: float, freq: float) -> float:
	return 1.0 if sin(freq * t * TAU) >= 0.0 else -1.0

func _saw(t: float, freq: float) -> float:
	return 2.0 * (freq * t - floor(freq * t + 0.5))

func _noise() -> float:
	return randf_range(-1.0, 1.0)

func _envelope(t: float, attack: float, sustain: float, release: float) -> float:
	if t < attack:
		return t / attack
	elif t < attack + sustain:
		return 1.0
	elif t < attack + sustain + release:
		var r = t - attack - sustain
		return 1.0 - r / release
	return 0.0

func _stream_from_data(data: PackedByteArray) -> AudioStreamWAV:
	var s = AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_8_BITS
	s.mix_rate = SAMPLE_RATE
	s.stereo = false
	s.data = data
	return s

# ---- individual sound generators ----

func _build(name: String) -> AudioStreamWAV:
	var data: PackedByteArray
	match name:
		"hit":
			data = _gen_hit()
		"levelup":
			data = _gen_levelup()
		"exp":
			data = _gen_exp()
		"equip":
			data = _gen_equip()
		"select":
			data = _gen_select()
		"talk":
			data = _gen_talk()
		"open_menu":
			data = _gen_open_menu()
		"close_menu":
			data = _gen_close_menu()
		_:
			data = PackedByteArray()
	return _stream_from_data(data)

func _gen_hit() -> PackedByteArray:
	var dur = 0.18
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.0, 0.02, dur - 0.02)
		var tone = _square(t, 80.0) * 0.4
		var nz = _noise() * 0.6
		var val = (tone + nz) * env
		data[i] = _u8(val * 0.6)
	return data

func _gen_levelup() -> PackedByteArray:
	var notes = [262.0, 330.0, 392.0, 523.0]
	var note_len = 0.12
	var gap = 0.04
	var dur = (note_len + gap) * len(notes) + 0.1
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var note_idx = int(t / (note_len + gap))
		if note_idx >= len(notes):
			break
		var note_t = t - note_idx * (note_len + gap)
		var env = _envelope(note_t, 0.01, note_len - 0.04, 0.03)
		var freq = notes[note_idx]
		var val = _square(note_t, freq) * 0.5
		val += _square(note_t, freq * 2.0) * 0.15
		data[i] = _u8(val * env)
	return data

func _gen_exp() -> PackedByteArray:
	var dur = 0.08
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.0, dur - 0.02, 0.02)
		var val = _square(t, 880.0) * env * 0.4
		data[i] = _u8(val)
	return data

func _gen_equip() -> PackedByteArray:
	var dur = 0.18
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.01, dur - 0.04, 0.03)
		var freq = 200.0 + 400.0 * (t / dur)
		var val = _square(t, freq) * env * 0.4
		data[i] = _u8(val)
	return data

func _gen_select() -> PackedByteArray:
	var dur = 0.05
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.0, dur - 0.015, 0.015)
		var val = _square(t, 660.0) * env * 0.35
		data[i] = _u8(val)
	return data

func _gen_talk() -> PackedByteArray:
	var dur = 0.04
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.0, dur - 0.01, 0.01)
		var val = _noise() * 0.4 + _square(t, 1200.0) * 0.2
		data[i] = _u8(val * env)
	return data

func _gen_open_menu() -> PackedByteArray:
	var dur = 0.15
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.01, dur - 0.04, 0.03)
		var freq = 200.0 + 600.0 * (t / dur)
		var val = _square(t, freq) * env * 0.35
		data[i] = _u8(val)
	return data

func _gen_close_menu() -> PackedByteArray:
	var dur = 0.12
	var n = int(dur * SAMPLE_RATE)
	var data = PackedByteArray()
	data.resize(n)
	for i in range(n):
		var t = float(i) / SAMPLE_RATE
		var env = _envelope(t, 0.01, dur - 0.04, 0.03)
		var freq = 600.0 - 400.0 * (t / dur)
		var val = _square(t, freq) * env * 0.35
		data[i] = _u8(val)
	return data
