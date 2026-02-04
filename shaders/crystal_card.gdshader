shader_type spatial;
render_mode unshaded, cull_disabled, async_visible;

uniform sampler2D albedo_texture;
uniform vec4 albedo_color : source_color = vec4(0.1, 0.15, 0.3, 0.8);
uniform float metallic : hint_range(0.0, 1.0) = 0.9;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform vec3 rim_color : source_color = vec3(1.0, 0.84, 0.0);
uniform float rim_power : hint_range(0.0, 10.0) = 3.0;

uniform float time;

void fragment() {
	vec4 albedo = albedo_color * texture(albedo_texture, UV);
	
	// 菲涅尔效应（流金边缘）
	float rim = 1.0 - abs(dot(NORMAL, VIEW));
	rim = pow(rim, rim_power);
	
	vec3 final_color = mix(albedo.rgb, rim_color, rim * 0.6);
	
	// 动态光效（随时间变化的折射）
	float sparkle = sin(time * 2.0 + UV.x * 10.0) * cos(time * 1.5 + UV.y * 10.0);
	final_color += rim_color * sparkle * 0.1;
	
	ALBEDO = final_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	ALPHA = albedo.a + rim * 0.3;
	EMISSION = rim_color * rim * 0.5;
}
