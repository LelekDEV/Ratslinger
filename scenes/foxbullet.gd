extends Node2D

class_name FoxBullet
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var bullet_acceleration: Timer = $Bullet_Acceleration

var direction: Vector2 = Vector2.ZERO
var speed: float = 100

func _ready():
	sprite.play("shoot")
	bullet_acceleration.start()                      

func _on_bullet_acceleration_timeout() -> void:
	on_accel()

func _physics_process(delta):
	global_position += direction * speed * delta

func on_accel():
	speed += 30

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("i got hit by a car")


func _on_area_entered(area: Area2D) -> void:
	print("both bullets should break")
	queue_free()
