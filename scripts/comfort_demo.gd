extends Node
## Labeled fixtures for visual review, not a student playtest.
var game
func _ready(): call_deferred("run")
func wait(seconds: float): await get_tree().create_timer(seconds).timeout
func shot(target: Vector3, offset: Vector3):
	game.player.camera.position=target+offset
	game.player.camera.look_at(target)
	game.player.camera.current=true

func run():
	game.demo_active=true
	game.autonomy_enabled=false
	game.begin_play()
	game.sound.clear_speech()
	for npc in game.npcs: npc.cancel(); npc.greeting_cooldown=999
	var p=game.player
	var w=game.world
	var item=w.pickups[12]
	p.position=w.ground(item.node.position+Vector3(0,0,0.4))
	game.demo_caption="AUTOMATED REVIEW / crouch, reach, collect, then stand"
	shot(p.position+Vector3(0,0.65,-0.1),Vector3(2.7,1.0,-3.3))
	await wait(2)
	game.actions.start_pickup(item)
	await wait(2.5)
	var npc=game.npcs[2]
	var wood=w.pickups[0]
	npc.position=w.ground(wood.node.position+Vector3(0,0,0.4))
	npc.gather("Wood")
	game.demo_caption="NPC / the same crouch, followed by carrying supplies to camp"
	shot(npc.position+Vector3(0,0.65,0),Vector3(3,1.2,-3.4))
	await wait(4)
	npc.cancel()
	game.health=40
	game.hunger=80
	p.position=w.ground(w.camp+Vector3(0,0,7))
	p.yaw=0
	game.demo_caption="STAGED HEALTH 40 / H makes a leaf mat before a tent exists"
	shot(p.position+Vector3(0,0.55,0.7),Vector3(3.4,2.8,3.3))
	game.actions.toggle_rest()
	await wait(9)
	game.actions.wake()
	await wait(game.actions.WAKE_DURATION+0.2)
	game.inventory.Ration=1
	game.inventory.Meal=0
	game.eat()
	game.demo_caption="FOOD / one ration restores 8 health; a cooked meal restores 15"
	game.M.animate_human(p.body,0,false,false,"idle",false,1)
	await wait(3)
	game.shelter.restore({"paid":true,"progress":1.0})
	p.position=w.ground(w.tent_center+Vector3(0,0,0.8))
	game.demo_caption="STAGED FINISHED TENT / H sleeps inside; faster health recovery"
	game.actions.toggle_rest()
	shot(w.tent_center+Vector3(0,0.6,0),Vector3(0,0.6,5))
	await wait(9)
	game.actions.wake()
	await wait(game.actions.WAKE_DURATION+0.2)
	game.demo_caption="H or movement wakes you / the island has no buggy"
	await wait(2)
	game.sound.stop_all()
	await wait(0.2)
	get_tree().quit()
