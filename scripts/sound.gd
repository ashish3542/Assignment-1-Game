extends Node
## Original synthesized audio. PCM is generated once, then played by Godot.
var clips: Dictionary = {}
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var muted = false
var music_on = true
var voice_on = true
var voice_index: Dictionary = {}
var speech: AudioStreamPlayer
var speech_queue: Array[String] = []
var engine: AudioStreamPlayer

func _ready():
	if FileAccess.file_exists("res://audio/voices/index.json"):
		var data=JSON.parse_string(FileAccess.get_file_as_string("res://audio/voices/index.json").trim_prefix("\ufeff"))
		if data is Dictionary: voice_index=data
	speech=AudioStreamPlayer.new()
	add_child(speech)
	speech.volume_db=-5
	speech.finished.connect(next_voice)
	for kind in ["pickup","step","click","catch","fire","success","crash"]:
		clips[kind] = make_clip(kind, 2.5 if kind in ["success","crash"] else 0.28)
	ambience = AudioStreamPlayer.new()
	add_child(ambience)
	ambience.stream = make_clip("sea",8.0,true)
	ambience.volume_db = -19
	ambience.play()
	music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = make_clip("music",16.0,true)
	music.volume_db = -25
	music.play()
	engine=AudioStreamPlayer.new()
	add_child(engine)
	engine.stream=make_clip("engine",2.0,true)
	engine.volume_db=-80
	engine.play()

func make_clip(kind: String, duration: float, looped: bool = false) -> AudioStreamWAV:
	var rate = 22050
	var count = int(duration*rate)
	var data = PackedByteArray()
	data.resize(count*2)
	var random = RandomNumberGenerator.new()
	random.seed = 531
	var low = 0.0
	for i in range(count):
		var t = float(i)/rate
		var decay = exp(-t*12)
		var sample = 0.0
		low = low*0.96+random.randf_range(-1,1)*0.04
		match kind:
			"sea":
				sample = low*3*(0.55+0.25*sin(t*TAU/8))+sin(t*TAU*55)*0.02
				var bird=fmod(t,3.1)
				if bird<0.22: sample+=sin(t*TAU*(1500+sin(bird*30)*500))*sin(bird/0.22*PI)*0.07
			"engine": sample=sin(t*TAU*48)*0.28+sin(t*TAU*96)*0.09+low*0.2
			"campfire": sample=low*2.2+random.randf_range(-0.2,0.2)*(1.0 if random.randf()>0.993 else 0.0)
			"music":
				var notes = [146.832,174.614,220.0,261.626]
				for j in range(4):
					sample += sin(TAU*float(notes[j])*t)*0.09*(0.6+0.4*sin(t*TAU/16+j))
				var beat = fmod(t,2.0)
				sample += sin(t*TAU*float(notes[int(t/2)%4])*2)*exp(-beat*2.8)*0.13
			"step": sample = low*2*decay+sin(t*TAU*90)*decay*0.2
			"pickup": sample = sin(t*TAU*(650+t*1300))*decay*0.6
			"click": sample = sin(t*TAU*550)*decay*0.3
			"catch": sample = sin(t*TAU*(500+t*1900))*decay*0.7
			"fire": sample = low*3*decay
			"crash": sample = (low*4+sin(t*TAU*(65-t*12))*0.3)*exp(-t*2)
			"success":
				var notes = [293.66,369.99,440.0,587.33]
				for j in range(4):
					if t>j*0.22:
						sample += sin(t*TAU*notes[j])*exp(-(t-j*0.22)*2)*0.2
		if looped:
			sample *= minf(1,minf(t*20,(duration-t)*20))
		var v = int(clampf(sample,-0.95,0.95)*32767)
		data.encode_s16(i*2,v)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = count
	return stream

func play(kind: String):
	if muted or not clips.has(kind): return
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = clips[kind]
	p.volume_db = -14
	p.finished.connect(p.queue_free)
	p.play()

func toggle_mute():
	muted = not muted
	AudioServer.set_bus_mute(0,muted)
	if muted: speech.stop()

func speak(line: String):
	if voice_on and not muted and voice_index.has(line):
		speech_queue.append(line)
		if not speech.playing: next_voice()

func next_voice():
	if speech_queue.is_empty(): return
	var line=speech_queue.pop_front()
	speech.stream=AudioStreamWAV.load_from_file(voice_index[line])
	speech.play()

func toggle_voice():
	voice_on=not voice_on
	speech.stop()
	speech_queue.clear()

func toggle_music():
	music_on = not music_on
	music.volume_db = -25 if music_on else -80

func stop_all():
	speech_queue.clear()
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream=null

func _exit_tree(): stop_all()
