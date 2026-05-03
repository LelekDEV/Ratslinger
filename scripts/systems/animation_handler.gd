extends Node
class_name AnimationHandler

@onready var players: Array = get_children()

func play(anim_name: String, restart: bool = true, args = null) -> void:
	if args == null: args = []
	
	for player: AnimationPlayer in players:
		if player.has_animation(anim_name):
			args.push_front(anim_name)
			if restart and player.is_playing(): player.stop()
			player.callv("play", args)
			
			return
	
	push_warning("Animation not found: " + anim_name)
