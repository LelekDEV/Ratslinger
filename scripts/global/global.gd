extends Node

var game: Game

var coins: int = 30

var block_input: bool = true
var block_movement: bool = true

var mission_target: Enemy.ID
var mission_total: int = 5
var mission_killed: int = 0
var is_mission_active: bool = false

var all_enemies: Array

var waves_cleared: int = 0

var rain_value: float = -randi_range(0, 600)

var is_title_on: bool = true

var scale_level: int = 0

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("scale_in"):
		scale_level = scale_level + 1
		SignalBus.scale_changed.emit()
	elif Input.is_action_just_pressed("scale_out"):
		scale_level = max(scale_level - 1, 0)
		SignalBus.scale_changed.emit()
	
	if rain_value < 0:
		rain_value += delta
		
		if rain_value > 0:
			# rain, 2.7 - 5.4 min, ~35%
			rain_value = randi_range(162, 324)
	else:
		rain_value -= delta
		
		if rain_value < 0:
			# clear, 5 - 10 min, ~65%
			rain_value = -randi_range(300, 600)

# THIS IS VERY IMPORTANT!!!
# Use this func whenever you want to call lerp() in _physics_process() such that:
# x = lerp(x, ...)
# All the weights are based on relation as if engine ticks per second was Consts.FIXED_LERP_RELATIVE_FPS
# The value, as the writing of this is set to 144
# It may be changed in scripts/global/consts.gd although that's unadvised, since it will result in disregulating all weights
func fixed_lerp(from: Variant, to: Variant, weight: Variant) -> Variant:
	return lerp(from, to, 1 - exp(Consts.FIXED_LERP_RELATIVE_FPS * log(1 - weight) * get_physics_process_delta_time()))

func get_rain_change_ratio() -> float:
	if rain_value < 0:
		return max(rain_value + Consts.RAIN_CHANGE_TIME, 0) / Consts.RAIN_CHANGE_TIME
	else:
		return min(rain_value, Consts.RAIN_CHANGE_TIME) / Consts.RAIN_CHANGE_TIME

func get_uid() -> StringName:
	return str(Time.get_ticks_usec()) + "_" + str(randi())

func roll_mission() -> void:
	var discluded_id: Array = [Enemy.ID.COW]
	var roll: int = randi_range(0, Enemy.ID.size() - discluded_id.size() - 1)
	
	for id in discluded_id:
		if roll >= id:
			roll += 1
	
	@warning_ignore("int_as_enum_without_cast")
	mission_target = roll
	update_dialogic_var()

func update_dialogic_var() -> void:
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
