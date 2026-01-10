extends CanvasLayer

@onready var bullet_bar: BulletBar = get_tree().get_first_node_in_group("bullet_bar")

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
	
	for i in bullet_bar.next_special.size():
		bullet_bar.next_special[i] = Upgrades.stat_1[i]
	
	bullet_bar.assign_specials(true)
	bullet_bar.update_textures()
	
	visible = false

func update_labels() -> void:
	var level: int = Upgrades.levels[0]
	
	var level_desc: String = "\nLevel: %s" % ("not bought" if level == 0 else str(level))
	var replaces_digit: int = (Upgrades.stat_1[0] + 1) % 10
	var replaces_suffix: String = "st" if replaces_digit == 1 else "nd" if replaces_digit == 2 else "rd" if replaces_digit == 3 else "th"
	var replaces_desc: String = "" if level == 0 else "\nReplaces: every %s%s bullet" % [Upgrades.stat_1[0] + 1, replaces_suffix]
	
	desc_label.text = Consts.ITEM_DESC[0] + level_desc + replaces_desc
	upgrade_button.text = "buy" if level == 0 else "upgrade"

func _on_button_pressed() -> void:
	exit()

func _on_upgrade_button_pressed() -> void:
	Upgrades.levels[0] += 1
	Upgrades.stat_1[0] = 10 - Upgrades.levels[0]
	
	update_labels()
