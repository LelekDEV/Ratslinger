extends Node

# Save paths relative to Global singleton
# In order to get data from the root node start with game:
var gloabal_save_paths: Array = [
	^"game:player:global_position",
	^"waves_cleared",
	^"coins",
	^"mission_target",
	^"mission_total",
	^"mission_killed",
	^"is_mission_active"
]

# Save paths relative to Global singleton
var upgrades_save_paths: Array = [
	^"levels",
	^"stat_1"
]

var save_on_exit: bool = true

func _ready() -> void:
	call_deferred("load_game")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if save_on_exit:
			save_game()
		
		get_tree().quit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("wipe_data"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://savegame.data"))
		save_on_exit = false
		
		print("ctrl + f1 pressed: save data will be wiped on next project debug")
	
	if Input.is_action_just_pressed("exit"):
		if save_on_exit:
			save_game()
		
		get_tree().quit()

func save_game() -> void:
	var file: FileAccess = FileAccess.open("user://savegame.data", FileAccess.WRITE)
	var data: Dictionary = {}
	
	for path in gloabal_save_paths:
		data[path] = Global.get_indexed(path)
	
	for path in upgrades_save_paths:
		data[path] = Upgrades.get_indexed(path)
	
	file.store_var(data)
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.data"):
		return
	
	var file: FileAccess = FileAccess.open("user://savegame.data", FileAccess.READ)
	var data: Dictionary = file.get_var()
	
	for path in data.keys():
		if path in gloabal_save_paths:
			Global.set_indexed(path, data[path])
		elif path in upgrades_save_paths:
			Upgrades.set_indexed(path, data[path])
	
	file.close()
	
	SignalBus.game_loaded.emit()
