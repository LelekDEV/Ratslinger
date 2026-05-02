extends Node2D
class_name Game

@onready var FoxEnemy: PackedScene = preload("res://scenes/enemies/fox_enemy.tscn")
@onready var BeaverEnemy: PackedScene = preload("res://scenes/enemies/beaver_enemy.tscn")
@onready var SnakeEnemy: PackedScene = preload("res://scenes/enemies/snake_enemy_wrapper.tscn")
@onready var OwlEnemy: PackedScene = preload("res://scenes/enemies/owl_enemy.tscn")

@onready var _SnakeBoss: PackedScene = preload("res://scenes/enemies/boss/snake_boss.tscn")

@onready var ui: UI = $UI

@onready var enemies: Node = $Enemies

@onready var player: Player = $Player
@onready var camera: Camera = $Player/Camera2D
@onready var crosshair: Sprite2D = $UI/Crosshair

@onready var tutorial_label: RichTextLabel = $Player/TutorialLabel
@onready var tutorial_handler: Node = $TutorialHandler

@onready var death_anim_handler: Node = $DeathAnimHandler
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer

@onready var gate: StaticBody2D = $Environment/Gate
@onready var wave_start_interaction_area: Area2D = $WaveStartInteractionArea
@onready var title_sand_sprite: Sprite2D = $SandSprite3

@onready var bossfight_bound: ReferenceRect = $BossfightBoundRect
@onready var bossfight_bound_shapes: Array = get_tree().get_nodes_in_group("bossfight_bound_shape")

@onready var sand_spike_spawner: Node2D = $Environment/SandSpikeSpawner
@onready var cutscene_audio: AudioStreamPlayer = $CutsceneAudio

@onready var boss_card_animation: AnimationPlayer = $BossCardLayer/AnimationPlayer

var enemies_total: int = 5
var enemies_to_spawn: int = enemies_total
var enemies_killed: int = 0
var enemies_prediction_weight: float = 0

var is_wave_active: bool = false
var is_boss_active: bool = false

var is_cutscene_on: bool = false

signal exit_boss_card

func _ready() -> void:
	setup_signals()
	Global.game = self
	Global.all_enemies.clear()
	Fullscreen.transition_rect = get_tree().get_first_node_in_group("fullscreen_transition_rect")
	
	if Global.is_game_restarted:
		GlobalAudio.music_player.stop()
		SaverLoader.load_game()
		
		title_sand_sprite.global_position.x = int(player.global_position.x)
		
		await get_tree().process_frame
		if Global.waves_cleared == Global.death_wave and Settings.on_death_action == 1:
			start_wave()
		
		return
	
	await SignalBus.game_loaded
	# L this actually only emits when the game is loaded the first time.
	# I'll workaround with a frame delay for restarting waves since I don't want to damage existing structure.
	# There's 13 references to 'game_loaded' in the whole project, ouch...
	
	title_sand_sprite.global_position.x = int(player.global_position.x)
	
	# boss testing...
	#Global.waves_cleared = 14

func setup_signals() -> void:
	SignalBus.player_shoot.connect(camera.shake.bind(0.2, 2.5, 0.8))
	SignalBus.player_shoot.connect(crosshair.on_player_shoot)
	
	SignalBus.player_death.connect(death_anim_handler.on_player_death)
	SignalBus.boss_death.connect(death_anim_handler.on_boss_death)
	SignalBus.boss_death.connect(on_boss_death)
	
	SignalBus.player_location_change.connect(ui.on_player_location_change)
	SignalBus.player_location_change.connect(on_player_location_change)
	
	SignalBus.player_hit.connect(ui.animation.play.bind("player_hit"))
	SignalBus.player_hit.connect(camera.shake)
	
	SignalBus.accuracy_perfect_entered.connect(tutorial_handler.display_shooting_tutorial)

func _physics_process(_delta: float) -> void:
	if wave_start_interaction_area.interacting and \
		Input.is_action_just_pressed("interact") and \
		not is_wave_active and \
		not is_boss_active and \
		not is_cutscene_on:
		
		start_wave()
	
	if Input.is_action_just_pressed("exit_boss_card"):
		exit_boss_card.emit()
	
	"""if Input.is_action_just_pressed("spawn_enemy_1"):
		var enemy: Enemy = FoxEnemy.instantiate()
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	if Input.is_action_just_pressed("spawn_enemy_2"):
		var enemy: Enemy = BeaverEnemy.instantiate()
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	if Input.is_action_just_pressed("spawn_enemy_3"):
		var enemy: SnakeEnemyWrapper = SnakeEnemy.instantiate()
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	if Input.is_action_just_pressed("spawn_enemy_4"):
		var enemy: Enemy = OwlEnemy.instantiate()
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)"""

func boss_card() -> void:
	if Settings.boss_card == 0 and not (Global.waves_cleared == Global.death_wave and Settings.on_death_action == 1):
		Global.block_input = true
		Global.block_movement = true
		is_cutscene_on = true
		
		boss_card_animation.play("enter")
		await boss_card_animation.animation_finished
		await exit_boss_card
		boss_card_animation.play("exit")
		await boss_card_animation.animation_finished
		
		Global.block_input = false
		Global.block_movement = false
		is_cutscene_on = false

func boss_cutscene() -> void:
	is_cutscene_on = true
	wave_start_interaction_area.visible = false
	
	# should probably change the name to start_cutscene lol
	ui.start_dialogue()
	ui.toggle_combat_hud(false)
	Global.block_input = true
	
	await get_tree().create_timer(1, false).timeout
	
	cutscene_audio.play()
	get_tree().create_timer(7.4, false).timeout.connect(cutscene_audio.stop)
	
	camera.shake_time = 8.5
	camera.shake_intensity = 1.5
	camera.shake()
	
	for spike: SandSpike in sand_spike_spawner.get_children():
		spike.appear(spike.order_value / 90)
	
	var h_size: Vector2 = bossfight_bound.size / 2
	
	# ISSUE: is not updated dynamically, very niche screen-size mismatch possible
	var override_1 := Camera.PositionOverride.new(
		camera, 
		-h_size + get_viewport_rect().size.normalized() * 100, 
		false, false
	)
	override_1.enter(1)
	override_1.interval(2)
	override_1.exit(1)
	override_1.end()
	
	await get_tree().create_timer(4, false).timeout
	
	var override_2 := Camera.PositionOverride.new(
		camera, 
		h_size - get_viewport_rect().size.normalized() * 100,
		false, false
	)
	override_2.enter(1)
	override_2.interval(2)
	override_2.exit(1)
	override_2.end()
	
	await get_tree().create_timer(4, false).timeout
	
	await boss_card()
	
	ui.end_dialogue()
	ui.toggle_combat_hud(true)
	Global.block_input = false

func boss_cutscene_skip() -> void:
	for spike: SandSpike in sand_spike_spawner.get_children():
		spike.appear(0, true)
	
	await boss_card()

func start_wave() -> void:
	gate.get_node("LockSprite").self_modulate.a = 1
	gate.get_node("CollisionShape2D").set_deferred("disabled", false)
	
	ui.animation.play("wave_start")
	
	if Global.waves_cleared % 15 == 14 and Global.waves_cleared >= 14:
		if Global.waves_cleared == Global.death_wave and Settings.on_death_action <= 1:
			await boss_cutscene_skip()
		else:
			await boss_cutscene()
		
		is_cutscene_on = false
		is_boss_active = true
		
		for shape: CollisionShape2D in bossfight_bound_shapes:
			shape.set_deferred("disabled", false)
		
		for spike: SandSpike in sand_spike_spawner.get_children():
			spike.collision.set_deferred("disabled", false)
		
		ui.animation.play("bossfight_start")
		
		var boss: SnakeBoss = _SnakeBoss.instantiate()
		add_child(boss)
	
	else:
		enemies_total = 5 + Global.waves_cleared
		enemies_to_spawn = enemies_total
		enemies_killed = 0
		
		spawn_enemy()
		ui.update_enemy_count(0, enemies_total)
		
		enemy_spawn_timer.wait_time = max(round((8 - log(Global.waves_cleared + 1)) * 100) / 100, 0.5)
		enemy_spawn_timer.start()
		
		enemies_prediction_weight = min(0.1 + log(Global.waves_cleared / 2.0 + 1) / 5, 0.75)
		
		print("Wave %s started, enemy count: %s, spawn inteval: %s, prediction weight: %s" % [
			Global.waves_cleared + 1, 
			enemies_total,
			enemy_spawn_timer.wait_time,
			enemies_prediction_weight
		])
		
		is_wave_active = true
	
	wave_start_interaction_area.visible = false
	
	SignalBus.wave_started.emit()
	
	if not Global.is_tutorial_passed:
		var enter_tween: Tween = create_tween() \
			.set_ease(Tween.EASE_OUT_IN) \
			.set_trans(Tween.TRANS_LINEAR)
		enter_tween.tween_property(tutorial_label, "visible_ratio", 1, 1)
		
		await SignalBus.player_shoot
		await get_tree().create_timer(0.5).timeout
		
		var exit_tween: Tween = create_tween() \
			.set_ease(Tween.EASE_OUT_IN) \
			.set_trans(Tween.TRANS_LINEAR)
		exit_tween.tween_property(tutorial_label, "visible_ratio", 0, 1)

func end_wave() -> void:
	if is_boss_active:
		for shape: CollisionShape2D in bossfight_bound_shapes:
			shape.set_deferred("disabled", true)
		
		ui.animation.play("bossfight_end")
		
		is_boss_active = false
	
	gate.get_node("AnimationPlayer2").play("unlock")
	gate.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	ui.animation.play("wave_end")
	
	ui.update_enemy_count(-1)
	
	is_wave_active = false
	wave_start_interaction_area.visible = true
	Global.waves_cleared += 1
	
	SignalBus.wave_ended.emit()

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
func update_enemies(killed_id: Enemy.ID = -1, killed_amount: int = 1) -> void:
	enemies_killed += killed_amount
	
	if killed_id != -1:
		var enemy_name: String
		match killed_id:
			Enemy.ID.FOX: enemy_name = "Fox"
			Enemy.ID.BEAVER: enemy_name = "Beaver"
			Enemy.ID.SNAKE: enemy_name = "Snake"
			Enemy.ID.OWL: enemy_name = "Owl"
			_: return
	
		Global.enemy_stats[enemy_name]["kills"] += killed_amount
	
	if killed_id == Global.mission_target:
		Global.mission_killed += killed_amount
	
	ui.update_enemy_count(enemies_killed, enemies_total)
	
	if enemies_killed >= enemies_total:
		end_wave()

func spawn_enemy() -> void:
	if enemies_to_spawn <= 0:
		enemy_spawn_timer.stop()
		return
	
	var enemy_roll: float = randf_range(0, 1)
	
	# ODDS:
	# fox ---- 45%
	# beaver - 30%
	# snake -- 15%
	# owl ---- 10%
	if enemy_roll > 0.25 or Global.waves_cleared == 0:
		var enemy: Enemy = FoxEnemy.instantiate() if enemy_roll > 0.55 else BeaverEnemy.instantiate()
		
		if randi_range(0, 1) == 0:
			if randi_range(0, 1) == 0:
				enemy.global_position.x = -364
				enemy.global_position.y = randi_range(100, 264) * (-1 if randi_range(0, 1) == 0 else 1)
			else:
				enemy.global_position.x = 364
				enemy.global_position.y = randi_range(-264, 264)
		else:
			enemy.global_position.x = randi_range(-364, 364)
			enemy.global_position.y = -264 if randi_range(0, 1) == 0 else 264
		
		enemy.prediction_weight_1 = enemies_prediction_weight
		
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	elif enemy_roll > 0.15:
		var enemy: Enemy = OwlEnemy.instantiate()
		
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	else:
		var enemy: SnakeEnemyWrapper = SnakeEnemy.instantiate()
		
		enemy.death.connect(update_enemies)
		enemies.add_child(enemy)
	
	enemies_to_spawn -= 1

func on_boss_death(_from_projectile: Projectile) -> void:
	for spike: SandSpike in sand_spike_spawner.get_children():
		spike.collision.set_deferred("disabled", true)
		spike.reset()

func on_player_location_change(_location: Player.Locations) -> void:
	"""if location == Player.Locations.ARENA:
		enemy_spawn_timer.paused = false
		enemies.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		enemy_spawn_timer.paused = true
		enemies.process_mode = Node.PROCESS_MODE_DISABLED"""

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
