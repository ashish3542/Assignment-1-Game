extends RefCounted
const Animal=preload("res://scripts/animal.gd")
var game
var animals: Array=[]
var tick=0.0
var attack_time=0.0
var attack_hit=false
var enabled=true

func _init(g):
	game=g
	var species=["Deer","Boar","Goat","Rabbit","Junglefowl","Monitor","Crocodile"]
	var homes=[Vector3(-18,0,-105),Vector3(28,0,-86),Vector3(70,0,-145),Vector3(-40,0,-86),Vector3(12,0,-64),Vector3(-64,0,-135),Vector3(-86,0,-158)]
	for kind in range(species.size()):
		for i in range(6):
			var point=homes[kind]+Vector3(cos(i*TAU/6)*9,0,sin(i*TAU/6)*9)
			var initial=point
			for attempt in range(150):
				if game.world.walkable(point,0.6): break
				point=initial+Vector3(cos(attempt*2.4),0,sin(attempt*2.4))*(0.8+attempt*0.15)
			var animal=Animal.new()
			game.world.add_child(animal)
			animal.setup(game,animals.size(),species[kind],game.world.ground(point))
			animal.visible=false
			animals.append(animal)

func update(delta: float):
	if not enabled or game.mode!="play": return
	if game.actions.busy(): attack_time=0
	if attack_time>0:
		attack_time+=delta
		if attack_time>=0.20 and not attack_hit:
			attack_hit=true
			var victim=target_in_reach()
			if victim: victim.damage(40); game.sound.play("step")
		if attack_time>=0.75: attack_time=0
	tick+=delta
	if tick>=0.083:
		for animal in animals: animal.update(minf(tick,0.15))
		tick=0

func attack():
	if game.mode!="play" or game.actions.busy() or game.fishing>0 or attack_time>0: return
	if not game.spear:
		game.report("Craft a hunting spear with R: 2 wood + 1 scrap."); return
	attack_time=0.001; attack_hit=false
	game.shelter.player_help=0
	game.player.body.rotation.y=game.player.yaw

func target_in_reach():
	var best=null
	var nearest=2.9
	var forward=Vector3(-sin(game.player.yaw),0,-cos(game.player.yaw))
	for animal in animals:
		if animal.dead: continue
		var offset=animal.position-game.player.position; offset.y=0
		if offset.length()<nearest and (offset.length()<0.5 or forward.dot(offset.normalized())>0.65) and game.world.clear_segment(game.player.position,animal.position,0.1):
			nearest=offset.length(); best=animal
	return best

func projectile_hit(from: Vector3, to: Vector3) -> bool:
	var best=null
	var nearest=INF
	for animal in animals:
		if animal.dead: continue
		var center=animal.position+Vector3(0,0.55,0)
		var point=Geometry3D.get_closest_point_to_segment(center,from,to)
		if point.distance_to(center)<0.7 and from.distance_to(point)<nearest and game.world.clear_segment(from,point,0.1):
			best=animal; nearest=from.distance_to(point)
	if best: best.damage(15); return true
	return false

func snapshot() -> Array:
	var result=[]
	for animal in animals: result.append(animal.snapshot())
	return result

func restore(data: Array):
	attack_time=0
	for i in range(game.world.pickups.size()-1,-1,-1):
		if game.world.pickups[i].get("source","")=="hunt": game.world.pickups.remove_at(i)
	var by_id={}
	for entry in data: by_id[int(entry.id)]=entry
	for animal in animals: animal.restore(by_id.get(animal.identity,{}))
