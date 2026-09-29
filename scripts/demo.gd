extends Node
## Deterministic, labeled walkthrough of actual gameplay. Never used in normal play.
var game
var failed=false

func _ready(): call_deferred("run")

func wait(seconds: float): await get_tree().create_timer(seconds).timeout

func walk(destination: Vector3):
	game.demo_focus=null
	var path=game.world.path_to(game.player.position,destination)
	if path.is_empty() and game.player.position.distance_to(destination)>1:
		fail("No route to walkthrough destination")
		return
	var travel_time=0.0
	for point in path:
		while game.player.position.distance_to(point)>0.3:
			var delta=get_physics_process_delta_time()
			travel_time+=delta
			if travel_time>120:
				fail("Walkthrough movement timed out")
				return
			var diff=point-game.player.position
			diff.y=0
			game.player.position=game.world.ground(game.player.position+diff.normalized()*minf(diff.length(),6*delta))
			game.player.body.rotation.y=atan2(-diff.x,-diff.z)
			game.player.yaw=lerp_angle(game.player.yaw,game.player.body.rotation.y,delta*2)
			game.player.update_camera(delta)
			game.M.animate_human(game.player.body,Time.get_ticks_msec()/1000.0,true)
			await get_tree().physics_frame
	game.player.moving=false

func fail(message: String):
	failed=true
	push_error(message)
	game.sound.stop_all()
	get_tree().quit(1)

func run():
	game.autonomy_enabled=false
	await wait(2)
	game.start_intro()
	while game.mode=="intro": await wait(0.2)
	game.demo_active=true
	game.autonomy_enabled=true
	game.demo_caption="AUTOMATED WALKTHROUGH / crew salvage materials and build shelter"
	var shelter_wait=0.0
	while not game.shelter.complete() and shelter_wait<360:
		game.demo_focus=game.npcs[int(shelter_wait/16)%3]
		await wait(0.25)
		shelter_wait+=0.25
	if not game.shelter.complete():
		push_error("Walkthrough: shelter did not finish")
		get_tree().quit(1)
		return
	game.autonomy_enabled=false
	for npc in game.npcs: npc.cancel()
	game.demo_caption="AUTOMATED WALKTHROUGH / actual game systems"
	await wait(2)
	game.demo_caption="01 / Gather supplies on foot"
	for p in game.world.pickups:
		if game.inventory.Wood>=4: break
		if p.kind!="Wood" or p.taken: continue
		await walk(p.node.position)
		game.interaction={"type":"pickup","item":p}
		game.interact()
		await wait(2.5)
		await wait(0.4)
	for p in game.world.pickups:
		if game.inventory.Stone>=3: break
		if p.kind!="Stone" or p.taken: continue
		await walk(p.node.position)
		game.interaction={"type":"pickup","item":p}
		game.interact()
		await wait(2.5)
		await wait(0.4)
	await walk(game.world.camp+Vector3(0,0,2))
	game.use_fire()
	if not game.fire_lit: fail("Walkthrough did not build campfire"); return
	game.demo_caption="02 / Build a fire, catch a fish, cook and eat"
	await wait(2)
	await walk(game.world.fish_spot)
	game.interaction={"type":"fish"}
	game.interact()
	await wait(3.5)
	game.interact()
	await wait(1)
	await walk(game.world.camp+Vector3(0,0,2))
	game.use_fire()
	game.eat()
	if not game.ate_meal: fail("Walkthrough did not cook and eat a fish"); return
	await wait(2)
	game.demo_caption="03 / Talk to Maya and direct her to repair the radio"
	await walk(game.npcs[0].position+Vector3(0,0,2))
	game.open_dialogue(game.npcs[0])
	game.choose_dialogue(game.npcs[0],"story")
	await wait(7)
	game.choose_dialogue(game.npcs[0],"repair")
	game.demo_caption="04 / Maya walks to the ridge and asks Finn for help"
	game.demo_focus=game.npcs[0]
	var elapsed=0.0
	while not game.module_carried and elapsed<90:
		if game.npcs[0].task=="waiting_parts":
			game.demo_focus=game.npcs[1]
			game.demo_caption="05 / Finn responds and retrieves the aircraft module"
		await wait(0.2)
		elapsed+=0.2
	game.demo_caption="06 / NPC-to-NPC delivery: Finn brings Maya the module"
	while not game.module_installed and elapsed<130:
		await wait(0.2)
		elapsed+=0.2
	game.demo_focus=game.npcs[0]
	game.demo_caption="07 / Maya acknowledges the handoff and completes repairs"
	while not game.repaired and elapsed<160:
		await wait(0.2)
		elapsed+=0.2
	await wait(3)
	if not game.repaired or not game.module_installed: fail("Walkthrough did not complete NPC radio handoff and repairs"); return
	game.demo_caption="08 / With camp secure, send the rescue signal"
	await walk(game.world.tower+Vector3(0,0,3))
	game.activate_beacon()
	if not game.won or failed: fail("Walkthrough failed to reach rescue ending"); return
	await wait(9)
	print("SUBMISSION WALKTHROUGH PASSED: shelter, fire, fishing, eating, dialogue, direction, NPC module handoff, repairs and rescue")
	game.sound.stop_all()
	game.fire_audio.stop()
	await wait(0.2)
	get_tree().quit()
