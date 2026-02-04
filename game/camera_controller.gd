extends Camera3D

## 相机控制器
## 管理相机轨道旋转和抽奖时的推镜动画

var rotation_speed: float = 0.1
var current_rotation: float = 0.0
var default_position: Vector3
var default_look_at: Vector3 = Vector3.ZERO

var is_focusing: bool = false

func _ready() -> void:
	default_position = position
	look_at(default_look_at)

func _process(delta: float) -> void:
	if not is_focusing:
		# 自动轨道旋转
		current_rotation += delta * rotation_speed
		
		var radius = 25.0
		var x = radius * sin(current_rotation)
		var z = radius * cos(current_rotation)
		var y = 10.0
		
		position = Vector3(x, y, z)
		look_at(default_look_at)

func focus_on_card(card: Node3D) -> void:
	is_focusing = true
	
	# 获取相机到卡片的初始向量
	var start_pos = position
	var target_pos = card.position + Vector3(0, 1, 4)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 推镜至卡片前方（带弧线轨迹）
	tween.tween_method(_move_camera_on_curve.bind(start_pos, target_pos), 0.0, 1.0, 2.0)\
		.set_ease(Tween.EaseType.EASE_IN_OUT)\
		.set_trans(Tween.TransitionType.TRANS_CUBIC)
	
	# 同时调整 FOV（增加戏剧性）
	tween.tween_property(self, "fov", 50.0, 2.0).set_ease(Tween.EaseType.EASE_OUT)
	
	await tween.finished

func _move_camera_on_curve(start: Vector3, end: Vector3, t: float) -> void:
	# Catmull-Rom 样条插值（平滑曲线）
	var mid_point = (start + end) / 2.0 + Vector3(0, 3, 0)
	var t2 = t * t
	var t3 = t2 * t
	
	# 二次贝塞尔曲线
	position = (1.0 - t) * (1.0 - t) * start + \
	           2.0 * (1.0 - t) * t * mid_point + \
	           t * t * end
	
	# 始终看向目标
	look_at(end - Vector3(0, 0, 4))

func reset_position() -> void:
	is_focusing = false
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", default_position, 1.5).set_ease(Tween.EaseType.EASE_IN_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_property(self, "fov", 60.0, 1.5)
	await tween.finished
