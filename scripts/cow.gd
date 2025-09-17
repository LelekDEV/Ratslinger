extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")

var is_playing = false

func _physics_process(_delta: float) -> void:
	if is_playing and sprite.animation == "kick":
		if sprite.frame == 4:
			player.kick_recoil(300)
			player.take_damage(2)
			print("Kick hit on frame 4")
			
			is_playing = false
	
func _on_kick_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.play("kick")
		is_playing = true
		
