extends RefCounted
## Interruptible player actions. Item ownership changes at contact, never on button press.
const PICKUP_DURATION=1.65
const CONTACT_TIME=0.85
const REST_DURATION=3.8
const WAKE_DURATION=3.2
var game
var pickup: Dictionary={}
var pickup_time=0.0
var approaching=false
var approach=Vector3.ZERO
var approach_time=0.0
var claimed=false
var resting=false
var rest_kind=""
var rest_time=0.0
var waking=0.0

func _init(g): game=g
func picking() -> bool: return not pickup.is_empty()
func busy() -> bool: return picking() or resting or waking>0

func start_pickup(item: Dictionary):
	if busy() or item.taken or game.reserved.has(item.id): return
	var player=game.player
	if player.position.distance_to(item.node.position)>2.1: return
	var away=player.position-item.node.position
	away.y=0
	if away.length()<0.1: away=Vector3(0,0,1).rotated(Vector3.UP,player.yaw)
	approach=game.world.ground(item.node.position+away.normalized()*0.4)
	if not game.world.walkable(approach) or not game.world.clear_segment(player.position,approach,0.45):
		game.report("Move around the obstacle and closer to the item.")
		return
	pickup=item
	pickup_time=0
	claimed=false
	approaching=true
	approach_time=0
	game.reserved[item.id]="Player"
	game.shelter.player_help=0
	player.velocity=Vector3.ZERO
	player.jump_y=0
	player.jump_speed=0

func cancel_pickup():
	if picking() and game.reserved.get(pickup.id,"")=="Player": game.reserved.erase(pickup.id)
	pickup={}
	pickup_time=0
	approaching=false
	game.player.pickup_prop.visible=false
	game.player.velocity=Vector3.ZERO
	game.player.moving=false

func toggle_rest():
	if resting: wake(); return
	if picking() or waking>0 or game.fishing>0 or game.player.jump_y>0: return
	if game.hunger<=5:
		game.report("Eat something first. Rest restores health but does not replace food.")
		return
	var w=game.world
	var p=game.player
	if game.shelter.complete() and w.in_tent(p.position):
		if is_instance_valid(w.rest_mat): w.rest_mat.visible=false
		rest_kind="tent"
		p.position=w.ground(w.tent_center+Vector3(0,0,-0.8))
		p.yaw=0
		p.body.rotation.y=0
	else:
		if p.position.distance_to(w.tent_center)<4.5:
			game.report("Enter the finished tent, or find clear ground away from the building site.")
			return
		var center=p.position+Vector3(0,0,0.8).rotated(Vector3.UP,p.yaw)
		for corner in [Vector3(-0.65,0,-1.05),Vector3(0.65,0,-1.05),Vector3(-0.65,0,1.05),Vector3(0.65,0,1.05),Vector3.ZERO]:
			var point=center+corner.rotated(Vector3.UP,p.yaw)
			if not w.walkable(point,0.25) or absf(w.height_at(point.x,point.z)-p.position.y)>0.35:
				game.report("Find a flat, clear patch of land before lying down.")
				return
		rest_kind="ground"
		w.place_rest_mat(center,p.yaw)
		p.body.rotation.y=p.yaw
	resting=true
	rest_time=0
	p.velocity=Vector3.ZERO
	p.moving=false
	p.jump_y=0
	p.jump_speed=0
	game.shelter.player_help=0
	game.sound.clear_speech()
	game.report("Resting in the tent. H or movement gets you up." if rest_kind=="tent" else "Lying on a leaf mat. Shelter gives faster recovery. H or movement gets you up.")

func wake():
	if not resting: return
	resting=false
	waking=WAKE_DURATION*clampf(rest_time/REST_DURATION,0,1)
	game.report("Getting up. Food and rest both help restore your health.")

func reset():
	cancel_pickup()
	if is_instance_valid(game.world.rest_mat): game.world.rest_mat.visible=false
	resting=false
	rest_time=0
	waking=0
	game.player.body.rotation.x=0
	game.player.body.rotation.z=0
	game.player.body.position=Vector3.ZERO
	game.player.body.get_node("Backpack").visible=true

func update(delta: float):
	if game.mode!="play": return
	if waking>0:
		waking=maxf(0,waking-delta)
		return
	if resting:
		var previous_rest=rest_time
		rest_time+=delta
		if game.hunger<=5: wake(); return
		if rest_time>REST_DURATION:
			var healing_time=maxf(0,rest_time-maxf(REST_DURATION,previous_rest))
			game.health=minf(100,game.health+healing_time*(2.0 if rest_kind=="tent" else 0.8))
			if game.health>=100: wake()
		return
	if not picking(): return
	var p=game.player
	if approaching:
		approach_time+=delta
		if approach_time>4:
			cancel_pickup()
			game.report("Couldn't reach that item. Try approaching from another side.")
			return
		var offset=approach-p.position
		offset.y=0
		if offset.length()>0.06:
			p.move_horizontal(offset.normalized(),minf(2.2,offset.length()/maxf(delta,0.001)),delta)
			p.body.rotation.y=atan2(-offset.x,-offset.z)
			return
		approaching=false
		p.velocity=Vector3.ZERO
		p.moving=false
	var look=pickup.node.position-p.position
	p.body.rotation.y=atan2(-look.x,-look.z)
	pickup_time+=delta
	if pickup_time>=CONTACT_TIME and not claimed:
		if pickup.taken or game.reserved.get(pickup.id,"")!="Player": cancel_pickup(); return
		pickup.taken=true
		pickup.node.visible=false
		game.inventory[pickup.kind]+=1
		game.reserved.erase(pickup.id)
		claimed=true
		p.pickup_prop.visible=true
		game.sound.play("pickup")
		game.report("Collected "+pickup.kind.to_lower()+". Added to shared camp supplies.")
	if pickup_time>=PICKUP_DURATION: cancel_pickup()
