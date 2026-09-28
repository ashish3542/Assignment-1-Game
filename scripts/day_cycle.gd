extends RefCounted
## One island hour per 90 seconds of ordinary play; sleep advances the same clock.
const SECONDS_PER_HOUR=90.0
var game
var hours=8.0
var daylight=1.0

func _init(g):
	game=g
	apply_light()

func update(delta: float):
	if game.mode=="play" and not game.actions.resting and game.actions.waking<=0:
		set_hours(hours+delta/SECONDS_PER_HOUR)

func set_hours(value: float):
	hours=maxf(0,value) if is_finite(value) else 8.0
	apply_light()

func label(value: float=-1) -> String:
	var time=hours if value<0 else value
	var minute=int(floor(fposmod(time,24)*60+0.001))
	return "Day %d / %02d:%02d" % [int(floor(time/24))+1,minute/60,minute%60]

func period() -> String:
	var h=fposmod(hours,24)
	if h<5 or h>=20: return "Night"
	if h<7: return "Dawn"
	if h<12: return "Morning"
	if h<17: return "Afternoon"
	return "Evening"

func apply_light():
	var w=game.world
	var h=fposmod(hours,24)
	var elevation=sin((h-6)/24*TAU)
	daylight=smoothstep(-0.12,0.25,elevation)
	var dusk=(1.0-smoothstep(0.0,0.4,absf(elevation)))*smoothstep(-0.25,0.0,elevation)
	w.sun.rotation_degrees=Vector3(-(h-6)*15,-38,0)
	w.sun.light_energy=maxf(0,elevation)*1.05
	w.sun.light_color=Color("ffb578").lerp(Color("fff0d0"),smoothstep(0.0,0.6,elevation))
	w.moon.light_energy=(1.0-daylight)*0.32
	w.moon_mesh.visible=daylight<0.6
	w.sky_mat.sky_top_color=Color("091629").lerp(Color("28648c"),daylight).lerp(Color("694969"),dusk*0.55)
	w.sky_mat.sky_horizon_color=Color("25394d").lerp(Color("cbd7cd"),daylight).lerp(Color("ef965d"),dusk*0.8)
	w.sky_mat.ground_horizon_color=w.sky_mat.sky_horizon_color
	w.sky_mat.ground_bottom_color=Color("101d2a").lerp(Color("244d53"),daylight)
	w.environment.ambient_light_color=Color("819cbf").lerp(Color("a1c7d0"),daylight)
	w.environment.ambient_light_energy=lerpf(0.23,0.43,daylight)
	w.environment.fog_light_color=Color("162639").lerp(Color("b3c9c1"),daylight).lerp(Color("b08275"),dusk*0.4)

func sleep_camera(elapsed: float):
	var w=game.world
	var p=game.player
	var camera=game.cine_camera
	camera.fov=58
	var focus=p.position+Vector3(0,0.55,0.65).rotated(Vector3.UP,p.body.rotation.y)
	var offset=Vector3(3.6,1.8,3.8).rotated(Vector3.UP,p.body.rotation.y)
	if game.actions.rest_kind=="tent":
		focus=w.tent_center+Vector3(0,0.55,0)
		offset=Vector3(0.2,1,5)
	if elapsed>=3 and elapsed<11:
		focus=w.camp+Vector3(0,2,-10)
		offset=Vector3(34,18,40).rotated(Vector3.UP,(elapsed-3)*0.025)
		camera.position=focus+offset
	else: camera.position=w.camera_position(focus,focus+offset)
	camera.look_at(focus)
	camera.current=true

func sleep_fade(elapsed: float) -> float:
	return maxf(1.0-clampf(elapsed/0.45,0,1),maxf(1.0-clampf(absf(elapsed-3)/0.3,0,1),1.0-clampf(absf(elapsed-11)/0.3,0,1)))
