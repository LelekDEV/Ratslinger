extends CanvasLayer

@onready var v_scroll_panel: VScrollBar = $Control/Panel/VScrollBar
@onready var v_box: VBoxContainer = $Control/Control/VBoxContainer
@onready var control: Control = $Control/Control

var mouse_inside: bool = false
		
func _process(_delta: float) -> void:
	set_up_panels() # not the most optimal thing but it will do for now
	v_box.position.y = lerp(0.0, control.size.y - v_box.size.y, v_scroll_panel.value / 100.0)

func set_up_panels() -> void:
	var enemies_cleared = (
	Global.enemy_stats["Fox"]["kills"] +
	Global.enemy_stats["Beaver"]["kills"] +
	Global.enemy_stats["Snake"]["kills"] +
	Global.enemy_stats["Owl"]["kills"]
	)

	var panel_texts = [
		["Waves beaten:", str(Global.waves_cleared)],
		["Enemies killed:", str(enemies_cleared)],
		["Coins collected:", "0"],
		["XP gained:", "0"],
		["Perfect shots:", "0"],
		["Bosses Defeated:", "0"],
		["Foxes Killed:", str(Global.enemy_stats["Fox"]["kills"])],
		["Beavers Killed:", str(Global.enemy_stats["Beaver"]["kills"])],
		["Snakes Killed:", str(Global.enemy_stats["Snake"]["kills"])],
		["Owls Killed:", str(Global.enemy_stats["Owl"]["kills"])],
	]
	
	for i in range(v_box.get_child_count()):
		var panel = v_box.get_child(i)
		
		panel.set_texts(
			panel_texts[i][0],
			panel_texts[i][1]
		)

func _input(event: InputEvent) -> void:
	if mouse_inside:
		if event is InputEventMouseButton and event.pressed:

			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				v_scroll_panel.value += 5

			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				v_scroll_panel.value -= 5

func _on_control_mouse_entered() -> void:
	mouse_inside = true
	print(mouse_inside)



func _on_control_mouse_exited() -> void:
	mouse_inside = false
