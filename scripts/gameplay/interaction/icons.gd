extends Node2D

@export var wave_start_interaction: Area2D

@onready var skull: Node = $Skull
@onready var skull_animation: AnimationPlayer = $Skull/AnimationPlayer

var skull_anim: float = 0
var is_skull_shown: bool = false

func _ready() -> void:
	SignalBus.wave_ended.connect(update_show)
	
	if Global.is_game_restarted:
		update_show()
	
	await SignalBus.game_loaded
	update_show()

func update_show() -> void:
	if Global.is_boss_wave() and Global.is_boss_warned:
		show_skull()

func update_hide() -> void:
	if is_skull_shown:
		hide_skull()

func show_skull() -> void:
	wave_start_interaction.direction = Vector2(0, 1)
	skull_animation.play("show")
	is_skull_shown = true

func hide_skull() -> void:
	wave_start_interaction.direction = Vector2(0, -1)
	skull_animation.play("hide")
	is_skull_shown = false

func _physics_process(delta: float) -> void:
	skull_anim = fmod(skull_anim + delta * 0.5, 1)
	skull.global_position.y = -20 + sin(skull_anim * TAU) * 3
	
	if Input.is_action_just_pressed("interact") and wave_start_interaction.interacting:
		update_hide()
