extends Node2D

@onready var interaction_area: Area2D = $InteractionArea

func _physics_process(_delta: float) -> void:
	if interaction_area.interacting and Input.is_action_just_pressed("interact") and not Global.block_movement:
		Dialogic.start("kiddo")
		
		interaction_area.animation.play("exit")
		await Dialogic.timeline_ended
		interaction_area.animation.play("enter")
