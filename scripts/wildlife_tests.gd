extends RefCounted
func run(g, failures: Array):
	g.mode="play"; g.actions.reset(); g.wildlife.enabled=false
	var w=g.world
	var animals=g.wildlife.animals
	if animals.size()!=42: failures.append("Wildlife population")
	var kinds={}
	for animal in animals:
		kinds[animal.species]=true
		if not w.walkable(animal.home,0.3): failures.append("Animal spawned inside obstacle / ocean")
	if kinds.size()!=7: failures.append("Wildlife species variety")
	if not w.walkable(Vector3(0,0,-220)) or w.path_to(w.camp,Vector3(0,0,-210)).is_empty(): failures.append("Expanded northern land / traversable connection")
	# Controlled encounter on clear original beach, using real attack timing and pickup actions.
	var victim=animals[18]
	victim.restore({})
	victim.position=w.ground(w.camp+Vector3(0,0,7))
	g.player.position=w.ground(victim.position+Vector3(0,0,2))
	g.player.yaw=0
	g.spear=false; g.wildlife.attack()
	if g.wildlife.attack_time>0: failures.append("Hunting without crafted spear")
	g.spear=true; g.add_spear_model()
	g.wildlife.enabled=true
	g.wildlife.attack(); g.wildlife.attack()
	g.mode="pause"
	var paused_attack=g.wildlife.attack_time
	g.wildlife.update(2)
	if g.wildlife.attack_time!=paused_attack: failures.append("Hunting advances during pause")
	g.mode="play"
	g.wildlife.update(0.1)
	if victim.dead: failures.append("Spear damage before thrust contact")
	g.wildlife.update(0.11)
	if not victim.dead: failures.append("Spear failed to hit animal ahead")
	g.wildlife.enabled=false
	var before=g.inventory.Meat
	g.player.position=w.ground(victim.position+Vector3(0,0,0.4))
	g.actions.start_pickup(victim.pickup)
	for i in range(40): g.actions.update(0.05)
	if g.inventory.Meat!=before+victim.meat or not victim.pickup.taken: failures.append("Carcass meat harvesting")
	g.actions.start_pickup(victim.pickup)
	if g.actions.picking(): failures.append("Carcass harvested twice")
	g.save_game(); g.load_game()
	if not victim.dead or not victim.harvested or g.inventory.Meat!=before+victim.meat: failures.append("Harvested animal / meat not preserved on load")
	# A carcass saved before collection remains available, without extra pickup entries.
	var carcass=animals[12]
	carcass.position=w.ground(w.camp+Vector3(0,0,8))
	carcass.damage(999,false)
	g.save_game(); g.load_game(); g.load_game()
	var carcass_count=0
	for item in w.pickups:
		if item.id==20000+carcass.identity: carcass_count+=1
	if not carcass.dead or carcass.harvested or carcass_count!=1: failures.append("Uncollected carcass lost / duplicated on reload")
	g.player.position=w.ground(carcass.position+Vector3(0,0,0.4))
	g.actions.start_pickup(carcass.pickup)
	for i in range(40): g.actions.update(0.05)
	if g.inventory.Meat!=before+victim.meat+carcass.meat: failures.append("Saved carcass failed to yield meat")
	var boar=animals[6]
	boar.restore({})
	boar.position=w.ground(Vector3(0,0,-110))
	g.player.position=w.ground(boar.position+Vector3(0,0,1.2))
	boar.think=0; boar.aggro=4
	g.health=80; boar.update(0.1)
	if g.health>=80: failures.append("Defensive animal never damages player")
	g.actions.resting=true; g.actions.asleep=true
	var health=g.health; boar.bite=0; boar.update(1)
	if g.health!=health: failures.append("Wildlife attacked during committed sleep")
	g.actions.reset()
	# Fleeing species respond to a nearby player outside the camp sanctuary.
	var deer=animals[0]
	deer.restore({}); deer.position=w.ground(Vector3(-18,0,-105))
	g.player.position=w.ground(deer.position+Vector3(0,0,5)); deer.update(0.1)
	if deer.state!="Fleeing": failures.append("Grazing animal failed to flee")
	g.fire_lit=true; g.inventory.Fish=0; g.inventory.Meat=1; g.inventory.Roast=0
	g.use_fire()
	if g.inventory.Meat!=0 or g.inventory.Roast!=1: failures.append("Meat cooking recipe")
	g.inventory.Meal=0; g.health=40; g.hunger=30
	g.eat()
	if g.inventory.Roast!=0 or g.health!=52 or g.hunger!=70: failures.append("Roast eating / health / hunger")
	# Rowan's real job loop consumes the same raw meat recipe as the player's fire action.
	var rowan=g.npcs[2]
	g.inventory.Meat=1; rowan.cancel()
	rowan.position=w.ground(w.camp+Vector3(1.5,0,0))
	rowan.command("cook",false)
	for i in range(150): rowan._process(0.05)
	if g.inventory.Meat!=0 or g.inventory.Roast!=1: failures.append("Rowan failed to cook shared raw meat")
	rowan.cancel()
	# Rocks hit a live animal once, with no extra damage after death.
	deer.position=w.ground(Vector3(0,0,-110)); deer.hp=60
	var hit=g.wildlife.projectile_hit(deer.position+Vector3(0,0.55,2),deer.position+Vector3(0,0.55,-2))
	if not hit or deer.hp!=45: failures.append("Thrown stone collision with wildlife")
	g.wildlife.attack_time=0.1; g.wildlife.attack_hit=false
	g.actions.resting=true; g.wildlife.enabled=true
	g.wildlife.update(0.2)
	if g.wildlife.attack_time!=0: failures.append("Spear thrust continued during rest / collection")
	g.actions.reset(); g.wildlife.enabled=false
	g.inventory.Stone=1; g.throw_stone()
	if g.projectiles.is_empty(): failures.append("Stone fixture failed to launch")
	g.save_game(); g.load_game()
	if not g.projectiles.is_empty(): failures.append("In-flight stone leaked across a loaded save")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(g.save_path))
	print("WILDLIFE: seven species, northern routes, timed hunting, loot, saves, defense/fleeing, sleep safety, cooking/eating and thrown stones checked")
