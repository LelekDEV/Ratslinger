extends Node2D
class_name BulletBar

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var container: HBoxContainer = $HBoxContainer

var current_slot: int = 0

func _ready() -> void:
	SignalBus.player_shoot.connect(free_slot)

func _physics_process(_delta: float) -> void:
	var i: int = 0
	
	for slot in container.get_children():
		var sprite: Sprite2D = slot.get_node("Sprite2D")
		
		sprite.position.y = lerp(sprite.position.y, -4.0 if i == current_slot else 0.0, 0.2)
		sprite.material.set_shader_parameter("is_visible", 
			i == current_slot and \
			player.reload_timer.is_stopped() and \
			player.shoot_cooldown.is_stopped()
		)
		
		i += 1

func free_slot(_miss: bool) -> void:
	container.get_child(current_slot).get_node("Sprite2D").frame = 1
	
	if current_slot == 5:
		player.reload_bullets()
	else:
		current_slot += 1

func load_slot() -> void:
	container.get_child(current_slot).get_node("Sprite2D").frame = 0
	
	if current_slot == 1:
		current_slot -= 1
		
		await get_tree().create_timer(0.2).timeout
		container.get_child(0).get_node("Sprite2D").frame = 0
	else:
		current_slot -= 1
