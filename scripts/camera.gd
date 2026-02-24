extends Camera2D

var shake_tween: Tween
var shake_value: float = 0

var shake_time: float = 0.2
var shake_intensity: float = 2.5
var shake_smoothness: float = 0.8

var intro_tween: Tween
var intro_value: float = 0
var intro_skip: bool = false

@onready var markers: Node2D = get_tree().get_first_node_in_group("markers")

@export var gate: StaticBody2D

func _ready() -> void:
	SignalBus.scale_changed.connect(update_scale)
	SignalBus.title_exit.connect(animate_intro)
	
	update_scale()
	
	await SignalBus.game_loaded
	
	if Settings.skip_title:
		intro_value = 1
		global_position = get_parent().global_position
		
		reset_physics_interpolation()
		reset_smoothing()
	
	reset_physics_interpolation()
	reset_smoothing()
	
	update_scale()

func _physics_process(_delta: float) -> void:
	if get_parent().location == Player.Locations.TOWN_HALL:
		global_position = markers.points.rat_house_cam_pos
		position_smoothing_enabled = false
		return
	
	position_smoothing_enabled = true
	
	if shake_tween and shake_tween.is_running():
		var target: Vector2 = Vector2.RIGHT.rotated(randf_range(-PI, PI)) * sin(shake_value * PI) * shake_intensity
		offset = Global.fixed_lerp(offset, target, 1 - shake_smoothness)
	else:
		offset = Vector2.ZERO
	
	if get_parent().global_position.x > gate.global_position.x:
		global_position.x = max(-324 + get_viewport_rect().size.x / zoom.x / 2, get_parent().global_position.x)
		global_position.y = get_parent().global_position.y
	else:
		global_position = get_parent().global_position
	
	if Global.is_title_on:
		global_position.y = Global.fixed_lerp(468.0, get_parent().to_global(Vector2.ZERO).y, intro_value)
		limit_bottom = 10000000
	else:
		limit_bottom = 234

func animate_intro() -> void:
	intro_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CIRC)
	
	intro_tween.tween_property(self, "intro_value", 1, 2)

func update_scale() -> void:
	zoom = Vector2.ONE * (Global.scale_level + 4)

func shake(miss: bool = false) -> void:
	if miss:
		return
	
	shake_tween = create_tween()
	
	shake_value = 0
	shake_tween.tween_property(self, "shake_value", 1, shake_time)
