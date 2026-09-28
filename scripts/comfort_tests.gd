extends RefCounted

func run(g, failures: Array):
	g.mode="play"
	g.autonomy_enabled=false
	for npc in g.npcs: npc.cancel(); npc.routine_enabled=false
	var a=g.actions
	var w=g.world
	var p=g.player
	a.reset()
	var stone=w.pickups[12]
	stone.taken=false
	stone.node.visible=true
	p.position=w.ground(stone.node.position+Vector3(0,0,0.4))
	var before=int(g.inventory.Stone)
	a.start_pickup(stone)
	a.update(0.4)
	if stone.taken or g.inventory.Stone!=before or g.reserved.get(stone.id,"")!="Player": failures.append("Pickup credited before hand contact / not reserved")
	a.cancel_pickup()
	if stone.taken or g.reserved.has(stone.id): failures.append("Cancelled pickup lost item or reservation")
	a.start_pickup(stone)
	g.mode="pause"
	a.update(10)
	if stone.taken: failures.append("Pickup advanced during pause")
	g.mode="play"
	for frame in range(19): a.update(0.05)
	if not stone.taken or g.inventory.Stone!=before+1 or not p.pickup_prop.visible: failures.append("Pickup contact did not transfer exactly one item")
	a.cancel_pickup()
	a.start_pickup(stone)
	if a.picking() or g.inventory.Stone!=before+1: failures.append("Pickup repeated after cancellation at contact")
	var npc=g.npcs[2]
	var wood=w.pickups[0]
	wood.taken=false; wood.node.visible=true
	npc.position=w.ground(wood.node.position+Vector3(0,0,0.4))
	npc.reserved_id=wood.id; g.reserved[wood.id]=npc.person
	npc.gather_point=wood.node.position
	npc.task="gathering"; npc.timer=0
	npc._process(0.4)
	if wood.taken or not npc.carry_kind.is_empty(): failures.append("NPC collected before reaching down")
	npc._process(0.5)
	if not wood.taken or npc.carry_kind!="Wood" or not npc.pickup_prop.visible or npc.task!="gathering": failures.append("NPC pickup contact / stand-up phase")
	var wood_before=int(g.inventory.Wood)
	npc.cancel()
	if g.inventory.Wood!=wood_before+1 or npc.pickup_prop.visible: failures.append("NPC interrupted pickup lost carried supply")
	# Saving cancels pending collection, and an older vehicle field must be harmless.
	stone.taken=false; stone.node.visible=true
	a.start_pickup(stone)
	g.save_game()
	if a.picking() or g.reserved.has(stone.id): failures.append("Save left pickup reservation")
	var data=JSON.parse_string(FileAccess.get_file_as_string(g.save_path))
	if data.has("buggy") or data.has("buggy_pos"): failures.append("Removed vehicle still saved")
	data.buggy=true; data.buggy_pos=[0,0]
	var file=FileAccess.open(g.save_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(data)); file.close()
	g.load_game()
	# Before construction, the same spot is a building site, never a sleeping tent.
	g.shelter.restore({})
	p.position=w.ground(w.tent_center)
	g.health=40; g.hunger=80
	a.toggle_rest()
	if a.resting: failures.append("Rest accepted inside unfinished shelter")
	p.position=w.ground(w.camp+Vector3(0,0,7))
	p.yaw=0
	a.toggle_rest()
	if not a.resting or a.rest_kind!="ground" or not is_instance_valid(w.rest_mat): failures.append("Ground leaf mat rest unavailable")
	a.update(a.REST_DURATION)
	if g.health!=40: failures.append("Healing started before settling onto the mat")
	var base=g.health
	a.update(5)
	var ground_gain=g.health-base
	if absf(ground_gain-24.0*5/a.SLEEP_SECONDS)>0.001: failures.append("Ground sleep recovery")
	g.mode="pause"; a.update(10)
	if g.health!=base+ground_gain: failures.append("Rest healed during pause")
	g.mode="play"
	a.wake()
	if not a.asleep: failures.append("Movement / H woke the player during committed sleep")
	a.update(a.SLEEP_SECONDS); a.update(a.WAKE_DURATION+0.1)
	if a.resting or a.busy(): failures.append("Wake did not release control")
	g.shelter.restore({"paid":true,"progress":1.0})
	p.position=w.ground(w.tent_center+Vector3(0,0,0.8))
	a.toggle_rest(); a.update(a.REST_DURATION)
	base=g.health; a.update(5)
	if a.rest_kind!="tent" or absf(g.health-base-48.0*5/a.SLEEP_SECONDS)>0.001: failures.append("Tent recovery should be faster")
	g.save_game(); base=g.health; g.load_game()
	if not a.asleep or absf(g.health-base)>0.001 or absf(a.sleep_elapsed-5)>0.001: failures.append("Sleeping save/load lost health or remaining sleep")
	a.update(a.SLEEP_SECONDS); a.update(a.WAKE_DURATION+0.1)
	g.hunger=0; a.toggle_rest()
	if a.resting: failures.append("Starvation bypassed with sleep")
	g.hunger=80; g.health=99.9; a.toggle_rest(); a.update(a.REST_DURATION+1)
	if g.health!=100 or not a.asleep: failures.append("Full health must not end the eight-hour sleep early")
	a.reset()
	g.health=50; g.inventory.Meal=1; g.eat()
	if g.health!=65: failures.append("Cooked meal healing")
	g.inventory.Meal=0; g.inventory.Ration=1; g.eat()
	if g.health!=73: failures.append("Ration healing")
	# Shared animation keeps the root upright and bends both knees.
	for frame in range(40): g.M.animate_human(p.body,0.85,false,false,"gather",false,0.05)
	if absf(p.body.rotation.x)>0.05 or p.body.get_node("Leg1/Knee").rotation.x>-2: failures.append("Pickup still bows whole body instead of crouching")
	for frame in range(40): g.M.animate_human(p.body,1.0,false,false,"sleep",false,0.05)
	if absf(p.body.rotation.x-PI/2)>0.05: failures.append("Rest pose is not lying down")
	# Interrupting during the seated phase must reverse the current pose, not jump flat.
	a.reset()
	p.position=w.ground(w.camp+Vector3(0,0,7))
	g.health=40; g.hunger=80
	a.toggle_rest(); a.update(a.REST_DURATION*0.48)
	for frame in range(20): p.animate_action(0.05)
	var seated_position=p.body.position
	var seated_tilt=p.body.rotation.x
	if absf(seated_tilt)>0.15 or p.body.get_node("Leg1").rotation.x<1.3: failures.append("Missing upright seated rest phase")
	a.wake(); p.animate_action(0.001)
	if p.body.position.distance_to(seated_position)>0.01 or absf(p.body.rotation.x-seated_tilt)>0.01: failures.append("Interrupted rest snapped to another pose")
	g.mode="pause"
	var wake_remaining=a.waking
	a.update(1)
	if a.waking!=wake_remaining: failures.append("Wake animation advanced while paused")
	g.mode="play"
	a.update(a.WAKE_DURATION)
	for frame in range(30): g.M.animate_human(p.body,0,false,false,"idle",false,0.05)
	if a.busy() or p.body.position.length()>0.02: failures.append("Wake left a displaced body / blocked movement")
	a.reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(g.save_path))
	print("COMFORT: contact-timed pickup, cancellation, rest gates/rates, food, save/load and poses checked")
	load("res://scripts/day_cycle_tests.gd").new().run(g,failures)
