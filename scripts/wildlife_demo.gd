extends Node
## Staged encounters use the actual hunt, harvest and cooking systems.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout
func shot(target: Vector3, offset: Vector3):
	game.player.camera.position=target+offset
	game.player.camera.look_at(target)
func run():
	game.demo_active=true; game.autonomy_enabled=false
	game.begin_play(); game.sound.clear_speech()
	game.day_cycle.set_hours(10)
	for npc in game.npcs: npc.cancel(); npc.greeting_cooldown=999
	game.demo_caption="EXPANDED ISLAND / northern meadows, woodland, ridge and marsh"
	game.player.position=game.world.ground(Vector3(0,0,-115))
	shot(Vector3(0,5,-115),Vector3(75,95,110))
	await wait(4)
	for index in [0,6,12,18,24,30,36]:
		var animal=game.wildlife.animals[index]
		game.player.position=game.world.ground(animal.home+Vector3(0,0,16))
		game.demo_caption="WILDLIFE / "+animal.species+" habitat / autonomous roaming"
		shot(animal.position+Vector3(0,0.6,0),Vector3(4.5,2.2,5.5))
		await wait(3)
	# Controlled location keeps this review focused on collection rather than chasing.
	game.wildlife.enabled=false
	var rabbit=game.wildlife.animals[18]
	rabbit.restore({})
	rabbit.position=game.world.ground(game.world.camp+Vector3(0,0,7))
	rabbit.visible=true
	game.player.position=game.world.ground(rabbit.position+Vector3(0,0,2))
	game.player.yaw=0; game.player.body.rotation.y=0
	game.inventory.Wood=2; game.inventory.Scrap=1
	game.craft_spear()
	game.demo_caption="STAGED HUNT / crafted spear; impact occurs during the thrust"
	shot(rabbit.position+Vector3(0,0.65,0),Vector3(4,2,4))
	game.wildlife.attack()
	for i in range(24):
		game.wildlife.enabled=true
		game.wildlife.update(1.0/24)
		game.wildlife.enabled=false
		game.M.animate_human(game.player.body,game.wildlife.attack_time,false,false,"hunt",false,1.0/24)
		await get_tree().process_frame
	await wait(1)
	game.player.position=game.world.ground(rabbit.position+Vector3(0,0,0.4))
	game.demo_caption="HARVEST / collect meat once, with the existing crouch and reach"
	game.actions.start_pickup(rabbit.pickup)
	while game.actions.busy(): await wait(0.1)
	game.player.position=game.world.ground(game.world.camp+Vector3(0,0,2))
	game.demo_caption="STAGED CAMP / build fire, cook raw meat, then eat the roast"
	game.inventory.Wood=4; game.inventory.Stone=3; game.inventory.Fish=0
	game.use_fire(); game.use_fire()
	game.health=50; game.hunger=35; game.inventory.Meal=0
	game.eat()
	shot(game.world.camp+Vector3(0,1,0),Vector3(6,3,7))
	await wait(4)
	game.sound.stop_all(); game.fire_audio.stop()
	await wait(0.2)
	get_tree().quit()
