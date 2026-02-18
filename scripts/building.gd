@tool
extends StaticBody2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var player_cam: Camera2D = player.get_node("Camera2D")

@onready var shop_layer: CanvasLayer = get_tree().get_first_node_in_group("shop_layer")
@onready var interaction_area: Area2D = $InteractionArea

@onready var markers: Node2D = get_tree().get_first_node_in_group("markers")

@export_tool_button("Update properties") var update_action = update

@onready var ui: UI = get_tree().get_first_node_in_group("ui")

@export var texture: Texture2D

enum ID {SHOP, TOWN_HALL}
@export var id: ID

func _ready() -> void:
	update()
	
	if Engine.is_editor_hint():
		return

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if interaction_area.interacting and Input.is_action_just_pressed("interact"):
		match id:
			ID.SHOP:
				shop_layer.enter()
			
			ID.TOWN_HALL:
				teleport()

func update() -> void:
	var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
	
	match id:
		ID.SHOP:
			sprite.frame = 1
		ID.TOWN_HALL:
			sprite.frame = 0
	
func teleport():
	player.location = Player.Locations.TOWN_HALL
	player.global_position = markers.points.rat_house_spawn_pos
	
