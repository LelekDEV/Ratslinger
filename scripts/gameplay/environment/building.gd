@tool
extends StaticBody2D
class_name Building

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var player_cam: Camera2D = player.get_node("Camera2D")

@onready var shop_layer: ShopLayer = get_tree().get_first_node_in_group("shop_layer")
@onready var weather_layer: CanvasLayer = get_tree().get_first_node_in_group("weather_layer")

@onready var markers: Node2D = get_tree().get_first_node_in_group("markers")
@onready var ui: UI = get_tree().get_first_node_in_group("ui")

@onready var interaction_area: Area2D = $InteractionArea

@export_tool_button("Update properties") var update_action = update

enum ID {SHOP, TOWN_HALL, FORGE}
@export var id: ID

func _ready() -> void:
	update()
	
	if Engine.is_editor_hint():
		return
	
	get_node("AnimatedSprite2D").call_deferred("get_all_points")

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if interaction_area.interacting and Input.is_action_just_pressed("interact"):
		match id:
			ID.SHOP:
				shop_layer.enter(ShopLayer.Shops.SHOP)
			
			ID.TOWN_HALL:
				teleport()
			
			ID.FORGE:
				shop_layer.enter(ShopLayer.Shops.FORGE)

func repair() -> void:
	var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
	var interaction_collision: CollisionShape2D = get_node("InteractionArea/CollisionShape2D")
	
	sprite.animation = &"regular"
	sprite.frame = id
	interaction_collision.set_deferred("disabled", false)

func update() -> void:
	var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
	var interaction_collision: CollisionShape2D = get_node("InteractionArea/CollisionShape2D")
	
	match id:
		ID.SHOP:
			sprite.animation = &"ruined"
			interaction_collision.disabled = true
		
		ID.TOWN_HALL:
			sprite.animation = &"regular"
			interaction_collision.disabled = false
		
		ID.FORGE:
			sprite.animation = &"regular"
			interaction_collision.disabled = false
	
	sprite.frame = id

func teleport():
	player.location = Player.Locations.TOWN_HALL
	player.global_position = markers.points.rat_house_spawn_pos
	
	weather_layer.visible = false
	player.local_fx.visible = false
