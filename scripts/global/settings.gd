extends Node

var accuracy_flash_accessibility: bool = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_accessibility"):
		accuracy_flash_accessibility = not accuracy_flash_accessibility
		GlobalAudio.play_sfx(AudioConsts.SFX.TURN_ON if accuracy_flash_accessibility else AudioConsts.SFX.TURN_OFF, -4)
