shader_type spatial;
render_mode cull_disabled;
varying vec3 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(world_pos.x*0.12 + TIME*0.7)*0.14 + sin(world_pos.z*0.17-TIME*0.5)*0.1;
}
void fragment() {
	float wave = sin(world_pos.x*0.24 + world_pos.z*0.12 + TIME*0.8);
	float ripple = sin(world_pos.x*1.8+TIME) * sin(world_pos.z*1.3-TIME*0.7);
	float shallow = 1.0-smoothstep(64.0,120.0,length(world_pos.xz*vec2(0.9,1.15)));
	ALBEDO = mix(vec3(0.025,0.19,0.26),vec3(0.09,0.55,0.53),shallow) + wave*0.025;
	ROUGHNESS = 0.27;
	METALLIC = 0.22;
	NORMAL = normalize(vec3(ripple*0.1,0.98,wave*0.05));
}
