extends Node
## Staged review of the complete transitions, including interrupted settling.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout
func shot(target: Vector3, offset: Vector3):
	game.player.camera.position=target+offset
	game.player.camera.look_at(target)
func run():
	game.demo_active=true
	game.autonomy_enabled=false
	game.begin_play()
	game.sound.clear_speech()
	for npc in game.npcs: npc.cancel(); npc.greeting_cooldown=999
	game.health=40
	game.hunger=80
	var p=game.player
	var w=game.world
	p.position=w.ground(w.camp+Vector3(0,0,7))
	p.yaw=0
	p.body.rotation.y=0
	shot(p.position+Vector3(0,0.6,0.65),Vector3(3.5,1.5,2.8))
	game.demo_caption="STAGED REVIEW / lower hips, sit, support with hands, settle"
	await wait(1)
	game.actions.toggle_rest()
	while game.actions.busy(): await wait(0.1)
	await wait(1)
	game.demo_caption="INTERRUPTION / change your mind halfway down"
	game.actions.toggle_rest()
	await wait(1.8)
	game.actions.wake()
	await wait(2.5)
	game.shelter.restore({"paid":true,"progress":1.0})
	p.position=w.ground(w.tent_center+Vector3(0,0,0.8))
	game.demo_caption="STAGED TENT / the same gradual movement onto raised bedding"
	game.actions.toggle_rest()
	shot(w.tent_center+Vector3(0,0.65,0),Vector3(0.4,0.5,4.7))
	while game.actions.busy(): await wait(0.1)
	game.sound.stop_all()
	await wait(0.2)
	get_tree().quit()
