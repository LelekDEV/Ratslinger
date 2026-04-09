extends Node2D

@onready var bestiary_layer = get_tree().get_first_node_in_group("bestiary_layer")

var button1: Button
var button2: Button

var base_pos1: Vector2
var base_pos2: Vector2

func _ready():
	button1 = get_tree().get_first_node_in_group("left_arrow")
	button2 = get_tree().get_first_node_in_group("right_arrow")

	
func _on_button_right_pressed() -> void:
	print("Right pressed")
	bestiary_layer.flip_page_data(2)


func _on_button_left_pressed() -> void:
	print("Left pressed")
	bestiary_layer.flip_page_data(-2)
