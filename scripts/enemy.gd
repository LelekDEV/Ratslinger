extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")

var speed: float = 30


func _physics_process(_delta: float) -> void:
	var player_pos = player.global_position
	var direction =  (player_pos - global_position).normalized()
	
	if global_position.distance_squared_to(player_pos) > 80 ** 2:
		velocity = speed * direction	
		
		if velocity.length() > 0:
			sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")
		
	move_and_slide()
