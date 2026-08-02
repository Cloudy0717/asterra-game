extends Node

const SAMPLE_RATE = 44100
const MAX_PLAYERS = 8

var streams = {}
var players = []
var bgm_player: AudioStreamPlayer

func _ready():
	_setup_audio_buses()
	generate_all()

func _setup_audio_buses():
	var bus_layout = AudioServer.generate_bus_layout()

	AudioServer.add_bus()
	var sfx_idx = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(sfx_idx, "SFX")
	AudioServer.set_bus_send(sfx_idx, "Master")

	AudioServer.add_bus()
	var music_idx = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(music_idx, "Music")
	AudioServer.set_bus_send(music_idx, "Master")

	AudioServer.add_bus()
	var amb_idx = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(amb_idx, "Ambient")
	AudioServer.set_bus_send(amb_idx, "Master")

	AudioServer.set_bus_layout(bus_layout)

func generate_all():
	streams["hit"] = _build("hit")
	streams["levelup"] = _build("levelup")
	streams["exp"] = _build("exp")
	streams["equip"] = _build("equip")
	streams["select"] = _build("select")
	streams["talk"] = _build("talk")
	streams["open_menu"] = _build("open_menu")
	streams["close_menu"] = _build("close_menu")
	streams["footstep"] = _build("footstep")
	streams["coin"] = _build("coin")
	streams["magic"] = _build("magic")
	streams["heal"] = _build("heal")
	streams["victory"] = _build("victory")
	streams["click"] = _build("click")
	streams["flee"] = _build("flee")
	streams["quest_complete"] = _build("quest_complete")

func play(sfx_type: String):
	if not streams.has(sfx_type):
		return
	if not _get_player():
		return
	var p = _get_player()
	p.stream = streams[sfx_type]
	p.bus = "SFX"
	p.volume_db = _sfx_db(GameState.get_settings().sfx_volume)
	p.play()

func play_bgm():
	if bgm_player and bgm_player.playing:
		return
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	bgm_player.volume_db = -12.0
	bgm_player.stream = _generate_bgm()
	add_child(bgm_player)
	bgm_player.play()

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

func _create_wav(frequency: float, duration: float, volume: float = 0.3, waveform: String = "sine") -> AudioStreamWAV:
	var sample_rate = SAMPLE_RATE
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var value = 0.0
		match waveform:
			"sine":
				value = sin(frequency * t * TAU)
			"square":
				value = 1.0 if sin(frequency * t * TAU) >= 0 else -1.0
			"saw":
				value = 2.0 * (frequency * t - floor(frequency * t + 0.5))
			"noise":
				value = randf_range(-1.0, 1.0)
			"triangle":
				value = 2.0 * abs(2.0 * (frequency * t - floor(frequency * t + 0.5))) - 1.0

		value *= volume
		value = clamp(value, -1.0, 1.0)

		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _build(sfx_name: String) -> AudioStreamWAV:
	match sfx_name:
		"hit":
			return _create_wav(80, 0.15, 0.4, "noise")
		"levelup":
			return _gen_levelup()
		"exp":
			return _create_wav(880, 0.08, 0.4, "square")
		"equip":
			return _gen_equip()
		"select":
			return _create_wav(600, 0.08, 0.2, "sine")
		"talk":
			return _create_wav(300, 0.1, 0.15, "square")
		"open_menu":
			return _gen_open_menu()
		"close_menu":
			return _create_wav(200, 0.12, 0.2, "saw")
		"footstep":
			return _create_wav(60, 0.05, 0.15, "noise")
		"coin":
			return _create_wav(1200, 0.1, 0.2, "sine")
		"magic":
			return _gen_magic()
		"heal":
			return _gen_heal()
		"victory":
			return _gen_victory()
		"click":
			return _create_wav(1400, 0.01, 0.15, "sine")
		"flee":
			return _gen_flee()
		"quest_complete":
			return _gen_quest_complete()
		_:
			return _create_wav(440, 0.1, 0.2, "sine")

func _square_wave(t: float, freq: float) -> float:
	return 1.0 if sin(freq * t * TAU) >= 0.0 else -1.0

func _gen_levelup() -> AudioStreamWAV:
	var sample_rate = SAMPLE_RATE
	var duration = 0.5
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var freq = 400 + (t / duration) * 800
		var value = sin(freq * t * TAU) * 0.3
		if t > duration * 0.7:
			value *= 1.0 - (t - duration * 0.7) / (duration * 0.3)
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _gen_equip() -> AudioStreamWAV:
	var sample_rate = SAMPLE_RATE
	var duration = 0.18
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var attack = 0.01
		var sustain = duration - 0.04
		var release = 0.03
		var envelope = 1.0
		if t < attack:
			envelope = t / attack
		elif t < attack + sustain:
			envelope = 1.0
		elif t < attack + sustain + release:
			var r = t - attack - sustain
			envelope = 1.0 - r / release
		else:
			envelope = 0.0

		var freq = 200.0 + 400.0 * (t / duration)
		var value = _square_wave(t, freq) * envelope * 0.4
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _gen_open_menu() -> AudioStreamWAV:
	var sample_rate = SAMPLE_RATE
	var duration = 0.15
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var attack = 0.01
		var sustain = duration - 0.04
		var release = 0.03
		var envelope = 1.0
		if t < attack:
			envelope = t / attack
		elif t < attack + sustain:
			envelope = 1.0
		elif t < attack + sustain + release:
			var r = t - attack - sustain
			envelope = 1.0 - r / release
		else:
			envelope = 0.0

		var freq = 200.0 + 600.0 * (t / duration)
		var value = _square_wave(t, freq) * envelope * 0.35
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _generate_bgm() -> AudioStreamWAV:
	var sample_rate = SAMPLE_RATE
	var bpm = 90
	var beat_duration = 60.0 / bpm
	var bars = 4
	var beats_per_bar = 4
	var total_duration = bars * beats_per_bar * beat_duration
	var total_samples = int(sample_rate * total_duration)

	var data = PackedByteArray()
	data.resize(total_samples * 2)

	var notes = {
		"C2": 65.41, "G2": 98.00, "F2": 87.31,
		"C3": 130.81, "D3": 146.83, "E3": 164.81, "F3": 174.61,
		"G3": 196.00, "A3": 220.00, "B3": 246.94, "C4": 261.63,
		"D4": 293.66, "E4": 329.63, "F4": 349.23, "G4": 392.00,
	}

	var melody = [
		"C3", "E3", "G3", "C4",
		"D3", "F3", "A3", "D4",
		"E3", "G3", "B3", "E4",
		"F3", "A3", "C4", "F4",
		"G3", "B3", "D4", "G4",
		"A3", "C4", "E4", "A4",
		"G3", "E3", "C3", "G2",
		"C3", "E3", "G3", "C4",
	]

	for i in range(total_samples):
		var t = float(i) / sample_rate
		var beat_idx = int(t / beat_duration) % melody.size()
		var note = notes[melody[beat_idx]]
		var beat_t = fmod(t, beat_duration) / beat_duration

		var envelope = 1.0
		if beat_t < 0.05:
			envelope = beat_t / 0.05
		elif beat_t > 0.6:
			envelope = 1.0 - (beat_t - 0.6) / 0.4

		var value = 2.0 * abs(2.0 * (note * t - floor(note * t + 0.5))) - 1.0
		value *= envelope * 0.15

		if beat_idx % 4 == 0 or beat_idx % 4 == 2:
			var bass_note = notes[["C2", "C2", "F2", "G2"][beat_idx % 4]]
			var bass = sin(bass_note * t * TAU) * 0.08
			value += bass

		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	return wav

# ========================= NEW SFX GENERATORS =========================

func _gen_magic() -> AudioStreamWAV:
	# Whooshing noise burst with descending pitch sweep — arcane casting feel
	var sample_rate = SAMPLE_RATE
	var duration = 0.35
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var progress = t / duration
		# Descending frequency sweep from 800Hz to 200Hz
		var freq = 800.0 - 600.0 * progress
		var tone = sin(freq * t * TAU) * 0.25
		# Add noise component that fades out
		var noise = randf_range(-1.0, 1.0) * 0.15 * (1.0 - progress)
		# Envelope: quick attack, sustained, then fade
		var envelope = 1.0
		if t < 0.02:
			envelope = t / 0.02
		elif t > duration * 0.6:
			envelope = 1.0 - (t - duration * 0.6) / (duration * 0.4)
		var value = (tone + noise) * envelope
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _gen_heal() -> AudioStreamWAV:
	# Rising 3-note arpeggio with gentle sine — soothing restoration feel
	var sample_rate = SAMPLE_RATE
	var duration = 0.45
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	# C5 -> E5 -> G5 arpeggio
	var note_freqs = [523.25, 659.25, 783.99]
	var note_dur = duration / 3.0

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var note_idx = mini(int(t / note_dur), 2)
		var freq = note_freqs[note_idx]
		var local_t = fmod(t, note_dur) / note_dur
		# Smooth envelope per note
		var envelope = 1.0
		if local_t < 0.08:
			envelope = local_t / 0.08
		elif local_t > 0.7:
			envelope = 1.0 - (local_t - 0.7) / 0.3
		# Add a shimmer harmonic
		var value = sin(freq * t * TAU) * 0.25 + sin(freq * 2.0 * t * TAU) * 0.08
		value *= envelope
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _gen_victory() -> AudioStreamWAV:
	# Triumphant 4-note ascending fanfare — C5 E5 G5 C6
	var sample_rate = SAMPLE_RATE
	var duration = 0.7
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	var note_freqs = [523.25, 659.25, 783.99, 1046.50]
	var note_dur = duration / 4.0

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var note_idx = mini(int(t / note_dur), 3)
		var freq = note_freqs[note_idx]
		var local_t = fmod(t, note_dur) / note_dur
		var envelope = 1.0
		if local_t < 0.05:
			envelope = local_t / 0.05
		elif local_t > 0.6:
			envelope = 1.0 - (local_t - 0.6) / 0.4
		# Bright square + sine mix
		var sq = 1.0 if sin(freq * t * TAU) >= 0 else -1.0
		var value = (sin(freq * t * TAU) * 0.2 + sq * 0.1) * envelope
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _gen_flee() -> AudioStreamWAV:
	# Rapid descending pitch slide — whoosh escape feel
	var sample_rate = SAMPLE_RATE
	var duration = 0.25
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var progress = t / duration
		# Fast descending from 600Hz to 100Hz
		var freq = 600.0 - 500.0 * progress
		var value = sin(freq * t * TAU) * 0.25 * (1.0 - progress * 0.7)
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav

func _gen_quest_complete() -> AudioStreamWAV:
	# Ascending celebration chime — 5 quick notes rising
	var sample_rate = SAMPLE_RATE
	var duration = 0.6
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	# G4 -> A4 -> B4 -> C5 -> E5
	var note_freqs = [392.00, 440.00, 493.88, 523.25, 659.25]
	var note_dur = duration / 5.0

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var note_idx = mini(int(t / note_dur), 4)
		var freq = note_freqs[note_idx]
		var local_t = fmod(t, note_dur) / note_dur
		var envelope = 1.0
		if local_t < 0.06:
			envelope = local_t / 0.06
		elif local_t > 0.5:
			envelope = 1.0 - (local_t - 0.5) / 0.5
		var value = sin(freq * t * TAU) * 0.3 * envelope
		value = clamp(value, -1.0, 1.0)
		var sample = int(value * 32767)
		sample = clampi(sample, -32768, 32767)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF

	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav
