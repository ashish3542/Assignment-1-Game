extends Node3D
const Models=preload("res://scripts/animal_models.gd")
var game
var identity=0
var species="Deer"
var home=Vector3.ZERO
var target=Vector3.ZERO
var hp=60.0
var max_hp=60.0
var meat=2
var speed=4.0
var aggressive=false
var body: Node3D
var state="Grazing"
var dead=false
var harvested=false
var pickup: Dictionary={}
var think=0.0
var aggro=0.0
var bite=0.0
var clock=0.0
var rng=RandomNumberGenerator.new()

func setup(g, id: int, kind: String, spawn: Vector3):
	game=g; identity=id; species=kind; home=spawn; position=spawn; target=spawn
	rng.seed=900+id
	var stats={"Deer":[60,3,5.5,false],"Boar":[90,3,4.5,true],"Goat":[60,2,4.8,false],"Rabbit":[25,1,6.5,false],"Junglefowl":[25,1,4.2,false],"Monitor":[50,2,3.5,true],"Crocodile":[120,4,3.2,true]}[kind]
	max_hp=stats[0]; hp=max_hp; meat=stats[1]; speed=stats[2]; aggressive=stats[3]
	body=Models.build(self,species)

func update(delta: float):
	clock+=delta
	if dead:
		harvested=pickup.get("taken",harvested)
		visible=not harvested and position.distance_to(game.player.position)<140
		Models.animate(body,clock,false,false,true)
		return
	var distance=position.distance_to(game.player.position)
	visible=distance<140
	if distance>95: return
	bite=maxf(0,bite-delta); aggro=maxf(0,aggro-delta); think-=delta
	var safe=game.player.position.distance_to(game.world.camp)<22 or game.actions.busy()
	if think<=0:
		think=rng.randf_range(1.5,3.5)
		var threat=distance<(7 if aggressive else 10) or aggro>0
		if threat and not safe:
			if aggressive and (distance<5 or aggro>0):
				state="Defending territory"; target=game.player.position; aggro=5
			else:
				state="Fleeing"
				var away=position-game.player.position; away.y=0
				target=game.world.ground(position+away.normalized()*14)
		elif rng.randf()<0.4: state="Grazing"; target=position
		else:
			state="Roaming"
			var angle=rng.randf()*TAU
			target=game.world.ground(home+Vector3(cos(angle),0,sin(angle))*rng.randf_range(2,14))
	if state=="Defending territory":
		if safe or distance>24: state="Roaming"; target=home; aggro=0
		else:
			target=game.player.position
			if distance<1.8 and bite<=0 and game.world.clear_segment(position,game.player.position,0.15):
				game.health=maxf(10,game.health-(14 if species=="Crocodile" else 8))
				game.report(species+" struck you. Back away or defend yourself!")
				game.sound.play("step"); bite=1.4
	var direction=target-position; direction.y=0
	var moving=direction.length()>0.4
	if moving:
		var previous=position
		var pace=speed if state in ["Fleeing","Defending territory"] else speed*0.3
		position=game.world.move_character(position,direction.normalized()*minf(direction.length(),pace*delta),0.30)
		rotation.y=lerp_angle(rotation.y,atan2(-direction.x,-direction.z),minf(1,delta*7))
		if position.distance_to(previous)<0.005:
			var sideways=direction.normalized().rotated(Vector3.UP,PI/3)
			position=game.world.move_character(position,sideways*pace*delta,0.30)
			if position.distance_to(previous)<0.005: think=0; state="Roaming"; target=home
	Models.animate(body,clock,moving,state=="Grazing",false)

func damage(amount: float, announce: bool=true):
	if dead: return
	hp=maxf(0,hp-amount)
	aggro=8; think=0
	if hp<=0:
		dead=true; state="Ready to collect"
		pickup={"id":20000+identity,"kind":"Meat","quantity":meat,"node":self,"taken":false,"source":"hunt"}
		game.world.pickups.append(pickup)
		Models.animate(body,clock,false,false,true)
		if announce: game.report(species+" down. E nearby collects %d raw meat; cook it at camp." % meat)
	elif announce: game.report(species+" / "+str(int(hp))+" health remaining")

func snapshot() -> Dictionary:
	return {"id":identity,"hp":hp,"position":[position.x,position.z],"harvested":pickup.get("taken",harvested)}

func restore(data: Dictionary):
	hp=max_hp; dead=false; harvested=false; pickup={}; state="Grazing"; aggro=0; bite=0; think=0
	position=home; target=home; body.rotation=Vector3.ZERO; body.position=Vector3.ZERO
	var saved=data.get("position",[home.x,home.z])
	var point=Vector3(float(saved[0]),0,float(saved[1]))
	if game.world.walkable(point,0.3): position=game.world.ground(point)
	var restored_hp=clampf(float(data.get("hp",max_hp)),0,max_hp)
	if restored_hp<=0:
		damage(max_hp,false)
		harvested=bool(data.get("harvested",false)); pickup.taken=harvested
	else: hp=restored_hp
	visible=not harvested and position.distance_to(game.player.position)<140
