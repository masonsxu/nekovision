extends GPUParticles3D

## 星光粒子效果
## 用于增强抽奖绽放仪式的视觉冲击力

func _ready() -> void:
	# 配置粒子系统
	emitting = false
	
	amount = 100
	lifetime = 2.0
	process_material = create_particle_material()
	
	# 设置粒子形状
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(5.0, 5.0, 5.0)
	
	# 暂时禁用粒子，等待绽放仪式时触发

func create_particle_material() -> ParticleProcessMaterial:
	var material = ParticleProcessMaterial.new()
	
	# 发射设置
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 2.0
	
	# 重力
	material.gravity = Vector3(0, -2.0, 0)
	
	# 初始速度
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	
	# 角速度
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	
	# 颜色渐变（金色 → 白色 → 消失）
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.84, 0.0, 1.0))
	gradient.add_point(0.3, Color(1.0, 1.0, 0.8, 0.8))
	gradient.add_point(1.0, Color(1.0, 0.84, 0.0, 0.0))
	material.color_ramp = gradient
	
	# 缩放曲线
	material.scale_min = 0.1
	material.scale_max = 0.3
	
	material.tangential_accel_min = -5.0
	material.tangential_accel_max = 5.0
	
	return material

func burst() -> void:
	# 爆发粒子
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	emitting = false
