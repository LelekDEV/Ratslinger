extends Node

var game: Node2D

var coins: int = 50

var block_input: bool = false
var block_movement: bool = false

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")

func pause_game() -> void:
	game.process_mode = Node.PROCESS_MODE_DISABLED

func resume_game() -> void:
	game.process_mode = Node.PROCESS_MODE_INHERIT
	block_input = true
	#set_deferred("block_input", false)
