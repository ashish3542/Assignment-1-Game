extends RefCounted
## Instanced forest canopy keeps dense inland growth to a small number of draw calls.
static func grow(world):
	var trunks=[]
	var crowns=[]
	for i in range(560):
		var p=Vector3(world.rng.randf_range(-72,72),0,world.rng.randf_range(-66,43))
		if world.height_at(p.x,p.z)<2.0 or world.near_landmark(p,7): continue
		var crowded=false
		for o in world.obstacles:
			if Vector2(p.x-o.x,p.z-o.y).length()<2.4: crowded=true; break
		if crowded: continue
		p=world.ground(p)
		var h=world.rng.randf_range(6,11)
		trunks.append(Transform3D(Basis.from_scale(Vector3(0.45,h,0.45)),p+Vector3(0,h/2,0)))
		for j in range(3):
			var a=j*TAU/3+world.rng.randf()
			var top=p+Vector3(cos(a)*1.6,h-0.5+j*0.45,sin(a)*1.6)
			crowns.append(Transform3D(Basis.from_scale(Vector3(4.5,3.2,4.5)),top))
		world.obstacles.append(Vector3(p.x,p.z,0.3))
	var trunk=CylinderMesh.new()
	trunk.top_radius=0.65
	trunk.bottom_radius=1
	trunk.height=1
	trunk.radial_segments=7
	instances(world,trunk,trunks,Color("65573b"))
	var leaves=SphereMesh.new()
	leaves.radius=0.5
	leaves.height=1
	leaves.radial_segments=10
	leaves.rings=5
	instances(world,leaves,crowns,Color("315c32"))
	world.forest_count=trunks.size()

static func instances(world, mesh: Mesh, transforms: Array, color: Color):
	var node=MultiMeshInstance3D.new()
	var multi=MultiMesh.new()
	multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.use_colors=true
	multi.mesh=mesh
	multi.instance_count=transforms.size()
	for i in range(transforms.size()):
		multi.set_instance_transform(i,transforms[i])
		multi.set_instance_color(i,color.lightened(world.rng.randf_range(0,0.13)))
	var mat=StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo=true
	mat.roughness=1
	mesh.material=mat
	node.multimesh=multi
	world.add_child(node)

static func shipwreck(world):
	var M=world.M
	var ship=Node3D.new()
	ship.name="TidebreakShipwreck"
	world.add_child(ship)
	ship.position=world.ground(world.ship_spot+Vector3(7,0,0),0.15)
	ship.rotation.y=-0.2
	# Split, ribbed hull and collapsed deck; salvage is on the accessible landward side.
	for side in [-1,1]:
		for i in range(10):
			if side==-1 and i in [3,4]: continue
			var z=-7.2+i*1.6
			var width=2.8*(1-pow(absf(z)/10.0,2))
			var plank=M.box(ship,Vector3(side*width,0.8,z),Vector3(0.25,2.4,1.5),Color("655947"))
			plank.rotation.z=side*0.22
	for z in [-6,-3,0,3,6]:
		M.beam(ship,Vector3(-2.5,0,z),Vector3(2.5,0,z),0.13,Color("3c413b"))
		M.beam(ship,Vector3(-2.5,0,z),Vector3(-2.8,2,z),0.09,Color("565348"))
		M.beam(ship,Vector3(2.5,0,z),Vector3(2.8,2,z),0.09,Color("565348"))
	M.box(ship,Vector3(0,0.02,3),Vector3(4.8,0.2,6),Color("766749"))
	M.box(ship,Vector3(0,2.1,4),Vector3(3.2,2.2,2.5),Color("9b9c83"))
	M.box(ship,Vector3(0,2.4,2.72),Vector3(2.4,0.65,0.08),Color("283f42"))
	M.beam(ship,Vector3(0,1,0),Vector3(5,3.5,-5),0.17,Color("665943"))
	for z in [-5,-2,1,4,7]:
		var p=ship.to_global(Vector3(0,0,z))
		world.obstacles.append(Vector3(p.x,p.z,2.5))
	var sign=Label3D.new()
	sign.text="TIDEBREAK"
	sign.font_size=42
	sign.pixel_size=0.02
	sign.position=Vector3(-3.0,1.6,4)
	sign.rotation.y=-PI/2
	ship.add_child(sign)
	return ship
