extends Node3D
const M = preload("res://scripts/models.gd")
var rng = RandomNumberGenerator.new()
var obstacles: Array[Vector3] = []
var solid_rects: Array[Dictionary] = []
var tent_center=Vector3.ZERO
var shelter_stage=0
var shelter_frame: Node3D
var shelter_cloth: Node3D
var camp_furniture: Node3D
var fire_base: Node3D
var signal_station: Node3D
var forest_count=0
var ship_spot=Vector3(55,0,27)
var shipwreck: Node3D
var fire: Node3D
var fire_light: OmniLight3D
var beacon_light: OmniLight3D
var beacon_beam: MeshInstance3D
var plane: Node3D
var wreck_root: Node3D
var smoke: GPUParticles3D
var rest_mat: Node3D
var palms: Array[Node3D] = []
var camp = Vector3(-8,0,51)
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
	ship_spot = ground(ship_spot)
	_build_environment()
	_build_terrain()
	_build_camp()
	_build_landmarks()
	_build_foliage()
	load("res://scripts/wilderness.gd").grow(self)
	_build_grass()
	_build_pickups()
	nav.region = Rect2i(-100,-100,201,201)
	nav.cell_size = Vector2(1,1)
	nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	nav.update()
	for x in range(-100,101):
		for z in range(-100,101):
			if not walkable(Vector3(x,0,z),0.45):
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
	tent_center=ground(camp+Vector3(-5,0,-3))
	shelter_frame=Node3D.new()
	add_child(shelter_frame)
	shelter_frame.position=tent_center
	shelter_cloth=Node3D.new()
	add_child(shelter_cloth)
	shelter_cloth.position=tent_center
	camp_furniture=Node3D.new()
	add_child(camp_furniture)
	for side in [-1,1]:
		add_solid(tent_center+Vector3(side*1.2,0,0),Vector2(0.7,3.6),2.3,"shelter")
		for z in [-1.9,1.9]:
			M.beam(shelter_frame,Vector3(side*1.8,0,z),Vector3(0,2.3,z),0.055,Color("695139"))
		var tarp=M.box(shelter_cloth,Vector3(side*0.78,1.15,0),Vector3(0.07,2.7,3.4),Color("c38548"))
		tarp.rotation.z=side*0.64
	M.beam(shelter_frame,Vector3(0,2.3,-2),Vector3(0,2.3,2),0.065,Color("695139"))
	add_solid(tent_center+Vector3(0,0,-1.7),Vector2(3.1,0.22),2.3,"shelter")
	M.box(shelter_cloth,Vector3(0,0.04,0),Vector3(3.2,0.05,3.3),Color("4c5546"))
	var back=SurfaceTool.new()
	back.begin(Mesh.PRIMITIVE_TRIANGLES)
	for point in [Vector3(-1.6,0,-1.7),Vector3(0,2.3,-1.7),Vector3(1.6,0,-1.7)]: back.add_vertex(point)
	back.generate_normals()
	var cloth=M.mesh(shelter_cloth,back.commit(),Vector3.ZERO,Color("ad773e"))
	cloth.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED
	# A low branch bench and recovered crates only appear after the crew finishes.
	M.box(camp_furniture,ground(camp+Vector3(0,0,3),0.4),Vector3(3.2,0.3,0.6),Color("716047"))
	add_solid(camp+Vector3(0,0,3),Vector2(3.2,0.6),0.6,"furniture")
	for i in range(3):
		M.box(camp_furniture,ground(camp+Vector3(4+i*0.8,0,2),0.35),Vector3(0.7,0.7,0.7),Color("6c6550"))
	add_solid(camp+Vector3(4.8,0,2),Vector2(2.3,0.7),0.7,"furniture")
	var table_pos=ground(camp+Vector3(3,0,-4))
	M.box(camp_furniture,table_pos+Vector3(0,0.9,0),Vector3(2,0.12,1),Color("a38c64"))
	add_solid(table_pos,Vector2(2,1),1.0,"furniture")
	for x in [-0.8,0.8]: M.box(camp_furniture,table_pos+Vector3(x,0.45,0),Vector3(0.12,0.9,0.7),Color("625a44"))
	M.box(camp_furniture,tent_center+Vector3(0,0.10,0),Vector3(1.3,0.12,2.1),Color("71826c"))
	fire_base=Node3D.new()
	add_child(fire_base)
	for i in range(10):
		var a=i*TAU/10
		M.sphere(fire_base,camp+Vector3(cos(a)*0.95,0.1,sin(a)*0.95),Vector3(0.5,0.35,0.4),Color("74766a"))
	for i in range(3):
		var log_mesh=M.cylinder(fire_base,camp+Vector3(0,0.2,0),0.15,1.4,Color("514034"))
		log_mesh.rotation=Vector3(PI/2,i*PI/3,0)
	fire_base.visible=false
	fire=Node3D.new()
	add_child(fire)
	fire.position=camp
	for i in range(7):
		var f=M.sphere(fire,Vector3(rng.randf_range(-0.3,0.3),0.55,rng.randf_range(-0.3,0.3)),Vector3(0.3,1.0,0.3),Color("ffac39"))
		var fm=M.material(Color("ffac39"))
		fm.emission_enabled=true
		fm.emission=Color("ff681c")
		fm.emission_energy_multiplier=2
		f.material_override=fm
	fire.visible=false
	fire_light=OmniLight3D.new()
	fire_light.position=camp+Vector3(0,1.5,0)
	fire_light.light_color=Color("ffa23d")
	fire_light.omni_range=14
	fire_light.visible=false
	add_child(fire_light)
	set_shelter_progress(0)

func set_shelter_progress(progress: float):
	var stage=0 if progress<=0 else (1 if progress<0.55 else (2 if progress<1 else 3))
	var changed=stage!=shelter_stage
	shelter_stage=stage
	shelter_frame.visible=stage>=1
	shelter_frame.scale.y=clampf(progress/0.5,0.03,1)
	shelter_cloth.visible=stage>=2
	shelter_cloth.scale.z=clampf((progress-0.55)/0.25,0.03,1)
	camp_furniture.visible=stage>=3
	if changed and nav.region.size.x>0:
		# Rebuild only camp cells; new walls must affect NPC routes as well as movement.
		for x in range(int(camp.x)-13,int(camp.x)+14):
			for z in range(int(camp.z)-12,int(camp.z)+13):
				var cell=Vector2i(x,z)
				if nav.is_in_boundsv(cell): nav.set_point_solid(cell,not walkable(Vector3(x,0,z),0.45))

func solid_active(solid: Dictionary) -> bool:
	if solid.group=="shelter": return shelter_stage>=2
	if solid.group=="furniture": return shelter_stage>=3
	return true

func _build_landmarks():
	wreck_root=Node3D.new()
	wreck_root.name="CrashWreckage"
	add_child(wreck_root)
	plane = M.plane(wreck_root,true)
	plane.scale=Vector3(1.65,1.65,1.65)
	plane.position = ground(Vector3(-40,0,37),1.55)
	plane.rotation = Vector3(0.1,-0.5,-0.13)
	for z in [-6,-3,0,3,6]:
		var hull_point=plane.to_global(Vector3(0,0,z*0.7))
		obstacles.append(Vector3(hull_point.x,hull_point.z,1.8))
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
	# A salvaged signal mast is assembled only after Maya completes her work.
	signal_station=Node3D.new()
	add_child(signal_station)
	for x in [-1.1,1.1]:
		for z in [-1.1,1.1]:
			M.beam(signal_station,tower+Vector3(x,0,z),tower+Vector3(x*0.35,12,z*0.35),0.11,Color("747d73"))
	for h in [3,6,9]:
		M.beam(signal_station,tower+Vector3(-0.9,h,-0.9),tower+Vector3(0.9,h+2,0.9),0.07,Color("787d71"))
	M.box(signal_station,tower+Vector3(0,0.7,2.6),Vector3(1.5,1.4,1),Color("425855"))
	M.box(signal_station,tower+Vector3(0,1.1,3.12),Vector3(0.9,0.25,0.03),Color("c8893d"))
	M.cylinder(signal_station,tower+Vector3(0,12,0),1,0.3,Color("ded6b4"))
	beacon_light = OmniLight3D.new()
	beacon_light.position = tower+Vector3(0,12.5,0)
	beacon_light.light_color = Color("ffe6a0")
	beacon_light.omni_range = 25
	beacon_light.visible = false
	add_child(beacon_light)
	beacon_beam = M.cylinder(signal_station,tower+Vector3(0,27,0),0.35,30,Color("fff2be"),2)
	var glow = M.material(Color(1,0.9,0.55,0.19))
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon_beam.material_override = glow
	beacon_beam.visible = false
	signal_station.visible=false
	shipwreck=load("res://scripts/wilderness.gd").shipwreck(self)
	# A natural rock fishing ledge, no prebuilt pier or ranger outpost.
	for i in range(3): M.sphere(self,ground(fish_spot+Vector3(3+i,0,2),-0.15),Vector3(2,0.7,2),Color("777b68"))

func _build_foliage():
	for i in range(230):
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
	# Larger wreck footprints need clear approaches and room for their wings / hull.
	if Vector2(p.x+40,p.z-37).length()<17: return true
	if Vector2(p.x-ship_spot.x-7,p.z-ship_spot.z).length()<13: return true
	for target in [camp,fish_spot,salvage,tower,ship_spot,ship_spot+Vector3(-5,0,-7),wood_spot,Vector3(-29,0,35),Vector3(-40,0,37)]:
		if Vector2(p.x-target.x,p.z-target.z).length()<distance:
			return true
	var escape_path=Geometry2D.get_closest_point_to_segment(Vector2(p.x,p.z),Vector2(-29,35),Vector2(camp.x,camp.z+4))
	if escape_path.distance_to(Vector2(p.x,p.z))<2.5: return true
	# Keep the central cooperation corridor clear.
	return absf(p.x)<3 and p.z>-36 and p.z<54

func set_crash_visible(value: bool):
	wreck_root.visible=value
	smoke.emitting=value
	for p in pickups:
		if p.get("source","")=="plane": p.node.visible=value and not p.taken

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
		add_pickup("Wood",camp+Vector3(-9-i%4*2,0,-10-i/4*2),i)
	for i in range(12):
		add_pickup("Stone",camp+Vector3(5+i%4*2,0,6+i/4*2),i+20)
	for i in range(9):
		add_pickup("Scrap",salvage+Vector3(4+i%3*1.5,0,-3-i/3*1.5),i+40,"plane")
	add_pickup("Ration",salvage+Vector3(3,0,3),60,"plane")
	add_pickup("Ration",salvage+Vector3(6,0,3),61,"plane")
	for i in range(4):
		add_pickup("Cloth",salvage+Vector3(7+i%2*1.8,0,1+i/2*2),70+i,"plane")
		add_pickup("Rope",ship_spot+Vector3(-3+i%2*2,0,2+i/2*2),80+i,"ship")
		add_pickup("Wood",ship_spot+Vector3(-5+i%2*2,0,6+i/2*2),90+i,"ship")
		add_pickup("Scrap",ship_spot+Vector3(-3+i%2*2,0,-4+i/2*2),100+i,"ship")
	for i in range(12): add_pickup("Wood",camp+Vector3(-12-i%4*2,0,-17-i/4*2),110+i,"forest")
	add_pickup("Ration",ship_spot+Vector3(-4,0,0),125,"ship")

func add_pickup(kind: String, p: Vector3, id: int, source: String="wild"):
	if id<1000: p+=Vector3(rng.randf_range(-0.65,0.65),0,rng.randf_range(-0.65,0.65))
	# Place supplies on traversable ground rather than inside a trunk or hull.
	if not walkable(p,0.65):
		for radius in range(1,9):
			var found=false
			for angle in range(12):
				var candidate=p+Vector3(cos(angle*TAU/12),0,sin(angle*TAU/12))*radius
				if walkable(candidate,0.65): p=candidate; found=true; break
			if found: break
	var node = Node3D.new()
	add_child(node)
	node.position = ground(p,0.18)
	match kind:
		"Wood":
			var log_mesh = M.cylinder(node,Vector3.ZERO,0.13,1.2,Color("795337"))
			log_mesh.rotation.z = PI/2
			log_mesh.rotation.y=rng.randf()*TAU
		"Stone": M.sphere(node,Vector3.ZERO,Vector3(0.6,0.37,0.5),Color("b9b7a0"))
		"Scrap": M.box(node,Vector3.ZERO,Vector3(0.65,0.24,0.45),Color("acb9b3"))
		"Cloth":
			for j in range(3): M.box(node,Vector3(0,j*0.09,0),Vector3(0.85,0.09,0.65),Color("c38548").lightened(j*0.07))
		"Rope":
			var coil=TorusMesh.new()
			coil.inner_radius=0.16
			coil.outer_radius=0.35
			M.mesh(node,coil,Vector3.ZERO,Color("c6ad72"))
		_: M.box(node,Vector3.ZERO,Vector3(0.42,0.26,0.32),Color("d6a14a"))
	pickups.append({"id":id,"kind":kind,"node":node,"taken":false,"source":source})

func walkable(p: Vector3, margin: float = 0.45) -> bool:
	if height_at(p.x,p.z)<0.25:
		return false
	for o in obstacles:
		if Vector2(p.x-o.x,p.z-o.y).length()<o.z+margin:
			return false
	for solid in solid_rects:
		if not solid_active(solid): continue
		if solid.rect.grow(margin).has_point(Vector2(p.x,p.z)): return false
	return true

func add_solid(center: Vector3, size: Vector2, height: float, group: String=""):
	solid_rects.append({"rect":Rect2(Vector2(center.x,center.z)-size*0.5,size),"base":height_at(center.x,center.z),"height":height,"group":group})

func in_tent(p: Vector3) -> bool:
	return shelter_stage>=2 and absf(p.x-tent_center.x)<0.8 and p.z>tent_center.z-1.6 and p.z<tent_center.z+1.7

func move_character(start: Vector3, displacement: Vector3, margin: float=0.45) -> Vector3:
	# Substeps prevent high speed or a slow frame from skipping a thin wall.
	var flat=Vector3(displacement.x,0,displacement.z)
	var steps=maxi(1,ceili(flat.length()/0.16))
	var step=flat/float(steps)
	var result=start
	for i in range(steps):
		var candidate=result+step
		if walkable(candidate,margin): result=candidate
		else:
			var along_x=result+Vector3(step.x,0,0)
			var along_z=result+Vector3(0,0,step.z)
			if absf(step.x)>0.0001 and walkable(along_x,margin): result=along_x
			elif absf(step.z)>0.0001 and walkable(along_z,margin): result=along_z
	return ground(result)

func clear_segment(a: Vector3, b: Vector3, margin: float=0.38) -> bool:
	var steps=maxi(1,ceili(a.distance_to(b)/0.15))
	for i in range(1,steps+1):
		if not walkable(a.lerp(b,float(i)/steps),margin): return false
	return true

func camera_position(focus: Vector3, desired: Vector3) -> Vector3:
	var steps=maxi(1,ceili(focus.distance_to(desired)/0.12))
	var last=focus
	for i in range(1,steps+1):
		var p=focus.lerp(desired,float(i)/steps)
		for solid in solid_rects:
			if not solid_active(solid): continue
			if p.y>solid.base and p.y<solid.base+solid.height+0.15 and solid.rect.grow(0.15).has_point(Vector2(p.x,p.z)):
				return last
		last=p
	return desired

func path_to(a: Vector3, b: Vector3) -> PackedVector3Array:
	var start = Vector2i(roundi(a.x),roundi(a.z))
	var end = Vector2i(roundi(b.x),roundi(b.z))
	var result = PackedVector3Array()
	if not nav.is_in_boundsv(start) or not nav.is_in_boundsv(end):
		return result
	start=nearest_nav_point(a,start)
	end=nearest_nav_point(b,end)
	if nav.is_point_solid(start) or nav.is_point_solid(end): return result
	for point in nav.get_point_path(start,end):
		result.append(ground(Vector3(point.x,0,point.y)))
	if not result.is_empty() and walkable(b,0.38) and clear_segment(result[result.size()-1],b): result.append(ground(b))
	return result

func nearest_nav_point(p: Vector3, cell: Vector2i) -> Vector2i:
	var best=cell
	var distance=INF
	for x in range(-2,3):
		for z in range(-2,3):
			var c=cell+Vector2i(x,z)
			if not nav.is_in_boundsv(c) or nav.is_point_solid(c): continue
			var q=ground(Vector3(c.x,0,c.y))
			if p.distance_to(q)<distance and clear_segment(p,q):
				best=c
				distance=p.distance_to(q)
	return best

func _process(_delta):
	var t = Time.get_ticks_msec()/1000.0
	if fire.visible:
		fire_light.light_energy = 1.4+sin(t*7)*0.2
		for i in range(fire.get_child_count()):
			fire.get_child(i).scale.y = 0.7+sin(t*8+i)*0.25
	for i in range(palms.size()):
		palms[i].rotation.z = sin(t*0.7+i)*0.009



func place_rest_mat(center: Vector3, angle: float):
	if not is_instance_valid(rest_mat):
		rest_mat=Node3D.new()
		rest_mat.name="LeafRestMat"
		add_child(rest_mat)
		for i in range(12):
			var leaf=M.box(rest_mat,Vector3(0,0.035+i%2*0.01,-1.0+i*0.18),Vector3(1.22,0.025,0.24),Color("657345") if i%2==0 else Color("7a8652"))
			leaf.rotation.y=0.12 if i%2==0 else -0.12
		M.box(rest_mat,Vector3(0,0.04,0.87),Vector3(0.5,0.03,0.28),Color("928765"))
	rest_mat.position=ground(center)
	rest_mat.rotation.y=angle
	rest_mat.visible=true
