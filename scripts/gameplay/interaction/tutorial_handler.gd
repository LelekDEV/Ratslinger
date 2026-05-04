extends Node
class_name TutorialHandler

@onready var enemies: Node2D = get_tree().get_first_node_in_group("enemies")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var accuracy_bar: AccuracyBar = get_tree().get_first_node_in_group("accuracy_bar")

@onready var proceed_timer: Timer = $ProceedTimer

@export var tutorial_container: Control

var is_shooting_tutorial_on: bool = false
var is_shooting_tutorial_queued: bool = false

func _physics_process(_delta: float) -> void:
	if is_shooting_tutorial_on and Input.is_action_just_pressed("shoot") and proceed_timer.is_stopped():
		is_shooting_tutorial_on = false
		is_shooting_tutorial_queued = false
		tutorial_container.visible = false
		
		Global.resume_game(false)
		Global.force_input = true
		Global.is_tutorial_passed = true

func display_shooting_tutorial(_miss: bool = false) -> void:
	if Global.is_tutorial_passed:
		return
	
	if enemies.get_child_count() == 0 or not Global.game.is_wave_active:
		return
	
	if not accuracy_bar.reload_bullets:
		return
	
	var to_return = true
	for enemy in enemies.get_children():
		if not enemy is Enemy:
			continue
		
		if player.global_position.distance_squared_to((enemy as Enemy).global_position) <= 150 ** 2:
			to_return = false
			break
	
	if to_return:
		return
	
	is_shooting_tutorial_queued = true
	Global.block_input = true
	
	await SignalBus.accuracy_perfect_entered
	await get_tree().create_timer(0.05, false).timeout
	
	is_shooting_tutorial_on = true
	tutorial_container.visible = true
	
	proceed_timer.start()
	
	Global.pause_game()
