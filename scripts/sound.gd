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
var speech_queue: Array[Dictionary] = []
var active_line=""
var active_speaker=""
var line_remaining=0.0
var conversation_gap=0.0
var conversation_clock=0.0
var recent_lines: Dictionary={}
var engine: AudioStreamPlayer

func _process(delta):
	var game=get_parent()
	var paused=game.mode in ["pause","help"]
	speech.stream_paused=paused
	if not paused: advance_conversation(delta)
	if music and speech:
		var level=-80.0 if not music_on else (-30.0 if speech.playing else -25.0)
		music.volume_db=lerpf(music.volume_db,level,minf(delta*3,1))

func _ready():
	if FileAccess.file_exists("res://audio/voices/index.json"):
		var data=JSON.parse_string(FileAccess.get_file_as_string("res://audio/voices/index.json").trim_prefix("\ufeff"))
		if data is Dictionary: voice_index=data
	speech=AudioStreamPlayer.new()
	add_child(speech)
	speech.volume_db=-5
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
				var chords=[[130.813,164.814,196.0],[110.0,130.813,164.814],[87.307,110.0,130.813],[97.999,123.471,146.832]]
				var chord=chords[int(t/4)%4]
				var section=fmod(t,4.0)
				var swell=sin(PI*section/4.0)
				for note in chord:
					sample+=(sin(TAU*float(note)*t)+sin(TAU*float(note)*1.002*t)*0.25)*0.075*swell
				var beat=fmod(t,0.5)
				var note=float(chord[int(t*2)%3])*2.0
				# Soft plucked overtones above a changing, warm major-key harmony.
				sample+=(sin(TAU*note*t)+sin(TAU*note*2*t)*0.28)*exp(-beat*8)*minf(1,beat*100)*0.12
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

func clear_speech():
	speech.stop()
	speech_queue.clear()
	active_line=""
	active_speaker=""
	line_remaining=0
	conversation_gap=0

func speak(line: String, speaker: String="", priority: int=1) -> bool:
	if line.is_empty() or active_line==line: return false
	for entry in speech_queue:
		if entry.line==line: return false
	if priority==0:
		# Ambient chatter is disposable. Do not build a backlog of old greetings.
		if not active_line.is_empty() or not speech_queue.is_empty() or conversation_gap>0: return false
		if conversation_clock-float(recent_lines.get(line,-100.0))<35: return false
	if speech_queue.size()>=4: return false
	var who=speaker
	if who.is_empty() and ":" in line: who=line.get_slice(":",0).capitalize()
	speech_queue.append({"line":line,"speaker":who,"priority":priority,"expires":conversation_clock+25})
	if active_line.is_empty() and conversation_gap<=0: next_voice()
	return true

func next_voice():
	if not active_line.is_empty(): return
	while not speech_queue.is_empty():
		var entry=speech_queue.pop_front()
		if entry.expires<conversation_clock: continue
		active_line=entry.line
		active_speaker=entry.speaker
		recent_lines[active_line]=conversation_clock
		var clip: AudioStreamWAV
		if voice_index.has(active_line): clip=AudioStreamWAV.load_from_file(voice_index[active_line])
		line_remaining=clip.get_length() if clip else clampf(active_line.length()/15.0,2,8)
		if clip and voice_on:
			speech.stream=clip
			speech.play()
		return

func advance_conversation(delta: float):
	conversation_clock+=delta
	if not active_line.is_empty():
		line_remaining=maxf(0,line_remaining-delta)
		if line_remaining<=0 and not speech.playing:
			active_line=""
			active_speaker=""
			conversation_gap=0.55
	else:
		conversation_gap=maxf(0,conversation_gap-delta)
		if conversation_gap<=0: next_voice()

func is_speaking(who: String) -> bool:
	return not active_line.is_empty() and active_speaker==who

func toggle_voice():
	voice_on=not voice_on
	speech.stop()

func toggle_music():
	music_on = not music_on
	music.volume_db = -25 if music_on else -80

func stop_all():
	clear_speech()
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream=null

func _exit_tree(): stop_all()
