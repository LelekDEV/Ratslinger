extends Node

var accuracy_flash_accessibility: bool = true
var skip_title: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_accessibility"):
		accuracy_flash_accessibility = not accuracy_flash_accessibility
		GlobalAudio.play_sfx(AudioConsts.SFX.TURN_ON if accuracy_flash_accessibility else AudioConsts.SFX.TURN_OFF, -4)
		
		print("Settings: 'accuracy_flash_accessibility' set to '" + str(accuracy_flash_accessibility) + "'")
	
	if Input.is_action_just_pressed("toggle_title"):
		skip_title = not skip_title
		GlobalAudio.play_sfx(AudioConsts.SFX.TURN_ON if skip_title else AudioConsts.SFX.TURN_OFF, -4)
		
		print("Settings: 'skip_title' set to '" + str(skip_title) + "'")
