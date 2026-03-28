extends ConfirmationDialog

@onready var framerate_label: Label = $VBoxContainer/FramerateContainer/ValueLabel
@onready var framerate_slider: HSlider = $VBoxContainer/FramerateContainer/HSlider

func _ready() -> void:
	await SignalBus.game_loaded
	framerate_slider.value = Engine.physics_ticks_per_second
	framerate_label.text = str(int(Engine.physics_ticks_per_second)) + "FPS"

func _on_framerate_slider_value_changed(value: float) -> void:
	framerate_label.text = str(int(value)) + "FPS"

func _on_about_to_popup() -> void:
	framerate_slider.value = Engine.physics_ticks_per_second
	framerate_label.text = str(int(Engine.physics_ticks_per_second)) + "FPS"
