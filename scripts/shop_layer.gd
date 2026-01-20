extends CanvasLayer

@onready var bullet_bar: BulletBar = get_tree().get_first_node_in_group("bullet_bar")

@onready var ui: UI = $"../UI"

@onready var title_label: Label = $HBoxContainer/RightContainer/TitleLabel
@onready var desc_label: Label = $HBoxContainer/RightContainer/DescLabel
@onready var upgrade_button: Button = $HBoxContainer/RightContainer/UpgradeButton
@onready var cost_label: Label = $HBoxContainer/RightContainer/HBoxContainer/CostLabel
@onready var cash_label: Label = $HBoxContainer/RightContainer/HBoxContainer/CashLabel

@onready var item_sprites: Array = [
	$HBoxContainer/LeftContainer/SpriteParent/VampireSprite,
	$HBoxContainer/LeftContainer/SpriteParent/FireSprite,
	$HBoxContainer/LeftContainer/SpriteParent/PoisonSprite
]

enum Pages {VAMPIRE_BULLET, FIRE_BULLET, POISON_BULLET}
var page: Pages = Pages.VAMPIRE_BULLET

func enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.pause_game()
	
	visible = true
	update_labels()

func exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Global.resume_game()
	
	ui.update_coin_count()
	
	visible = false

func get_cost(level: int) -> int:
	return int(5 + (level + 1) * level / 2.0)

func update_labels() -> void:
	var level: int = Upgrades.levels[page]
	
	var level_desc: String = "\nLevel: %s" % ("not bought" if level == 0 else str(level))
	var replaces_digit: int = (Upgrades.stat_1[page] + 1) % 10
	var replaces_suffix: String = "st" if replaces_digit == 1 else "nd" if replaces_digit == 2 else "rd" if replaces_digit == 3 else "th"
	var replaces_desc: String = "" if level == 0 else "\nReplaces: every %s%s bullet" % [Upgrades.stat_1[page] + 1, replaces_suffix]
	
	title_label.text = Consts.ITEM_NAMES[page]
	desc_label.text = Consts.ITEM_DESC[page] + level_desc + replaces_desc
	
	cost_label.text = "Cost: %s" % get_cost(level)
	cash_label.text = "Cash: %s" % Global.coins
	
	if level == 10:
		upgrade_button.text = "max level"
		upgrade_button.disabled = true
		
		cost_label.text = "Cost: -"
	else:
		upgrade_button.text = "buy" if level == 0 else "upgrade"
		upgrade_button.disabled = false
	
	var i: int = 0
	
	for sprite in item_sprites:
		sprite.material.set_shader_parameter("is_visible", i == page)
		i += 1

func _on_button_pressed() -> void:
	exit()

func _on_upgrade_button_pressed() -> void:
	var level: int = Upgrades.levels[page]
	var cost: int = get_cost(level)
	
	if Global.coins >= cost:
		Global.coins -= cost
		Upgrades.levels[page] += 1
		Upgrades.stat_1[page] = 10 - level
		
		GlobalAudio.play_sfx(GlobalAudio.SFX.SELECT, -4)
	
	update_labels()

func _on_next_button_pressed() -> void:
	page = (page + 1) % Pages.size() as Pages
	update_labels()

func _on_previous_button_pressed() -> void:
	page = Pages.size() - 1 if page == 0 else page - 1 as Pages
	update_labels()
