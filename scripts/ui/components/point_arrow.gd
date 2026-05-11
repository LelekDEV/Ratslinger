extends Sprite2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")

@export var wave_start_area: Area2D
@export var target_pos: Vector2 = Vector2.ZERO

enum Type {TUTORIAL, BOSS_RETURN}
@export var type: Type

var anim: float = 0

func _physics_process(delta: float) -> void:
	if type == Type.TUTORIAL and Global.is_tutorial_passed or \
		type == Type.BOSS_RETURN and Global.is_boss_warned:
		queue_free()
	
	anim = fmod(anim + delta * 6, TAU)
	offset.x = -20 + sin(anim) * 3
	
	if type == Type.TUTORIAL:
		visible = not wave_start_area.interacting and not Global.game.is_wave_active and not player.location == Player.Locations.TOWN_HALL
	elif type == Type.BOSS_RETURN:
		visible = Global.is_boss_wave()
	
	var c_size = get_viewport().get_visible_rect().size / camera.zoom
	var c_rect = Rect2(camera.get_screen_center_position() - c_size / 2, c_size)
	
	if c_rect.has_point(target_pos):
		global_position = get_viewport().get_canvas_transform() * target_pos
		global_rotation = PI / 2
	
	else:
		var angle: float = (target_pos - player.global_position).angle()
		var vector := Vector2.RIGHT.rotated(angle)
		var size = get_viewport().get_visible_rect().size
		
		global_position = size / 2 \
			+ vector / max(abs(vector.x), abs(vector.y)) \
			* size / 2
		global_rotation = angle
