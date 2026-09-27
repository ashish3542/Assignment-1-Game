extends Node3D
const M = preload("res://scripts/models.gd")
var game
var world
var person = ""
var role = ""
var state = "At camp"
var task = "idle"
var path = PackedVector3Array()
var target = Vector3.ZERO
var next_task = "idle"
var timer = 0.0
var body: Node3D
var tag: Label3D
var cargo: MeshInstance3D
var chat: Label3D
var chat_time = 0.0
var reserved_id = -1
var carry_kind = ""

func setup(g, who: String, job: String, color: Color, p: Vector3):
	game = g
	world = g.world
	person = who
	role = job
	position = world.ground(p)
	body = M.human(self,color,Color("b88161") if who!="Finn" else Color("d3a078"))
	tag = Label3D.new()
	tag.position.y = 2.25
	tag.font_size = 38
	tag.pixel_size = 0.008
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.modulate = Color("f4e8ce")
	add_child(tag)
	chat = Label3D.new()
	chat.position.y = 2.85
	chat.font_size = 28
	chat.pixel_size = 0.008
	chat.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chat.modulate = Color("ffd68b")
	chat.outline_size = 8
	add_child(chat)
	cargo = M.box(body,Vector3(0,0.95,-0.43),Vector3(0.52,0.34,0.4),Color("b6b597"))
	cargo.visible = false

func say(line: String):
	chat.text = line
	chat_time = 6
	game.report(person+": "+line)

func go(destination: Vector3, after: String, description: String):
	target = world.ground(destination)
	path = world.path_to(position,target)
	next_task = after
	task = "walk"
	state = description
	if path.is_empty():
		task = "idle"
		state = "Path blocked"
		say("I cannot reach that spot. Try another task.")

func cancel():
	if person=="Finn" and task=="walk" and next_task=="deliver_module": game.module_carried=false
	if reserved_id>=0: game.reserved.erase(reserved_id)
	reserved_id = -1
	if not carry_kind.is_empty():
		game.inventory[carry_kind] += 1
		carry_kind = ""
	cargo.visible = false
	path.clear()
	task = "idle"
	state = "Waiting"
	if person=="Maya" and game.repair_requested and not game.repaired:
		game.repair_requested = false

func command(action: String):
	cancel()
	match action:
		"follow":
			task = "follow"
			state = "Following you"
			say("Lead the way.")
		"wait": say("I'll wait here.")
		"camp": go(world.camp+Vector3(2,0,1),"idle","Returning to camp")
		"wood": gather("Wood")
		"fish": go(world.fish_spot,"fish","Walking to fishing pier")
		"repair":
			if game.repaired:
				say("The transmitter is ready. You can send the signal.")
				return
			game.repair_requested = true
			go(world.tower+Vector3(2,0,3),"request_parts","Inspecting transmitter")
		"parts":
			if game.module_installed:
				say("Maya already has the module.")
			elif game.module_carried:
				say("The module is already on its way.")
			else: go(world.salvage+Vector3(3,0,0),"take_module","Finding aircraft radio module")
		"cook":
			go(world.camp+Vector3(1.5,0,0),"cook","Preparing camp meal")

func gather(kind: String):
	var best = -1
	var distance = INF
	for i in range(world.pickups.size()):
		var p = world.pickups[i]
		if p.kind!=kind or p.taken or game.reserved.has(p.id): continue
		var d = position.distance_to(p.node.position)
		if d<distance:
			best=i
			distance=d
	if best<0:
		say("There are no unclaimed supplies left here.")
		return
	var pickup = world.pickups[best]
	reserved_id = pickup.id
	game.reserved[reserved_id] = person
	go(pickup.node.position,"take_resource","Collecting "+kind.to_lower())

func _process(delta):
	if not game or game.mode!="play": return
	tag.text = person.to_upper()+" / "+role+"\n"+state
	chat_time = maxf(0,chat_time-delta)
	chat.visible = chat_time>0
	var moving = false
	if task=="follow":
		if position.distance_to(game.player.position)>4:
			if path.is_empty() or target.distance_to(game.player.position)>4:
				target = game.player.position
				path = world.path_to(position,target)
			moving = move_path(delta)
	elif task=="walk":
		moving = move_path(delta)
		if path.is_empty():
			task = next_task
			timer = 0
			arrive()
	elif task=="repairing":
		timer += delta
		state = "Repairing · "+str(int(timer/10*100))+"%"
		if timer>=10:
			game.repaired = true
			game.repair_requested = false
			task = "idle"
			state = "Transmitter repaired"
			say("Rowan, power is restored. Tell our friend to send the signal!")
			game.npcs[2].say("Once we have fire and food, we can call for rescue.")
			game.sound.play("success")
	elif task=="waiting_parts":
		if game.module_installed:
			task = "repairing"
			timer = 0
			say("Thanks, Finn. This module will work. Starting repairs.")
		elif not game.module_carried and game.npcs[1].task=="idle":
			game.npcs[1].command("parts")
	elif task=="fish":
		timer += delta
		state = "Fishing for the camp"
		if timer>=10:
			carry_kind = "Fish"
			cargo.visible = true
			say("Got one! Rowan, I'll bring dinner.")
			go(world.camp+Vector3(2,0,0),"deliver_fish","Carrying fish to Rowan")
	elif task=="cook":
		timer += delta
		if not game.fire_lit:
			task = "idle"
			state = "Needs a campfire"
			say("Build the fire first: four wood and three stones.")
		elif game.inventory.Fish<=0:
			task = "idle"
			state = "Waiting for fish"
			say("Finn, can you catch something for dinner?")
			if game.npcs[1].task=="idle": game.npcs[1].command("fish")
		elif timer>4:
			game.inventory.Fish -= 1
			game.inventory.Meal += 1
			task = "idle"
			state = "Meal ready"
			say("Dinner is ready. Press 1 to eat from our shared supplies.")
	M.animate_human(body,Time.get_ticks_msec()/1000.0,moving,cargo.visible)

func move_path(delta: float) -> bool:
	if path.is_empty(): return false
	var point = path[0]
	var flat = Vector3(point.x-position.x,0,point.z-position.z)
	if flat.length()<0.28:
		path.remove_at(0)
		return false
	var step = flat.normalized()*minf(flat.length(),3.4*delta)
	position = world.ground(position+step)
	body.rotation.y = lerp_angle(body.rotation.y,atan2(-flat.x,-flat.z),minf(1,delta*8))
	return true

func arrive():
	match task:
		"idle": state = "At camp"
		"request_parts":
			if game.module_installed:
				task = "repairing"
			else:
				task = "waiting_parts"
				state = "Waiting for Finn's delivery"
				say("Finn, I need the aircraft radio module. Can you bring it?")
				if game.npcs[1].task=="idle": game.npcs[1].command("parts")
				else: game.npcs[1].say("I'll finish my current task, then help you.")
		"take_module":
			game.module_carried = true
			cargo.visible = true
			say("Found the module. Bringing it to Maya.")
			go(world.tower+Vector3(3,0,3),"deliver_module","Delivering module to Maya")
		"deliver_module":
			game.module_installed = true
			game.module_carried = false
			game.team_events += 1
			cargo.visible = false
			task = "idle"
			state = "Delivery complete"
			say("Maya, here's the module from the aircraft.")
		"take_resource":
			for pickup in world.pickups:
				if pickup.id==reserved_id and not pickup.taken:
					pickup.taken = true
					pickup.node.visible = false
					carry_kind = pickup.kind
					cargo.visible = true
			game.reserved.erase(reserved_id)
			reserved_id=-1
			go(world.camp+Vector3(2,0,1),"deliver_resource","Delivering camp supplies")
		"deliver_resource":
			if not carry_kind.is_empty(): game.inventory[carry_kind]+=1
			carry_kind=""
			cargo.visible=false
			task="idle"
			state="Supplies delivered"
			say("Wood is in our shared supplies. Everyone can use it.")
		"deliver_fish":
			game.inventory.Fish+=1
			carry_kind=""
			cargo.visible=false
			game.team_events+=1
			task="idle"
			state="Fish delivered"
			say("Rowan, here's a fresh fish for the camp.")
			if game.npcs[2].task=="idle": game.npcs[2].command("cook")
