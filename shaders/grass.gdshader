shader_type spatial;
render_mode cull_disabled;
void vertex() {
	vec3 p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	VERTEX.x += sin(TIME*1.5+p.x*0.42+p.z*0.3)*UV.y*0.07;
}
void fragment() { ALBEDO=COLOR.rgb; ROUGHNESS=0.94; }
