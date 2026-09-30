extends Node3D
const M = preload("res://scripts/models.gd")
var world
var game
var body: Node3D
var camera: Camera3D
var yaw = 0.0
var pitch = 0.22
var moving = false
var foot_time = 0.0
var pickup_prop: MeshInstance3D
var jump_y = 0.0
var jump_speed = 0.0
var velocity=Vector3.ZERO
var space_was_down=false

func setup(w, g):
	world = w
	game = g
	body = M.human(self,Color("ddbd82"),Color("bc8a65"))
	pickup_prop=M.box(body.get_node("Arm1/Elbow"),Vector3(0,-0.32,0),Vector3(0.18,0.16,0.22),Color("b6a47d"))
	pickup_prop.visible=false
	camera = Camera3D.new()
	camera.fov = 65
	camera.far = 900
	game.add_child(camera)
	position = world.ground(world.camp+Vector3(0,0,6))
	update_camera(1)

func _input(event):
	if game.mode != "play": return
	if game.actions.asleep: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x*0.003
		pitch = clampf(pitch+event.relative.y*0.002,0.02,0.95)

func _physics_process(delta):
	if not game or game.mode != "play" or game.demo_active: return
	var input = Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): input.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): input.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): input.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): input.x += 1
	if game.actions.resting and (input.length()>0 or Input.is_physical_key_pressed(KEY_SPACE)): game.actions.wake()
	if game.actions.picking() and input.length()>0: game.actions.cancel_pickup()
	if game.actions.busy():
		animate_action(delta)
		update_camera(delta)
		return
	if game.fishing>0:
		velocity=Vector3.ZERO; moving=false
		update_camera(delta)
		return
	input = input.normalized()
	var dir = Vector3(input.x,0,input.y).rotated(Vector3.UP,yaw)
	var speed = 5.0
	if Input.is_physical_key_pressed(KEY_SHIFT): speed = 8.0
	if game.fishing > 0: speed = 0
	if world.in_tent(position): speed=minf(speed,2.2)
	move_horizontal(dir,speed,delta)
	var space_down=Input.is_physical_key_pressed(KEY_SPACE)
	if not world.in_tent(position) and space_down and not space_was_down and jump_y<=0 and game.fishing<=0:
		jump_speed = 5
	space_was_down=space_down
	jump_speed -= 15*delta
	jump_y = maxf(0,jump_y+jump_speed*delta)
	if jump_y==0: jump_speed=0
	position.y = world.height_at(position.x,position.z)+jump_y
	if moving:
		body.rotation.y = lerp_angle(body.rotation.y,atan2(-dir.x,-dir.z),minf(1,delta*12))
		foot_time += delta
		if foot_time>0.42:
			game.sound.play("step")
			foot_time = 0
	var pose="escape" if world.in_tent(position) else "idle"
	body.get_node("Head").rotation.y=lerp_angle(body.get_node("Head").rotation.y,0,minf(1,delta*8))
	if game.shelter.player_help>0 and not moving: pose="repair"
	if game.wildlife.attack_time>0:
		pose="hunt"
		body.rotation.y=yaw
	M.animate_human(body,game.wildlife.attack_time if pose=="hunt" else Time.get_ticks_msec()/1000.0,moving,false,pose,false,delta,clampf(velocity.length()/3.5,0.6,1.65))
	update_camera(delta)

func move_horizontal(direction: Vector3, speed: float, delta: float):
	velocity=velocity.move_toward(direction*speed,delta*(20.0 if direction.length()>0 else 28.0))
	var previous=position
	position=world.move_character(position,velocity*delta,0.45)
	moving=Vector2(position.x-previous.x,position.z-previous.z).length()>0.002
	if not moving: velocity=Vector3.ZERO

func update_camera(delta: float):
	var distance = 5.2
	var focus = position+Vector3(0,0.6 if game.actions and (game.actions.resting or game.actions.waking>0) else 1.4,0)
	var desired = focus+Vector3(sin(yaw)*distance,1.3+pitch*3,cos(yaw)*distance)
	desired.y = maxf(desired.y,world.height_at(desired.x,desired.z)+0.7)
	desired=world.camera_position(focus,desired)
	# Contract immediately at an obstruction; only ease out into clear space.
	var eased=camera.position.lerp(desired,minf(1,delta*12))
	camera.position=world.camera_position(focus,eased)
	camera.look_at(focus)

func animate_action(delta: float):
	var a=game.actions
	if a.resting or a.waking>0:
		body.set_meta("sleep_height",0.33 if a.rest_kind=="tent" else 0.20)
		body.set_meta("rest_breath",a.rest_time)
		var amount=clampf(a.rest_time/a.REST_DURATION,0,1) if a.resting else a.waking/a.WAKE_DURATION
		M.animate_human(body,amount,false,false,"sleep",false,delta)
	elif a.picking():
		M.animate_human(body,a.pickup_time,a.approaching,false,"idle" if a.approaching else "gather",false,delta)
