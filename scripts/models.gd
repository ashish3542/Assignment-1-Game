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
	s.radial_segments = 16
	s.rings = 8
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
	sphere(body, Vector3(0,1.12,0), Vector3(0.53,0.72,0.34), shirt)
	box(body, Vector3(0,0.83,0), Vector3(0.44,0.13,0.3), Color("353c35"))
	box(body, Vector3(0,0.86,-0.17), Vector3(0.07,0.08,0.025), Color("b8aa85"))
	sphere(body, Vector3(0,1.66,0), Vector3(0.34,0.42,0.34), skin)
	sphere(body, Vector3(0,1.82,0.02), Vector3(0.35,0.18,0.35), Color("302720"))
	box(body, Vector3(0,1.63,-0.161), Vector3(0.19,0.035,0.024), Color("202c34"))
	sphere(body, Vector3(0,1.61,-0.18), Vector3(0.07,0.09,0.075), skin)
	box(body, Vector3(0,1.1,0.19), Vector3(0.35,0.46,0.19), Color("403e32"))
	for side in [-1,1]:
		var arm = Node3D.new()
		arm.name = "Arm" + str(side)
		arm.position = Vector3(side*0.31,1.39,0)
		body.add_child(arm)
		cylinder(arm, Vector3(0,-0.17,0), 0.105,0.35,shirt,0.09)
		cylinder(arm, Vector3(0,-0.42,0), 0.065,0.24,skin,0.075)
		sphere(arm,Vector3(0,-0.56,0),Vector3(0.13,0.17,0.13),skin)
		var leg = Node3D.new()
		leg.name = "Leg" + str(side)
		leg.position = Vector3(side*0.135,0.84,0)
		body.add_child(leg)
		cylinder(leg, Vector3(0,-0.32,0),0.095,0.64,Color("354a4a"),0.12)
		box(leg, Vector3(0,-0.73,-0.06), Vector3(0.22,0.17,0.36), Color("292c29"))
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

static func animate_human(body: Node3D, t: float, moving: bool, carry: bool = false):
	var stride = sin(t*9.0)*0.55 if moving else sin(t*1.6)*0.018
	for side in [-1,1]:
		body.get_node("Leg"+str(side)).rotation.x = stride*side
		body.get_node("Arm"+str(side)).rotation.x = -1.0 if carry else -stride*side

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
