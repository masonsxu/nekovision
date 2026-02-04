extends Node3D

## log-lottery 主控制器（Godot 重写版）
## 整合 3D 布局、动画、着色器、Confetti 等

signal layout_changed(layout_type: LayoutAlgorithm.LayoutType)
signal card_selected(index: int)

const CARD_COUNT = 50
const DEFAULT_RADIUS = 800.0

@onready var camera = $Camera3D
@onready var card_container = $CardContainer
@onready var stellar_core = $StellarCore
@onready var stardust_container = $StardustContainer
@onready var confetti_system = $ConfettiSystem
@onready var ui_layer = $UILayer

var person_cards: Array[Node3D] = []
var current_layout: LayoutAlgorithm.LayoutType = LayoutAlgorithm.LayoutType.SPHERE
var layout_tween: Tween
var is_animating: bool = false

## 配置数据
var person_list: Array[Dictionary] = []

func _ready() -> void:
	_setup_scene()
	_generate_cards()
	_switch_to_layout(LayoutAlgorithm.LayoutType.SPHERE)
	_connect_signals()

func _setup_scene() -> void:
	# 设置环境
	var world_env = WorldEnvironment.new()
	var env = _create_environment()
	world_env.environment = env
	add_child(world_env)
	
	# 设置相机
	camera.position = Vector3(0, 0, 3000)
	camera.look_at(Vector3.ZERO)

func _create_environment() -> Environment:
	var env = Environment.new()
	
	# 背景色（午夜蓝）
	env.background_color = Color(0.02, 0.04, 0.1, 1.0)
	env.background_mode = Environment.BG_COLOR
	
	# 启用后处理
	env.glow_enabled = true
	env.glow_strength = 1.5
	env.glow_bloom = 0.3
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	
	# DOF 在 Godot 4.6 中需要使用 CameraAttributes
	# 暂时禁用，后续可通过 CameraAttributesDOF 添加
	
	return env

## 生成人员卡片
func _generate_cards() -> void:
	var card_scene = preload("res://scenes/PersonCard.tscn")
	
	for i in range(CARD_COUNT):
		var card = card_scene.instantiate()
		
		# 设置模拟数据
		var person_data = {
			"index": i,
			"name": "员工 %d" % (i + 1),
			"avatar": ""  # TODO: 加载真实头像
		}
		
		# 连接信号
		card.card_clicked.connect(_on_card_clicked)
		
		# 添加到场景
		card_container.add_child(card)
		person_cards.append(card)
		
		# 延迟设置数据（确保节点完全初始化）
		card.set_person_data.call_deferred(person_data)

## 切换布局
func switch_layout(layout_type: LayoutAlgorithm.LayoutType) -> void:
	if is_animating:
		return
	
	is_animating = true
	current_layout = layout_type
	
	# 停止之前的动画
	if layout_tween and layout_tween.is_valid():
		layout_tween.kill()
	
	match layout_type:
		LayoutAlgorithm.LayoutType.SPHERE:
			_animate_to_sphere()
		LayoutAlgorithm.LayoutType.VORTEX:
			_animate_to_vortex()
		LayoutAlgorithm.LayoutType.GRID:
			_animate_to_grid()
		LayoutAlgorithm.LayoutType.HELIX:
			_animate_to_helix()
		LayoutAlgorithm.LayoutType.TABLE:
			_animate_to_table()
	
	layout_changed.emit(layout_type)

## 动画到球体布局
func _animate_to_sphere() -> void:
	var positions = LayoutAlgorithm.create_sphere_vertices(person_cards.size(), DEFAULT_RADIUS)
	
	layout_tween = create_tween()
	layout_tween.set_parallel(true)
	
	for i in range(person_cards.size()):
		var card = person_cards[i]
		var target_pos = positions[i]
		
		# 位置动画
		layout_tween.tween_property(card, "position", target_pos, 1.5)\
			.set_ease(Tween.EaseType.EASE_IN_OUT)\
			.set_trans(Tween.TransitionType.TRANS_CUBIC)
		
		# 旋转动画（面向中心）
		var look_at_rotation = _calculate_look_at_rotation(target_pos, Vector3.ZERO)
		layout_tween.tween_property(card, "rotation_degrees", look_at_rotation, 1.5)
	
	await layout_tween.finished
	is_animating = false

## 动画到星涡布局
func _animate_to_vortex() -> void:
	var layout_data = LayoutAlgorithm.create_vortex_vertices(person_cards.size(), 400.0)
	
	layout_tween = create_tween()
	layout_tween.set_parallel(true)
	
	for i in range(person_cards.size()):
		var card = person_cards[i]
		var data = layout_data[i]
		
		card.set_layout_data(data)
		
		layout_tween.tween_property(card, "position", data["position"], 2.0)\
			.set_ease(Tween.EaseType.EASE_IN_OUT)\
			.set_trans(Tween.TransitionType.TRANS_CUBIC)
		
		var rot_deg = Vector3(
			rad_to_deg(data["rotation"].x),
			rad_to_deg(data["rotation"].y),
			rad_to_deg(data["rotation"].z)
		)
		layout_tween.tween_property(card, "rotation_degrees", rot_deg, 2.0)
	
	await layout_tween.finished
	is_animating = false

## 动画到网格布局
func _animate_to_grid() -> void:
	var positions = LayoutAlgorithm.create_grid_vertices(person_cards.size(), 150.0)
	
	layout_tween = create_tween()
	layout_tween.set_parallel(true)
	
	for i in range(person_cards.size()):
		var card = person_cards[i]
		
		layout_tween.tween_property(card, "position", positions[i], 1.5)
		layout_tween.tween_property(card, "rotation_degrees", Vector3.ZERO, 1.5)
	
	await layout_tween.finished
	is_animating = false

## 动画到螺旋布局
func _animate_to_helix() -> void:
	var layout_data = LayoutAlgorithm.create_helix_vertices(person_cards.size(), 600.0, 2000.0)
	
	layout_tween = create_tween()
	layout_tween.set_parallel(true)
	
	for i in range(person_cards.size()):
		var card = person_cards[i]
		var data = layout_data[i]
		
		layout_tween.tween_property(card, "position", data["position"], 1.8)
		layout_tween.tween_property(card, "rotation_degrees", 
			Vector3(rad_to_deg(data["rotation"].x), rad_to_deg(data["rotation"].y), 0), 1.8)
	
	await layout_tween.finished
	is_animating = false

## 动画到表格布局
func _animate_to_table() -> void:
	# TODO: 实现表格布局动画
	is_animating = false

## 抽奖动画
func start_lottery_animation() -> void:
	if is_animating:
		return
	
	is_animating = true
	
	# 1. 加速旋转
	# 2. 停止并选中中奖者
	# 3. Confetti 效果
	var winner_index = randi() % person_cards.size()
	_reveal_winner(winner_index)

func _reveal_winner(index: int) -> void:
	var winner_card = person_cards[index]
	
	# 高亮中奖卡片
	winner_card.highlight()
	
	# 触发 Confetti
	confetti_system.confetti_fire()
	
	# 相机推镜
	var tween = create_tween()
	var target_pos = winner_card.position + Vector3(0, 0, 500)
	tween.tween_property(camera, "position", target_pos, 1.5)
	
	await confetti_system.confetti_finished
	is_animating = false

## 计算看向目标的旋转
func _calculate_look_at_rotation(from: Vector3, to: Vector3) -> Vector3:
	var direction = (to - from).normalized()
	
	var yaw = atan2(direction.x, direction.z)
	var pitch = asin(-direction.y)
	
	return Vector3(rad_to_deg(pitch), rad_to_deg(yaw), 0)

## 切换到指定布局的快捷方法
func _switch_to_layout(layout: LayoutAlgorithm.LayoutType) -> void:
	switch_layout(layout)

## 连接信号
func _connect_signals() -> void:
	pass

## 卡片点击事件
func _on_card_clicked(index: int) -> void:
	card_selected.emit(index)

## 持续旋转球体
func _process(delta: float) -> void:
	if not is_animating and current_layout == LayoutAlgorithm.LayoutType.SPHERE:
		card_container.rotate_y(delta * 0.1)
