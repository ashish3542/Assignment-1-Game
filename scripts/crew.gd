extends Node3D
const M=preload("res://scripts/models.gd")
var game
var world
var person=""
var role=""
var state="At camp"
var task="idle"
var path=PackedVector3Array()
var target=Vector3.ZERO
var next_task="idle"
var timer=0.0
var body: Node3D
var tag: Label3D
var cargo: MeshInstance3D
var chat: Label3D
var chat_time=0.0
var reserved_id=-1
var carry_kind=""
var routine_enabled=true
var idle_time=0.0
var greeting_cooldown=8.0
var player_was_near=false
var wave_time=0.0
var pose_clock=0.0
var routine_step=0
var fishing_rod: Node3D
var tool: Node3D
var pickup_prop: MeshInstance3D
var gather_point=Vector3.ZERO

func setup(g, who: String, job: String, color: Color, p: Vector3):
	game=g
	world=g.world
	person=who
	role=job
	position=world.ground(p)
	body=M.human(self,color,Color("b88161") if who!="Finn" else Color("d3a078"))
	if who=="Maya":
		M.sphere(body.get_node("Head"),Vector3(0,0.02,0.19),Vector3(0.16,0.24,0.20),Color("38251c"))
	elif who=="Finn":
		M.sphere(body.get_node("Head"),Vector3(0,0.16,0),Vector3(0.33,0.12,0.31),Color("817348"))
		M.box(body.get_node("Head"),Vector3(0,0.13,-0.20),Vector3(0.29,0.025,0.20),Color("817348"))
	else:
		M.box(body,Vector3(0.25,0.9,0),Vector3(0.15,0.2,0.18),Color("dfd2ac"))
		M.box(body,Vector3(0.331,0.9,0),Vector3(0.01,0.12,0.04),Color("b44938"))
		M.box(body,Vector3(0.333,0.9,0),Vector3(0.01,0.04,0.12),Color("b44938"))
	tag=Label3D.new()
	tag.position.y=2.22
	tag.font_size=28
	tag.pixel_size=0.006
	tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	tag.modulate=Color("f4e8ce")
	add_child(tag)
	chat=Label3D.new()
	chat.position.y=2.95
	chat.font_size=28
	chat.pixel_size=0.007
	chat.width=440
	chat.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	chat.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	chat.modulate=Color("ffd68b")
	chat.outline_size=8
	add_child(chat)
	cargo=M.box(body,Vector3(0,0.99,-0.4),Vector3(0.45,0.30,0.33),Color("b6b597"))
	cargo.visible=false
	pickup_prop=M.box(body.get_node("Arm1/Elbow"),Vector3(0,-0.32,0),Vector3(0.18,0.16,0.22),Color("b6a47d"))
	pickup_prop.visible=false
	fishing_rod=Node3D.new()
	body.add_child(fishing_rod)
	M.beam(fishing_rod,Vector3(0.15,1.05,-0.35),Vector3(0.1,2.7,-2.5),0.018,Color("b09561"))
	M.beam(fishing_rod,Vector3(0.1,2.7,-2.5),Vector3(0.1,0.02,-3.5),0.004,Color("cbd0b6"))
	fishing_rod.visible=false
	tool=Node3D.new()
	body.get_node("Arm1/Elbow").add_child(tool)
	M.cylinder(tool,Vector3(0,-0.28,0),0.025,0.3,Color("88998f"))
	tool.visible=false

func say(line: String, ambient: bool=false) -> bool:
	return game.report(person+": "+line,person,0 if ambient else 1)

func go(destination: Vector3, after: String, description: String):
	target=world.ground(destination)
	path=world.path_to(position,target)
	next_task=after
	task="walk"
	state=description
	if path.is_empty():
		if reserved_id>=0: game.reserved.erase(reserved_id)
		reserved_id=-1
		task="idle"
		state="Choosing another route"
		idle_time=-5

func cancel():
	if person=="Finn" and ((task=="walk" and next_task=="deliver_module") or task=="handoff_module"):
		game.module_carried=false
	if reserved_id>=0: game.reserved.erase(reserved_id)
	reserved_id=-1
	if not carry_kind.is_empty():
		game.inventory[carry_kind]+=1
		carry_kind=""
	cargo.visible=false
	pickup_prop.visible=false
	path.clear()
	task="idle"
	state="Waiting"
	timer=0
	idle_time=0
	if person=="Maya" and not game.repaired: game.repair_requested=false

func available() -> bool:
	return task=="idle" and routine_enabled

func command(action: String, from_player: bool=true):
	cancel()
	if from_player: routine_enabled=action not in ["wait","follow"]
	match action:
		"routine":
			routine_enabled=true
			idle_time=3
			say("Of course. I'll get back to it.")
		"follow":
			task="follow"
			state="Following you"
			say("Lead the way.")
		"wait":
			state="Holding here · duties paused"
			say("I'll stay here. Take your time.")
		"camp": go(world.camp+Vector3(2,0,1),"idle","Returning to camp")
		"wood": gather("Wood")
		"shelter": game.shelter.assign(self)
		"fish": go(world.fish_spot,"fish","Heading to the cove")
		"repair":
			if game.repaired:
				say("The transmitter is ready. You can send the signal.")
				return
			game.repair_requested=true
			go(world.tower+Vector3(2,0,3),"request_parts","Checking the ridge radio")
		"parts":
			if not game.module_installed and not game.module_carried:
				go(world.salvage+Vector3(3,0,0),"take_module","Searching the wreck for a radio module")
		"cook": go(world.camp+Vector3(1.5,0,0),"cook","Preparing a camp meal")

func choose_routine():
	idle_time=0
	if not game.shelter.complete():
		game.shelter.assign(self)
		return
	match person:
		"Maya":
			if not game.repaired: command("repair",false)
			elif game.inventory.Scrap<3: gather("Scrap")
			else: go(world.camp+Vector3(3,0,-2.5),"rest","Checking salvaged equipment")
		"Finn":
			if game.repair_requested and not game.module_installed and not game.module_carried: command("parts",false)
			elif game.inventory.Fish+game.inventory.Meal<2: command("fish",false)
			else:
				routine_step+=1
				go(world.camp+Vector3(6 if routine_step%2==0 else -6,0,6),"rest","Keeping watch along the shore")
		"Rowan":
			if game.fire_lit and game.inventory.Fish>0: command("cook",false)
			elif game.inventory.Wood<4: gather("Wood")
			else: go(world.tent_center+Vector3(0,0,2.8),"rest","Checking the shelter and first-aid kit")

func has_resource(kind: String) -> bool:
	for p in world.pickups:
		if p.kind==kind and not p.taken and not game.reserved.has(p.id): return true
	return false

func gather(kind: String):
	var best=-1
	var distance=INF
	for i in range(world.pickups.size()):
		var p=world.pickups[i]
		if p.kind!=kind or p.taken or game.reserved.has(p.id): continue
		var d=position.distance_to(p.node.position)
		if d<distance: best=i; distance=d
	if best<0:
		go(world.camp+Vector3(3,0,-2.5),"rest","Sorting the camp supplies")
		return
	var pickup=world.pickups[best]
	reserved_id=pickup.id
	game.reserved[reserved_id]=person
	gather_point=pickup.node.position
	var away=position-gather_point
	away.y=0
	if away.length()<0.1: away=Vector3.BACK
	var approach=world.ground(gather_point+away.normalized()*0.4)
	if not world.walkable(approach,0.38): approach=world.ground(gather_point)
	go(approach,"gathering","Collecting "+kind.to_lower())

func greet(delta):
	if game.actions.asleep: return
	greeting_cooldown=maxf(0,greeting_cooldown-delta)
	var distance=position.distance_to(game.player.position)
	if distance>6: player_was_near=false
	if distance<3.8 and not player_was_near and greeting_cooldown<=0 and game.nearby_voice_cooldown<=0:
		if not game.sound.active_line.is_empty() or not game.sound.speech_queue.is_empty() or game.sound.conversation_gap>0: return
		var greetings={"Maya":"Hey. Good to see you on your feet. I'll handle the radio.","Finn":"Hey, you doing okay? I'll keep an eye on the food.","Rowan":"There you are. Take a breath. We're in this together."}
		if not say(greetings[person],true): return
		player_was_near=true
		greeting_cooldown=38
		game.nearby_voice_cooldown=8
		wave_time=2.2

func _process(delta):
	if not game: return
	if game.mode=="dialogue":
		if game.active_npc==self:
			pose_clock+=delta
			face_point(game.player.position,delta)
			M.animate_human(body,pose_clock,false,cargo.visible,"idle",game.sound.is_speaking(person),delta)
		return
	if game.mode!="play": return
	pose_clock+=delta
	tag.text=person.to_upper()
	if position.distance_to(game.player.position)<5: tag.text+=" / "+role+"\n"+state.left(34)
	chat.visible=false # The single shared subtitle is the authoritative speech display.
	wave_time=maxf(0,wave_time-delta)
	greet(delta)
	var moving=false
	if task=="follow":
		if position.distance_to(game.player.position)>3:
			if path.is_empty() or target.distance_to(game.player.position)>4:
				target=game.player.position
				path=world.path_to(position,target)
			moving=move_path(delta)
	elif task=="walk":
		moving=move_path(delta)
		if path.is_empty(): task=next_task; timer=0; arrive()
	elif task=="idle":
		idle_time+=delta
		if game.autonomy_enabled and routine_enabled and idle_time>2.5: choose_routine()
	elif task=="rest":
		timer+=delta
		face_point(world.camp,delta)
		if timer>9: task="idle"
	elif task=="gathering":
		timer+=delta
		face_point(gather_point,delta)
		if timer>=0.85 and carry_kind.is_empty(): collect_resource()
		if timer>=1.65:
			pickup_prop.visible=false
			cargo.visible=not carry_kind.is_empty()
			go(world.camp+Vector3(2,0,1),"deliver_resource","Bringing supplies home")
	elif task=="building":
		face_point(world.tent_center+Vector3(0,1,0),delta)
		state="Raising shelter · "+str(int(game.shelter.progress*100))+"%"
		if game.shelter.complete(): task="idle"; idle_time=0
	elif task=="handoff_module":
		timer+=delta
		face_point(game.npcs[0].position,delta)
		if timer>2:
			game.module_installed=true
			game.module_carried=false
			game.team_events+=1
			cargo.visible=false
			task="idle"
			state="Delivery complete"
			say("Maya, here's the module from the aircraft.")
	elif task=="repairing":
		timer+=delta
		face_point(world.tower+Vector3(0,0,2.6),delta)
		state="Repairing · "+str(int(timer/10*100))+"%"
		if timer>=10:
			game.repaired=true
			world.signal_station.visible=true
			game.repair_requested=false
			task="idle"
			state="Transmitter repaired"
			say("Rowan, power is restored. Tell our friend to send the signal!")
			game.npcs[2].say("Once we have fire and food, we can call for rescue.")
			game.sound.play("success")
	elif task=="waiting_parts":
		if game.module_installed:
			task="repairing"
			timer=0
			say("Thanks, Finn. This module will work. Starting repairs.")
		elif not game.module_carried and game.npcs[1].available(): game.npcs[1].command("parts",false)
	elif task=="fish":
		timer+=delta
		face_point(world.fish_spot+Vector3(0,0,15),delta)
		state="Fishing for the camp"
		if timer>=10:
			carry_kind="Fish"
			cargo.visible=true
			say("Got one! Rowan, I'll bring dinner.")
			go(world.camp+Vector3(2,0,0),"deliver_fish","Carrying fish to Rowan")
	elif task=="cook":
		timer+=delta
		face_point(world.camp,delta)
		if not game.fire_lit:
			task="idle"
			state="Needs a campfire"
			say("Build the fire first: four wood and three stones.")
		elif game.inventory.Fish<=0:
			task="idle"
			state="Waiting for fish"
			say("Finn, can you catch something for dinner?")
			if game.npcs[1].available(): game.npcs[1].command("fish",false)
		elif timer>4:
			game.inventory.Fish-=1
			game.inventory.Meal+=1
			task="idle"
			state="Meal ready"
			say("Dinner is ready. Press 1 to eat from our shared supplies.")
	fishing_rod.visible=task=="fish"
	tool.visible=task in ["repairing","building"]
	var pose="idle"
	if task=="gathering": pose="gather"
	elif task=="fish": pose="fish"
	elif task=="cook": pose="cook"
	elif task in ["repairing","building"]: pose="repair"
	elif wave_time>0 and not moving and not cargo.visible: pose="wave"; face_point(game.player.position,delta)
	if world.in_tent(position): pose="escape"
	M.animate_human(body,timer if pose=="gather" else pose_clock,moving,cargo.visible,pose,game.sound.is_speaking(person),delta)
	var look=game.player.position-position
	var head=body.get_node("Head")
	var desired=clampf(wrapf(atan2(-look.x,-look.z)-body.rotation.y,-PI,PI),-0.55,0.55) if wave_time>0 else 0.0
	head.rotation.y=lerp_angle(head.rotation.y,desired,minf(1,delta*5))

func face_point(point: Vector3, delta: float):
	var diff=point-position
	if Vector2(diff.x,diff.z).length()>0.1: body.rotation.y=lerp_angle(body.rotation.y,atan2(-diff.x,-diff.z),minf(1,delta*4))

func move_path(delta: float) -> bool:
	if path.is_empty(): return false
	var flat=Vector3(path[0].x-position.x,0,path[0].z-position.z)
	var tolerance=0.04 if next_task=="gathering" and path.size()==1 else 0.22
	if flat.length()<tolerance: path.remove_at(0); return false
	if wave_time>1.0: face_point(game.player.position,delta); return false
	var previous=position
	position=world.move_character(position,flat.normalized()*minf(flat.length(),2.6*delta),0.38)
	if position.distance_to(previous)<0.002:
		# Replan a segment if a corner became blocked; never tunnel through a prop.
		path=world.path_to(position,target)
		return false
	body.rotation.y=lerp_angle(body.rotation.y,atan2(-flat.x,-flat.z),minf(1,delta*8))
	return true

func collect_resource():
	for pickup in world.pickups:
		if pickup.id==reserved_id and not pickup.taken:
			pickup.taken=true
			pickup.node.visible=false
			carry_kind=pickup.kind
			pickup_prop.visible=true
	game.reserved.erase(reserved_id)
	reserved_id=-1

func arrive():
	match task:
		"idle": state="At camp"
		"request_parts":
			if game.module_installed: task="repairing"
			else:
				task="waiting_parts"
				state="Waiting for Finn's delivery"
				say("Finn, I need the aircraft radio module. Can you bring it?")
				if game.npcs[1].available(): game.npcs[1].command("parts",false)
		"take_module":
			game.module_carried=true
			cargo.visible=true
			say("Found the module. Bringing it to Maya.")
			go(world.tower+Vector3(3,0,3),"deliver_module","Delivering the module to Maya")
		"deliver_module": task="handoff_module"; state="Handing Maya the module"
		"deliver_resource":
			var delivered=carry_kind
			if not carry_kind.is_empty(): game.inventory[carry_kind]+=1
			carry_kind=""
			cargo.visible=false
			task="idle"
			state="Supplies delivered"
			if delivered=="Cloth": say("I found fabric in the aircraft. This should keep the rain off." if person=="Rowan" else "Rowan, I found fabric in the aircraft. This should keep the rain off.")
			elif delivered=="Rope": say("Rope from the shipwreck. Let's lash those poles together." if person=="Maya" else "Rope from the shipwreck. Maya, let's lash those poles together.")
			elif delivered=="Wood":
				if not game.shelter.complete(): say("The wood is here. Let's get that shelter up.",true)
				else: say("More firewood. That's one less thing to worry about.",true)
			else: say("I've put the spare parts by the shelter.",true)
		"deliver_fish":
			game.inventory.Fish+=1
			carry_kind=""
			cargo.visible=false
			game.team_events+=1
			task="idle"
			state="Fish delivered"
			say("Rowan, here's a fresh fish for the camp.")
			if game.npcs[2].available() and game.fire_lit: game.npcs[2].command("cook",false)
