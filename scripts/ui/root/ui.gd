extends CanvasLayer
class_name UI

@onready var hearts: HBoxContainer = $Hearts
@onready var location_popup: Sprite2D = $LocationPopup
@onready var margin_container: MarginContainer = $MarginContainer

@onready var enemies_label: Label = $MarginContainer/VBoxContainer/EnemiesLabel
@onready var mission_label: Label = $MarginContainer/VBoxContainer/MissionLabel
@onready var coin_label: Label = $MarginContainer/CoinsContainer/ContainerContent/CoinLabel

@onready var accuracy_bar: AccuracyBar = $AccuracyBar
@onready var bullet_bar: BulletBar = $BulletBar
@onready var crosshair: Sprite2D = $Crosshair

@onready var boss_healthbar: Node2D = $BossHealthbar

@onready var shooting_tutorial: Node2D = $TutorialContainer/ShootingTutorial
@onready var shooting_tutorial_label: Label = $TutorialContainer/ShootingTutorialLabel
@onready var tutorial_arrow: Sprite2D = $TutorialArrow

@onready var animation: AnimationHandler = $AnimationHandler

var scale_factor: float = 1
var scale_float: float

var is_combat_hud_on: bool = true
var player_location: Player.Locations = Player.Locations.ARENA

var popup_tween: Tween
var popup_value: float = 0

func _ready() -> void:
	SignalBus.player_coin_collect.connect(update_coin_count)
	
	SignalBus.accuracy_perfect_entered.connect(animation.play.bind("accuracy_perfect"))
	
	if not SignalBus.accuracy_perfect_early.is_connected(GlobalAudio.play_sfx):
		SignalBus.accuracy_perfect_early.connect(GlobalAudio.play_sfx.bind(AudioConsts.SFX.PERFECT))
	
	SignalBus.scale_changed.connect(update_scale)
	
	Dialogic.timeline_started.connect(start_dialogue)
	Dialogic.timeline_ended.connect(end_dialogue)
	
	Dialogic.signal_event.connect(func(signal_data: Dictionary):
		if signal_data.name == "mission_reward":
			mission_label.text = "No mission active"
			animation.play("mission_redeem")
	)
	
	ready_load()
	update_scale()
	
	await SignalBus.game_loaded
	
	if Global.is_title_on:
		animation.play("hide_ui")
		toggle_combat_hud(false)
		
		await get_tree().process_frame
		if not Global.is_introduction_passed:
			get_node("../NPC/MayorNPC/InteractionArea").animation.play("exit")
		
		await SignalBus.title_exited
		if Global.is_introduction_passed:
			animation.play("show_ui")
			Global.block_movement = false
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		else:
			Dialogic.start("introduction")
		
			await Dialogic.timeline_ended
			Global.is_introduction_passed = true
	else:
		toggle_combat_hud(false)
		
		if Global.is_introduction_passed:
			Global.block_movement = false
		else:
			animation.play("hide_ui")
			
			await get_tree().process_frame
			get_node("../NPC/MayorNPC/InteractionArea").animation.play("exit")
			
			Dialogic.start("introduction")
		
			await Dialogic.timeline_ended
			Global.is_introduction_passed = true
	
	if player_location == Player.Locations.ARENA:
		toggle_combat_hud(true)
		Global.block_input = false
	
	show_location_popup()
	update_coin_count()
	update_enemy_count()

func ready_load() -> void:
	await SignalBus.game_loaded
	
	Global.update_dialogic_var()
	
	update_coin_count()
	update_enemy_count()

func update_scale() -> void:
	scale_float = (Global.scale_level + 4) * scale_factor
	var scale_vector: Vector2 = Vector2i.ONE * scale_float
	
	hearts.scale = scale_vector
	hearts.global_position = Vector2i.ZERO
	
	location_popup.scale = scale_vector
	
	accuracy_bar.scale = scale_vector
	accuracy_bar.global_position.y = (-6 if is_combat_hud_on else -46) * scale_float
	
	bullet_bar.scale = scale_vector
	bullet_bar.global_position.y = (35 + 6) * scale_float
	
	shooting_tutorial.scale = scale_vector
	if tutorial_arrow: tutorial_arrow.scale = scale_vector
	
	margin_container.scale = scale_vector / 4
	
	crosshair.origin_scale = scale_float
	
	boss_healthbar.scale = scale_vector / 4

func start_dialogue() -> void:
	Global.block_movement = true
	crosshair.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	Global.update_dialogic_var()
	
	if Global.is_introduction_passed: animation.play("hide_ui")
	animation.play("show_dialogue_strips")

func end_dialogue() -> void:
	Global.block_movement = false
	crosshair.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	update_enemy_count()
	
	animation.play("show_ui")
	animation.play("hide_dialogue_strips")

func toggle_combat_hud(on: bool) -> void:
	is_combat_hud_on = on
	
	accuracy_bar.anim_tween = create_tween() \
		.set_ease(Tween.EASE_OUT if on else Tween.EASE_IN) \
		.set_trans(Tween.TRANS_BACK)
	
	accuracy_bar.anim_tween.tween_property(accuracy_bar, "position:y", (-6 if on else -46) * scale_float, 0.5)
	
	for slot: BulletBarSlot in bullet_bar.container.get_children():
		slot.anim_tween = create_tween() \
			.set_ease(Tween.EASE_OUT if on else Tween.EASE_IN) \
			.set_trans(Tween.TRANS_CUBIC)
		
		slot.anim_tween.tween_property(slot, "position:y", (0 if on else -40) * scale_float, 0.5)
		
		await get_tree().create_timer(0.05).timeout

func update_coin_count() -> void:
	coin_label.text = str(Global.coins)

func update_enemy_count(enemies_killed: int = -1, enemies_total: int = 0) -> void:
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
	player_location = location
	location_popup.frame = location
	
	if Global.is_title_on:
		return
	
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
		
		if location == Player.Locations.TOWN and Global.builder_value == 1:
			await get_tree().create_timer(0.5).timeout
			Dialogic.start("building_repaired")
