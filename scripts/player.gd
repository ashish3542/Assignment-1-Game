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
var driving = false
var jump_y = 0.0
var jump_speed = 0.0

func setup(w, g):
	world = w
	game = g
	body = M.human(self,Color("ddbd82"),Color("bc8a65"))
	camera = Camera3D.new()
	camera.fov = 65
	camera.far = 900
	game.add_child(camera)
	position = world.ground(Vector3(-6,0,33))
	update_camera(1)

func _input(event):
	if game.mode != "play": return
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
	input = input.normalized()
	var dir = Vector3(input.x,0,input.y).rotated(Vector3.UP,yaw)
	var speed = 5.0
	if Input.is_physical_key_pressed(KEY_SHIFT): speed = 8.0
	if driving: speed = 15.0
	if game.fishing > 0: speed = 0
	moving = dir.length()>0.1 and speed>0
	var target = position+dir*speed*delta
	var margin = 1.2 if driving else 0.45
	if world.walkable(target,margin):
		position.x = target.x
		position.z = target.z
	else:
		var xonly = Vector3(target.x,0,position.z)
		var zonly = Vector3(position.x,0,target.z)
		if world.walkable(xonly,margin): position.x = target.x
		elif world.walkable(zonly,margin): position.z = target.z
	if not driving and Input.is_physical_key_pressed(KEY_SPACE) and jump_y<=0 and game.fishing<=0:
		jump_speed = 5
	jump_speed -= 15*delta
	jump_y = maxf(0,jump_y+jump_speed*delta)
	if jump_y==0: jump_speed=0
	position.y = world.height_at(position.x,position.z)+jump_y
	if moving:
		body.rotation.y = lerp_angle(body.rotation.y,atan2(-dir.x,-dir.z),minf(1,delta*12))
		foot_time += delta
		if foot_time>0.42 and not driving:
			game.sound.play("step")
			foot_time = 0
	M.animate_human(body,Time.get_ticks_msec()/1000.0,moving)
	if driving:
		world.buggy.position = world.ground(position)
		world.buggy.rotation.y = body.rotation.y
		body.visible = false
	else: body.visible = true
	update_camera(delta)

func update_camera(delta: float):
	var distance = 8.2 if driving else 5.2
	var focus = position+Vector3(0,1.4,0)
	var desired = focus+Vector3(sin(yaw)*distance,1.3+pitch*3,cos(yaw)*distance)
	desired.y = maxf(desired.y,world.height_at(desired.x,desired.z)+0.7)
	camera.position = camera.position.lerp(desired,minf(1,delta*12))
	camera.look_at(focus)
