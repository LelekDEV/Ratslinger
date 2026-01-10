extends CanvasLayer

@onready var title_label: Label = $HBoxContainer/RightContainer/TitleLabel
@onready var desc_label: Label = $HBoxContainer/RightContainer/DescLabel
@onready var upgrade_button: Button = $HBoxContainer/RightContainer/UpgradeButton

func enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.pause_game()
	
	visible = true
	update_labels()

func exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Global.resume_game()
	
	visible = false

func update_labels() -> void:
	var level: int = Upgrades.levels[0]
	
	desc_label.text = "%s\nLevel: %s" % [Consts.ITEM_DESC[0], "not bought" if level == 0 else str(level)]
	upgrade_button.text = "buy" if level == 0 else "upgrade"

func _on_button_pressed() -> void:
	exit()

func _on_upgrade_button_pressed() -> void:
	Upgrades.levels[0] += 1
	update_labels()
