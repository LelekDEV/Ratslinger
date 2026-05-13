extends Node2D

@onready var title_background: Node2D = $Ground/TitleBackground

@onready var sand_sprite_title: Sprite2D = $Ground/TitleBackground/SandSprite
@onready var cow_sprites: Array = [
	$Ground/TitleBackground/CowSprite1,
	$Ground/TitleBackground/CowSprite2,
	$Ground/TitleBackground/CowSprite3
]

@onready var cow_anim_timer: Timer = $Ground/CowAnimTimer
var cow_anim_idx: int = 0

const title_anim_speed: float = 10

var title_anim: float = 0
var is_title_anim_disabled: bool = false

var title_exit_tween: Tween

func _ready() -> void:
	SignalBus.title_exit.connect(disable_title_anim)
	
	for sprite: AnimatedSprite2D in cow_sprites:
		sprite.position.x += randf_range(-20, 20)
		sprite.position.y = 468 + randf_range(-70, 70)
		sprite.flip_h = randi_range(0, 1)
	
	await SignalBus.game_loaded
	
	if not Global.is_title_on:
		disable_title_anim(true)

func _physics_process(delta: float) -> void:
	if is_title_anim_disabled == true:
		return
	
	title_anim += delta * title_anim_speed
	sand_sprite_title.position.x = 32 - fmod(title_anim, 64)
	
	for sprite: AnimatedSprite2D in cow_sprites:
		sprite.position.x -= delta * title_anim_speed
		
		if sprite.position.x < -300:
			while sprite.position.x <= 100:
				sprite.position.x += 200
			
			sprite.position.x += randf_range(-20, 20)
			sprite.position.y = 468 + randf_range(-70, 70)
			sprite.flip_h = randi_range(0, 1)

func disable_title_anim(is_instant: bool = false) -> void:
	cow_anim_timer.stop()
	
	if not is_instant:
		title_exit_tween = create_tween() \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)
		
		title_exit_tween.tween_property(self, "title_anim_speed", 0, 0.5)
		
		await SignalBus.title_exited
	
	is_title_anim_disabled = true
	title_background.visible = false

func _on_cow_anim_timer_timeout() -> void:
	cow_anim_timer.start(randf_range(1, 5))
	cow_sprites[cow_anim_idx].play([&"eat", &"yell"][randi_range(0, 1)])
	cow_anim_idx = (cow_anim_idx + 1) % cow_sprites.size()
