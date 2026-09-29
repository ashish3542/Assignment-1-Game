extends RefCounted
const M=preload("res://scripts/models.gd")
const Forest=preload("res://scripts/wilderness.gd")

static func build(w):
	var state=w.rng.state
	w.rng.seed=81024
	var trunks=[]; var crowns=[]
	for i in range(780):
		var p=Vector3(w.rng.randf_range(-133,133),0,w.rng.randf_range(-242,-68))
		if w.height_at(p.x,p.z)<2 or absf(p.x)<5: continue
		if Vector2(p.x+18,p.z+105).length()<20 or Vector2(p.x+80,p.z+150).length()<23: continue
		var crowded=false
		for o in w.obstacles:
			if Vector2(p.x-o.x,p.z-o.y).length()<3.0: crowded=true; break
		if crowded: continue
		p=w.ground(p)
		var height=w.rng.randf_range(5,11)
		trunks.append(Transform3D(Basis.from_scale(Vector3(0.45,height,0.45)),p+Vector3(0,height/2,0)))
		crowns.append(Transform3D(Basis.from_scale(Vector3(5,4,5)),p+Vector3(0,height,0)))
		w.obstacles.append(Vector3(p.x,p.z,0.32))
	var trunk=CylinderMesh.new(); trunk.height=1; trunk.radial_segments=7
	Forest.instances(w,trunk,trunks,Color("645d41"))
	var crown=SphereMesh.new(); crown.radius=0.5; crown.height=1; crown.radial_segments=10; crown.rings=5
	Forest.instances(w,crown,crowns,Color("426b38"))
	w.forest_count+=trunks.size()
	# A shallow marsh pool is scenery with a blocked footprint; reptiles roam its banks.
	var pool=w.ground(Vector3(-80,0,-150),0.04)
	M.sphere(w,pool,Vector3(18,0.14,13),Color("365d55"))
	w.obstacles.append(Vector3(pool.x,pool.z,8.8))
	for i in range(28):
		var angle=i*TAU/28
		var point=w.ground(pool+Vector3(cos(angle)*11,0,sin(angle)*9))
		M.beam(w,point,point+Vector3(0.15,1.5,0),0.025,Color("82884b"))
		M.cylinder(w,point+Vector3(0.15,1.45,0),0.065,0.35,Color("665638"))
	for i in range(22):
		var point=w.ground(Vector3(w.rng.randf_range(40,100),0,w.rng.randf_range(-210,-120)))
		if w.height_at(point.x,point.z)<2: continue
		M.sphere(w,point,Vector3(3,2.5,3),Color("72796a"))
		w.obstacles.append(Vector3(point.x,point.z,1.3))
	w.rng.state=state

static func navigation(w):
	w.nav.region=Rect2i(-180,-280,361,385)
	w.nav.cell_size=Vector2.ONE
	w.nav.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	w.nav.update()
	for x in range(-180,181):
		for z in range(-280,105):
			if w.height_at(x,z)<0.25: w.nav.set_point_solid(Vector2i(x,z))
	# Rasterize only each obstacle's small bounding box instead of scanning every tree per cell.
	for obstacle in w.obstacles:
		var radius=obstacle.z+0.45
		for x in range(floori(obstacle.x-radius),ceili(obstacle.x+radius)+1):
			for z in range(floori(obstacle.y-radius),ceili(obstacle.y+radius)+1):
				var cell=Vector2i(x,z)
				if w.nav.is_in_boundsv(cell) and Vector2(x-obstacle.x,z-obstacle.y).length()<radius: w.nav.set_point_solid(cell)
	for solid in w.solid_rects:
		if not w.solid_active(solid): continue
		var rect=solid.rect.grow(0.45)
		for x in range(floori(rect.position.x),ceili(rect.end.x)+1):
			for z in range(floori(rect.position.y),ceili(rect.end.y)+1):
				var cell=Vector2i(x,z)
				if w.nav.is_in_boundsv(cell) and rect.has_point(Vector2(x,z)): w.nav.set_point_solid(cell)
