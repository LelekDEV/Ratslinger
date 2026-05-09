extends CanvasLayer
class_name ShopLayer

@onready var bullet_bar: BulletBar = get_tree().get_first_node_in_group("bullet_bar")

@onready var ui: UI = $"../UI"

@onready var bullet_info: ShopInfo = $HBoxContainer/RightContainer/BulletInfoContainer
@onready var weapon_info: ShopInfo = $HBoxContainer/RightContainer/WeaponInfoParent/WeaponInfoContainer
@onready var weapon_info_parent: Control = $HBoxContainer/RightContainer/WeaponInfoParent
@onready var scroll_bar: VScrollBar = $HBoxContainer/VScrollBar

@onready var upgrade_button: Button = $HBoxContainer/RightContainer/UpgradeButton
@onready var cost_label: Label = $HBoxContainer/RightContainer/CoinsContainer/CostLabel
@onready var cash_label: Label = $HBoxContainer/RightContainer/CoinsContainer/CashLabel

@onready var main_container: HBoxContainer = $HBoxContainer

@onready var item_sprites: Array = [
	$HBoxContainer/LeftContainer/ShopSpriteParent/VampireSprite,
	$HBoxContainer/LeftContainer/ShopSpriteParent/FireSprite,
	$HBoxContainer/LeftContainer/ShopSpriteParent/PoisonSprite,
	$HBoxContainer/LeftContainer/ForgeSpriteParent/ShotgunSprite,
	$HBoxContainer/LeftContainer/ForgeSpriteParent/BlunderboostSprite
]

@onready var shop_sprite_parents: Array = [
	$HBoxContainer/LeftContainer/ShopSpriteParent,
	$HBoxContainer/LeftContainer/ForgeSpriteParent
]

@onready var shop_visible_nodes: Array = [
	$HBoxContainer/RightContainer/BulletInfoContainer
]

@onready var forge_visible_nodes: Array = [
	$HBoxContainer/RightContainer/WeaponInfoParent,
	$HBoxContainer/RightContainer/TitleLabelWeapon,
	$HBoxContainer/VScrollBar
]

enum Pages {VAMPIRE_BULLET, FIRE_BULLET, POISON_BULLET, SHOTGUN_WEAPON, BLUNDERBOOST_WEAPON}
var page: Pages = Pages.VAMPIRE_BULLET

enum Shops {SHOP, FORGE}
var shop: Shops

func enter(new_shop: Shops) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	Global.pause_game()
	
	shop = new_shop
	if shop == Shops.SHOP: 
		page = Pages.VAMPIRE_BULLET
		
		# Why in the actual word is node.visible green?
		# That's so funny
		for node in shop_visible_nodes: node.visible = true
		for node in forge_visible_nodes: node.visible = false
	
	elif shop == Shops.FORGE:
		page = Pages.SHOTGUN_WEAPON
		
		for node in shop_visible_nodes: node.visible = false
		for node in forge_visible_nodes: node.visible = true
	
	var i: int = 0
	for p in shop_sprite_parents:
		p.visible = i == shop
		i += 1
	
	visible = true
	update_labels()

func exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	Global.resume_game()
	
	ui.update_coin_count()
	
	visible = false

func get_cost(level: int) -> int:
	return int(5 + (level + 1) * level / 2.0)

func _physics_process(delta: float) -> void:
	if shop == Shops.FORGE:
		# Aside for the is_action_just_released quirk,
		# it is fairly interesting how scroll isn't affected by framerate
		if Input.is_action_just_released("scroll_down"):
			scroll_bar.value += 7.5
		if Input.is_action_pressed("scroll_down_button"):
			scroll_bar.value += 1 * delta * Consts.FIXED_LERP_RELATIVE_FPS
		
		if Input.is_action_just_released("scroll_up"):
			scroll_bar.value -= 7.5
		if Input.is_action_pressed("scroll_up_button"):
			scroll_bar.value -= 1 * delta * Consts.FIXED_LERP_RELATIVE_FPS
		
		weapon_info.position.y = lerp(0.0, weapon_info_parent.size.y - weapon_info.size.y, scroll_bar.value / 100.0)

func update_labels() -> void:
	if shop == Shops.SHOP:
		var level: int = Upgrades.levels[page]
		
		var level_desc: String = "\nLevel: %s" % ("not bought" if level == 0 else str(level))
		var replaces_digit: int = (Upgrades.stat_1[page] + 1) % 10
		var replaces_suffix: String = "st" if replaces_digit == 1 else "nd" if replaces_digit == 2 else "rd" if replaces_digit == 3 else "th"
		var replaces_desc: String = "" if level == 0 else "\nReplaces: every %s%s bullet" % [Upgrades.stat_1[page] + 1, replaces_suffix]
		
		bullet_info.title_label.text = Consts.ITEM_NAMES[page]
		bullet_info.desc_label.text = Consts.ITEM_DESC[page] + level_desc + replaces_desc
		
		cost_label.text = "Cost: %s" % get_cost(level)
		
		if level == 10:
			upgrade_button.text = "max level"
			upgrade_button.disabled = true
			
			cost_label.text = "Cost: -"
		else:
			upgrade_button.text = "buy" if level == 0 else "upgrade"
			upgrade_button.disabled = false
	
	elif shop == Shops.FORGE:
		scroll_bar.value = 0
		
		weapon_info.title_label.text = Consts.ITEM_NAMES[page]
		weapon_info.desc_label.text = Consts.ITEM_DESC[page][0]
		weapon_info.desc_label_extra.text = Consts.ITEM_DESC[page][1]
		
		weapon_info.accuracy_layout_sprite.texture = Global.resources.accuracy_texture_test
		
		match page:
			Pages.SHOTGUN_WEAPON: cost_label.text = "Cost: %s" % Consts.SHOTGUN_PRICE
			Pages.BLUNDERBOOST_WEAPON: cost_label.text = "Cost: %s" % Consts.BLUNDERBOOST_PRICE
		
		if Upgrades.unlocked_weapons[page - 3]:
			upgrade_button.text = "bought"
			upgrade_button.disabled = true
		else:
			upgrade_button.text = "buy"
			upgrade_button.disabled = false
	
	cash_label.text = "Cash: %s" % Global.coins
	
	var i: int = 0
	for sprite in item_sprites:
		sprite.material.set_shader_parameter("is_visible", i == page)
		i += 1

func _on_button_pressed() -> void:
	exit()

func _on_upgrade_button_pressed() -> void:
	if shop == Shops.SHOP:
		var level: int = Upgrades.levels[page]
		var cost: int = get_cost(level)
		
		if Global.coins >= cost:
			Global.coins -= cost
			Upgrades.levels[page] += 1
			Upgrades.stat_1[page] = 10 - level
			
			GlobalAudio.play_sfx(AudioConsts.SFX.SELECT, -4)
	
	elif shop == Shops.FORGE:
		var cost: int
		match page:
			Pages.SHOTGUN_WEAPON: cost = Consts.SHOTGUN_PRICE
			Pages.BLUNDERBOOST_WEAPON: cost = Consts.BLUNDERBOOST_PRICE
		
		if Global.coins >= cost:
			Global.coins -= cost
			Upgrades.unlocked_weapons[page - 3] = true
			
			GlobalAudio.play_sfx(AudioConsts.SFX.SELECT, -4)
	
	update_labels()

func _on_next_button_pressed() -> void:
	match shop:
		Shops.SHOP: page = (page + 1) % 3 as Pages
		Shops.FORGE: page = max((page + 1) % 5, 3) as Pages
	
	update_labels()

func _on_previous_button_pressed() -> void:
	match shop:
		Shops.SHOP: page = (page - 1) % 3 as Pages
		Shops.FORGE: page = (page - 1) % 5 + int(page == 3) * 2 as Pages
	
	update_labels()
