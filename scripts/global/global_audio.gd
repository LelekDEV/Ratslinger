extends Node

enum SFX {HIT, LOSE, BLOCK,ENEMY_SHOOT, PLAYER_SHOOT}

func play_sfx(sfx: SFX, volume: int = 0) -> void:
	var audio = AudioStreamPlayer.new()
	
	match sfx:
		SFX.HIT: audio.stream = preload("res://audio/SFX/hit.wav")
		SFX.LOSE: audio.stream = preload("res://audio/SFX/lose.wav")
		SFX.BLOCK: audio.stream = preload("res://audio/SFX/block.wav")
		SFX.ENEMY_SHOOT: audio.stream = preload("res://audio/SFX/enemy_shoot.wav")
		SFX.PLAYER_SHOOT: audio.stream = preload("res://audio/SFX/player_shoot.wav")
	
	audio.volume_db = volume
	audio.finished.connect(on_audio_finished.bind(audio))
	
	add_child(audio)
	audio.play()

func on_audio_finished(audio: AudioStreamPlayer) -> void:
	audio.queue_free()
