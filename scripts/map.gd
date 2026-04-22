extends CanvasLayer

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var map_sprite: Sprite2D = get_tree().get_first_node_in_group("map_sprite")
@onready var player_marker: Sprite2D = get_tree().get_first_node_in_group("player_map_sprite")

var map_size: Vector2 = Vector2.ZERO
var map_visibility: bool = false

var world_min: Vector2 = Vector2(-432, 0)
var world_max: Vector2 = Vector2(648, 468)

func _ready():
	map_size = map_sprite.texture.get_size() * map_sprite.scale

func _input(event):
	if event.is_action_pressed("Map"):
		map_visibility = !map_visibility
		visible = map_visibility

func _physics_process(delta):
	if player == null or map_sprite == null:
		return

	var map_pos = world_to_map(player.global_position)
	player_marker.position = map_pos

func world_to_map(world_pos: Vector2) -> Vector2:
	var world_size = world_max - world_min
	var normalized = (world_pos - world_min) / world_size
	return normalized * map_size
