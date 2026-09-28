extends RefCounted
## Regression scenarios for reported wall clipping and simultaneous conversation.
func run(g, failures: Array):
	g.mode="play"
	g.autonomy_enabled=false
	g.sound.voice_on=false
	g.sound.clear_speech()
	var tent=g.world.tent_center
	var p=g.player
	p.velocity=Vector3.ZERO
	p.position=g.world.ground(tent+Vector3(4,0,0))
	for i in range(8): p.move_horizontal(Vector3.LEFT,8,0.5)
	if p.position.x<tent.x+1.95: failures.append("Player crossed tent side at sprint speed / long frame")
	p.velocity=Vector3.ZERO
	p.position=g.world.ground(tent+Vector3(0,0,4))
	for i in range(90): p.move_horizontal(Vector3.FORWARD,2,0.01667)
	if p.position.z>tent.z+1.3 or not g.world.walkable(p.position): failures.append("Tent entrance inaccessible")
	for i in range(90): p.move_horizontal(Vector3.FORWARD,3,0.01667)
	if p.position.z<tent.z-1.2: failures.append("Player crossed tent rear wall")
	var start=g.world.ground(tent+Vector3(4,0,0))
	var end=g.world.ground(tent+Vector3(-4,0,0))
	var route=g.world.path_to(start,end)
	if route.is_empty(): failures.append("No NPC route around tent")
	var previous=start
	for point in route:
		if not g.world.clear_segment(previous,point): failures.append("NPC route cuts through solid scenery")
		previous=point
	var npc=g.npcs[0]
	npc.cancel()
	npc.greeting_cooldown=999
	npc.position=start
	npc.go(end,"idle","Collision regression route")
	for i in range(900):
		npc._process(0.01667)
		if not g.world.walkable(npc.position,0.38): failures.append("NPC entered a solid while following route"); break
		if npc.task=="idle": break
	if npc.position.distance_to(end)>0.5: failures.append("NPC failed to finish route around tent")
	var camera=g.world.camera_position(tent+Vector3(3,1.2,0),tent+Vector3(-3,1.2,0))
	if camera.x<tent.x+1.5: failures.append("Camera crossed tent wall")
	# All three request a turn in the same frame. Exactly one may speak at a time.
	g.sound.clear_speech()
	var lines=["Maya: Finn, I need the aircraft radio module. Can you bring it?","Finn: Found the module. Bringing it to Maya.","Rowan: Once we have fire and food, we can call for rescue."]
	for line in lines: g.sound.speak(line)
	if g.sound.active_speaker!="Maya" or g.sound.speech_queue.size()!=2: failures.append("Simultaneous speech requests not serialized")
	if g.sound.speak(lines[0]) or g.sound.speak(lines[1]): failures.append("Duplicate speech accepted")
	if g.sound.speak("Finn: Hey, you doing okay? I'll keep an eye on the food.","Finn",0): failures.append("Greeting interrupted a conversation")
	var remaining=g.sound.line_remaining
	g.mode="pause"
	g.sound._process(5)
	if g.sound.line_remaining!=remaining: failures.append("Conversation progressed while paused")
	g.mode="play"
	g.sound._process(0)
	for who in ["Maya","Finn","Rowan"]:
		if g.sound.active_speaker!=who: failures.append("Conversation order changed")
		var speaking=0
		for crew in g.npcs:
			if g.sound.is_speaking(crew.person): speaking+=1
		if speaking!=1: failures.append("Multiple characters marked as speaking")
		g.sound.advance_conversation(g.sound.line_remaining+0.01)
		if not g.sound.active_line.is_empty(): failures.append("Subtitle did not end with speech")
		g.sound.advance_conversation(0.2)
		if not g.sound.active_line.is_empty(): failures.append("Missing turn-taking pause")
		g.sound.advance_conversation(0.4)
	g.sound.speak(lines[0])
	g.sound.speak(lines[1])
	g.open_dialogue(g.npcs[2])
	if not g.sound.active_line.is_empty() or not g.sound.speech_queue.is_empty(): failures.append("Direct conversation retained unrelated chatter")
	g.choose_dialogue(g.npcs[2],"story")
	if not g.sound.is_speaking("Rowan"): failures.append("Story animation does not identify its speaker")
	g.sound.clear_speech()
	g.resume_game()
	p.velocity=Vector3.ZERO
