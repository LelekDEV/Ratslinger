extends CanvasLayer

@onready var hearts: HBoxContainer = $Hearts
@onready var location_popup: Sprite2D = $LocationPopup
@onready var margin_container: MarginContainer = $MarginContainer
@onready var enemies_label: Label = $MarginContainer/EnemiesLabel
@onready var accuracy_bar: AccuracyBar = $AccuracyBar

@onready var animation1: AnimationPlayer = $AnimationPlayer1
@onready var animation2: AnimationPlayer = $AnimationPlayer2

var scale_factor: float = 1

var popup_tween: Tween
var popup_value: float = 0

func _ready() -> void:
	hearts.scale = Vector2i.ONE * 4 * scale_factor
	hearts.global_position = Vector2i.ZERO
	
	location_popup.scale = Vector2i.ONE * 4
	
	accuracy_bar.scale = Vector2i.ONE * 4
	
	show_location_popup()

func _physics_process(_delta: float) -> void:
	location_popup.global_position = get_viewport().get_visible_rect().size / 2 + Vector2(0, popup_value * -100 - 80)
	location_popup.self_modulate.a = sin(popup_value * PI)
	
	accuracy_bar.global_position.x = get_viewport().get_visible_rect().size.x - 85

func update_enemy_count(enemies_killed: int) -> void:
	enemies_label.text = "Enemies killed: " + str(enemies_killed) + "/5"

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

func on_player_location_change(_location: Player.Locations) -> void:
	show_location_popup()
