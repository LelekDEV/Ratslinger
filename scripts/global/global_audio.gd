extends Node

enum SFX {HIT, LOSE, BLOCK,ENEMY_SHOOT, PLAYER_SHOOT, DANGER, COLLECT, SELECT, PLAYER_SHOOT_VAMPIRE}

func play_sfx(sfx: SFX, volume: int = 0, pitch: float = 1) -> void:
	var audio = AudioStreamPlayer.new()
	
	match sfx:
		SFX.HIT: audio.stream = preload("res://audio/sfx/hit.wav")
		SFX.LOSE: audio.stream = preload("res://audio/sfx/lose.wav")
		SFX.BLOCK: audio.stream = preload("res://audio/sfx/block.wav")
		SFX.ENEMY_SHOOT: audio.stream = preload("res://audio/sfx/enemy_shoot.wav")
		SFX.PLAYER_SHOOT: audio.stream = preload("res://audio/sfx/player_shoot.wav")
		SFX.DANGER: audio.stream = preload("res://audio/sfx/danger.wav")
		SFX.COLLECT: audio.stream = preload("res://audio/sfx/collect.wav")
		SFX.SELECT: audio.stream = preload("res://audio/sfx/select.wav")
		SFX.PLAYER_SHOOT_VAMPIRE: audio.stream = preload("res://audio/sfx/player_shoot_vampire.wav")
	
	audio.set_meta("sfx", sfx)
	audio.volume_db = volume
	audio.pitch_scale = pitch
	
	audio.finished.connect(on_audio_finished.bind(audio))
	
	for played_audio in get_children():
		if played_audio.get_meta("sfx") == sfx and played_audio.get_playback_position() < 0.05:
			played_audio.stop()
			played_audio.queue_free()
	
	add_child(audio)
	audio.play()

func on_audio_finished(audio: AudioStreamPlayer) -> void:
	audio.queue_free()
