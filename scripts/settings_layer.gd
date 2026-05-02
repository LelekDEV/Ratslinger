extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var button_container: VBoxContainer = $ButtonContainer

@onready var wheel_sprite: Sprite2D = $WheelSprite

@onready var options_parent: Node = $Options
@onready var options: Array = options_parent.get_children()

@onready var slots_parent: Node2D = $Slots
@onready var slots: Array = slots_parent.get_children()

var selected_option: int = 0
var progress_option: float = 0
var option_tween: Tween

const SLOT_POS: Array = [
	Vector2(-120.0, 40.0), 
	Vector2(-120.0, -80.0), 
	Vector2(0.0, -144.0), 
	Vector2(120.0, -80.0), 
	Vector2(120.0, 40.0), 
	Vector2(0.0, 112.0)
]

func _ready() -> void:
	for option: Option in options:
		if option.type == Option.Type.VALUE:
			option.get_node("LabelParent/HSlider").connect(
				"value_changed", 
				func(value: float): option.get_node("LabelParent/Value").text = str(int(value)) + option.value_suffix
			)
		
		elif option.type == Option.Type.SELECT:
			option.get_node("LabelParent/HSlider").connect(
				"value_changed", 
				func(value: float): option.get_node("LabelParent/Value").text = option.select_options[int(value)]
			)
	
	exit()

func _physics_process(_delta: float) -> void:
	handle_input()
	
	var scale_factor: float = Global.scale_level / 4.0 + 1
	scale = Vector2.ONE * scale_factor
	
	color_rect.set_deferred("size", get_viewport().get_visible_rect().size / scale)
	color_rect.global_position = Vector2.ZERO
	
	button_container.set_deferred("size", get_viewport().get_visible_rect().size / scale * Vector2(0, 0.25))
	button_container.global_position = Vector2(20, 0)
	
	var center: Vector2 = get_viewport().get_visible_rect().size * Vector2(1, 0.5) / scale
	const DIST: float = 250
	
	wheel_sprite.global_position = center
	slots_parent.global_position = center
	
	var i: int = 0
	for slot: Sprite2D in slots:
		var clamped_progress: float = max(progress_option, selected_option - 1)
		slot.position = lerp(
			SLOT_POS[(i + selected_option + 1) % 6], 
			SLOT_POS[(i + selected_option) % 6],
			max(int(selected_option < clamped_progress), 0) + selected_option - clamped_progress
		) # L crazy formula right there
		# anything but if statements
		
		i += 1
	
	i = 0
	for option: Option in options:
		option.global_position = center
		option.rotation = (i - progress_option) * PI / len(options)
		
		var label: Label = option.get_node("LabelParent/Label")
		var value: Label = option.get_node("LabelParent/Value")
		var line_size: float = max(abs(label.position.x), abs(value.position.x))
		
		var slider: HSlider = option.get_node("LabelParent/HSlider")
		
		option.get_node("LabelParent").position.x = -DIST
		label.add_theme_font_size_override("font_size", lerp(64, 32, abs(i - progress_option)))
		
		for line: ColorRect in [option.get_node("LabelParent/Underline"), option.get_node("LabelParent/Overline")]:
			line.size.x = line_size * lerp(1.0, 0.0, abs(i - progress_option))
			line.position.x = -line_size
		
		for child: Node in option.get_node("LabelParent").get_children():
			if child != label:
				child.visible = i == selected_option
		
		if i == selected_option:
			if Input.is_action_just_pressed("left"):
				slider.value -= 5 if option.type == Option.Type.VALUE else 1
			if Input.is_action_just_pressed("right"):
				slider.value += 5 if option.type == Option.Type.VALUE else 1
		
		i += 1

func save_values() -> void:
	for option: Option in options:
		# Ok so apparently you cannot merge NodePaths as of now:
		# https://github.com/godotengine/godot-proposals/issues/13777
		# It is not my fault if the program uses 1.00069 times more resources by using strings
		
		# Also, that approach wouldn't work since built-in Singleton paths are weird.
		# If you wan't to have a custom one it's time to hardcode another bool :3
		
		var slider: HSlider = option.get_node("LabelParent/HSlider")
		
		if option.use_engine_singleton:
			Engine.set_indexed(option.setting_path, slider.value)
			if option.setting_path_extra:
				Engine.set_indexed(option.setting_path, slider.value)
		else:
			Settings.set_indexed(option.setting_path, slider.value)
			if option.setting_path_extra:
				Settings.set_indexed(option.setting_path, slider.value)

func update_values() -> void:
	for option: Option in options:
		var value: Label = option.get_node("LabelParent/Value")
		var slider: HSlider = option.get_node("LabelParent/HSlider")
		
		var data: int
		if option.use_engine_singleton:
			data = Engine.get_indexed(option.setting_path)
		else:
			data = Settings.get_indexed(option.setting_path)
		
		slider.value = data
		
		if option.type == Option.Type.VALUE:
			value.text = str(data) + option.value_suffix
		elif option.type == Option.Type.SELECT:
			value.text = option.select_options[data]

func enter() -> void:
	update_values()
	visible = true

func exit() -> void:
	visible = false

func handle_input() -> void:
	if Input.is_action_just_pressed("up") and selected_option < len(options) - 1:
		selected_option += 1
		
		option_tween = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUINT)
		
		option_tween.tween_property(self, "progress_option", selected_option, 0.25)
	
	if Input.is_action_just_pressed("down") and selected_option > 0:
		selected_option -= 1
		
		option_tween = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUINT)
		
		option_tween.tween_property(self, "progress_option", selected_option, 0.25)

func _on_apply_button_pressed() -> void:
	save_values()
	Settings.update()
	exit()

func _on_cancel_button_pressed() -> void:
	exit()
