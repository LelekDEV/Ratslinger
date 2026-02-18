@tool
extends Node2D

@onready var coins: Node2D = get_tree().get_first_node_in_group("coins")
@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var interaction_area: Area2D = $InteractionArea

enum ID {KIDDO, MAYOR}
@export var id: ID
@export_tool_button("Update properties") var update_action = update

@export var reward_coins_curve: Curve

func _ready() -> void:
	update() 
	
	if Engine.is_editor_hint():
		return
	
	if id == ID.MAYOR:
		Dialogic.signal_event.connect(mission_reward)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if interaction_area.interacting and Input.is_action_just_pressed("interact") and not Global.block_movement:
		match id:
			ID.KIDDO: Dialogic.start("kiddo")
			ID.MAYOR: Dialogic.start("mayor")
		
		interaction_area.animation.play("exit")
		await Dialogic.timeline_ended
		interaction_area.animation.play("enter")

func update() -> void:
	var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
	var c_shape: CollisionShape2D = get_node("CollisionShape2D")
	var shape: CircleShape2D = c_shape.shape
	
	match id:
		ID.KIDDO:
			sprite.play("kiddo")
			shape.radius = Consts.NPC_SHAPE_RADIUS[0]
			c_shape.position = Consts.NPC_SHAPE_POS[0]
		
		ID.MAYOR:
			sprite.play("mayor")
			shape.radius = Consts.NPC_SHAPE_RADIUS[1]
			c_shape.position = Consts.NPC_SHAPE_POS[1]

func mission_reward(signal_name: String) -> void:
	if signal_name != "mission_reward":
		return
	
	for i in range(30):
		var coin: Coin = Coin.instantiate()
		
		coin.mode = Coin.Modes.ARC
		
		coin.circle_center = (player.global_position + global_position) / 2
		coin.circle_radius = (player.global_position - global_position).length() / 2
		coin.circle_rot = (player.global_position - global_position).angle()
		
		coin.mult_y = randf_range(-0.5, 0.5)
		
		coins.add_child(coin)
		
		await get_tree().create_timer(reward_coins_curve.sample((i + 1) / 30.0) * 0.5).timeout
