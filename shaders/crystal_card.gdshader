shader_type spatial;
render_mode cull_disabled, blend_mix;

uniform vec4 albedo_color : source_color = vec4(0.1, 0.15, 0.3, 0.85);
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform vec3 rim_color : source_color = vec3(1.0, 0.84, 0.0);
uniform float rim_power : hint_range(0.0, 15.0) = 5.0;
uniform float rim_intensity : hint_range(0.0, 2.0) = 1.2;

uniform float time;
uniform float sparkle_speed : hint_range(0.1, 5.0) = 2.0;
uniform float rainbow_intensity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	// 菲涅尔效应（流金边缘）
	float rim = 1.0 - max(0.0, dot(NORMAL, VIEW));
	rim = pow(rim, rim_power);
	
	// 彩虹色流光效果
	float rainbow = sin(UV.x * 3.14159 * 2.0 + time) * 0.5 + 0.5;
	vec3 rainbow_color = vec3(
		sin(rainbow * 6.28 + 0.0) * 0.5 + 0.5,
		sin(rainbow * 6.28 + 2.094) * 0.5 + 0.5,
		sin(rainbow * 6.28 + 4.188) * 0.5 + 0.5
	);
	
	// 动态闪光效果（珠光噪点）
	float sparkle1 = sin(time * sparkle_speed + UV.x * 15.0) * cos(time * sparkle_speed * 1.3 + UV.y * 15.0);
	float sparkle2 = cos(time * sparkle_speed * 0.7 + UV.x * 20.0) * sin(time * sparkle_speed * 0.9 + UV.y * 20.0);
	float sparkle = (sparkle1 + sparkle2) * 0.5;
	
	// 组合颜色
	vec3 base_color = albedo_color.rgb;
	vec3 rim_effect = rim_color * rim * rim_intensity;
	vec3 rainbow_effect = rainbow_color * rainbow * 0.4;
	vec3 sparkle_effect = rim_color * sparkle * 0.15;
	
	vec3 final_color = base_color + rim_effect + rainbow_effect + sparkle_effect;
	
	// 增强自发光（流光溢彩效果）
	float emission_intensity = rim * 1.5 + sparkle * 0.3;
	vec3 final_emission = rim_color * emission_intensity + rainbow_color * rainbow * 0.2;
	
	ALBEDO = final_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	ALPHA = albedo_color.a + rim * 0.2;
	EMISSION = final_emission;
	
	// 增强法线细节（模拟玻璃折射）
	NORMAL = normalize(NORMAL + vec3(sparkle * 0.05));
}
