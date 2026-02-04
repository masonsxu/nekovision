extends Node3D
class_name LayoutAlgorithm

## 3D 布局算法集合
## 从 log-lottery 的 Three.js 实现迁移到 Godot

enum LayoutType {
	SPHERE,    ## 球体布局
	VORTEX,    ## 以太星涡布局
	GRID,      ## 网格布局
	HELIX,     ## 螺旋布局
	TABLE      ## 表格布局
}

## 创建球体布局（原 log-lottery 实现）
static func create_sphere_vertices(objects_length: int, radius: float = 800.0) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	
	for i in range(objects_length):
		var phi = acos(-1.0 + (2.0 * i) / objects_length)
		var theta = sqrt(objects_length * PI) * phi
		
		var x = radius * cos(theta) * sin(phi)
		var y = radius * sin(theta) * sin(phi)
		var z = -radius * cos(phi)
		
		positions.append(Vector3(x, y, z))
	
	return positions

## 创建以太星涡布局（原 log-lottery 实现 + 优化）
static func create_vortex_vertices(objects_length: int, base_radius: float = 400.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var golden_angle = deg_to_rad(137.508)
	
	for i in range(objects_length):
		var t = float(i) / float(objects_length)
		var angle = i * golden_angle
		
		# 半径随高度变化，形成漏斗状
		var radius = base_radius + 1200.0 * pow(t, 1.5)
		var y = (t - 0.5) * 2000.0
		
		# 双螺旋偏移
		var spiral_offset = (1.0 if i % 2 == 0 else -1.0) * 100.0 * (1.0 - t)
		var x = (radius + spiral_offset) * cos(angle)
		var z = (radius + spiral_offset) * sin(angle)
		
		# 计算朝向（看向星涡中心）
		var look_at_target = Vector3(0, y, 0)
		var position = Vector3(x, y, z)
		var rotation = _calculate_rotation_to_look_at(position, look_at_target)
		
		# 额外的艺术旋转
		rotation.z += (t - 0.5) * 0.5
		
		result.append({
			"position": position,
			"rotation": rotation,
			"index": i
		})
	
	return result

## 创建螺旋布局
static func create_helix_vertices(objects_length: int, radius: float = 600.0, height: float = 2000.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for i in range(objects_length):
		var t = float(i) / float(objects_length)
		var angle = i * deg_to_rad(60.0)  # 每个卡片60度
		
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var y = t * height - height / 2.0
		
		var position = Vector3(x, y, z)
		var look_at_target = Vector3(0, y, 0)
		var rotation = _calculate_rotation_to_look_at(position, look_at_target)
		
		result.append({
			"position": position,
			"rotation": rotation,
			"index": i
		})
	
	return result

## 创建网格布局
static func create_grid_vertices(objects_length: int, spacing: float = 150.0) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	var grid_size = ceil(sqrt(objects_length))
	var offset = (grid_size * spacing) / 2.0
	
	for i in range(objects_length):
		var row = i / grid_size
		var col = i % grid_size
		
		var x = col * spacing - offset
		var y = row * spacing - offset
		var z = 0.0
		
		positions.append(Vector3(x, y, z))
	
	return positions

## 计算朝向目标的旋转
static func _calculate_rotation_to_look_at(from: Vector3, to: Vector3) -> Vector3:
	var direction = (to - from).normalized()
	var rotation = Vector3.ZERO
	
	rotation.y = atan2(direction.x, direction.z)
	rotation.x = asin(-direction.y)
	
	return rotation

## 创建表格布局（原 log-lottery 实现）
static func create_table_vertices(table_data: Array, row_count: int, card_size: Vector2) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	
	for i in range(table_data.size()):
		var x = table_data[i].x * (card_size.x + 40.0) - row_count * 90.0
		var y = -table_data[i].y * (card_size.y + 20.0) + 1000.0
		var z = 0.0
		
		positions.append(Vector3(x, y, z))
	
	return positions
