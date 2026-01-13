extends Area2D
class_name Coin

static func instantiate() -> Coin:
	return preload("res://scenes/coin.tscn").instantiate() as Coin

var target_player: Player

var lerp_tween: Tween
var lerp_value: float = 0.01

var velocity: Vector2

func _physics_process(_delta: float) -> void:
	if target_player:
		global_position = lerp(global_position, target_player.global_position, lerp_value)
		
		if round(global_position) == round(target_player.global_position):
			GlobalAudio.play_sfx(GlobalAudio.SFX.COLLECT, -2, randf_range(0.9, 1.1))
			Global.coins += 1
			SignalBus.player_coin_collect.emit()
			
			queue_free()
	else:
		global_position += velocity
		velocity = lerp(velocity, Vector2.ZERO, 0.05)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body
		
		lerp_tween = create_tween()
		lerp_tween.tween_property(self, "lerp_value", 1, 1)
