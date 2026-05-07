extends Panel

@onready var left_label = $MarginContainer/HBoxContainer/LeftLabel
@onready var right_label = $MarginContainer/HBoxContainer/RightLabel

func set_texts(left_text: String, right_text: String):
	left_label.text = left_text
	right_label.text = right_text
