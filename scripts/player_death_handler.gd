extends Node2D

@onready var player: Player = get_tree().get_first_node_in_group("player")

@export var camera: Camera2D
@export var death_shadow_rect: ColorRect
@export var ui: CanvasLayer

var line_start_pos: Vector2
var line_end_pos: Vector2
var line_direction: Vector2
var line_thickness: float = 6

var line_tween: Tween

var is_player_dead: bool = false

func _physics_process(delta: float) -> void:
	if not is_player_dead:
		return
	
	death_shadow_rect.color += Color.WHITE * delta * 0.8
	queue_redraw()

func _draw() -> void:
	if not is_player_dead:
		return
	
	draw_line(line_start_pos, line_end_pos, Color.WHITE, line_thickness)

func on_player_death(from_projectile: EnemyProjectile, from_enemy: Enemy) -> void:
	get_tree().paused = true
	is_player_dead = true
	
	death_shadow_rect.visible = true
	ui.visible = false
	
	for node in [from_projectile, from_enemy, player]:
		node.z_index = death_shadow_rect.z_index + 1
		
		for sprite in node.find_children("*Sprite*"):
			sprite.material = preload("res://data/flash_shader_material.tres")
			sprite.material.set_shader_parameter("active", true)
	
	for particles in get_tree().get_nodes_in_group("particles"):
		particles.queue_free()
	
	line_direction = from_projectile.direction
	
	line_start_pos = from_projectile.global_position + line_direction * 4
	line_end_pos = line_start_pos
	
	camera.shake_time = 0.35
	camera.shake_intensity = 7.5
	camera.shake()
	
	await get_tree().create_timer(0.75).timeout
	
	line_tween = create_tween()
	
	line_tween.set_ease(Tween.EASE_OUT)
	line_tween.set_trans(Tween.TRANS_EXPO)
	
	line_tween.tween_property(self, "line_end_pos", line_start_pos + line_direction * 200, 2)
	
	await get_tree().create_timer(1.5).timeout
	
	get_tree().paused = false
	get_tree().reload_current_scene()
