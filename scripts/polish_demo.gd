extends Node
## Explicitly staged review: uses real movement and speech scheduling, not manual play.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout

func stage(position: Vector3, yaw: float):
	game.player.position=game.world.ground(position)
	game.player.velocity=Vector3.ZERO
	game.player.yaw=yaw
	game.player.body.rotation.y=yaw
	game.player.update_camera(1)

func move(direction: Vector3, speed: float, seconds: float):
	var elapsed=0.0
	while elapsed<seconds:
		var delta=get_physics_process_delta_time()
		game.player.move_horizontal(direction,speed,delta)
		game.player.body.rotation.y=atan2(-direction.x,-direction.z)
		game.M.animate_human(game.player.body,elapsed,game.player.moving,false,"escape" if game.world.in_tent(game.player.position) else "idle",false,delta)
		game.player.update_camera(delta)
		elapsed+=delta
		await get_tree().physics_frame
	game.player.velocity=Vector3.ZERO
	game.player.moving=false

func run():
	game.autonomy_enabled=false
	# This staged collision check needs a completed shelter; the survival demo builds it.
	game.shelter.restore({"paid":true,"progress":1.0})
	game.begin_play()
	game.demo_active=true
	for npc in game.npcs:
		npc.cancel()
		npc.greeting_cooldown=999
	game.sound.clear_speech()
	game.toast_time=0
	game.demo_caption="AUTOMATED CHECK / sprinting into the tent stops at its wall"
	stage(game.world.tent_center+Vector3(4,0,0),PI/2)
	await move(Vector3.LEFT,8,3)
	await wait(2)
	game.demo_caption="02 / The open entrance is still usable"
	stage(game.world.tent_center+Vector3(0,0,4),0)
	await move(Vector3.FORWARD,2,1.7)
	await wait(1)
	await move(Vector3.BACK,2,1.7)
	game.demo_caption="03 / Three speech requests: one voice, subtitle and speaker at a time"
	stage(game.world.camp+Vector3(0,0,1),0)
	game.npcs[0].say("Finn, I need the aircraft radio module. Can you bring it?")
	game.npcs[1].say("Found the module. Bringing it to Maya.")
	game.npcs[2].say("Once we have fire and food, we can call for rescue.")
	while not game.sound.active_line.is_empty() or not game.sound.speech_queue.is_empty(): await wait(0.2)
	game.demo_caption="04 / Direct conversations get a closer camera and clear the chatter"
	game.open_dialogue(game.npcs[0])
	game.choose_dialogue(game.npcs[0],"story")
	await wait(9)
	game.sound.stop_all()
	await wait(0.15)
	get_tree().quit()
