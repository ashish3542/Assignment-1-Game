extends Node
## Explicit staged camera positions, using real fishing timing and inventory transfer.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout
func run():
	game.demo_active=true; game.autonomy_enabled=false; game.begin_play()
	game.sound.clear_speech(); game.day_cycle.set_hours(10)
	for npc in game.npcs: npc.cancel(); npc.greeting_cooldown=999
	game.player.position=game.world.ground(game.world.fish_spot)
	game.player.camera.position=game.player.position+Vector3(4,3,-5)
	game.player.camera.look_at(game.player.position+Vector3(0,1,5))
	game.demo_caption="UPDATED FISHING / staged close camera; real cast, bite and landing"
	game.interaction={"type":"fish"}; game.interact()
	await wait(3.4); game.interact()
	game.player.camera.position=game.player.position+Vector3(5,2.5,0)
	game.player.camera.look_at(game.player.position+Vector3(0,1,2))
	while game.fishing>0: await wait(0.1)
	game.M.animate_human(game.player.body,0,false,false,"idle",false,0.4)
	await wait(2)
	game.demo_caption="EMPTY LINE / pressing too early does not add a fish"
	game.interact(); await wait(0.6); game.interact()
	while game.fishing>0: await wait(0.1)
	game.M.animate_human(game.player.body,0,false,false,"idle",false,0.4)
	await wait(2)
	var finn=game.npcs[1]
	finn.position=game.world.ground(game.world.fish_spot+Vector3(1,0,0))
	finn.task="fish"; finn.timer=0; finn.body.rotation.y=PI
	game.player.position=game.world.ground(game.world.fish_spot+Vector3(-3,0,-2))
	game.player.camera.position=finn.position+Vector3(4,3,-5)
	game.player.camera.look_at(finn.position+Vector3(0,1,4))
	game.demo_caption="FINN / casts, watches, reels in a visible fish, then carries it to Rowan"
	await wait(14)
	game.sound.stop_all(); game.fire_audio.stop()
	await wait(0.2)
	get_tree().quit()
