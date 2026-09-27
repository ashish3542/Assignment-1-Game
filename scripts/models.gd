extends RefCounted
## All geometry is original and generated locally; no asset downloads needed.

static func material(color: Color, rough: float = 0.85) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	n.mesh = shape
	n.material_override = material(color)
	n.position = pos
	parent.add_child(n)
	return n

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var b = BoxMesh.new()
	b.size = size
	return mesh(parent, b, pos, color)

static func sphere(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var s = SphereMesh.new()
	s.radius = 0.5
	s.height = 1.0
	s.radial_segments = 24
	s.rings = 12
	var n = mesh(parent, s, pos, color)
	n.scale = size
	return n

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, top: float = -1.0) -> MeshInstance3D:
	var c = CylinderMesh.new()
	c.bottom_radius = radius
	c.top_radius = radius if top < 0 else top
	c.height = height
	c.radial_segments = 12
	return mesh(parent, c, pos, color)

static func beam(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var n = cylinder(parent, (a + b) * 0.5, radius, a.distance_to(b), color)
	var axis = (b-a).normalized()
	n.quaternion = Quaternion(Vector3.UP, axis)
	return n

static func human(parent: Node3D, shirt: Color, skin: Color) -> Node3D:
	var body = Node3D.new()
	parent.add_child(body)
	var chest = sphere(body, Vector3(0,1.17,0), Vector3(0.53,0.66,0.32), shirt)
	chest.name = "Chest"
	box(body, Vector3(0,0.83,0), Vector3(0.44,0.13,0.3), Color("353c35"))
	box(body, Vector3(0,0.86,-0.17), Vector3(0.07,0.08,0.025), Color("b8aa85"))
	cylinder(body,Vector3(0,1.49,0),0.074,0.16,skin)
	var head = Node3D.new()
	head.name="Head"
	head.position=Vector3(0,1.65,0)
	body.add_child(head)
	sphere(head,Vector3.ZERO,Vector3(0.29,0.38,0.29),skin)
	sphere(head,Vector3(0,-0.07,-0.055),Vector3(0.23,0.20,0.23),skin)
	sphere(head,Vector3(0,0.135,0.025),Vector3(0.30,0.15,0.30),Color("302720"))
	for side in [-1,1]:
		sphere(head,Vector3(side*0.146,-0.015,0),Vector3(0.055,0.093,0.047),skin)
		sphere(head,Vector3(side*0.061,0.025,-0.132),Vector3(0.057,0.025,0.018),Color("ece4ce"))
		sphere(head,Vector3(side*0.061,0.025,-0.142),Vector3(0.022,0.025,0.012),Color("344144"))
		box(head,Vector3(side*0.061,0.058,-0.126),Vector3(0.064,0.012,0.018),Color("4b342a"))
	sphere(head,Vector3(0,-0.015,-0.147),Vector3(0.048,0.072,0.062),skin.lightened(0.035))
	var mouth=box(head,Vector3(0,-0.088,-0.151),Vector3(0.076,0.012,0.012),Color("785044"))
	mouth.name="Mouth"
	# Clothing seams, collar, straps and boots give the silhouettes a human scale.
	for side in [-1,1]:
		beam(body,Vector3(side*0.06,1.47,-0.1),Vector3(side*0.14,1.35,-0.14),0.016,shirt.darkened(0.25))
		beam(body,Vector3(side*0.16,1.42,0),Vector3(side*0.17,0.98,-0.14),0.026,Color("565947"))
	box(body,Vector3(-0.12,1.19,-0.162),Vector3(0.12,0.13,0.022),shirt.lightened(0.08))
	box(body, Vector3(0,1.13,0.20), Vector3(0.32,0.43,0.20), Color("655e45"))
	for side in [-1,1]:
		var arm = Node3D.new()
		arm.name = "Arm" + str(side)
		arm.position = Vector3(side*0.285,1.40,0)
		body.add_child(arm)
		sphere(arm,Vector3(0,-0.12,0),Vector3(0.18,0.29,0.19),shirt)
		var elbow=Node3D.new()
		elbow.name="Elbow"
		elbow.position.y=-0.28
		arm.add_child(elbow)
		cylinder(elbow, Vector3(0,-0.11,0), 0.054,0.24,skin,0.073)
		sphere(elbow,Vector3(0,-0.26,0),Vector3(0.11,0.15,0.075),skin)
		var leg = Node3D.new()
		leg.name = "Leg" + str(side)
		leg.position = Vector3(side*0.12,0.83,0)
		body.add_child(leg)
		cylinder(leg, Vector3(0,-0.18,0),0.088,0.37,Color("354a4a"),0.11)
		var knee=Node3D.new()
		knee.name="Knee"
		knee.position.y=-0.36
		leg.add_child(knee)
		cylinder(knee, Vector3(0,-0.16,0),0.067,0.33,Color("354a4a"),0.083)
		sphere(knee, Vector3(0,-0.38,-0.05), Vector3(0.18,0.18,0.30), Color("39372c"))
	return body

static func frond(parent: Node3D, origin: Vector3, angle: float, length: float, color: Color):
	var st=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var direction=Vector3(cos(angle),0,sin(angle))
	var side=Vector3(-sin(angle),0,cos(angle))
	for i in range(8):
		var t0=float(i)/8
		var t1=float(i+1)/8
		var c0=origin+direction*t0*length+Vector3(0,sin(t0*PI)*0.55-t0*t0*1.2,0)
		var c1=origin+direction*t1*length+Vector3(0,sin(t1*PI)*0.55-t1*t1*1.2,0)
		var w0=sin(t0*PI)*0.52
		var w1=sin(t1*PI)*0.52
		for v in [c0-side*w0,c1-side*w1,c0+side*w0,c1-side*w1,c1+side*w1,c0+side*w0]: st.add_vertex(v)
	st.generate_normals()
	var leaf=MeshInstance3D.new()
	leaf.mesh=st.commit()
	var mat=material(color)
	mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	leaf.material_override=mat
	parent.add_child(leaf)
	beam(parent,origin,origin+direction*length*0.8+Vector3(0,-0.5,0),0.018,Color("8c9451"))

static func animate_human(body: Node3D, t: float, moving: bool, carry: bool = false, pose: String = "idle", talking: bool = false):
	var stride = sin(t*7.4)*0.48 if moving else sin(t*1.6)*0.018
	body.position.y=absf(sin(t*7.4))*0.026 if moving else sin(t*1.8)*0.006
	body.rotation.x=0.035 if moving else 0.0
	body.rotation.z=sin(t*(7.4 if moving else 1.1))*0.014
	body.get_node("Head").rotation.x=sin(t*1.6)*0.025
	body.get_node("Head/Mouth").scale.y=1.0+absf(sin(t*12))*1.8 if talking else 1.0
	for side in [-1,1]:
		var leg=body.get_node("Leg"+str(side))
		var arm=body.get_node("Arm"+str(side))
		leg.rotation.x=stride*side
		leg.get_node("Knee").rotation.x=maxf(0,-stride*side)*0.9
		arm.rotation=Vector3(-0.48 if carry else -stride*side,0,side*0.07)
		arm.get_node("Elbow").rotation=Vector3(-0.85 if carry else -0.14-maxf(0,stride*side)*0.35,0,0)
	if pose in ["gather","escape"]:
		body.rotation.x=0.48 if pose=="gather" else 0.20
		body.position.y-=0.15
		body.get_node("Arm1").rotation.x=-0.6
	elif pose=="wave":
		body.get_node("Arm1").rotation=Vector3(-0.6,0,-1.0)
		body.get_node("Arm1/Elbow").rotation=Vector3(-2.1,0,sin(t*8)*0.22)
	elif pose in ["repair","cook","fish"]:
		body.rotation.x=0.12
		for side in [-1,1]:
			body.get_node("Arm"+str(side)).rotation.x=-0.55+sin(t*3+side)*0.13
			body.get_node("Arm"+str(side)+"/Elbow").rotation.x=-0.8+sin(t*4)*0.15
	elif talking and not moving and not carry:
		body.get_node("Arm1").rotation.x=-0.3+sin(t*2)*0.15
		body.get_node("Arm1/Elbow").rotation.x=-0.7+sin(t*2.7)*0.25

static func plane(parent: Node3D, broken: bool = false) -> Node3D:
	var p = Node3D.new()
	parent.add_child(p)
	sphere(p, Vector3.ZERO, Vector3(2.2,2.3,12), Color("d7dbcf"))
	box(p, Vector3(0,-0.2,0), Vector3(15,0.15,2.4), Color("c9cfbf"))
	box(p, Vector3(0,0.1,4.1), Vector3(5.6,0.12,1.3), Color("d3d8ca"))
	box(p, Vector3(0,1.1,4.4), Vector3(0.17,2.7,1.9), Color("e58c3f"))
	for side in [-1,1]:
		for i in range(6):
			sphere(p, Vector3(side*1.02,0.35,-2.6+i*0.95), Vector3(0.09,0.28,0.36), Color("344d56"))
		var engine = cylinder(p, Vector3(side*3,-0.7,-0.4),0.57,2.4,Color("6f7b7c"))
		engine.rotation.x = PI/2
	if broken:
		box(p,Vector3(0,0.9,-3.4),Vector3(1.3,0.15,1.7),Color("252c2a"))
		# Open emergency exit on the starboard side; the escape scene uses this doorway.
		box(p,Vector3(1.04,0.02,-2.5),Vector3(0.15,1.5,0.9),Color("222b29"))
		for z in [-3.0,-2.0]: beam(p,Vector3(1.13,-0.7,z),Vector3(1.13,0.85,z),0.045,Color("9caaa4"))
		var door=box(p,Vector3(1.7,-0.65,-2.5),Vector3(1.4,0.09,1.0),Color("a5ada6"))
		door.rotation.z=-0.2
		box(p,Vector3(3.2,-0.37,-0.5),Vector3(1.7,0.08,1.8),Color("3c4540"))
	return p

static func buggy(parent: Node3D) -> Node3D:
	var b = Node3D.new()
	parent.add_child(b)
	box(b,Vector3(0,0.65,0),Vector3(1.7,0.4,2.7),Color("cf8f36"))
	box(b,Vector3(0,0.92,-0.85),Vector3(1.65,0.23,0.95),Color("e3ab50"))
	box(b,Vector3(0,1.0,0.15),Vector3(1.35,0.2,0.7),Color("303e39"))
	for side in [-1,1]:
		for z in [-0.92,0.95]:
			var wheel = cylinder(b,Vector3(side*0.89,0.45,z),0.43,0.28,Color("252e2e"))
			wheel.rotation.z = PI/2
		beam(b,Vector3(side*0.7,0.8,0.85),Vector3(side*0.7,1.95,0.8),0.055,Color("404b46"))
		beam(b,Vector3(side*0.7,0.8,-0.7),Vector3(side*0.7,1.95,-0.5),0.055,Color("404b46"))
		box(b,Vector3(side*0.57,0.9,-1.37),Vector3(0.25,0.18,0.05),Color("fff1b8"))
	box(b,Vector3(0,2,0.15),Vector3(1.65,0.09,1.65),Color("545b45"))
	return b
