extends RefCounted
## Shared materials are committed once; work advances only with people at the site.
const COST={"Wood":6,"Cloth":2,"Rope":2}
var game
var paid=false
var progress=0.0
var player_help=0.0
var announced=false

func _init(g): game=g
func complete() -> bool: return progress>=1.0

func work_position(who: String) -> Vector3:
	var offset={"Maya":Vector3(-2.8,0,0),"Finn":Vector3(2.8,0,0),"Rowan":Vector3(0,0,2.8)}
	return game.world.ground(game.world.tent_center+offset[who])

func needed() -> String:
	if paid: return "Shelter · "+str(int(progress*100))+"% · two people needed"
	return "Shelter: wood %d/6 · cloth %d/2 · rope %d/2" % [mini(game.inventory.Wood,6),mini(game.inventory.Cloth,2),mini(game.inventory.Rope,2)]

func assign(npc):
	if complete(): return
	if not announced:
		announced=true
		game.report("Work together: wood from the forest, cloth from the plane, rope from the shipwreck.")
		game.npcs[2].say("We need a roof before nightfall. I'll gather wood. Bring back cloth and rope.")
	if not paid:
		var ready=true
		for kind in COST:
			if game.inventory[kind]<COST[kind]: ready=false
		if ready:
			for kind in COST: game.inventory[kind]-=COST[kind]
			paid=true
			progress=0.02
			game.world.set_shelter_progress(progress)
			game.npcs[0].say("We've got the supplies. Finn, hold the frame while we tie it down.")
	if paid:
		npc.go(work_position(npc.person),"building","Helping raise the shelter")
		return
	var preferred={"Maya":"Cloth","Finn":"Rope","Rowan":"Wood"}[npc.person]
	var choices=[preferred,"Wood","Cloth","Rope"]
	for kind in choices:
		if game.inventory[kind]<COST[kind] and npc.has_resource(kind):
			npc.gather(kind)
			return
	# Other crew may be carrying the last pieces. Stay near the build site.
	npc_wait(npc)

func npc_wait(npc):
	npc.go(work_position(npc.person),"rest","Waiting for the shared building supplies")

func help():
	if complete():
		game.report("The shelter is ready. Walk inside and press H to sleep and recover health.")
	elif not paid:
		game.report(needed()+". Supplies are shared automatically.")
	else:
		player_help=6.0
		game.report("Helping tie the shelter. Stay by the entrance; B helps for another six seconds.")

func update(delta: float):
	if game.mode!="play" or complete(): return
	player_help=maxf(0,player_help-delta)
	if not paid: return
	var workers=0
	for npc in game.npcs:
		if npc.task=="building" and npc.position.distance_to(work_position(npc.person))<1.0:
			workers+=1
	if player_help>0 and game.player.position.distance_to(game.world.tent_center+Vector3(0,0,3.5))<2.5 and not game.actions.busy():
		workers+=1
	else: player_help=0
	if workers<2: return
	progress=minf(1,progress+delta*workers/60.0)
	game.world.set_shelter_progress(progress)
	# A player standing where newly raised cloth appears is moved to the open entrance.
	if not game.world.walkable(game.player.position):
		game.player.position=game.world.ground(game.world.tent_center+Vector3(0,0,3.8))
	if complete():
		player_help=0
		game.team_events+=1
		game.npcs[2].say("That's our roof. Good work, everyone. Now let's get a fire and some food.")
		game.report("Shelter complete. The survivors can now focus on fire, food and rescue.")
		game.sound.play("success")

func restore(data: Dictionary):
	paid=bool(data.get("paid",false))
	progress=clampf(float(data.get("progress",0)),0,1) if paid else 0.0
	player_help=0
	announced=paid
	game.world.set_shelter_progress(progress)

func snapshot() -> Dictionary:
	return {"paid":paid,"progress":progress}
