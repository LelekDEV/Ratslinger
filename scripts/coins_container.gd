extends Control

@onready var timer = $Timer
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var container: Control = $ContainerContent

var is_active: bool = false

func _ready() -> void:
	hide()
	animation.animation_finished.connect(_on_animation_finished)
	SignalBus.player_coin_collect.connect(_on_coin_collected)
	timer.timeout.connect(_on_timer_timeout)
	
func _on_coin_collected() -> void:
	if not is_active:
		show()
		animation.play("slide_in")
		is_active = true

	timer.start()
	
func _on_timer_timeout() -> void:
	animation.play("slide_out")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slide_out":
		hide()
		is_active = false
