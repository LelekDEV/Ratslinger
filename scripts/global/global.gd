extends Node

var game: Game

var coins: int = 30

var block_input: bool = false
var block_movement: bool = false

var mission_target: Enemy.ID
var mission_total: int = 5
var mission_killed: int = 0
var is_mission_active: bool = false

var waves_cleared: int = 0

var scale_level: int = 0

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("scale_in"):
		scale_level = scale_level + 1
		SignalBus.scale_changed.emit()
	elif Input.is_action_just_pressed("scale_out"):
		scale_level = max(scale_level - 1, 0)
		SignalBus.scale_changed.emit()

func roll_mission() -> void:
	var discluded_id: Array = [Enemy.ID.COW]
	var roll: int = randi_range(0, Enemy.ID.size() - discluded_id.size() - 1)
	
	for id in discluded_id:
		if roll >= id:
			roll += 1
	
	@warning_ignore("int_as_enum_without_cast")
	mission_target = roll
	
	Dialogic.VAR.set_variable("mission_enemy_name", ["foxes", "cows", "beavers", "snakes"][mission_target])

func start_mission() -> void:
	is_mission_active = true
	mission_killed = 0

func pause_game() -> void:
	game.process_mode = Node.PROCESS_MODE_DISABLED

func resume_game() -> void:
	game.process_mode = Node.PROCESS_MODE_INHERIT
	block_input = true
	#set_deferred("block_input", false)
