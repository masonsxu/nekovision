extends Node3D

## 以太星涡 - 3D抽奖系统主控制器
## 负责场景初始化、卡片生成和抽奖流程控制

signal lottery_started()
signal prize_revealed(prize_index: int)

const CARD_COUNT = 50

@onready var vortex_container = $VortexContainer
@onready var camera_controller = $CameraController
@onready var lottery_button = $UI/LotteryButton

var card_nodes: Array[Node3D] = []
var is_lottery_running: bool = false

func _ready() -> void:
	_setup_lighting()
	_generate_cards()
	_connect_signals()

func _setup_lighting() -> void:
	# 主光源（直射光）
	var sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-45, 45, 0)
	add_child(sun)

func _generate_cards() -> void:
	var card_scene = preload("res://scenes/Card3D.tscn")
	
	for i in range(CARD_COUNT):
		var card = card_scene.instantiate()
		card.name = "Card_" + str(i)
		
		# 计算位置（双螺旋布局）
		var phase = float(i % 2) * PI  # 双螺旋相位
		var pos = VortexLayout.calculate_double_helix_position(i, CARD_COUNT, phase)
		card.position = pos
		
		# 设置卡片朝向
		card.look_at(Vector3.ZERO)
		
		# 设置卡片数据
		if card.has_method("set_prize_data"):
			card.set_prize_data({
				"index": i,
				"name": "Prize " + str(i),
				"color": Color.from_hsv(float(i) / float(CARD_COUNT), 0.7, 0.9)
			})
		
		# 获取轨道参数
		var orbit_params = VortexLayout.get_orbit_parameters(i, CARD_COUNT)
		if card.has_method("set_orbit_parameters"):
			card.set_orbit_parameters(orbit_params)
		
		vortex_container.add_child(card)
		card_nodes.append(card)

func _connect_signals() -> void:
	if lottery_button:
		lottery_button.pressed.connect(_on_lottery_button_pressed)

func _process(delta: float) -> void:
	# 所有卡片持续轨道运动
	if not is_lottery_running:
		for card in card_nodes:
			if card.has_method("orbit_update"):
				card.orbit_update(delta)

func _on_lottery_button_pressed() -> void:
	if is_lottery_running:
		return
	
	start_lottery()

func start_lottery() -> void:
	is_lottery_running = true
	lottery_started.emit()
	
	# 隐藏按钮
	if lottery_button:
		lottery_button.hide()
	
	# 开始动画序列
	_run_lottery_sequence()

func _run_lottery_sequence() -> void:
	# 阶段1: 加速旋转（3秒）
	await _accelerate_rotation(3.0)
	
	# 阶段2: 引力收缩（2秒）
	await _gravitational_contraction(2.0)
	
	# 阶段3: 选择中奖卡片
	var winner_index = randi() % CARD_COUNT
	_reveal_prize(winner_index)

func _accelerate_rotation(duration: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	for card in card_nodes:
		if card.has_method("accelerate"):
			card.accelerate(5.0)  # 5倍速
	
	tween.tween_callback(func(): pass).set_delay(duration)
	await tween.finished

func _gravitational_contraction(duration: float) -> void:
	var tween = create_tween()
	
	for card in card_nodes:
		var card_tween = create_tween()
		card_tween.set_parallel(true)
		card_tween.tween_property(card, "scale", Vector3(0.3, 0.3, 0.3), duration)
		card_tween.tween_property(card, "position", Vector3.ZERO, duration)
	
	tween.tween_callback(func(): pass).set_delay(duration)
	await tween.finished

func _reveal_prize(winner_index: int) -> void:
	# 爆发效果
	for i in range(card_nodes.size()):
		var card = card_nodes[i]
		var card_tween = create_tween()
		
		if i == winner_index:
			# 中奖卡片放大
			card_tween.set_parallel(true)
			card_tween.tween_property(card, "scale", Vector3(2.0, 2.0, 2.0), 1.0)
			card_tween.tween_property(card, "position", Vector3(0, 0, 5), 1.0)
		else:
			# 其他卡片向外飞散
			var direction = card.position.normalized()
			card_tween.tween_property(card, "position", direction * 20.0, 1.5)
			card_tween.tween_property(card, "scale", Vector3(0.1, 0.1, 0.1), 1.5)
	
	# 相机推镜至中奖卡片
	if camera_controller and camera_controller.has_method("focus_on_card"):
		await camera_controller.focus_on_card(card_nodes[winner_index])
	
	prize_revealed.emit(winner_index)
	
	# 延迟后重置
	await get_tree().create_timer(3.0).timeout
	_reset_lottery()

func _reset_lottery() -> void:
	# 重置所有卡片位置
	for i in range(card_nodes.size()):
		var card = card_nodes[i]
		var phase = float(i % 2) * PI
		var pos = VortexLayout.calculate_double_helix_position(i, CARD_COUNT, phase)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "position", pos, 1.0)
		tween.tween_property(card, "scale", Vector3.ONE, 1.0)
	
	# 重置相机
	if camera_controller and camera_controller.has_method("reset_position"):
		camera_controller.reset_position()
	
	await get_tree().create_timer(1.0).timeout
	
	is_lottery_running = false
	
	if lottery_button:
		lottery_button.show()
