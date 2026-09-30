extends Node3D
## Shared player / Finn fishing props. The line, float and fish are world-space.
const M=preload("res://scripts/models.gd")
var game
var body: Node3D
var rods: Array=[]
var line: MeshInstance3D
var bobber: Node3D
var fish: Node3D
var ripple: MeshInstance3D
var water=Vector3.ZERO

func setup(g, actor_body: Node3D):
	game=g; body=actor_body
	for i in range(3): rods.append(M.cylinder(self,Vector3.ZERO,1,1,Color("a88750")))
	line=M.cylinder(self,Vector3.ZERO,1,1,Color("e8e1c8"))
	bobber=Node3D.new(); add_child(bobber)
	M.sphere(bobber,Vector3.ZERO,Vector3(0.18,0.27,0.18),Color("e6783b"))
	M.sphere(bobber,Vector3(0,0.08,0),Vector3(0.15,0.12,0.15),Color("f4ead0"))
	fish=Node3D.new(); add_child(fish)
	M.sphere(fish,Vector3.ZERO,Vector3(0.18,0.27,0.65),Color("7dc1bd"))
	M.sphere(fish,Vector3(0,0.03,-0.19),Vector3(0.17,0.21,0.24),Color("bcd4c5"))
	for side in [-1,1]:
		M.sphere(fish,Vector3(side*0.085,0.07,-0.22),Vector3(0.035,0.045,0.04),Color("172d32"))
		M.beam(fish,Vector3(0,0,0.23),Vector3(side*0.18,0.06,0.43),0.055,Color("4b9698"))
	var ring=TorusMesh.new(); ring.inner_radius=0.32; ring.outer_radius=0.36
	ripple=M.mesh(self,ring,Vector3.ZERO,Color("c2e8df")); ripple.scale.y=0.05
	water=game.world.fish_spot+Vector3(0,0,6)
	while game.world.height_at(water.x,water.z)>-0.4 and water.z<game.world.fish_spot.z+40: water.z+=1
	water.y=0.09
	visible=false

func span(node: Node3D, a: Vector3, b: Vector3, radius: float):
	node.position=(a+b)*0.5
	node.scale=Vector3(radius,maxf(0.001,a.distance_to(b)),radius)
	node.quaternion=Quaternion(Vector3.UP,(b-a).normalized())

func sample(elapsed: float, reeling: bool=false, progress: float=0.0, caught: bool=true, bite_time: float=3.0):
	visible=elapsed>=0
	if not visible: return
	var hand=body.get_node("Arm1/Elbow").to_global(Vector3(0,-0.34,0))
	var forward=Vector3(-sin(body.rotation.y),0,-cos(body.rotation.y))
	var cast=smoothstep(0.12,1.0,elapsed)
	var lift=sin(clampf(elapsed,0,1)*PI)
	var tip=hand+forward*(2.5-3.2*lift)+Vector3(0,1.2+lift*0.7,0)
	if reeling: tip+=Vector3(0,0.35+sin(progress*35)*0.10,0)-forward*0.5
	var bend=0.18 if reeling else 0.035
	for i in range(3):
		var a=hand.lerp(tip,float(i)/3)+Vector3(0,bend*sin(float(i)/3*PI),0)
		var b=hand.lerp(tip,float(i+1)/3)+Vector3(0,bend*sin(float(i+1)/3*PI),0)
		span(rods[i],a,b,0.025-i*0.005)
	var landing=hand+forward*0.20-Vector3(0,0.18,0)
	var point=hand.lerp(water,cast)+Vector3(0,sin(cast*PI)*3,0)
	if reeling:
		point=water.lerp(landing,smoothstep(0,1,progress))+Vector3(0,sin(progress*PI)*0.8,0)
	else:
		point.y+=sin(elapsed*5)*0.035
		if elapsed>=bite_time: point.y-=0.12+absf(sin(elapsed*15))*0.10
	bobber.position=point
	bobber.visible=not reeling or not caught
	fish.visible=reeling and caught
	fish.position=point
	fish.rotation=Vector3(sin(progress*32)*0.3,progress*15,PI/2+sin(progress*40)*0.2)
	span(line,tip,point,0.009)
	ripple.visible=cast>0.95 and (not reeling or progress<0.25)
	ripple.position=water
	var radius=1.0+fmod(elapsed*1.7,1.5)
	ripple.scale=Vector3(radius,0.05,radius)
