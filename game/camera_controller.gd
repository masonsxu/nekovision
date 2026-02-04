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
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 推镜至卡片前方
	var target_pos = card.position + Vector3(0, 0, 3)
	tween.tween_property(self, "position", target_pos, 1.5).set_ease(Tween.EaseType.EASE_IN_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_callback(func(): look_at(card.position))
	
	await tween.finished

func reset_position() -> void:
	is_focusing = false
	
	var tween = create_tween()
	tween.tween_property(self, "position", default_position, 1.0)
	await tween.finished
