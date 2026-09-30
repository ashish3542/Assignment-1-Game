extends RefCounted
const M=preload("res://scripts/models.gd")
const Rig=preload("res://scripts/fishing_rig.gd")
const REEL_SECONDS=3.0
var game
var rig
var reeling=false
var caught=false
var reel_time=0.0

func _init(g):
	game=g; rig=Rig.new(); game.add_child(rig); rig.setup(game,game.player.body)

func start():
	if game.actions.busy() or game.player.jump_y>0: return
	game.fishing=0.01; reeling=false; caught=false; reel_time=0
	game.player.velocity=Vector3.ZERO; game.player.moving=false
	game.wildlife.attack_time=0
	game.player.yaw=PI; game.player.body.rotation.y=PI
	game.report("Casting the line. Watch the float; press E when it dips and BITE appears.")

func reel():
	if reeling: return
	caught=game.fishing>=3 and game.fishing<=5
	reeling=true; reel_time=0
	game.report("Fish hooked! Reeling it onto shore..." if caught else "Too early. Bringing the empty line back in.")
	if caught: game.sound.play("catch")

func cancel():
	game.fishing=0; reeling=false; caught=false; reel_time=0; rig.visible=false

func update(delta: float):
	if game.mode!="play" or game.fishing<=0: return
	if reeling:
		reel_time+=delta
		var duration=REEL_SECONDS if caught else 0.9
		if reel_time>=duration:
			if caught:
				game.inventory.Fish+=1
				game.report("Fish landed and packed. Cook it at camp, then press 1 to eat.")
			cancel(); return
		M.animate_human(game.player.body,reel_time,false,false,"fish_reel",false,delta)
		rig.sample(game.fishing,true,reel_time/duration,caught)
	else:
		game.fishing+=delta
		if game.fishing>5:
			reeling=true; caught=false; reel_time=0
			game.report("The fish escaped. Reeling in the empty line; E at the cove tries again.")
		M.animate_human(game.player.body,game.fishing,false,false,"fish_cast" if game.fishing<1 else "fish_wait",false,delta)
		rig.sample(game.fishing)

func label() -> String:
	if reeling: return "Reeling in the catch..." if caught else "Retrieving empty line..."
	if game.fishing<1: return "Casting..."
	return "BITE! PRESS E NOW" if game.fishing>=3 else "Watch the float..."
