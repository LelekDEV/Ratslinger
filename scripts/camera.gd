extends Camera2D
class_name Camera

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

class PositionOverride:
	var camera: Camera
	var pos: Vector2
	var tween: Tween
	var value: float
	var ignore_x: bool
	var ignore_y: bool
	var meta: StringName
	
	func _init(_camera: Camera, _pos: Vector2, _ignore_x: bool, _ignore_y: bool, _meta: StringName = &"") -> void:
		camera = _camera
		pos = _pos
		ignore_x = _ignore_x
		ignore_y = _ignore_y
		meta = _meta
		
		initiate_tween()
		camera.position_overrides.append(self)
	
	func initiate_tween() -> void:
		tween = camera.create_tween() \
			.set_trans(Tween.TRANS_CIRC) \
			.set_ease(Tween.EASE_IN_OUT)
	
	func end() -> void:
		if not tween.is_valid(): initiate_tween()
		tween.tween_callback(camera.position_overrides.erase.bind(self))
	
	func interval(time: float) -> void:
		if not tween.is_valid(): initiate_tween()
		tween.tween_interval(time)
	
	func enter(time: float) -> void:
		if not tween.is_valid(): initiate_tween()
		tween.tween_property(self, "value", 1, time)
	
	func exit(time: float) -> void:
		if not tween.is_valid(): initiate_tween()
		tween.tween_property(self, "value", 0, time)

var position_overrides: Array

func _ready() -> void:
	SignalBus.scale_changed.connect(update_scale)
	SignalBus.title_exit.connect(animate_intro)
	Dialogic.signal_event.connect(alter_overrides)
	
	update_scale()
	
	if Global.is_game_restarted:
		reset_physics_interpolation.call_deferred()
		reset_smoothing.call_deferred()
	
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
		global_position.y = lerp(468.0, get_parent().to_global(Vector2.ZERO).y, intro_value)
		limit_bottom = 10000000
	else:
		limit_bottom = 234
	
	var last_pos: Vector2 = get_parent().global_position
	for override: PositionOverride in position_overrides:
		if not override.ignore_x:
			global_position.x = lerp(last_pos.x, override.pos.x, override.value)
			last_pos.x = global_position.x
		if not override.ignore_x:
			global_position.y = lerp(last_pos.y, override.pos.y, override.value)
			last_pos.y = global_position.y

func alter_overrides(signal_data: Dictionary) -> void:
	if signal_data.name != "camera_override":
		return
	
	match signal_data.type:
		"arena":
			var override := PositionOverride.new(self, Consts.CAMERA_POSITIONS.arena, false, true)
			override.enter(1)
			override.interval(2)
			override.exit(1)
			override.end()
		
		"shop":
			var override := PositionOverride.new(self, Consts.CAMERA_POSITIONS.shop, false, false)
			override.enter(1)
			override.interval(2)
			override.exit(1)
			override.end()
		
		"mayor_enter":
			var override := PositionOverride.new(self, Consts.CAMERA_POSITIONS.mayor, false, true)
			override.enter(1)
			# This is needed for further reuse of the override
			override.meta = &"mayor"
		
		"mayor_exit":
			var override: PositionOverride = position_overrides.filter(func(o): return o.meta == &"mayor")[0]
			override.exit(1)
			override.end()

func animate_intro() -> void:
	intro_tween = create_tween() \
		.set_trans(Tween.TRANS_CIRC) \
		.set_ease(Tween.EASE_IN_OUT)
	
	intro_tween.tween_property(self, "intro_value", 1, 2)

func update_scale() -> void:
	zoom = Vector2.ONE * (Global.scale_level + 4)

func shake(miss: bool = false) -> void:
	if miss:
		return
	
	shake_tween = create_tween()
	
	shake_value = 0
	shake_tween.tween_property(self, "shake_value", 1, shake_time)
