extends RefCounted
func run(g, failures: Array):
	var w=g.world
	if w.shelter_frame.visible or w.shelter_cloth.visible or w.camp_furniture.visible or w.fire_base.visible or w.signal_station.visible:
		failures.append("New island already has constructed camp structures")
	if w.forest_count<100: failures.append("Forest density missing")
	if w.plane.scale.x<1.5 or not is_instance_valid(w.shipwreck): failures.append("Larger plane / shipwreck missing")
	if not w.walkable(w.tent_center+Vector3(1.2,0,0)): failures.append("Invisible tent collision before construction")
	for pickup in w.pickups:
		var route=w.path_to(w.camp,pickup.node.position)
		if route.is_empty() or route[route.size()-1].distance_to(pickup.node.position)>0.8:
			failures.append("Unreachable salvage / pickup "+str(pickup.id))
	w.set_crash_visible(false)
	for pickup in w.pickups:
		if pickup.source=="plane" and pickup.node.visible: failures.append("Plane salvage visible before crash")
		if pickup.source=="ship" and not pickup.node.visible: failures.append("Old ship salvage hidden with plane")
	w.set_crash_visible(true)
	# Real material gate: insufficient supplies cannot create a frame.
	g.shelter.assign(g.npcs[0])
	if g.shelter.paid or w.shelter_frame.visible: failures.append("Shelter built without supplies")
	for npc in g.npcs: npc.cancel()
	g.inventory.Wood=6; g.inventory.Cloth=2; g.inventory.Rope=2
	g.shelter.assign(g.npcs[0])
	g.shelter.assign(g.npcs[1])
	if not g.shelter.paid or g.inventory.Wood!=0 or g.inventory.Cloth!=0 or g.inventory.Rope!=0:
		failures.append("Shelter cost not charged exactly once")
	for npc in g.npcs: npc.command("wait")
	g.npcs[0].position=g.shelter.work_position("Maya")
	g.npcs[0].task="building"
	var initial=g.shelter.progress
	g.shelter.update(10)
	if g.shelter.progress!=initial: failures.append("One survivor built the shelter alone")
	g.player.position=w.ground(w.tent_center+Vector3(0,0,3.5))
	g.shelter.help()
	g.shelter.update(2)
	if g.shelter.progress<=initial: failures.append("Player assistance did not count as a second builder")
	g.shelter.player_help=0
	initial=g.shelter.progress
	g.mode="pause"
	g.npcs[1].position=g.shelter.work_position("Finn")
	g.npcs[1].task="building"
	g.shelter.update(10)
	if g.shelter.progress!=initial: failures.append("Construction advanced while paused")
	g.mode="play"
	g.shelter.update(2)
	if g.shelter.progress<=initial: failures.append("Two nearby builders did not cooperate")
	var partial=g.shelter.progress
	g.save_game()
	g.shelter.restore({})
	g.load_game()
	if not g.shelter.paid or absf(g.shelter.progress-partial)>0.0001 or g.inventory.Wood!=0:
		failures.append("Partial shelter save lost progress or duplicated materials")
	# Restart the actual resource-to-build loop on an empty beach.
	g.shelter.restore({})
	for kind in g.inventory: g.inventory[kind]=0
	for pickup in w.pickups: pickup.taken=false; pickup.node.visible=true
	for i in range(g.npcs.size()):
		var npc=g.npcs[i]
		npc.cancel()
		npc.routine_enabled=true
		npc.position=w.ground(w.camp+Vector3(-2+i*3,0,-2))
		npc.greeting_cooldown=999
	g.reserved.clear()
	g.autonomy_enabled=true
	var elapsed=0.0
	while elapsed<650 and not g.shelter.complete():
		for npc in g.npcs: npc._process(0.05)
		g.shelter.update(0.05)
		elapsed+=0.05
	if not g.shelter.complete():
		failures.append("Autonomous forest / plane / ship supply loop failed to build shelter")
		print("SHELTER DEBUG ",g.inventory," ",g.shelter.progress)
		for npc in g.npcs: print(npc.person," ",npc.task," ",npc.position," ",npc.state)
	else: print("SURVIVAL: crew gathered and built shelter in ",snappedf(elapsed,0.1)," simulated seconds")
	if not w.camp_furniture.visible or not w.shelter_cloth.visible: failures.append("Completed camp visuals missing")
	if w.walkable(w.tent_center+Vector3(1.2,0,0)): failures.append("Finished tent has no collision")
	var cloth=0
	var rope=0
	for pickup in w.pickups:
		if pickup.taken and pickup.kind=="Cloth" and pickup.source=="plane": cloth+=1
		if pickup.taken and pickup.kind=="Rope" and pickup.source=="ship": rope+=1
	if cloth<2 or rope<2: failures.append("Shelter bypassed plane cloth or ship rope")
	g.save_game()
	g.shelter.restore({})
	g.load_game()
	if not g.shelter.complete() or not w.camp_furniture.visible: failures.append("Completed shelter save lost")
	var legacy=JSON.parse_string(FileAccess.get_file_as_string(g.save_path))
	legacy.version=1
	legacy.erase("shelter")
	var legacy_file=FileAccess.open(g.save_path,FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify(legacy))
	legacy_file.close()
	g.shelter.restore({})
	g.load_game()
	if not g.shelter.complete(): failures.append("Version-1 save did not preserve established camp")
	g.autonomy_enabled=false
	for npc in g.npcs: npc.cancel(); npc.routine_enabled=true
	for kind in g.inventory: g.inventory[kind]=0
	for pickup in w.pickups: pickup.taken=false; pickup.node.visible=true
	g.reserved.clear()
	# The remaining legacy checks deliberately start with the new shelter completed.
