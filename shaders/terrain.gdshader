shader_type spatial;
varying vec3 world_pos;
uniform vec4 sand_color : source_color = vec4(0.70,0.62,0.43,1.0);
uniform vec4 grass_color : source_color = vec4(0.24,0.36,0.15,1.0);
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
	vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex() { world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
	float macro=noise(world_pos.xz*0.23);
	float grass=smoothstep(1.8,3.2,world_pos.y+macro*0.9);
	float grain=noise(world_pos.xz*18.0);
	float detail=noise(world_pos.xz*3.7);
	ALBEDO=mix(sand_color.rgb,grass_color.rgb,grass)*(0.78+macro*0.23+detail*0.13+grain*0.08);
	ROUGHNESS=0.98;
}
