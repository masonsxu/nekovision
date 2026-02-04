extends Node3D

## 3D 卡片（显示姓名 + 头像）
## 从 log-lottery 的 CSS3DRenderer 迁移到 Godot

signal card_clicked(index: int)

var person_data: Dictionary = {}
var layout_data: Dictionary = {}

@onready var card_mesh = $CardMesh
@onready var viewport = $SubViewport
@onready var texture_rect = $SubViewport/TextureRect
@onready var name_label = $SubViewport/TextureRect/VBoxContainer/NameLabel
@onready var avatar_texture = $SubViewport/TextureRect/VBoxContainer/AvatarTexture

func _ready() -> void:
	# 设置视口纹理到卡片
	var material = card_mesh.get_active_material(0)
	if material:
		material.albedo_texture = viewport.get_texture()

## 设置人员数据（姓名 + 头像）
func set_person_data(data: Dictionary) -> void:
	person_data = data
	
	# 设置姓名
	if name_label and data.has("name"):
		name_label.text = data["name"]
	
	# 设置头像（如果有）
	if avatar_texture and data.has("avatar"):
		_load_avatar(data["avatar"])
	else:
		# 使用默认头像
		avatar_texture.texture = null

## 设置布局数据
func set_layout_data(data: Dictionary) -> void:
	layout_data = data
	
	if data.has("position"):
		position = data["position"]
	
	if data.has("rotation"):
		rotation_degrees = data["rotation"]

## 加载头像
func _load_avatar(path: String) -> void:
	if FileAccess.file_exists(path):
		var image = Image.new()
		if image.load(path) == OK:
			var texture = ImageTexture.create_from_image(image)
			avatar_texture.texture = texture

## 高亮卡片（中奖时）
func highlight() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.5)
	tween.tween_property(card_mesh, "rotation_degrees:y", 360.0, 1.0)

## 重置卡片
func reset_card() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE, 0.5)
	tween.tween_property(card_mesh, "rotation_degrees:y", 0.0, 0.5)

## 点击事件
func _on_input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(layout_data.get("index", -1))
