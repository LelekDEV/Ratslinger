extends Node

@onready var enemies: Node2D = get_tree().get_first_node_in_group("enemies")
@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var proceed_timer: Timer = $ProceedTimer

@export var tutorial_container: Control

var is_shooting_tutorial_on: bool = false

func _physics_process(_delta: float) -> void:
	if is_shooting_tutorial_on and Input.is_action_just_pressed("shoot") and proceed_timer.is_stopped():
		is_shooting_tutorial_on = false
		tutorial_container.visible = false
		
		Global.resume_game(false)
		Global.force_input = true
		Global.is_tutorial_passed = true

func display_shooting_tutorial() -> void:
	if Global.is_tutorial_passed:
		return
	
	if enemies.get_child_count() == 0 or not Global.game.is_wave_active:
		return
	
	var to_return = true
	for enemy: Enemy in enemies.get_children():
		if player.global_position.distance_squared_to(enemy.global_position) <= 150 ** 2:
			to_return = false
			break
	
	if to_return:
		return
	
	is_shooting_tutorial_on = true
	tutorial_container.visible = true
	
	proceed_timer.start()
	
	Global.pause_game()
