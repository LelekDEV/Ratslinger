extends CanvasLayer

@onready var settings_dialog: ConfirmationDialog = get_tree().get_first_node_in_group("settings_dialog")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var shop_layer: CanvasLayer = get_tree().get_first_node_in_group("shop_layer")

@onready var paused_label: RichTextLabel = $PausedLabel
@onready var button_container: HBoxContainer = $ButtonContainer

@export var croshair: Sprite2D

func _ready() -> void:
	SignalBus.scale_changed.connect(update_scale)
	
	button_container.get_child(0).connect("pressed", func():
		visible = false
		
		if not (shop_layer.visible or Dialogic.current_timeline):
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
		if not Dialogic.current_timeline:
			croshair.visible = true
		
		Global.resume_game(not player.location == Player.Locations.ARENA)
	)
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
	
	update_scale()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not Global.is_title_on:
		visible = true
		croshair.visible = false
		
		Global.is_game_restarted = true
		Global.is_title_restarted = true
		
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Global.pause_game()
	
	button_container.set_deferred("size", get_viewport().get_visible_rect().size / button_container.scale)
	button_container.global_position = Vector2.ZERO
	
	paused_label.global_position = Vector2(0, 100)

func update_scale() -> void:
	var scale_float: float = Global.scale_level + 4
	var scale_vector: Vector2 = Vector2i.ONE * scale_float
	
	button_container.scale = scale_vector
	
	paused_label.add_theme_font_size_override("normal_font_size", int(scale_float * 16))
