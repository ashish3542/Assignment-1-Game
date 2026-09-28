extends RefCounted
## Hip-centered key poses: lower, sit with support, recline, then settle.
## Reversing the same timeline also handles an interrupted lie-down without a snap.
const TIMES=[0.0,0.24,0.36,0.48,0.76,1.0]
const HIPS=[Vector3(0,0.83,0),Vector3(0,0.40,0.08),Vector3(0,0.36,0.40),Vector3(0,0.19,0.72),Vector3(0,0.20,0.83),Vector3(0,0.20,0.83)]
const TILT=[0.0,-0.10,0.02,0.06,0.78,PI/2]
const THIGH=[0.0,1.40,1.90,1.48,0.76,0.08]
const KNEE=[0.0,-2.65,-1.50,-0.08,-0.10,-0.14]
const ARM=[0.0,0.65,0.20,-0.45,-0.65,-0.05]
const ELBOW=[-0.14,0.65,0.20,0.14,0.70,0.80]

static func apply(body: Node3D, amount: float):
	var t=clampf(amount,0,1)
	var index=0
	while index<TIMES.size()-2 and t>TIMES[index+1]: index+=1
	var weight=smoothstep(TIMES[index],TIMES[index+1],t)
	var angle=lerpf(TILT[index],TILT[index+1],weight)
	var hip=HIPS[index].lerp(HIPS[index+1],weight)
	var thigh=lerpf(THIGH[index],THIGH[index+1],weight)
	var knee=lerpf(KNEE[index],KNEE[index+1],weight)
	# Maintain sole clearance while the feet swing out of the crouch.
	var shin_angle=angle+thigh+knee
	var boot_extent=sqrt(pow(0.09*cos(shin_angle),2)+pow(0.15*sin(shin_angle),2))
	var sole_height=0.36*cos(angle+thigh)+0.38*cos(shin_angle)-0.05*sin(shin_angle)+boot_extent
	hip.y=maxf(hip.y,sole_height+0.04*smoothstep(0.0,0.24,t))
	# Tent bedding is higher than the leaf mat; lift only as the hips settle.
	hip.y+=(float(body.get_meta("sleep_height",0.20))-0.20)*smoothstep(0.20,0.48,t)
	body.rotation.x=angle
	body.rotation.z=0
	var offset=hip-Basis(Vector3.RIGHT,angle)*Vector3(0,0.83,0)
	body.position=offset.rotated(Vector3.UP,body.rotation.y)
	var settle=smoothstep(0.76,1.0,t)
	body.get_node("Head").rotation=Vector3(-0.06*settle,0.16*settle,0)
	for side in [-1,1]:
		body.get_node("Leg"+str(side)).rotation=Vector3(thigh,0,side*0.025*settle)
		body.get_node("Leg"+str(side)+"/Knee").rotation=Vector3(knee,0,0)
		# Hands move behind the hips for support, then relax over the abdomen.
		body.get_node("Arm"+str(side)).rotation=Vector3(lerpf(ARM[index],ARM[index+1],weight),0,lerpf(side*0.12,-side*0.24,settle))
		body.get_node("Arm"+str(side)+"/Elbow").rotation=Vector3(lerpf(ELBOW[index],ELBOW[index+1],weight)-side*0.08*settle,0,0)
	var breath=float(body.get_meta("rest_breath",0.0))
	body.get_node("Chest").scale.y=0.66*(1.0+sin(breath*1.7)*0.012*settle)
