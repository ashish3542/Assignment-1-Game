extends Node
## Explicitly staged starting clocks; each sleep uses the real eight-hour sequence.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout
func run():
	game.demo_active=true
	game.autonomy_enabled=false
	game.begin_play()
	game.sound.clear_speech()
	for npc in game.npcs: npc.cancel(); npc.greeting_cooldown=999
	for start in [8.0,16.0,22.0]:
		game.actions.reset()
		game.day_cycle.set_hours(start)
		game.health=100
		game.hunger=80
		var p=game.player
		p.position=game.world.ground(game.world.camp+Vector3(0,0,7))
		p.yaw=0; p.body.rotation.y=0
		p.camera.current=true
		p.camera.position=p.position+Vector3(3.5,2.2,3.5)
		p.camera.look_at(p.position+Vector3(0,0.6,0.7))
		game.demo_caption="STAGED CLOCK / %02d:00 start, eight-hour sleep at full health" % int(start)
		await wait(1)
		game.actions.toggle_rest()
		while game.actions.busy(): await wait(0.1)
		game.demo_caption="AWAKE / "+game.day_cycle.label()+" / "+game.day_cycle.period()
		await wait(2)
	game.sound.stop_all()
	await wait(0.2)
	get_tree().quit()
