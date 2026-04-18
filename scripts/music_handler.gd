extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	SignalBus.wave_started.connect(func():
		GlobalAudio.music_player.stop()
		GlobalAudio.music_player.stream = preload("res://audio/music/boss.wav") if Global.game.is_boss_active else preload("res://audio/music/battle.wav")
		GlobalAudio.music_player.play()
	)
	SignalBus.wave_ended.connect(func():
		GlobalAudio.music_player.stop()
		GlobalAudio.music_player.stream = preload("res://audio/music/town.wav")
		GlobalAudio.music_player.play()
	)
	if not SignalBus.player_death.is_connected(_on_player_death):
		SignalBus.player_death.connect(_on_player_death)
	if not SignalBus.game_restart.is_connected(_on_game_restart):
		SignalBus.game_restart.connect(_on_game_restart)
	
	await SignalBus.game_loaded
	if Global.is_title_on: await SignalBus.title_exited
	if not Global.is_introduction_passed: await Dialogic.timeline_ended
	
	GlobalAudio.music_player.stream = preload("res://audio/music/town.wav")
	GlobalAudio.music_player.volume_db = 12
	GlobalAudio.music_player.play()

func _physics_process(_delta: float) -> void:
	if Global.game.is_boss_active:
		GlobalAudio.music_player.volume_db = -6
	elif Global.game.is_wave_active:
		GlobalAudio.music_player.volume_db = -14
	else:
		# fade from -300 to -50
		GlobalAudio.music_player.volume_db = linear_to_db(clamp(-db_to_linear(12) * (player.global_position.x + 50) / 250, 0, db_to_linear(12)))

func _on_player_death(_from_projectile: EnemyProjectile, _from_enemy: Enemy) -> void:
	GlobalAudio.music_player.stop()

func _on_game_restart() -> void:
	GlobalAudio.music_player.stream = preload("res://audio/music/town.wav")
	GlobalAudio.music_player.volume_db = 12
	GlobalAudio.music_player.play()
