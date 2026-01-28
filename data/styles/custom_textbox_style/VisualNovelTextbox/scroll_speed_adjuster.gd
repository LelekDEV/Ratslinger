extends Node

@onready var bar: VScrollBar = get_parent().get_v_scroll_bar()

@export var speed: int = 1

func _process(_delta: float):
	if Input.is_action_just_released("text_scroll_down") or Input.is_action_pressed("text_scroll_down"):
		bar.value += speed
	elif Input.is_action_just_released("text_scroll_up") or Input.is_action_pressed("text_scroll_up"):
		bar.value -= speed
