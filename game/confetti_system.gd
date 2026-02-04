extends Node3D

## Confetti 粒子系统（五彩纸屑效果）
## 从 canvas-confetti 库迁移到 Godot

signal confetti_finished

var confetti_particles: Array[Dictionary] = []
var is_emitting: bool = false
var emission_time: float = 0.0
var lifetime: float = 3.0

# Confetti 颜色配置
var confetti_colors: Array[Color] = [
	Color(1.0, 0.3, 0.3),  # Red
	Color(1.0, 0.6, 0.0),  # Orange
	Color(1.0, 1.0, 0.3),  # Yellow
	Color(0.3, 1.0, 0.3),  # Green
	Color(0.3, 0.6, 1.0),  # Blue
	Color(0.8, 0.3, 1.0),  # Purple
]

func _ready() -> void:
	pass

## 从左侧发射
func fire_left(angle: float = 60.0, spread: float = 55.0, particle_count: int = 2) -> void:
	_fire_from_side(Vector3(-1.0, 0.0, 0.0), angle, spread, particle_count)

## 从右侧发射
func fire_right(angle: float = 120.0, spread: float = 55.0, particle_count: int = 2) -> void:
	_fire_from_side(Vector3(1.0, 0.0, 0.0), angle, spread, particle_count)

## 从中心发射
func fire_center(spread: float = 26.0, start_velocity: float = 55.0, particle_count: int = 50) -> void:
	_fire_from_center(spread, start_velocity, particle_count)

## 完整的 confetti 效果（原 log-lottery 实现）
func confetti_fire(duration: float = 3.0) -> void:
	var end_time = Time.get_time_dict_from_system()["second"] + duration
	
	# 持续发射
	while Time.get_time_dict_from_system()["second"] < end_time:
		fire_left()
		fire_right()
		await get_tree().process_frame
		await get_tree().create_timer(0.05).timeout
	
	# 中心爆发
	fire_center(26.0, 55.0, 50)
	fire_center(60.0, 45.0, 40)
	fire_center(100.0, 35.0, 70)
	fire_center(120.0, 25.0, 20)
	fire_center(120.0, 45.0, 20)

func _fire_from_side(direction: Vector3, angle: float, spread: float, particle_count: int) -> void:
	for i in range(particle_count):
		_spawn_confetti(direction, deg_to_rad(angle), deg_to_rad(spread))

func _fire_from_center(spread: float, start_velocity: float, particle_count: int) -> void:
	var origin_y = 0.7
	for i in range(particle_count):
		_spawn_center_confetti(origin_y, deg_to_rad(spread), start_velocity)

func _spawn_confetti(direction: Vector3, base_angle: float, spread: float) -> void:
	var particle = _create_confetti_particle()
	
	# 随机角度扩散
	var angle = base_angle + randf_range(-spread / 2.0, spread / 2.0)
	
	# 计算速度向量
	var velocity = Vector3(
		direction.x * cos(angle),
		sin(angle) * 0.5 + 0.5,
		direction.z * sin(angle)
	).normalized() * randf_range(30.0, 50.0)
	
	particle["velocity"] = velocity
	particle["position"] = direction * 10.0
	particle["lifetime"] = randf_range(2.0, 3.0)
	particle["rotation"] = randf() * 360.0
	particle["rotation_speed"] = randf_range(-180.0, 180.0)
	
	confetti_particles.append(particle)

func _spawn_center_confetti(origin_y: float, spread: float, start_velocity: float) -> void:
	var particle = _create_confetti_particle()
	
	# 随机方向
	var angle = randf_range(-spread / 2.0, spread / 2.0) * PI / 180.0
	
	# 计算速度向量（从中心向上发射）
	var velocity = Vector3(
		cos(angle) * 0.5,
		1.0,
		sin(angle) * 0.5
	).normalized() * start_velocity * randf_range(0.8, 1.2)
	
	particle["velocity"] = velocity
	particle["position"] = Vector3(0, origin_y * 10.0, 0)
	particle["lifetime"] = randf_range(2.0, 3.0)
	particle["rotation"] = randf() * 360.0
	particle["rotation_speed"] = randf_range(-180.0, 180.0)
	
	confetti_particles.append(particle)

func _create_confetti_particle() -> Dictionary:
	return {
		"mesh": QuadMesh.new(),
		"material": null,
		"color": confetti_colors.pick_random(),
		"velocity": Vector3.ZERO,
		"position": Vector3.ZERO,
		"lifetime": 0.0,
		"rotation": 0.0,
		"rotation_speed": 0.0,
		"decay": randf_range(0.89, 0.98)
	}

func _process(delta: float) -> void:
	if confetti_particles.is_empty():
		return
	
	# 更新所有粒子
	for i in range(confetti_particles.size() - 1, -1, -1):
		var particle = confetti_particles[i]
		
		# 更新生命周期
		particle["lifetime"] -= delta
		
		# 应用重力
		particle["velocity"].y -= 9.8 * delta
		
		# 应用阻力
		particle["velocity"] *= particle["decay"]
		
		# 更新位置
		particle["position"] += particle["velocity"] * delta
		
		# 更新旋转
		particle["rotation"] += particle["rotation_speed"] * delta
		
		# 移除死亡的粒子
		if particle["lifetime"] <= 0:
			confetti_particles.remove_at(i)
	
	# 如果粒子全部消失，发送完成信号
	if confetti_particles.is_empty() and is_emitting:
		is_emitting = false
		confetti_finished.emit()
