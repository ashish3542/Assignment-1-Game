extends Node
## Automated review of actual gathering and construction; no inventory is injected.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout

static func shot(g, view: String):
	g.demo_focus=null
	var target=g.world.camp+Vector3(-2,1,-2)
	var offset=Vector3(14,8,16)
	match view:
		"plane": target=g.world.plane.position; offset=Vector3(23,10,22)
		"ship": target=g.world.ship_spot+Vector3(6,1,0); offset=Vector3(-18,9,16)
		"forest": target=g.world.ground(Vector3(7,0,-6))+Vector3(0,4,0); offset=Vector3(16,9,20)
		"build": target=g.world.tent_center+Vector3(0,1,0); offset=Vector3(8,5,10)
	g.player.camera.position=target+offset
	g.player.camera.look_at(target)
	g.player.camera.current=true

func run():
	game.autonomy_enabled=false
	game.demo_active=true
	game.begin_play()
	game.sound.clear_speech()
	game.player.position=game.world.ground(game.world.camp+Vector3(0,0,7))
	game.demo_caption="AUTOMATED REVIEW / an empty beach before the survivors build"
	shot(game,"empty")
	await wait(4)
	game.demo_caption="01 / A larger aircraft: recover fabric, rations and spare parts"
	shot(game,"plane")
	await wait(5)
	game.demo_caption="02 / Tidebreak shipwreck: rope, timber and spare parts"
	shot(game,"ship")
	await wait(5)
	game.demo_caption="03 / Dense inland forest; clear beach for the new camp"
	shot(game,"forest")
	await wait(4)
	game.autonomy_enabled=true
	var elapsed=0.0
	while not game.shelter.complete() and elapsed<360:
		if game.shelter.paid:
			game.demo_caption="05 / The crew raise a frame, tie on the tarp and finish their shelter"
			shot(game,"build")
		else:
			game.demo_caption="04 / Real supply trips: Maya, Finn and Rowan share what they recover"
			game.demo_focus=game.npcs[int(elapsed/16)%3]
		await wait(0.25)
		elapsed+=0.25
	if not game.shelter.complete():
		push_error("Survival preview: shelter did not complete in time")
		game.sound.stop_all()
		get_tree().quit(1)
		return
	game.demo_caption="06 / A finished camp, built from recovered supplies; next, fire and food"
	shot(game,"empty")
	await wait(8)
	game.sound.stop_all()
	await wait(0.15)
	get_tree().quit()
