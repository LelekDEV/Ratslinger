extends Node2D
class_name SqueezeLock

@onready var container: HBoxContainer = $HBoxContainer

enum Keys {UP, DOWN, LEFT, RIGHT}
var keys: Array = []
var current_key: int = 0

const sprite_coords: Array = [
	Vector2(97, 66), 
	Vector2(33, 66), 
	Vector2(1, 34),
	Vector2(49, 34)
]

const actions: Array = [
	&"up", &"down", &"left", &"right"
]

var is_locked: bool = false

signal right_key_pressed

func _physics_process(_delta: float) -> void:
	if not is_locked:
		return
	
	if Input.is_action_just_pressed(actions[keys[current_key]]):
		container.get_child(current_key).visible = false
		
		if current_key == keys.size() - 1:
			is_locked = false
		else:
			current_key += 1
		
		right_key_pressed.emit()

func lock() -> void:
	generate_keys()
	
	var i: int = 0
	for key: Control in container.get_children():
		key.visible = true
		(key.get_node("Sprite2D") as Sprite2D).region_rect.position = sprite_coords[keys[i]]
		i += 1
	
	is_locked = true
	current_key = 0

func generate_keys():
	keys.clear()
	
	for i in range(3):
		if i == 2 and keys[0] == keys[1]:
			var roll: int = randi_range(0, Keys.size() - 2)
			if roll >= keys[0]:
				roll += 1
			keys.append(roll)
		else:
			keys.append(randi_range(0, Keys.size() - 1))
