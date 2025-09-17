extends Node

enum SFX {HIT, LOSE}

func play_sfx(sfx: SFX) -> void:
	var audio = AudioStreamPlayer.new()
	
	match sfx:
		SFX.HIT: audio.stream = preload("res://audio/SFX/hit.wav")
		SFX.LOSE: audio.stream = preload("res://audio/SFX/lose.wav")
	
	audio.finished.connect(on_audio_finished.bind(audio))
	
	add_child(audio)
	audio.play()

func on_audio_finished(audio: AudioStreamPlayer) -> void:
	audio.queue_free()
