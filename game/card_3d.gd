extends Node3D

## 3D卡片控制器
## 管理单个奖品的展示和动画

var prize_data: Dictionary = {}
var orbit_params: Dictionary = {}
var orbit_time: float = 0.0
var base_position: Vector3
var rotation_speed: float = 0.5

@onready var mesh_instance = $MeshInstance3D
@onready var label_3d = $Label3D

var shader_time: float = 0.0

func _ready() -> void:
	base_position = position

func set_prize_data(data: Dictionary) -> void:
	prize_data = data
	
	# 设置卡片颜色（如果存在）
	if data.has("color") and mesh_instance:
		var material = mesh_instance.get_active_material(0)
		if material:
			material.albedo_color = data.color
	
	# 设置3D标签
	if label_3d and data.has("name"):
		label_3d.text = data.name

func set_orbit_parameters(params: Dictionary) -> void:
	orbit_params = params
	rotation_speed = params.get("orbit_speed", 0.5)

func orbit_update(delta: float) -> void:
	orbit_time += delta * rotation_speed
	shader_time += delta
	
	# 更新着色器时间参数
	if mesh_instance and mesh_instance.get_active_material(0):
		var material = mesh_instance.get_active_material(0)
		if material is ShaderMaterial:
			material.set_shader_parameter("time", shader_time)
	
	# 围绕中心旋转
	var orbit_radius = orbit_params.get("orbit_radius", 5.0)
	var offset_angle = orbit_params.get("orbit_offset", 0.0)
	
	var current_angle = orbit_time + offset_angle
	var x = base_position.x + orbit_radius * sin(current_angle)
	var z = base_position.z + orbit_radius * cos(current_angle)
	var y = base_position.y + sin(current_angle * 2.0) * 0.5
	
	position = Vector3(x, y, z)
	
	# 自转
	rotate_y(delta * rotation_speed)

func accelerate(multiplier: float) -> void:
	rotation_speed *= multiplier

func _on_mouse_entered() -> void:
	# 鼠标悬停效果
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.2)

func _on_mouse_exited() -> void:
	# 恢复原始大小
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.2)
