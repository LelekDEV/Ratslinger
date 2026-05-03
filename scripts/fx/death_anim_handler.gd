extends Node2D

@onready var DeathParticles: PackedScene = preload("res://scenes/fx/particles/death_particles.tscn")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var enemies: Node2D = get_tree().get_first_node_in_group("enemies")

@export var camera: Camera2D
@export var death_shadow_rect: ColorRect
@export var ui: CanvasLayer
@export var weather_layer: CanvasLayer

var line_start_pos: Vector2
var line_end_pos: Vector2
var line_direction: Vector2
var line_thickness: float = 6

var line_tween: Tween

var is_anim_on: bool = false

func _physics_process(delta: float) -> void:
	if not is_anim_on:
		return
	
	death_shadow_rect.color += Color.WHITE * delta * 0.8
	queue_redraw()

func _draw() -> void:
	if not is_anim_on:
		return
	
	draw_line(line_start_pos, line_end_pos, Color.WHITE, line_thickness)

func animate(from_projectile: Node2D, from_enemy: Enemy) -> void:
	is_anim_on = true
	
	death_shadow_rect.visible = true
	ui.visible = false
	weather_layer.visible = false
	
	death_shadow_rect.color = Color.BLACK
	
	var highlight_nodes: Array = [player, from_projectile]
	const DISCLUDED_NODE_PATHS: Array = ["LocalFX", "FireFX", "FlightPath"]
	
	if from_enemy:
		if from_enemy.ai == Enemy.AI.SEGMENT:
			if from_enemy.get_parent().type == SnakeEnemyWrapper.Type.BOSS_RAPID:
				for wrapper in enemies.get_children():
					if wrapper is SnakeEnemyWrapper and wrapper.type == SnakeEnemyWrapper.Type.BOSS_RAPID:
						highlight_nodes.append_array(wrapper.get_children())
			else:
				highlight_nodes.append_array(from_enemy.get_parent().get_children())
		else:
			highlight_nodes.append(from_enemy)
	
	else:
		for wrapper in enemies.get_children():
			if wrapper is SnakeEnemyWrapper:
				highlight_nodes.append_array(wrapper.get_children())
	
	for node: Node in highlight_nodes:
		if not node:
			continue
		
		for path in DISCLUDED_NODE_PATHS:
			if node.has_node(path):
				node.get_node(path).visible = false
		
		node.z_index = death_shadow_rect.z_index + 1
		
		for sprite in node.find_children("*Sprite*"):
			sprite.material = preload("res://data/materials/flash_shader_material.tres")
			sprite.material.set_shader_parameter("flash_active", true)
	
	for particles in get_tree().get_nodes_in_group("particles"):
		particles.queue_free()
	
	if from_projectile:
		line_direction = from_projectile.direction
		line_start_pos = from_projectile.global_position + line_direction * 4
		line_end_pos = line_start_pos
		
		var particles: CPUParticles2D = DeathParticles.instantiate()
		
		particles.global_position = from_projectile.global_position
		particles.global_rotation = from_projectile.global_rotation
		particles.emitting = true
		
		get_tree().root.add_child(particles)
	
	camera.shake_time = 0.35
	camera.shake_intensity = 7.5
	camera.shake()
	
	await get_tree().create_timer(0.75).timeout
	
	line_tween = create_tween()
	
	line_tween.set_ease(Tween.EASE_OUT)
	line_tween.set_trans(Tween.TRANS_EXPO)
	
	line_tween.tween_property(self, "line_end_pos", line_start_pos + line_direction * 200, 2)
	
	await get_tree().create_timer(1.5).timeout
	
	is_anim_on = false

func on_boss_death(from_projectile: Projectile) -> void:
	get_tree().paused = true
	
	await animate(from_projectile, null)
	
	get_tree().paused = false
	
	player.local_fx.visible = true
	player.z_index = Consts.ORIG_PLAYER_Z_IDX
	
	for sprite in player.find_children("*Sprite*"):
		sprite.material = null
	
	death_shadow_rect.visible = false
	ui.visible = true
	weather_layer.visible = true
	
	queue_redraw()
	
	SignalBus.boss_death_anim_ended.emit()

func on_player_death(from_projectile: EnemyProjectile, from_enemy: Enemy) -> void:
	get_tree().paused = true
	
	await animate(from_projectile, from_enemy)
	
	get_tree().paused = false
	
	Global.is_game_restarted = true
	Global.is_title_restarted = false
	
	get_tree().reload_current_scene()
	SignalBus.game_restart.emit()
