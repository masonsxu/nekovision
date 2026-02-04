shader_type spatial;
render_mode blend_add, unshaded;
cull_disabled;

uniform float u_time = 0.0;

varying vec3 v_color;
varying float v_opacity;

void vertex() {
	// Add custom color attribute from instance
	v_color = COLOR.rgb;
	v_opacity = COLOR.a;
	
	// Add subtle movement to particles
	vec3 pos = VERTEX;
	float angle = u_time * 0.1 + length(pos.xz) * 0.001;
	float s = sin(angle);
	float c = cos(angle);
	
	// Rotate particles around Y axis
	float nx = pos.x * c - pos.z * s;
	float nz = pos.x * s + pos.z * c;
	pos.x = nx;
	pos.z = nz;
	
	// Vertical oscillation
	pos.y += sin(u_time + pos.x * 0.01) * 20.0;
	
	v_opacity = 0.4 + 0.4 * sin(u_time + pos.x);
	
	VERTEX = pos;
}

void fragment() {
	// Circular particles
	float dist = length(POINT_COORD - vec2(0.5));
	if (dist > 0.5) {
		discard;
	}
	
	// Soft edges
	float strength = 1.0 - smoothstep(0.0, 0.5, dist);
	
	EMISSION = v_color;
	ALPHA = strength * v_opacity;
}
