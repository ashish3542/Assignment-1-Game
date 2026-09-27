extends Node3D
const M = preload("res://scripts/models.gd")
var rng = RandomNumberGenerator.new()
var obstacles: Array[Vector3] = []
var fire: Node3D
var fire_light: OmniLight3D
var beacon_light: OmniLight3D
var beacon_beam: MeshInstance3D
var plane: Node3D
var wreck_root: Node3D
var smoke: GPUParticles3D
var buggy: Node3D
var palms: Array[Node3D] = []
var camp = Vector3(-8,0,20)
var fish_spot = Vector3(25,0,49)
var salvage = Vector3(-37,0,29)
var tower = Vector3(15,0,-35)
var wood_spot = Vector3(-29,0,2)
var pickups: Array[Dictionary] = []
var nav = AStarGrid2D.new()

func height_at(x: float, z: float) -> float:
	var radius = Vector2(x/1.12,z).length()
	var edge = 1.0-smoothstep(56.0,87.0,radius)
	var hill = exp(-((x-6)*(x-6)+(z+35)*(z+35))/950.0)*8.0
	return -2.5 + edge*(4.0+hill+sin(x*0.06)*cos(z*0.07)*1.0)

func ground(p: Vector3, extra: float = 0.0) -> Vector3:
	return Vector3(p.x,height_at(p.x,p.z)+extra,p.z)

func _ready():
	rng.seed = 24681
	camp = ground(camp)
	fish_spot = ground(fish_spot)
	salvage = ground(salvage)
	tower = ground(tower)
	wood_spot = ground(wood_spot)
	_build_environment()
	_build_terrain()
	_build_camp()
	_build_landmarks()
	_build_foliage()
	_build_grass()
	_build_pickups()
	nav.region = Rect2i(-50,-50,101,101)
	nav.cell_size = Vector2(2,2)
	nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	nav.update()
	for x in range(-50,51):
		for z in range(-50,51):
			if not walkable(Vector3(x*2,0,z*2),0.65):
				nav.set_point_solid(Vector2i(x,z))

func _build_environment():
	var we = WorldEnvironment.new()
	var env = Environment.new()
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("28648c")
	sky_mat.sky_horizon_color = Color("e8d8ae")
	sky_mat.ground_bottom_color = Color("244d53")
	sky_mat.ground_horizon_color = Color("c9c9a9")
	sky_mat.sky_curve = 0.18
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("a1c7d0")
	env.ambient_light_energy = 0.43
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.fog_enabled = true
	env.fog_light_color = Color("b3c9c1")
	env.fog_density = 0.0017
	we.environment = env
	add_child(we)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-27,-38,0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 1.02
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120
	add_child(sun)
	var sea = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1500,1500)
	plane_mesh.subdivide_width = 90
	plane_mesh.subdivide_depth = 90
	sea.mesh = plane_mesh
	var sm = ShaderMaterial.new()
	sm.shader = load("res://shaders/ocean.gdshader")
	sea.material_override = sm
	sea.position.y = -0.1
	add_child(sea)
	# Distant uninhabited islets give the ocean a readable horizon.
	for i in range(8):
		var a = float(i)*TAU/8
		M.sphere(self,Vector3(cos(a)*330,-3,sin(a)*330),Vector3(90,22,70),Color("527b7d"))

func _build_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(-104,104,2):
		for z in range(-104,104,2):
			var points = [Vector2(x,z),Vector2(x+2,z),Vector2(x,z+2),Vector2(x+2,z+2)]
			for k in [0,1,2,1,3,2]:
				var q: Vector2 = points[k]
				var h = height_at(q.x,q.y)
				var sand = Color("c7b17d")
				var grass = Color("566b35")
				var n = (sin(q.x*0.7)*cos(q.y*0.4)+1)*0.035
				var c = sand.lerp(grass,smoothstep(1.5,3.3,h))
				st.set_color(c.lightened(n))
				st.set_uv(q*0.1)
				st.add_vertex(Vector3(q.x,h,q.y))
	st.generate_normals()
	var terrain = MeshInstance3D.new()
	terrain.mesh = st.commit()
	var mat = ShaderMaterial.new()
	mat.shader = load("res://shaders/terrain.gdshader")
	terrain.material_override = mat
	add_child(terrain)
	terrain.create_trimesh_collision()

func _build_camp():
	var tent = Node3D.new()
	add_child(tent)
	tent.position = ground(camp+Vector3(-5,0,-3))
	for side in [-1,1]:
		var tarp = M.box(tent,Vector3(side*0.78,1.15,0),Vector3(0.07,2.7,3.4),Color("c38548"))
		tarp.rotation.z = side*0.64
		M.beam(tent,Vector3(side*1.8,0,-1.9),Vector3(0,2.3,-1.9),0.045,Color("473e2c"))
	M.box(tent,Vector3(0,0.04,0),Vector3(3.2,0.05,3.3),Color("4c5546"))
	for i in range(3):
		M.box(self,ground(camp+Vector3(4+i*0.8,0,2),0.35),Vector3(0.7,0.7,0.7),Color("6c6550"))
	for i in range(10):
		var a = i*TAU/10
		M.sphere(self,camp+Vector3(cos(a)*0.95,0.1,sin(a)*0.95),Vector3(0.5,0.35,0.4),Color("74766a"))
	for i in range(3):
		var log_mesh = M.cylinder(self,camp+Vector3(0,0.2,0),0.15,1.4,Color("514034"))
		log_mesh.rotation = Vector3(PI/2,i*PI/3,0)
	fire = Node3D.new()
	add_child(fire)
	fire.position = camp
	for i in range(7):
		var f = M.sphere(fire,Vector3(rng.randf_range(-0.3,0.3),0.55,rng.randf_range(-0.3,0.3)),Vector3(0.3,1.0,0.3),Color("ffac39"))
		var fm = M.material(Color("ffac39"))
		fm.emission_enabled = true
		fm.emission = Color("ff681c")
		fm.emission_energy_multiplier = 2
		f.material_override = fm
	fire.visible = false
	fire_light = OmniLight3D.new()
	fire_light.position = camp+Vector3(0,1.5,0)
	fire_light.light_color = Color("ffa23d")
	fire_light.omni_range = 14
	fire_light.visible = false
	add_child(fire_light)
	# A driftwood bench and a modest communal workbench.
	M.box(self,ground(camp+Vector3(0,0,3),0.4),Vector3(3.2,0.3,0.6),Color("716047"))
	var table_pos = ground(camp+Vector3(3,0,-4))
	M.box(self,table_pos+Vector3(0,0.9,0),Vector3(2,0.12,1),Color("a38c64"))
	for x in [-0.8,0.8]:
		M.box(self,table_pos+Vector3(x,0.45,0),Vector3(0.12,0.9,0.7),Color("625a44"))

func _build_landmarks():
	wreck_root=Node3D.new()
	wreck_root.name="CrashWreckage"
	add_child(wreck_root)
	plane = M.plane(wreck_root,true)
	plane.position = ground(Vector3(-40,0,37),0.9)
	plane.rotation = Vector3(0.1,-0.5,-0.13)
	obstacles.append(Vector3(-40,37,3.3))
	for i in range(8):
		var pos = ground(Vector3(-42+rng.randf_range(-7,8),0,37+rng.randf_range(-7,8)),0.15)
		var debris = M.box(wreck_root,pos,Vector3(1.5,0.15,0.6),Color("b5bbae"))
		debris.rotation = Vector3(0,rng.randf()*TAU,0.2)
	# Slow, soft smoke marks the crash site after impact only.
	smoke=GPUParticles3D.new()
	wreck_root.add_child(smoke)
	smoke.position=plane.position+Vector3(-2,1.5,0)
	smoke.amount=22
	smoke.lifetime=8
	smoke.preprocess=6
	smoke.visibility_aabb=AABB(Vector3(-12,-3,-12),Vector3(30,40,30))
	var pm=ParticleProcessMaterial.new()
	pm.direction=Vector3(0.18,1,0.05)
	pm.spread=15
	pm.initial_velocity_min=0.8
	pm.initial_velocity_max=1.4
	pm.gravity=Vector3(0.08,0.1,0)
	pm.scale_min=1.5
	pm.scale_max=3.5
	var gradient=Gradient.new()
	gradient.set_color(0,Color(0.17,0.19,0.18,0.22))
	gradient.set_color(1,Color(0.4,0.43,0.42,0))
	var ramp=GradientTexture1D.new()
	ramp.gradient=gradient
	pm.color_ramp=ramp
	smoke.process_material=pm
	var puff=QuadMesh.new()
	puff.size=Vector2(2.5,2.5)
	var smoke_mat=M.material(Color.WHITE)
	smoke_mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_mat.vertex_color_use_as_albedo=true
	smoke_mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	smoke_mat.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED
	smoke_mat.billboard_keep_scale=true
	smoke_mat.no_depth_test=false
	var soft=Gradient.new()
	soft.set_color(0,Color(1,1,1,0.65))
	soft.set_color(1,Color(1,1,1,0))
	soft.add_point(0.35,Color(1,1,1,0.25))
	var puff_texture=GradientTexture2D.new()
	puff_texture.gradient=soft
	puff_texture.width=64
	puff_texture.height=64
	puff_texture.fill=GradientTexture2D.FILL_RADIAL
	puff_texture.fill_from=Vector2(0.5,0.5)
	puff_texture.fill_to=Vector2(1,0.5)
	smoke_mat.albedo_texture=puff_texture
	puff.material=smoke_mat
	smoke.draw_pass_1=puff
	# Signal station: open sides make interaction and movement readable.
	for x in [-1.1,1.1]:
		for z in [-1.1,1.1]:
			M.beam(self,tower+Vector3(x,0,z),tower+Vector3(x*0.35,12,z*0.35),0.11,Color("747d73"))
	for h in [3,6,9]:
		M.beam(self,tower+Vector3(-0.9,h,-0.9),tower+Vector3(0.9,h+2,0.9),0.07,Color("787d71"))
	M.box(self,tower+Vector3(0,0.7,2.6),Vector3(1.5,1.4,1),Color("425855"))
	M.box(self,tower+Vector3(0,1.1,3.12),Vector3(0.9,0.25,0.03),Color("c8893d"))
	M.cylinder(self,tower+Vector3(0,12,0),1,0.3,Color("ded6b4"))
	beacon_light = OmniLight3D.new()
	beacon_light.position = tower+Vector3(0,12.5,0)
	beacon_light.light_color = Color("ffe6a0")
	beacon_light.omni_range = 25
	beacon_light.visible = false
	add_child(beacon_light)
	beacon_beam = M.cylinder(self,tower+Vector3(0,27,0),0.35,30,Color("fff2be"),2)
	var glow = M.material(Color(1,0.9,0.55,0.19))
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon_beam.material_override = glow
	beacon_beam.visible = false
	buggy = M.buggy(self)
	buggy.position = ground(Vector3(24,0,3))
	buggy.rotation.y = -0.5
	# Fishing pier.
	for i in range(7):
		M.box(self,fish_spot+Vector3(0,0.17,i*0.65),Vector3(2.6,0.16,0.58),Color("8d7960"))
	for x in [-1,1]:
		M.cylinder(self,fish_spot+Vector3(x,-0.15,2.8),0.09,2.2,Color("6e6249"))
	# Ranger shelter near buggy.
	var shed = ground(Vector3(31,0,-3))
	M.box(self,shed+Vector3(0,2.2,0),Vector3(5,0.15,4),Color("746f53"))
	for x in [-2.2,2.2]:
		for z in [-1.7,1.7]:
			M.cylinder(self,shed+Vector3(x,1.1,z),0.1,2.2,Color("776347"))
	# Faint sandy service trail toward the ridge.
	for i in range(27):
		var p = camp.lerp(tower,float(i)/26)
		M.sphere(self,ground(p,-0.04),Vector3(3.2,0.14,3.2),Color("aa9e68"))

func _build_foliage():
	for i in range(105):
		var p = Vector3(rng.randf_range(-66,66),0,rng.randf_range(-64,48))
		if height_at(p.x,p.z)<1.8 or near_landmark(p,10):
			continue
		p = ground(p)
		var palm = Node3D.new()
		add_child(palm)
		palm.position = p
		palms.append(palm)
		var h = rng.randf_range(5.5,9.5)
		var lean = Vector3(rng.randf_range(-1,1),0,rng.randf_range(-1,1))
		M.beam(palm,Vector3.ZERO,Vector3(0,h,0)+lean,0.22,Color("796547"))
		for j in range(7):
			var a = j*TAU/7+rng.randf()*0.2
			M.frond(palm,Vector3(0,h,0)+lean,a,rng.randf_range(3.0,4.4),Color("42652d").lightened(rng.randf()*0.07))
		obstacles.append(Vector3(p.x,p.z,0.35))
	for i in range(115):
		var p = Vector3(rng.randf_range(-72,72),0,rng.randf_range(-67,58))
		if height_at(p.x,p.z)<0.2 or near_landmark(p,7):
			continue
		var s = rng.randf_range(0.6,2.7)
		var rock=M.sphere(self,ground(p,-0.2),Vector3(s*1.6,s,s*1.2),Color("73786b"))
		rock.rotation=Vector3(rng.randf()*0.3,rng.randf()*TAU,rng.randf()*0.25)
		if s>1.3:
			obstacles.append(Vector3(p.x,p.z,s*0.65))
	for i in range(400):
		var p = Vector3(rng.randf_range(-67,67),0,rng.randf_range(-65,52))
		if height_at(p.x,p.z)<2.6 or near_landmark(p,5):
			continue
		if i%3==0:
			var fern=Node3D.new()
			add_child(fern)
			fern.position=ground(p)
			for j in range(5): M.frond(fern,Vector3(0,0.6,0),j*TAU/5,1.1,Color("4b7137"))
		else:
			M.sphere(self,ground(p,0.15),Vector3(1.1,0.55,0.85),Color("496637").lightened(rng.randf()*0.1))

func near_landmark(p: Vector3, distance: float) -> bool:
	for target in [camp,fish_spot,salvage,tower,Vector3(24,0,3),wood_spot,Vector3(-29,0,35),Vector3(-40,0,37)]:
		if Vector2(p.x-target.x,p.z-target.z).length()<distance:
			return true
	var escape_path=Geometry2D.get_closest_point_to_segment(Vector2(p.x,p.z),Vector2(-29,35),Vector2(-8,24))
	if escape_path.distance_to(Vector2(p.x,p.z))<2.5: return true
	# Keep the central cooperation corridor clear.
	return absf(p.x)<8 and p.z>-30 and p.z<28

func set_crash_visible(value: bool):
	wreck_root.visible=value
	smoke.emitting=value
	for p in pickups:
		if p.kind=="Scrap" or p.id==60: p.node.visible=value and not p.taken

func _build_grass():
	# One mesh for thousands of blades keeps the extra vegetation inexpensive.
	var st=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(6500):
		var p=Vector3(rng.randf_range(-70,70),0,rng.randf_range(-66,56))
		if height_at(p.x,p.z)<2.7 or near_landmark(p,4): continue
		p=ground(p)
		var h=rng.randf_range(0.18,0.52)
		var a=rng.randf()*TAU
		var side=Vector3(cos(a),0,sin(a))*0.06
		var c=Color("5c803f").lightened(rng.randf()*0.16)
		for j in range(2):
			st.set_color(c.darkened(0.22))
			st.set_uv(Vector2(0,0))
			st.add_vertex(p-side)
			st.set_uv(Vector2(1,0))
			st.add_vertex(p+side)
			st.set_color(c)
			st.set_uv(Vector2(0.5,1))
			st.add_vertex(p+Vector3(0.09,h,0.06))
			side=side.rotated(Vector3.UP,PI/2)
	st.generate_normals()
	var grass=MeshInstance3D.new()
	grass.mesh=st.commit()
	var mat=ShaderMaterial.new()
	mat.shader=load("res://shaders/grass.gdshader")
	grass.material_override=mat
	add_child(grass)

func _build_pickups():
	for i in range(12):
		add_pickup("Wood",camp+Vector3(-9-i%4*2,0,-8-i/4*2),i)
	for i in range(12):
		add_pickup("Stone",camp+Vector3(5+i%4*2,0,6+i/4*2),i+20)
	for i in range(9):
		add_pickup("Scrap",salvage+Vector3(4+i%3*1.5,0,-3-i/3*1.5),i+40)
	add_pickup("Ration",salvage+Vector3(3,0,3),60)
	add_pickup("Ration",camp+Vector3(4,0,3),61)

func add_pickup(kind: String, p: Vector3, id: int):
	var node = Node3D.new()
	add_child(node)
	node.position = ground(p,0.18)
	match kind:
		"Wood":
			var log_mesh = M.cylinder(node,Vector3.ZERO,0.13,1.2,Color("795337"))
			log_mesh.rotation.z = PI/2
		"Stone": M.sphere(node,Vector3.ZERO,Vector3(0.6,0.37,0.5),Color("b9b7a0"))
		"Scrap": M.box(node,Vector3.ZERO,Vector3(0.65,0.24,0.45),Color("acb9b3"))
		_: M.box(node,Vector3.ZERO,Vector3(0.42,0.26,0.32),Color("d6a14a"))
	pickups.append({"id":id,"kind":kind,"node":node,"taken":false})

func walkable(p: Vector3, margin: float = 0.45) -> bool:
	if height_at(p.x,p.z)<0.25:
		return false
	for o in obstacles:
		if Vector2(p.x-o.x,p.z-o.y).length()<o.z+margin:
			return false
	return true

func path_to(a: Vector3, b: Vector3) -> PackedVector3Array:
	var start = Vector2i(roundi(a.x/2),roundi(a.z/2))
	var end = Vector2i(roundi(b.x/2),roundi(b.z/2))
	var result = PackedVector3Array()
	if not nav.is_in_boundsv(start) or not nav.is_in_boundsv(end):
		return result
	if nav.is_point_solid(start):
		for offset in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
			if nav.is_in_boundsv(start+offset) and not nav.is_point_solid(start+offset):
				start += offset
				break
	if nav.is_point_solid(end):
		return result
	for point in nav.get_point_path(start,end):
		result.append(ground(Vector3(point.x,0,point.y)))
	return result

func _process(_delta):
	var t = Time.get_ticks_msec()/1000.0
	if fire.visible:
		fire_light.light_energy = 1.4+sin(t*7)*0.2
		for i in range(fire.get_child_count()):
			fire.get_child(i).scale.y = 0.7+sin(t*8+i)*0.25
	for i in range(palms.size()):
		palms[i].rotation.z = sin(t*0.7+i)*0.009


