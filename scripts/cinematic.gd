extends RefCounted
## A seekable timeline: every shot derives from time, so skipping never leaves actors behind.
const DURATION=75.3
# Authored shot time -> playback time. Each spoken clip has room to finish.
const CUES=[Vector2(0,0),Vector2(4,6.1),Vector2(8,11.5),Vector2(10.5,14),Vector2(13,18.3),Vector2(18,24),Vector2(23,28.2),Vector2(29,35.3),Vector2(35,41.5),Vector2(40,48.3),Vector2(45,53.5),Vector2(50,59.5),Vector2(55,65.3),Vector2(64,75.3)]
var game
var actors: Array
var meeting: Vector3
var door: Vector3
var outside: Vector3

func _init(g):
	game=g
	actors=[g.npcs[1],g.npcs[2],g.player,g.npcs[0]]
	meeting=g.world.ground(Vector3(-29,0,35))
	door=g.world.plane.to_global(Vector3(1.2,-0.67,-2.5))
	outside=g.world.ground(g.world.plane.to_global(Vector3(3.2,-0.8,-2.5)))

func slot(i: int) -> Vector3:
	return game.world.ground(meeting+Vector3(-1.5 if i%2==0 else 1.5,0,-1.4 if i<2 else 1.4))

func shot(position: Vector3, target: Vector3, fov: float=52):
	game.cine_camera.position=position
	game.cine_camera.look_at(target)
	game.cine_camera.fov=fov

func caption(line: String):
	game.intro_caption=line
	if line!=game.last_intro_caption:
		game.last_intro_caption=line
		game.sound.clear_speech()
		game.sound.speak(line)

func sample(playback_time: float):
	var t=story_time(playback_time)
	game.intro_fade=0.0
	game.world.set_crash_visible(t>=9.8)
	game.flight.visible=t<8
	for actor in actors: actor.visible=t>=13
	if t<8:
		game.intro_phase="FLIGHT 408 / THE LAST APPROACH"
		var u=t/8.0
		game.flight.position=Vector3(-48,38,103).lerp(game.world.plane.position+Vector3(0,3,1),u)
		game.flight.rotation=Vector3(-0.24,-0.05,sin(t*3)*0.06-u*0.14)
		shot(game.flight.position+Vector3(18,6,16),game.flight.position,56)
		caption("PILOT: We've lost an engine. There's a beach ahead. Hold on!" if t<4 else "MAYA: Heads down. Stay together. Brace!")
		game.intro_fade=smoothstep(7.6,8.0,t)
	elif t<10.5:
		game.intro_phase="IMPACT"
		game.intro_fade=1.0 if t<9.8 else 1.0-smoothstep(9.8,10.5,t)
		if not game.crash_played:
			game.sound.play("crash")
			game.crash_played=true
		caption("")
		shot(game.world.plane.position+Vector3(16,5,13),game.world.plane.position)
	elif t<13:
		game.intro_phase="CRASH BEACH / MOMENTS LATER"
		shot(game.world.plane.position+Vector3(15-(t-10.5)*0.4,4,12),door+Vector3(0,0.7,0))
		caption("FINN: This way! The emergency door is open.")
	elif t<29:
		game.intro_phase="THE ESCAPE / FOUR SURVIVORS"
		shot(door+Vector3(9,3.2,8).rotated(Vector3.UP,-0.2),door.lerp(meeting,0.28)+Vector3(0,0.7,0),55)
		for i in range(actors.size()):
			var actor=actors[i]
			var elapsed=t-(13+i*3.0)
			actor.visible=elapsed>=0
			if elapsed<0: continue
			var p: Vector3
			var target: Vector3
			if elapsed<1.5:
				p=door.lerp(outside,clampf(elapsed/1.5,0,1))
				target=outside
			else:
				p=outside.lerp(slot(i),clampf((elapsed-1.5)/3.5,0,1))
				p=game.world.ground(p)
				target=slot(i) if elapsed<5 else meeting
			actor.position=p
			face(actor,target)
			game.M.animate_human(actor.body,t+i,elapsed<5,false,"escape" if elapsed<1.5 else "idle")
		if t<18: caption("ROWAN: Easy. One step at a time. I've got you.")
		elif t<23: caption("FINN: Keep moving. Get clear of the wing.")
		else: caption("MAYA: I'm out. Let's get away from the smoke.")
	elif t<55:
		game.intro_phase="TAKING STOCK / NO ONE ELSE ANSWERED"
		for i in range(actors.size()):
			actors[i].position=slot(i)
			face(actors[i],meeting)
			# A voice can finish before its shot; don't keep the mouth moving in silence.
			var talking=i!=2 and game.sound.is_speaking(["Finn","Rowan","","Maya"][i])
			game.M.animate_human(actors[i].body,t+i,false,false,"idle",talking)
		if t<35:
			shot(meeting+Vector3(7,3.0,8).lerp(Vector3(6,2.7,7), (t-29)/6),meeting+Vector3(0,0.9,0))
			caption("ROWAN: Can you hear me? Breathe. You're safe with us now.")
		elif t<40:
			shot(meeting+Vector3(6,2.5,6),meeting+Vector3(0,1,0),48)
			caption("FINN: I checked the cabin. No one else made it. Just the four of us.")
		elif t<45:
			shot(slot(3)+Vector3(1.8,1.65,-4.5),slot(3)+Vector3(0,1.2,0),44)
			caption("MAYA: We'll need a signal from the ridge. First, let's get a roof over us.")
		elif t<50:
			shot(slot(0)+Vector3(4,2,4),slot(0)+Vector3(0,1.1,0),48)
			caption("FINN: I'm heading for that wrecked boat. There might be rope we can use.")
		else:
			shot(meeting+Vector3(6,3,7),meeting+Vector3(0,1,0))
			caption("ROWAN: I'll gather wood. Maya, check the plane for fabric. Finn, look for rope.")
	else:
		game.intro_phase="KESTREL ISLAND / A SECOND CHANCE"
		var u=smoothstep(55.0,64.0,t)
		var center=meeting.lerp(game.world.camp+Vector3(0,0,4),u)
		for i in range(actors.size()):
			var finish=game.world.ground(game.world.camp+Vector3(-3+i*2,0,4))
			actors[i].position=game.world.ground(slot(i).lerp(finish,u))
			face(actors[i],finish+Vector3(0,0,-1))
			game.M.animate_human(actors[i].body,t+i,true)
		shot(center+Vector3(10,5.5,12),center+Vector3(0,0.9,0),56)
		caption("ROWAN: That beach is clear. We'll build a shelter there, together.")
		game.intro_fade=smoothstep(63.0,64.0,t)

func story_time(playback_time: float) -> float:
	for i in range(CUES.size()-1):
		if playback_time<=CUES[i+1].y:
			return lerpf(CUES[i].x,CUES[i+1].x,clampf(inverse_lerp(CUES[i].y,CUES[i+1].y,playback_time),0,1))
	return 64.0

func playback_time(authored_time: float) -> float:
	for i in range(CUES.size()-1):
		if authored_time<=CUES[i+1].x:
			return lerpf(CUES[i].y,CUES[i+1].y,inverse_lerp(CUES[i].x,CUES[i+1].x,authored_time))
	return DURATION

func face(actor, target: Vector3):
	var d=target-actor.position
	if Vector2(d.x,d.z).length()>0.05: actor.body.rotation.y=atan2(-d.x,-d.z)

func finish():
	game.world.set_crash_visible(true)
	game.sound.clear_speech()
	game.intro_fade=0.0
	for i in range(game.npcs.size()):
		var npc=game.npcs[i]
		npc.visible=true
		npc.position=game.world.ground(game.world.camp+Vector3(-2+i*3,0,-2))
		game.M.animate_human(npc.body,0,false)
	game.player.position=game.world.ground(game.world.camp+Vector3(0,0,6))
	game.player.body.rotation=Vector3.ZERO
	game.M.animate_human(game.player.body,0,false)
	game.player.visible=true
