extends Node3D
class_name VortexLayout

## 斐波那契黄金螺旋布局算法
## 用于生成"以太星涡"的空间分布

var card_count: int = 50
var spiral_a: float = 0.5  ## 螺旋缩放参数
var spiral_b: float = 0.1  ## 螺旋增长率
var golden_angle: float = 137.508  ## 黄金角（度）
var orbit_radius_min: float = 5.0
var orbit_radius_max: float = 15.0
var vertical_amplitude: float = 3.0  ## Y轴波浪幅度

## 计算卡片的初始位置（基于黄金螺旋）
static func calculate_spiral_position(index: int, total: int, a: float = 0.5, b: float = 0.1) -> Vector3:
	var golden_angle_rad = deg_to_rad(137.508)
	var theta: float = index * golden_angle_rad
	var r: float = a * exp(b * theta)
	
	# 限制在合理范围内
	var max_r = 20.0
	r = min(r, max_r)
	
	var x = r * cos(theta)
	var z = r * sin(theta)
	var y = sin(theta * 2.0) * 3.0  # Y轴波浪运动
	
	return Vector3(x, y, z)

## 计算双螺旋位置（相位偏移）
static func calculate_double_helix_position(index: int, total: int, phase_offset: float = 0.0) -> Vector3:
	var golden_angle_rad = deg_to_rad(137.508)
	var theta: float = index * golden_angle_rad + phase_offset
	var r: float = 0.5 * exp(0.08 * theta)
	
	r = min(r, 18.0)
	
	var x = r * cos(theta)
	var z = r * sin(theta)
	var y = (index % 10 - 5.0) * 0.6  # 分层
	
	return Vector3(x, y, z)

## 获取轨道运动参数
static func get_orbit_parameters(index: int, total: int) -> Dictionary:
	var base_speed = 0.1
	var speed_variation = float(index) / float(total)
	
	return {
		"orbit_speed": base_speed + speed_variation * 0.2,
		"orbit_radius": 5.0 + float(index) / float(total) * 10.0,
		"orbit_offset": float(index) * 0.5,
		"vertical_speed": 0.5 + speed_variation * 0.3
	}
