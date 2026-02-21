extends CanvasLayer

@export var tail_frame_curve: Curve

@onready var letters: HBoxContainer = $SubViewport/Letters
@onready var tail_sprite: Sprite2D = $SubViewport/TailSprite
@onready var gun_sprite: Sprite2D = $SubViewport/GunSprite

@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

@onready var button_container: VBoxContainer = $ButtonContainer

@onready var all_sprites: Array = find_children("*Sprite*", "Sprite2D")

var tail_anim: float = 0
var frame: float = 0

var intro_tween: Tween
var intro_value: float = 0

var sprites_scale_tween: Tween
var sprites_scale_value: float = 0

func _ready() -> void:
	await SignalBus.game_loaded
	
	if Settings.skip_title:
		Global.is_title_on = false
		SignalBus.title_exited.emit()
	
	if not Global.is_title_on:
		return
	
	button_container.get_child(0).connect("pressed", exit)
	visible = true
	
	for letter in letters.get_children():
		var sprite: Sprite2D = letter.get_child(0)
		
		sprite.visible = false
		sprite.scale = Vector2.ONE / 4
		sprite.rotation = PI / 2
		sprite.material.set_shader_parameter("value", 1)
	
	gun_sprite.position.y = -150
	gun_sprite.rotation = TAU
	
	anim_gun()
	
	for letter in letters.get_children():
		var sprite: Sprite2D = letter.get_child(0)
		
		sprite.visible = true
		
		var scale_tween: Tween = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_CUBIC)
		
		scale_tween.tween_property(sprite, "scale", Vector2.ONE, 0.75)
		
		var rotate_tween: Tween = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_BACK)
		
		rotate_tween.tween_property(sprite, "rotation", 0, 0.75)
		
		var flash_tween: Tween = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_LINEAR)
		
		flash_tween.tween_method(func(value: float): sprite.material.set_shader_parameter("value", value), 1.0, 0.0, 0.5)
		
		await get_tree().create_timer(0.25).timeout
	
	await get_tree().create_timer(0.5).timeout
	
	intro_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	
	intro_tween.tween_property(self, "intro_value", 1, 2)
	intro_tween.tween_callback(button_container.set.bind("visible", true))

func _process(delta: float) -> void:
	frame += delta
	tail_sprite.frame = int(tail_frame_curve.sample(frame))
	
	texture_rect.position = \
		((get_viewport().get_visible_rect().size / scale - texture_rect.size) / 2 + Vector2.ONE * 10) \
		* Vector2(1, ease(1 - intro_value, -2)) - Vector2.ONE * 10
	
	color_rect.color.a = 1 - intro_value
	
	button_container.position = Vector2(0, texture_rect.size.y + texture_rect.position.y)
	button_container.size = get_viewport().get_visible_rect().size / scale - Vector2(0, texture_rect.size.y + texture_rect.position.y)
	
	if sprites_scale_value != 0:
		for sprite: Sprite2D in all_sprites:
			if sprites_scale_value == 1:
				sprite.visible = false
			else:
				sprite.scale = Vector2.ONE / ((sprites_scale_value * 100) + 1)

func exit() -> void:
	SignalBus.title_exit.emit()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	button_container.visible = false
	
	sprites_scale_tween = create_tween() \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	
	sprites_scale_tween.tween_property(self, "sprites_scale_value", 1, 1)
	
	await get_tree().create_timer(2).timeout
	
	Global.is_title_on = false
	SignalBus.title_exited.emit()

func anim_gun() -> void:
	await get_tree().create_timer(0.35).timeout
	
	var gun_tween: Tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_parallel()
	
	gun_tween.tween_property(gun_sprite, "position:y", 56, 1.5)
	gun_tween.tween_property(gun_sprite, "rotation", 0, 1.5)
	
	await get_tree().create_timer(1).timeout
	
	var shine_tween: Tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	
	shine_tween.tween_method(func(value: float): gun_sprite.material.set_shader_parameter("shine_progress", value), 0.0, 1.0, 1)
