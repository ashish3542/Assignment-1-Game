extends Node
## Recorded review of the new cinematic and actual autonomous crew behavior.
var game

func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout

func walk(destination: Vector3):
	game.demo_focus=null
	var route=game.world.path_to(game.player.position,destination)
	for point in route:
		while game.player.position.distance_to(point)>0.3:
			var delta=get_physics_process_delta_time()
			var diff=point-game.player.position
			diff.y=0
			game.player.position=game.world.ground(game.player.position+diff.normalized()*minf(diff.length(),5.5*delta))
			game.player.body.rotation.y=atan2(-diff.x,-diff.z)
			game.player.yaw=lerp_angle(game.player.yaw,game.player.body.rotation.y,delta*2)
			game.player.update_camera(delta)
			game.M.animate_human(game.player.body,Time.get_ticks_msec()/1000.0,true)
			await get_tree().physics_frame
	game.M.animate_human(game.player.body,0,false)

func run():
	await wait(2)
	game.start_intro()
	while game.mode=="intro": await wait(0.2)
	game.demo_active=true
	game.demo_caption="AUTOMATED REVIEW / the crew choose their own jobs"
	game.demo_focus=game.npcs[2]
	await wait(8)
	game.demo_caption="01 / Approach Rowan: a greeting without pressing E"
	await walk(game.npcs[2].position)
	await walk(game.npcs[2].position)
	game.demo_focus=game.npcs[2]
	await wait(5)
	game.demo_caption="02 / Rowan gathers wood; Maya and Finn work on the radio"
	# Use real pickups and the real fire gate, while the crew continue their routines.
	for i in range(12,15):
		var p=game.world.pickups[i]
		await walk(p.node.position)
		game.interaction={"type":"pickup","item":p}
		game.interact()
	await walk(game.world.camp+Vector3(0,0,2))
	var elapsed=0.0
	while game.inventory.Wood<4 and elapsed<100:
		game.demo_focus=game.npcs[2]
		await wait(0.5)
		elapsed+=0.5
	game.use_fire()
	game.demo_caption="03 / Finn supplies food; Rowan cooks without a command"
	elapsed=0
	while game.inventory.Meal<1 and elapsed<130:
		game.demo_focus=game.npcs[2] if game.npcs[2].task=="cook" else game.npcs[1]
		await wait(0.5)
		elapsed+=0.5
	game.eat()
	game.demo_caption="04 / You can still interrupt a routine with a direct command"
	await walk(game.npcs[2].position+Vector3(0,0,2))
	game.open_dialogue(game.npcs[2])
	await wait(3)
	game.choose_dialogue(game.npcs[2],"wait")
	await wait(4)
	game.open_dialogue(game.npcs[2])
	await wait(2)
	game.choose_dialogue(game.npcs[2],"routine")
	game.demo_caption="05 / Duties resume; camp, food and radio progress are real"
	await wait(6)
	game.sound.stop_all()
	game.fire_audio.stop()
	await wait(0.2)
	get_tree().quit()
