extends CanvasLayer

@onready var settings_dialog: ConfirmationDialog = get_tree().get_first_node_in_group("settings_dialog")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var shop_layer: CanvasLayer = get_tree().get_first_node_in_group("shop_layer")
@onready var bestiary_layer: CanvasLayer = get_tree().get_first_node_in_group("bestiary_layer")

@onready var paused_label: RichTextLabel = $PausedLabel
@onready var action_label: Label = $ActionLabel
@onready var button_container: HBoxContainer = $ButtonContainer

@export var croshair: Sprite2D

var action_label_tween: Tween

func _ready() -> void:
	SignalBus.scale_changed.connect(update_scale)
	
	button_container.get_child(0).connect("pressed", resume)
	button_container.get_child(1).connect("pressed", settings_dialog.popup_centered)
	button_container.get_child(2).connect("pressed", func():
		get_tree().paused = false
		
		Global.is_title_on = true
		Settings.skip_title = false
		SaverLoader.save_game()
		
		get_tree().reload_current_scene()
		SignalBus.game_restart.emit()
	)
	button_container.get_child(3).connect("pressed", SaverLoader.exit)
	
	var i: int = 0
	for text in ["Resume", "Settings", "Return to title screen", "Exit"]:
		button_container.get_child(i).connect("mouse_entered", show_action_label.bind(text))
		button_container.get_child(i).connect("mouse_exited", hide_action_label)
		i += 1
	
	update_scale()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not Global.is_title_on and not Global.game.is_cutscene_on:
		if visible:
			resume()
		else:
			visible = true
			croshair.visible = false
			
			Global.is_game_restarted = true
			Global.is_title_restarted = true
			
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Global.pause_game()
	
	button_container.set_deferred("size", get_viewport().get_visible_rect().size / button_container.scale)
	button_container.global_position = Vector2.ZERO
	
	paused_label.global_position = Vector2(0, 100)
	action_label.global_position.y = get_viewport().get_visible_rect().size.y / 2 + 20 * button_container.scale.y
	action_label.size.y = 0
	
	var filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(0, 0)
	filter.cutoff_hz = Global.fixed_lerp(filter.cutoff_hz, 500.0 if visible else 15000.0, 0.2)
	AudioServer.set_bus_effect_enabled(0, 0, filter.cutoff_hz != 15000)

func resume() -> void:
	visible = false
	
	if not (shop_layer.visible or bestiary_layer.visible or Dialogic.current_timeline):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if not Dialogic.current_timeline:
		croshair.visible = true
	
	Global.resume_game(not player.location == Player.Locations.ARENA)

func update_scale() -> void:
	var scale_float: float = Global.scale_level + 4
	var scale_vector: Vector2 = Vector2i.ONE * scale_float
	
	button_container.scale = scale_vector
	
	paused_label.add_theme_font_size_override("normal_font_size", int(scale_float * 16))
	action_label.add_theme_font_size_override("font_size", int(scale_float * 16) - 16)

func show_action_label(set_text: String) -> void:
	action_label.text = set_text
	
	action_label_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	
	action_label_tween.tween_property(action_label, "visible_ratio", 1, 0.2)

func hide_action_label() -> void:
	if action_label_tween.is_valid() and action_label_tween.is_running():
		action_label_tween.kill()
	
	action_label.visible_ratio = 0
