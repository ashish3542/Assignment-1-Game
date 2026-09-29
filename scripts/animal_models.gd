extends RefCounted
const M=preload("res://scripts/models.gd")

static func oval(parent, pos: Vector3, size: Vector3, color: Color):
	var mesh=SphereMesh.new()
	mesh.radial_segments=12; mesh.rings=6
	mesh.radius=0.5; mesh.height=1
	var node=M.mesh(parent,mesh,pos,color)
	node.scale=size
	return node

static func build(parent, species: String) -> Node3D:
	var body=Node3D.new()
	parent.add_child(body)
	var reptile=species in ["Monitor","Crocodile"]
	var bird=species=="Junglefowl"
	var rabbit=species=="Rabbit"
	var colors={"Deer":Color("a67d51"),"Boar":Color("554438"),"Goat":Color("b1ac96"),"Rabbit":Color("b39777"),"Junglefowl":Color("9c633b"),"Monitor":Color("59684b"),"Crocodile":Color("485b43")}
	var color=colors[species]
	var height=0.36 if reptile else (0.4 if rabbit or bird else 0.9)
	var length=1.8 if reptile else (0.6 if rabbit or bird else 1.3)
	var width=0.7 if species in ["Boar","Crocodile"] else (0.34 if rabbit or bird else 0.58)
	body.set_meta("rest_height",width*0.5)
	body.set_meta("rest_offset",height)
	oval(body,Vector3(0,height,0),Vector3(width,0.35 if reptile else height*0.7,length),color)
	var head=Node3D.new(); head.name="Head"
	head.position=Vector3(0,height+(0.12 if reptile else 0.23),-length*0.48)
	body.add_child(head)
	oval(head,Vector3.ZERO,Vector3(width*0.62,0.26 if reptile else 0.4,0.65 if reptile else 0.43),color)
	oval(head,Vector3(0,-0.06,-0.24),Vector3(width*0.52,0.15,0.65 if species=="Crocodile" else 0.24),color.lightened(0.09))
	for side in [-1,1]:
		oval(head,Vector3(side*width*0.28,0.07,-0.1),Vector3(0.045,0.045,0.06),Color("181c12"))
		if not reptile and not bird:
			var ear=oval(head,Vector3(side*0.14,0.25 if not rabbit else 0.36,0.02),Vector3(0.11,0.48 if rabbit else 0.22,0.10),color.lightened(0.1))
			ear.rotation.z=-side*0.25
		if species in ["Deer","Goat"]:
			M.beam(head,Vector3(side*0.1,0.15,0),Vector3(side*0.23,0.64,0.08),0.035,Color("d1c6a5"))
			if species=="Deer": M.beam(head,Vector3(side*0.18,0.43,0.03),Vector3(side*0.35,0.58,-0.12),0.027,Color("d1c6a5"))
		if species=="Boar": M.beam(head,Vector3(side*0.15,-0.13,-0.23),Vector3(side*0.23,0.07,-0.35),0.035,Color("d7cfad"))
		if bird:
			oval(body,Vector3(side*0.2,height,0),Vector3(0.10,0.30,0.48),Color("573b2f"))
		for end in ([1] if bird else [-1,1]):
			var leg=Node3D.new(); leg.name="Leg%d_%d" % [side,end]
			leg.position=Vector3(side*width*0.36,height*0.85,end*length*0.32)
			body.add_child(leg)
			M.beam(leg,Vector3.ZERO,Vector3(side*0.16 if reptile else 0,-height*0.8,0.08),0.035 if bird else 0.055,color.darkened(0.2))
			oval(leg,Vector3(side*0.16 if reptile else 0,-height*0.82,-0.03),Vector3(0.15,0.09,0.24),color.darkened(0.3))
	if reptile:
		for i in range(5):
			oval(body,Vector3(0,height*0.7-i*0.025,length*0.43+i*0.24),Vector3(0.35-i*0.055,0.22-i*0.035,0.48),color)
		for i in range(7): M.box(body,Vector3(0,height+0.18,-0.6+i*0.25),Vector3(0.10,0.08,0.15),color.darkened(0.25))
	elif bird:
		M.box(head,Vector3(0,0.2,0),Vector3(0.05,0.16,0.22),Color("b84432"))
		M.beam(head,Vector3(0,0,-0.2),Vector3(0,-0.025,-0.4),0.045,Color("c3ab59"))
		for i in range(3): M.beam(body,Vector3(0,0.4,0.25),Vector3((i-1)*0.13,0.9,0.6),0.075,Color("234c45"))
	else: oval(body,Vector3(0,height,length*0.55),Vector3(0.18,0.20,0.2),color.lightened(0.1))
	return body

static func animate(body: Node3D, time: float, moving: bool, grazing: bool, dead: bool):
	if dead:
		body.rotation.z=PI/2
		body.position=Vector3(body.get_meta("rest_offset"),body.get_meta("rest_height"),0)
		return
	body.rotation.z=0
	body.position.x=0
	body.position.y=absf(sin(time*8))*0.035 if moving else sin(time*1.8)*0.005
	body.get_node("Head").rotation.x=0.45+sin(time*2)*0.08 if grazing else 0.0
	for joint in body.get_children():
		if str(joint.name).begins_with("Leg"):
			var side=-1 if "-1_" in str(joint.name) else 1
			var end=-1 if str(joint.name).ends_with("_-1") else 1
			joint.rotation.x=sin(time*8)*0.45*side*end if moving else 0.0
