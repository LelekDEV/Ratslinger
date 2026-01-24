extends CanvasLayer
class_name UI

@onready var hearts: HBoxContainer = $Hearts
@onready var location_popup: Sprite2D = $LocationPopup
@onready var margin_container: MarginContainer = $MarginContainer

@onready var enemies_label: Label = $MarginContainer/VBoxContainer/EnemiesLabel
@onready var mission_label: Label = $MarginContainer/VBoxContainer/MissionLabel
@onready var coin_label: Label = $MarginContainer/CoinsContainer/CoinLabel

@onready var accuracy_bar: AccuracyBar = $AccuracyBar
@onready var bullet_bar: BulletBar = $BulletBar
@onready var crosshair: Sprite2D = $Crosshair

@onready var animation: AnimationHandler = $AnimationHandler

var scale_factor: float = 1

var popup_tween: Tween
var popup_value: float = 0

func _ready() -> void:
	SignalBus.player_coin_collect.connect(update_coin_count)
	
	Dialogic.timeline_started.connect(start_dialogue)
	Dialogic.timeline_ended.connect(end_dialogue)
	
	Dialogic.signal_event.connect(func(signal_name: String):
		if signal_name == "mission_reward":
			mission_label.text = "No mission active"
			animation.play("mission_redeem")
	)
	
	hearts.scale = Vector2i.ONE * 4 * scale_factor
	hearts.global_position = Vector2i.ZERO
	
	location_popup.scale = Vector2i.ONE * 4
	
	accuracy_bar.scale = Vector2i.ONE * 4
	
	bullet_bar.scale = Vector2i.ONE * 4
	bullet_bar.global_position.y = 140 + 6 * 4
	
	show_location_popup()
	update_coin_count()

func _physics_process(_delta: float) -> void:
	location_popup.global_position = get_viewport().get_visible_rect().size / 2 + Vector2(0, popup_value * -100 - 80)
	location_popup.self_modulate.a = sin(popup_value * PI)
	
	accuracy_bar.global_position.x = get_viewport().get_visible_rect().size.x - 85
	bullet_bar.global_position.x = get_viewport().get_visible_rect().size.x - 85 * 4 - 86

func start_dialogue() -> void:
	Global.block_movement = true
	crosshair.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	animation.play("start_dialogue")

func end_dialogue() -> void:
	Global.block_movement = false
	crosshair.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if Global.is_mission_active:
		mission_label.text = "Mission - %s killed: %s/%s" % [
			Dialogic.VAR.get_variable("mission_enemy_name"),
			Global.mission_killed, Global.mission_total
		]
	
	animation.play("end_dialogue")

func toggle_combat_hud(on: bool) -> void:
	accuracy_bar.anim_tween = create_tween() \
		.set_ease(Tween.EASE_OUT if on else Tween.EASE_IN) \
		.set_trans(Tween.TRANS_BACK)
	
	accuracy_bar.anim_tween.tween_property(accuracy_bar, "position:y", (-6 if on else -46) * 4, 0.5)
	
	for slot: BulletBarSlot in bullet_bar.container.get_children():
		slot.anim_tween = create_tween() \
			.set_ease(Tween.EASE_OUT if on else Tween.EASE_IN) \
			.set_trans(Tween.TRANS_CUBIC)
		
		slot.anim_tween.tween_property(slot, "position:y", (0 if on else -40) * 4, 0.5)
		
		await get_tree().create_timer(0.05).timeout

func update_coin_count() -> void:
	coin_label.text = str(Global.coins)

func update_enemy_count(enemies_killed: int, enemies_total: int = 0) -> void:
	if enemies_killed == -1:
		enemies_label.text = "Wave cleared"
	else:
		enemies_label.text = "Wave - enemies killed: " + str(enemies_killed) + "/" + str(enemies_total)
	
	if Global.is_mission_active:
		if Global.mission_killed >= Global.mission_total:
			if mission_label.text != "Mission completed":
				animation.play("mission_complete")
			
			mission_label.text = "Mission completed"
		else:
			mission_label.text = "Mission - %s killed: %s/%s" % [
				Dialogic.VAR.get_variable("mission_enemy_name"),
				Global.mission_killed, Global.mission_total
			]
	else:
		mission_label.text = "No mission active"

func show_location_popup() -> void:
	popup_value = 0
	
	if popup_tween:
		popup_tween.kill()
	
	popup_tween = create_tween()
	
	popup_tween.set_trans(Tween.TRANS_CUBIC)
	popup_tween.set_ease(Tween.EASE_OUT)
	
	popup_tween.tween_property(self, "popup_value", 1, 6)

func update_hearts(health: float) -> void:
	var i: int = 0
	
	var hearts_sorted: Array = hearts.get_children()
	hearts_sorted.reverse()
	
	for heart: Control in hearts_sorted:
		heart.target_fill = clamp((health + (i - 1) * 4) / 4, 0, 1)
		i += 1

func update_hearts_old(health: int) -> void:
	var i: int = 0
	
	var hearts_sorted: Array = hearts.get_children()
	hearts_sorted.reverse()
	
	for heart: Sprite2D in hearts_sorted:
		heart.frame = clamp(8 - health - i * 4, 0, 4)
		i += 1

func on_player_location_change(location: Player.Locations) -> void:
	show_location_popup()
	
	if location == Player.Locations.ARENA:
		toggle_combat_hud(true)
		Global.block_input = false
		
		for i in bullet_bar.next_special.size():
			bullet_bar.next_special[i] = Upgrades.stat_1[i]
		
		bullet_bar.assign_specials(true)
		bullet_bar.update_textures()
	else:
		toggle_combat_hud(false)
		Global.block_input = true
