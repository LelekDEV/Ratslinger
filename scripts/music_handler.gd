extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	SignalBus.wave_started.connect(func():
		GlobalAudio.music_player.stop()
		GlobalAudio.music_player.stream = preload("res://audio/music/battle.wav")
		GlobalAudio.music_player.play()
	)
	SignalBus.wave_ended.connect(func():
		GlobalAudio.music_player.stop()
		GlobalAudio.music_player.stream = preload("res://audio/music/town.wav")
		GlobalAudio.music_player.play()
	)
	
	await SignalBus.game_loaded
	if Global.is_title_on: await SignalBus.title_exited
	if not Global.is_introduction_passed: await Dialogic.timeline_ended
	
	GlobalAudio.music_player.stream = preload("res://audio/music/town.wav")
	GlobalAudio.music_player.volume_db = 12
	GlobalAudio.music_player.play()

func _physics_process(_delta: float) -> void:
	if Global.game.is_wave_active:
		GlobalAudio.music_player.volume_db = -14
	else:
		# fade from -300 to -50
		GlobalAudio.music_player.volume_db = linear_to_db(clamp(-db_to_linear(12) * (player.global_position.x + 50) / 250, 0, db_to_linear(12)))
