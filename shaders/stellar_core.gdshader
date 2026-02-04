shader_type spatial;
render_mode cull_disabled, blend_add, unshaded;

uniform float u_time = 0.0;

varying vec3 v_normal;
varying vec3 v_position;
varying vec2 v_uv;

void vertex() {
	v_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	v_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_uv = UV;
}

// Simple noise function
float noise(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

void fragment() {
	// Luxury Gold Color Palette
	vec3 gold_low = vec3(0.83, 0.68, 0.21);  // Metallic Gold
	vec3 gold_high = vec3(1.0, 0.9, 0.5);    // Bright Gold
	
	// Create a pulsing liquid gold effect
	float n = noise(v_position * 0.01 + u_time * 0.5);
	float pulse = 0.5 + 0.5 * sin(u_time * 2.0 + v_position.y * 0.01);
	
	// Fresnel effect
	vec3 normal = normalize(v_normal);
	vec3 view_dir = normalize(VERTEX - CAMERA_POSITION_WORLD);
	float fresnel = pow(1.0 - abs(dot(normal, view_dir)), 2.0);
	
	// Mix colors, making core brighter
	vec3 color = mix(gold_low, gold_high, pulse * n);
	color += fresnel * vec3(1.0, 0.8, 0.4) * 0.8;  // Overlay gold highlight
	
	// Add transparency variation for energy effect
	float alpha = 0.6 + 0.4 * n;
	
	ALBEDO = color;
	ALPHA = alpha;
	EMISSION = color * (1.0 + fresnel);
}
