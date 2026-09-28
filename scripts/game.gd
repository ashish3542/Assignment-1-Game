extends Node3D
## Coordinates the chapter; individual movement, world, UI and audio live separately.
const Island = preload("res://scripts/island.gd")
const Player = preload("res://scripts/player.gd")
const Survivor = preload("res://scripts/crew.gd")
const Interface = preload("res://scripts/interface.gd")
const Sound = preload("res://scripts/sound.gd")
const M = preload("res://scripts/models.gd")
var world
var player
var ui
var sound
var npcs: Array = []
var cine_camera: Camera3D
var flight: Node3D
var cinematic
var shelter
var actions
var day_cycle
var intro_fade=0.0
var intro_phase=""
var autonomy_enabled=true
var nearby_voice_cooldown=0.0
var mode = "menu"
var previous_mode = "play"
var inventory = {"Wood":0,"Stone":0,"Scrap":0,"Fish":0,"Meal":0,"Ration":1,"Cloth":0,"Rope":0}
var health = 100.0
var hunger = 85.0
var fire_lit = false
var ate_meal = false
var repaired = false
var repair_requested = false
var module_installed = false
var module_carried = false
var won = false
var spear = false
var team_events = 0
var reserved: Dictionary = {}
var events: Array[String] = []
var toast = ""
var toast_time = 0.0
var prompt = ""
var active_npc
var dialogue_line = ""
var interaction: Dictionary = {}
var fishing = 0.0
var intro_time = 0.0
var intro_caption = ""
var crash_played = false
var last_intro_caption = ""
var projectiles: Array[Dictionary] = []
var run_time = 0.0
var demo_active = false
var demo_caption = ""
var demo_focus: Node3D
var save_path = "user://kestrel_save.json"
var fire_audio: AudioStreamPlayer3D

func _ready():
	world = Island.new()
	add_child(world)
	day_cycle=load("res://scripts/day_cycle.gd").new(self)
	shelter=load("res://scripts/shelter.gd").new(self)
	sound = Sound.new()
	add_child(sound)
	fire_audio=AudioStreamPlayer3D.new()
	add_child(fire_audio)
	fire_audio.position=world.camp+Vector3(0,0.5,0)
	fire_audio.stream=sound.make_clip("campfire",4.0,true)
	fire_audio.max_distance=23
	fire_audio.unit_size=4
	fire_audio.volume_db=-15
	player = Player.new()
	add_child(player)
	actions=load("res://scripts/player_actions.gd").new(self)
	player.setup(world,self)
	var names = ["Maya","Finn","Rowan"]
	var jobs = ["Engineer","Scout","Medic"]
	var colors = [Color("c2734b"),Color("467b78"),Color("b6ba99")]
	for i in range(3):
		var npc = Survivor.new()
		add_child(npc)
		npc.setup(self,names[i],jobs[i],colors[i],world.camp+Vector3(-2+i*3,0,-2))
		npcs.append(npc)
	cine_camera = Camera3D.new()
	cine_camera.far=900
	cine_camera.fov=58
	add_child(cine_camera)
	cine_camera.current=true
	var layer = CanvasLayer.new()
	add_child(layer)
	ui = Interface.new()
	layer.add_child(ui)
	ui.setup(self)
	ui.show_menu()
	report("Four survivors. Start with shelter, fire and food.")
	for arg in OS.get_cmdline_user_args():
		if arg=="--test":
			save_path="user://kestrel_test.json"
			sound.voice_on=false
			call_deferred("run_tests")
		if arg.begins_with("--capture="):
			call_deferred("capture",arg.trim_prefix("--capture="))
		if arg=="--demo":
			var demo=load("res://scripts/demo.gd").new()
			demo.game=self
			add_child(demo)
		if arg=="--revision-demo":
			var demo=load("res://scripts/revision_demo.gd").new()
			demo.game=self
			add_child(demo)
		if arg=="--polish-demo":
			var demo=load("res://scripts/polish_demo.gd").new()
			demo.game=self
			add_child(demo)
		if arg=="--survival-demo":
			var demo=load("res://scripts/survival_demo.gd").new()
			demo.game=self
			add_child(demo)
		if arg=="--comfort-demo":
			var demo=load("res://scripts/comfort_demo.gd").new()
			demo.game=self
			add_child(demo)
		if arg=="--sleep-demo":
			var demo=load("res://scripts/sleep_demo.gd").new()
			demo.game=self
			add_child(demo)
		if arg=="--day-cycle-demo":
			var demo=load("res://scripts/day_cycle_demo.gd").new()
			demo.game=self
			add_child(demo)

func _process(delta):
	run_time+=delta
	if mode=="play": nearby_voice_cooldown=maxf(0,nearby_voice_cooldown-delta)
	for npc in npcs:
		npc.tag.visible=mode=="play" and not actions.asleep and npc.position.distance_to(player.position)<12 and npc.position.distance_to(player.camera.position)>2.5
		if mode!="play": npc.chat.visible=false
	toast_time=maxf(0,toast_time-delta)
	if mode=="menu":
		var a=0.45+sin(run_time*0.05)*0.17
		cine_camera.position=world.camp+Vector3(sin(a)*28,13,cos(a)*28)
		cine_camera.look_at(world.camp+Vector3(2,1,-8))
	elif mode=="intro": update_intro(delta)
	elif mode=="play":
		day_cycle.update(delta)
		shelter.update(delta)
		actions.update(delta)
		if demo_active and actions.busy(): player.animate_action(delta)
		if demo_active and is_instance_valid(demo_focus):
			player.camera.position=player.camera.position.lerp(demo_focus.position+Vector3(7,4,7),minf(delta*3,1))
			player.camera.look_at(demo_focus.position+Vector3(0,1,0))
		hunger=maxf(0,hunger-delta*0.055)
		if hunger<1: health=maxf(10,health-delta*0.22)
		if fishing>0:
			fishing+=delta
			if fishing>5:
				fishing=0
				report("The fish escaped. Press E at the pier to try again.")
		find_interaction()
		update_projectiles(delta)

func _unhandled_input(event):
	if not event is InputEventKey or not event.pressed or event.echo: return
	var key = event.physical_keycode
	if demo_active:
		if key==KEY_ESCAPE: get_tree().quit()
		return
	if key==KEY_M: sound.toggle_mute()
	if key==KEY_N: sound.toggle_voice(); report("Survivor voice "+("on" if sound.voice_on else "off"))
	if mode=="intro" and (key==KEY_ENTER or key==KEY_ESCAPE):
		begin_play()
		return
	if mode=="menu": return
	if key==KEY_ESCAPE or key==KEY_TAB:
		if mode=="play":
			if key==KEY_TAB: show_help()
			else: pause_game()
		elif mode=="help" and previous_mode=="menu":
			mode="menu"
			ui.show_menu()
		else: resume_game()
		return
	if mode!="play": return
	if key==KEY_H:
		actions.toggle_rest()
		return
	if actions.busy() and key not in [KEY_F6,KEY_F9,KEY_E]: return
	match key:
		KEY_E: interact()
		KEY_B:
			if player.position.distance_to(world.tent_center+Vector3(0,0,3.5))<2.5: shelter.help()
			else: report("Move to the shelter entrance, then press B to help build.")
		KEY_1: eat()
		KEY_R: craft_spear()
		KEY_G: throw_stone()
		KEY_F6: save_game()
		KEY_F9: load_game()

func start_intro():
	ui.clear_buttons()
	mode="intro"
	intro_time=0
	crash_played=false
	last_intro_caption=""
	flight=M.plane(self)
	flight.scale=Vector3(1.65,1.65,1.65)
	cinematic=load("res://scripts/cinematic.gd").new(self)
	cine_camera.current=true
	cinematic.sample(0)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func update_intro(delta):
	intro_time+=delta
	cinematic.sample(intro_time)
	if intro_time>=cinematic.DURATION: begin_play()

func begin_play():
	if cinematic: cinematic.finish()
	else: world.set_crash_visible(true)
	if is_instance_valid(flight): flight.queue_free()
	player.visible=true
	player.camera.current=true
	player.update_camera(1)
	resume_game()
	report("Help the crew: salvage cloth and rope, gather wood, then build a shelter.")

func resume_game():
	ui.clear_buttons()
	mode="play"
	player.camera.current=true
	if actions.asleep: day_cycle.sleep_camera(actions.sleep_elapsed)
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func pause_game():
	mode="pause"
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	ui.show_pause()

func show_help():
	previous_mode=mode
	mode="help"
	ui.clear_buttons()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func restart():
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func report(line: String, speaker: String="", priority: int=1) -> bool:
	events.append(line)
	if events.size()>60: events.pop_front()
	if line.begins_with("Maya:") or line.begins_with("Finn:") or line.begins_with("Rowan:") or line.begins_with("COAST GUARD:"):
		if actions.asleep: return false
		# Crew speech stays local. Distant job progress is still recorded in the journal.
		if not speaker.is_empty() and priority<=1:
			for npc in npcs:
				if npc.person==speaker and npc.position.distance_to(player.position)>22: return false
		return sound.speak(line,speaker,priority)
	toast=line
	toast_time=4
	return false

func location_name() -> String:
	if player.position.distance_to(world.ship_spot)<19: return "Tidebreak Shipwreck"
	if player.position.distance_to(world.tower)<17: return "Signal Ridge"
	if player.position.distance_to(world.salvage)<17: return "Crash Beach"
	if player.position.distance_to(world.fish_spot)<17: return "Sheltered Cove"
	if player.position.distance_to(world.camp)<20: return "Survivors' Camp" if shelter.complete() else "Empty Beach / Shelter Site"
	return "Kestrel Forest"

func find_interaction():
	interaction={}
	prompt=""
	if actions.resting:
		prompt="Sleeping for eight hours..." if actions.asleep else "Settling down / H or movement cancels before sleep"
		return
	if actions.picking():
		prompt="Collecting "+actions.pickup.kind.to_lower()+" · Move to cancel"
		return
	if actions.waking>0:
		prompt="Getting up..."
		return
	if fishing>0:
		prompt="E  /  Reel in!" if fishing>=3 else "Wait for the bite..."
		return
	var closest=3.0
	for npc in npcs:
		var distance=player.position.distance_to(npc.position)
		if distance<closest:
			closest=distance
			interaction={"type":"npc","npc":npc}
			prompt="E  /  Talk to "+npc.person
	for p in world.pickups:
		if p.taken or reserved.has(p.id): continue
		var distance=player.position.distance_to(p.node.position)
		if distance<minf(closest,2.0):
			closest=distance
			interaction={"type":"pickup","item":p}
			prompt="E  /  Collect "+p.kind.to_lower()
	if not interaction.is_empty(): return
	if player.position.distance_to(world.tent_center+Vector3(0,0,3.5))<2.5:
		interaction={"type":"shelter"}
		prompt="E  /  Help raise the shelter" if shelter.paid else "E  /  Inspect shelter site"
		if shelter.complete(): prompt="E  /  Check completed shelter"
	elif player.position.distance_to(world.camp)<3:
		interaction={"type":"fire"}
		prompt="E  /  Cook fish" if fire_lit else "E  /  Build fire · 4 wood + 3 stone"
	elif player.position.distance_to(world.fish_spot)<4:
		interaction={"type":"fish"}
		prompt="E  /  Cast the salvaged fishing line"
	elif player.position.distance_to(world.tower+Vector3(0,0,3))<4:
		interaction={"type":"beacon"}
		prompt="E  /  Send rescue signal" if repaired else "E  /  Inspect transmitter"

func interact():
	if actions.resting: actions.wake(); return
	if actions.busy(): return
	if fishing>0:
		if fishing>=3 and fishing<=5:
			inventory.Fish+=1
			sound.play("catch")
			report("Caught a fish. Cook it at the campfire, then press 1 to eat.")
		else: report("Too soon. Wait until the fishing indicator says BITE.")
		fishing=0
		return
	if interaction.is_empty(): return
	match interaction.type:
		"shelter": shelter.help()
		"npc": open_dialogue(interaction.npc)
		"pickup": actions.start_pickup(interaction.item)
		"fire": use_fire()
		"fish":
			fishing=0.01
			report("Line cast. Wait for BITE, then press E.")
		"beacon": activate_beacon()

func use_fire():
	if not fire_lit:
		if inventory.Wood<4 or inventory.Stone<3:
			report("Need 4 wood and 3 stone. Wood is west of camp; stones are east.")
			return
		inventory.Wood-=4
		inventory.Stone-=3
		fire_lit=true
		world.fire_base.visible=true
		world.fire.visible=true
		world.fire_light.visible=true
		fire_audio.play()
		sound.play("fire")
		report("A fire, a little warmth, a place to belong. Next: catch and cook a fish.")
	elif inventory.Fish>0:
		inventory.Fish-=1
		inventory.Meal+=1
		sound.play("fire")
		report("Fish cooked. Press 1 to eat your meal.")
	else: report("No raw fish. Fish at the pier or ask Finn to catch one.")

func eat():
	if actions.busy(): return
	if inventory.Meal>0:
		inventory.Meal-=1
		ate_meal=true
		hunger=minf(100,hunger+45)
		health=minf(100,health+15)
		sound.play("pickup")
		report("A warm meal. Ask Maya to repair the transmitter when you're ready.")
	elif inventory.Ration>0:
		inventory.Ration-=1
		hunger=minf(100,hunger+25)
		health=minf(100,health+8)
		report("A salvaged ration helps. A cooked fish is still needed for the camp objective.")
	else: report("No meals or rations. Cook a fish at camp.")

func craft_spear():
	if actions.busy(): return
	if spear:
		report("Your spear is ready. It is a survival tool; wildlife combat is not in this chapter.")
		return
	if inventory.Wood<2 or inventory.Scrap<1:
		report("Crafting a spear needs 2 wood and 1 scrap.")
		return
	inventory.Wood-=2
	inventory.Scrap-=1
	spear=true
	add_spear_model()
	report("Spear crafted and equipped. Fishing still uses your salvaged line.")

func add_spear_model():
	if player.body.has_node("Spear"): return
	var tool=M.beam(player.body,Vector3(0.48,0.2,-0.2),Vector3(0.48,2.4,-0.2),0.035,Color("8e7150"))
	tool.name="Spear"

func throw_stone():
	if actions.busy(): return
	if inventory.Stone<=0:
		report("No stones to throw. Save three for the fire.")
		return
	inventory.Stone-=1
	var n=M.sphere(self,player.position+Vector3(0,1.5,0),Vector3(0.18,0.18,0.18),Color("adad97"))
	var forward=Vector3(-sin(player.yaw),0,-cos(player.yaw))
	projectiles.append({"node":n,"velocity":forward*15+Vector3(0,5,0),"life":0.0})
	sound.play("step")

func update_projectiles(delta):
	for i in range(projectiles.size()-1,-1,-1):
		var p=projectiles[i]
		p.velocity.y-=18*delta
		p.node.position+=p.velocity*delta
		p.life+=delta
		if p.node.position.y<world.height_at(p.node.position.x,p.node.position.z) or p.life>4:
			world.add_pickup("Stone",p.node.position,1000+world.pickups.size())
			p.node.queue_free()
			projectiles.remove_at(i)

func open_dialogue(npc):
	sound.clear_speech()
	active_npc=npc
	dialogue_line="I am here. "+npc.state+". Need a hand with something?"
	mode="dialogue"
	player.velocity=Vector3.ZERO
	var facing=(player.position-npc.position).normalized()
	var side=Vector3(-facing.z,0,facing.x)
	cine_camera.fov=48
	cine_camera.position=world.camera_position(npc.position+Vector3(0,1.2,0),npc.position+facing*4.5+side*1.6+Vector3(0,1.8,0))
	cine_camera.look_at(npc.position+Vector3(0,1.15,0)-side*1.0)
	cine_camera.current=true
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	ui.show_dialogue(npc)

func choose_dialogue(npc, action: String):
	if action=="story":
		match npc.person:
			"Maya": dialogue_line="We need a shelter first. I'll salvage fabric from the plane. Later, Finn and I can build a radio on the ridge."
			"Finn": dialogue_line="That old ship has rope and spare parts. I'll bring rope for our shelter, then catch fish for Rowan at the cove."
			"Rowan": dialogue_line="Four of us survived. First we need a roof: wood, fabric and rope. Let's build it together. Then I'll help with food."
		sound.clear_speech()
		sound.speak(dialogue_line,npc.person,2)
		return
	npc.command(action)
	resume_game()

func activate_beacon():
	if won:
		report("Rescue acknowledged. You can keep exploring and save your journey.")
		return
	if not repaired:
		report("The radio is damaged. Ask Maya to repair it; watch Finn deliver the module.")
		return
	if not shelter.complete() or not fire_lit or not ate_meal:
		report("Secure the camp first: shelter, a fire, and a cooked meal.")
		return
	won=true
	sound.clear_speech()
	world.beacon_light.visible=true
	world.beacon_beam.visible=true
	sound.play("success")
	mode="ending"
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	ui.show_end()
	report("COAST GUARD: Kestrel station, we read you. Hold your position. Help is coming.")

func save_game():
	actions.cancel_pickup()
	var saved_inventory=inventory.duplicate()
	for npc in npcs:
		if not npc.carry_kind.is_empty(): saved_inventory[npc.carry_kind]+=1
	var taken=[]
	for p in world.pickups:
		if p.taken and p.id<1000: taken.append(p.id)
	var data={"version":1,"inventory":saved_inventory,"health":health,"hunger":hunger,"fire":fire_lit,"meal":ate_meal,"repaired":repaired,"module":module_installed,"won":won,"spear":spear,"team_events":team_events,"taken":taken,"player":[player.position.x,player.position.z]}
	data.version=2
	data.shelter=shelter.snapshot()
	data.time_hours=day_cycle.hours
	data.sleep=actions.sleep_snapshot()
	# Save delivered supplies only; reset active tasks on load to avoid ghost reservations.
	var file=FileAccess.open(save_path,FileAccess.WRITE)
	if not file:
		report("Could not write save file.")
		return
	file.store_string(JSON.stringify(data))
	report("Journey saved on this computer. F9 loads it; active jobs restart at camp.")

func load_game():
	if not FileAccess.file_exists(save_path):
		report("No saved journey yet. Begin the story, then press F6 to save.")
		return
	var parsed=JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not parsed is Dictionary or not int(parsed.get("version",0)) in [1,2]:
		report("Save file is not a supported journey.")
		return
	var data: Dictionary=parsed
	actions.reset()
	day_cycle.set_hours(float(data.get("time_hours",8.0)))
	sound.clear_speech()
	player.velocity=Vector3.ZERO
	player.jump_y=0
	player.jump_speed=0
	for npc in npcs: npc.cancel()
	reserved.clear()
	for k in inventory: inventory[k]=maxi(0,int(data.get("inventory",{}).get(k,0)))
	health=clampf(float(data.get("health",100)),10,100)
	hunger=clampf(float(data.get("hunger",85)),0,100)
	fire_lit=bool(data.get("fire",false))
	ate_meal=bool(data.get("meal",false))
	repaired=bool(data.get("repaired",false))
	module_installed=bool(data.get("module",false))
	module_carried=false
	repair_requested=false
	won=bool(data.get("won",false))
	spear=bool(data.get("spear",false))
	team_events=int(data.get("team_events",0))
	# Old saves already had a furnished camp. Preserve it without charging new materials.
	var old_camp={"paid":true,"progress":1.0} if int(data.version)==1 else {}
	shelter.restore(data.get("shelter",old_camp))
	world.signal_station.visible=repaired
	world.fire_base.visible=fire_lit
	world.fire.visible=fire_lit
	world.fire_light.visible=fire_lit
	if fire_lit: fire_audio.play()
	else: fire_audio.stop()
	world.beacon_light.visible=won
	world.beacon_beam.visible=won
	for p in world.pickups:
		p.taken=p.id in data.get("taken",[]) or p.id>=1000
		p.node.visible=not p.taken
	var pp=data.get("player",[-6,33])
	player.position=world.ground(Vector3(float(pp[0]),0,float(pp[1])))
	if not world.walkable(player.position): player.position=world.ground(world.camp+Vector3(0,0,6))
	world.set_crash_visible(true)
	for i in range(npcs.size()):
		npcs[i].position=world.ground(world.camp+Vector3(-2+i*3,0,-2))
		npcs[i].visible=true
		npcs[i].routine_enabled=true
		npcs[i].idle_time=0
	player.visible=true
	player.body.visible=true
	if spear: add_spear_model()
	elif player.body.has_node("Spear"): player.body.get_node("Spear").queue_free()
	fishing=0
	player.update_camera(1)
	resume_game()
	actions.restore_sleep(data.get("sleep",{}))
	report("Journey restored. The crew will resume their duties from camp.")

func capture(filename: String):
	autonomy_enabled=false
	if "--camp" in OS.get_cmdline_user_args():
		begin_play()
		player.position=world.ground(world.camp+Vector3(7,0,11))
		player.yaw=0.25
		player.update_camera(1)
	if "--dialogue" in OS.get_cmdline_user_args(): open_dialogue(npcs[0])
	if "--intro-shot" in OS.get_cmdline_user_args():
		start_intro()
		intro_time=2
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--survival-view="):
			demo_active=true
			begin_play()
			var view=arg.trim_prefix("--survival-view=")
			if view=="complete": shelter.restore({"paid":true,"progress":1.0})
			if view=="frame": shelter.restore({"paid":true,"progress":0.3})
			load("res://scripts/survival_demo.gd").shot(self,"build" if view in ["complete","frame"] else view)
		if arg.begins_with("--shot-time="):
			if mode!="intro": start_intro()
			intro_time=float(arg.trim_prefix("--shot-time="))
	for i in range(12): await get_tree().process_frame
	var image=get_viewport().get_texture().get_image()
	image.save_png(filename)
	get_tree().quit()

func run_tests():
	var failures=[]
	autonomy_enabled=false
	mode="play"
	load("res://scripts/survival_tests.gd").new().run(self,failures)
	# Run the actual gameplay methods and NPC updates, without waiting in real time.
	use_fire()
	if fire_lit: failures.append("Fire accepted missing resources")
	inventory.Wood=4
	inventory.Stone=3
	use_fire()
	if not fire_lit or inventory.Wood!=0 or inventory.Stone!=0: failures.append("Fire resource accounting")
	npcs[1].command("fish")
	for i in range(6000):
		for npc in npcs: npc._process(0.05)
		if inventory.Meal>0: break
	if inventory.Meal!=1: failures.append("Finn to Rowan fishing/cooking chain"); print(events); print(npcs[1].state, npcs[1].position, npcs[1].task); print(npcs[2].state, npcs[2].task)
	eat()
	if not ate_meal: failures.append("Meal objective")
	npcs[0].command("repair")
	for i in range(10000):
		for npc in npcs: npc._process(0.05)
		if repaired: break
	if not repaired or not module_installed: failures.append("Maya to Finn repair/handoff chain")
	if team_events<2: failures.append("Actual NPC handoffs not recorded")
	activate_beacon()
	if not won: failures.append("Chapter completion")
	if not world.walkable(world.camp): failures.append("Camp inaccessible")
	if world.walkable(Vector3(200,0,200)): failures.append("Ocean boundary")
	npcs[2].command("wood")
	npcs[2].cancel()
	if not reserved.is_empty(): failures.append("Cancelled collection reservation leaked")
	# Verify actual player interactions and duplicate protection.
	mode="play"
	var stone=world.pickups[12]
	player.position=world.ground(stone.node.position+Vector3(0,0,0.4))
	interaction={"type":"pickup","item":stone}
	var before=int(inventory.Stone)
	interact()
	interact()
	for frame in range(100): actions.update(0.05)
	interact()
	if inventory.Stone!=before+1: failures.append("Duplicate pickup")
	fishing=1
	interact()
	if inventory.Fish!=0: failures.append("Early fishing accepted")
	fishing=3.5
	interact()
	if inventory.Fish!=1: failures.append("Player fishing timing")
	# An interrupted module delivery must become retrievable again.
	module_installed=false
	repaired=false
	npcs[1].command("parts")
	for i in range(3000):
		npcs[1]._process(0.05)
		if module_carried: break
	if not module_carried: failures.append("Module pickup")
	npcs[1].command("wait")
	if module_carried: failures.append("Cancelled module delivery locked mission")
	# Saving while someone carries a resource must preserve that resource.
	npcs[2].command("wood")
	for i in range(3000):
		npcs[2]._process(0.05)
		if not npcs[2].carry_kind.is_empty(): break
	if npcs[2].carry_kind!="Wood": failures.append("NPC wood collection")
	var expected_wood=int(inventory.Wood)+1
	save_game()
	inventory.Wood=999
	load_game()
	if inventory.Wood!=expected_wood: failures.append("Save/load carried resource preservation")
	if not fire_lit or not ate_meal: failures.append("Save/load progress")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	for kind in ["pickup","step","success","crash"]:
		if sound.clips[kind].data.is_empty(): failures.append("Missing audio "+kind)
	if sound.voice_index.size()<35: failures.append("Missing spoken dialogue")
	check_voice_assets(failures)
	await run_revision_tests(failures)
	load("res://scripts/polish_tests.gd").new().run(self,failures)
	load("res://scripts/comfort_tests.gd").new().run(self,failures)
	# Free queued menu controls before the runner exits.
	mode="pause"
	sound.stop_all()
	fire_audio.stop()
	fire_audio.stream=null
	await get_tree().create_timer(0.15).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	if failures.is_empty():
		print("KESTREL TESTS PASSED: resource gates, player/NPC fishing, cooking, meal, pathfinding, NPC requests, handoffs, repairs, ending, cancellation, duplicate pickups, animated collection, rest recovery, save/load, carried resources, island boundary, sound data, voice inventory, cinematic visibility/skip, autonomous jobs, command priority and greeting cooldowns")
		get_tree().quit(0)
	else:
		for failure in failures: push_error("TEST FAILED: "+failure)
		get_tree().quit(1)

func check_voice_assets(failures: Array):
	# Keep temporary WAV references outside the async test runner's lifetime.
	for line in sound.voice_index:
		var recorded_voice=AudioStreamWAV.load_from_file(sound.voice_index[line])
		if not recorded_voice or recorded_voice.get_length()<0.5:
			failures.append("Missing or empty voice recording: "+line)

func run_revision_tests(failures: Array):
	# Test the actual seekable scene rather than duplicating its visibility rules.
	start_intro()
	for i in range(cinematic.CUES.size()-1):
		cinematic.sample(cinematic.CUES[i].y+0.01)
		if intro_caption.is_empty(): continue
		if not sound.voice_index.has(intro_caption):
			failures.append("Cinematic caption has no voice clip: "+intro_caption)
			continue
		var clip=AudioStreamWAV.load_from_file(sound.voice_index[intro_caption])
		if not clip or clip.get_length()>cinematic.CUES[i+1].y-cinematic.CUES[i].y:
			failures.append("Cinematic cut interrupts spoken dialogue: "+intro_caption)
	for t in [0.0,4.0,7.9]:
		cinematic.sample(cinematic.playback_time(t))
		if world.plane.is_visible_in_tree() or world.wreck_root.visible: failures.append("Wreck visible before impact")
		for npc in npcs:
			if npc.visible: failures.append("Survivor visible before impact")
	cinematic.sample(cinematic.playback_time(8.5))
	if flight.visible or intro_fade<0.99: failures.append("Impact transition")
	cinematic.sample(cinematic.playback_time(12.0))
	if not world.wreck_root.visible or flight.visible: failures.append("Post-crash aircraft visibility")
	cinematic.sample(cinematic.playback_time(13.5))
	var count=0
	for actor in cinematic.actors:
		if actor.visible: count+=1
	if count!=1: failures.append("Staggered emergency exit")
	cinematic.sample(cinematic.playback_time(28.0))
	for actor in cinematic.actors:
		if not actor.visible: failures.append("Four survivors did not escape")
	cinematic.sample(cinematic.playback_time(34.0))
	for i in range(cinematic.actors.size()):
		if cinematic.actors[i].position.distance_to(cinematic.slot(i))>0.1: failures.append("Regroup formation")
	begin_play()
	if mode!="play" or not player.visible or not world.wreck_root.visible: failures.append("Intro skip final state")
	# A held Finn must not be stolen by Maya's automatic request.
	for npc in npcs:
		npc.cancel()
		npc.routine_enabled=true
		npc.greeting_cooldown=999
	for p in world.pickups:
		p.taken=false
		p.node.visible=true
	inventory.Wood=0
	inventory.Fish=0
	inventory.Meal=0
	inventory.Scrap=0
	fire_lit=false
	world.fire.visible=false
	repaired=false
	module_installed=false
	module_carried=false
	autonomy_enabled=true
	npcs[1].command("wait")
	var held_position=npcs[1].position
	for i in range(1600):
		for npc in npcs: npc._process(0.05)
	if npcs[1].position.distance_to(held_position)>0.1 or npcs[1].task!="idle" or module_installed:
		failures.append("Wait command overridden by autonomous request")
	npcs[1].command("routine")
	for i in range(9000):
		for npc in npcs: npc._process(0.05)
		if repaired and inventory.Wood>=4 and inventory.Fish>=1: break
	if not repaired or inventory.Wood<4 or inventory.Fish<1:
		failures.append("Autonomous radio, supplies and food progression")
		for npc in npcs: print(npc.person," ",npc.task," ",npc.state," ",npc.position)
	inventory.Stone=3
	use_fire()
	for i in range(4000):
		for npc in npcs: npc._process(0.05)
		if inventory.Meal>0: break
	if inventory.Meal<1: failures.append("Autonomous cooking after fire is built")
	# One greeting per approach; remaining nearby does not retrigger it.
	var rowan=npcs[2]
	rowan.command("wait")
	sound.clear_speech()
	sound.recent_lines.clear()
	rowan.greeting_cooldown=0
	rowan.player_was_near=false
	nearby_voice_cooldown=0
	player.position=rowan.position+Vector3(1,0,0)
	# The log has a fixed cap, so inspect the greeting counter through its cooldown.
	rowan.greet(0.1)
	if rowan.greeting_cooldown<37 or not rowan.player_was_near: failures.append("Approach greeting")
	var line=events.back()
	rowan.greet(40)
	if events.back()!=line or rowan.greeting_cooldown!=0: failures.append("Greeting repeated while stationary")
	player.position=rowan.position+Vector3(8,0,0)
	rowan.greet(0.1)
	sound.clear_speech()
	sound.advance_conversation(40)
	nearby_voice_cooldown=0
	player.position=rowan.position+Vector3(1,0,0)
	rowan.greet(0.1)
	if rowan.greeting_cooldown<37: failures.append("Greeting failed on re-entry")
	# Pause must freeze jobs and resource accounting.
	mode="pause"
	var supplies=inventory.duplicate()
	for npc in npcs: npc._process(100)
	if inventory!=supplies: failures.append("Jobs advanced while paused")
	autonomy_enabled=false

