extends Node

# IMPORTANT!! Keep this at the bottom of autoload hierarchy to ensure it's working

# Save paths relative to specific Singletons
# This does support Godot's built-in Singletons such as Engine
# In order to get data from the root node start with 'game:'
var save_paths: Dictionary = {
	Global: [
		^"game:player:global_position",
		^"waves_cleared",
		^"coins",
		^"mission_target",
		^"mission_total",
		^"mission_killed",
		^"is_mission_active",
		^"is_tutorial_passed",
		^"is_introduction_passed",
		^"builder_value",
		^"rain_value"
	],
	Upgrades: [
		^"levels",
		^"stat_1"
	],
	Settings: [
		^"accuracy_flash_accessibility",
		^"skip_title"
	],
	Engine: [
		^"physics_ticks_per_second",
		^"max_fps"
	]
}

var save_on_exit: bool = true

func _ready() -> void:
	call_deferred("load_game")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit()

func _process(_delta: float) -> void:
	"""if Input.is_action_just_pressed("wipe_data"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://savegame.data"))
		save_on_exit = false
		
		print("ctrl + f1 pressed: save data will be wiped on next project debug")"""
	
	if Input.is_action_just_pressed("exit"):
		if save_on_exit:
			save_game()
		
		get_tree().quit()

func exit() -> void:
	if save_on_exit:
		save_game()
	
	get_tree().quit()

func save_game() -> void:
	SignalBus.game_save_queued.emit()
	
	var file: FileAccess = FileAccess.open("user://savegame.data", FileAccess.WRITE)
	var data: Dictionary = {}
	
	for key in save_paths:
		for path: NodePath in save_paths[key]:
			data[path] = key.get_indexed(path)
	
	file.store_var(data)
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.data"):
		SignalBus.game_loaded.emit()
		return
	
	var file: FileAccess = FileAccess.open("user://savegame.data", FileAccess.READ)
	var data: Dictionary = file.get_var()
	
	for path: NodePath in data.keys():
		for key in save_paths:
			if path in save_paths[key]:
				key.set_indexed(path, data[path])
	
	file.close()
	
	SignalBus.game_loaded.emit()
