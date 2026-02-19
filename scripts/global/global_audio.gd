extends Node

func play_sfx(sfx: AudioStream, volume: int = 0, pitch: float = 1, delay: float = 0) -> void:
	await get_tree().create_timer(delay).timeout
	
	var audio = AudioStreamPlayer.new()
	
	audio.stream = sfx
	audio.set_meta("sfx", sfx.resource_path)
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
