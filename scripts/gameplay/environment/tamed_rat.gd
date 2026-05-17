extends Node2D

@onready var anim: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var timer: Timer = $"Timer"

func _on_timer_timeout() -> void:
	var random_num = randi_range(1,3)
	
	if random_num == 1:
		anim.play("tail_wag")
		timer.stop()
	else:
		timer.start(3)

func _on_anim_animation_finished() -> void:
	if anim.animation == &"tail_wag":
		anim.play("idle")
		timer.start(3)
