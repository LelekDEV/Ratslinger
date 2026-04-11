extends CanvasLayer

@onready var left_page = get_tree().get_first_node_in_group("left_page")
@onready var right_page = get_tree().get_first_node_in_group("right_page")

@onready var left_name_label = $Control/LeftLabel/NameLabel
@onready var left_desc_label = $Control/LeftLabel/DescLabel

var enemies: Array = [
	{ "name": "Fox", "description": "A quick forest predator.", "sprite": preload("res://graphics/characters/enemies/fox/fox_frame.png") },
	{ "name": "Beaver", "description": "Blocks paths with wood.", "sprite": preload("res://graphics/characters/enemies/beaver/beaver_frame.png") },
	{ "name": "Snake", "description": "Slithers silently through grass.", "sprite": preload("res://graphics/characters/enemies/snake/snake_frame.png") },
	{ "name": "Owl", "description": "A nocturnal predator with sharp eyes.", "sprite": preload("res://graphics/characters/enemies/owl/owl_frame.png") }
]

@onready var question_mark_sprite = preload("res://graphics/bestiary/question_mark_frame.png")

@export var book_animation: AnimatedSprite2D
@export var teeny_font: Font

var page_index = 0
var is_busy: bool = false
var current_tween: Tween = null

func _ready():
	hide_pages(true)

	# left_name_label.add_theme_font_override("font", teeny_font)
	# left_desc_label.add_theme_font_override("font", teeny_font)

func enter() -> void:
	if is_animating():
		return
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	Global.pause_game()
	on_entered()

func on_entered():
	if book_animation:
		book_animation.frame = 0
		book_animation.play("FirstPage")
		print("Playing animation:", book_animation.animation)

func update_pages():
	var left_enemy = enemies[page_index]
	var right_enemy = enemies[page_index + 1] if page_index + 1 < enemies.size() else null
	
	var left_encountered = Global.enemy_stats.get(left_enemy.name, {}).get("encountered", false)
	var right_encountered
	
	if right_enemy != null:
		right_encountered = Global.enemy_stats.get(right_enemy.name, {}).get("encountered", false)
	else:
		right_encountered = false

	for node in get_tree().get_nodes_in_group("left_page"):
		if node is Sprite2D:
			if left_encountered == true:
				node.texture = left_enemy.sprite
			else:
				node.texture = question_mark_sprite

		elif node is Label:
			node.text = left_enemy.name if node.name.contains("Name") else left_enemy.description

	if right_enemy:
		for node in get_tree().get_nodes_in_group("right_page"):
			if node is Sprite2D:
				if right_encountered == true:
					node.texture = right_enemy.sprite
				else:
					node.texture = question_mark_sprite
					
			elif node is Label:
				node.text = right_enemy.name if node.name.contains("Name") else right_enemy.description
	else:
		for node in get_tree().get_nodes_in_group("right_page"):
			if node is Sprite2D:
				node.texture = null
			elif node is Label:
				node.text = ""

	show_pages()

func show_pages():
	current_tween = create_tween()
	for node in [left_page, right_page]:
		current_tween.tween_property(node, "modulate:a", 1.0, 0.4)

func hide_pages(immediate: bool=false) -> Tween:
	if immediate:
		for node in [left_page, right_page]:
			node.modulate.a = 0
		current_tween = null
		return null
	else:
		current_tween = create_tween()
		for node in [left_page, right_page]:
			current_tween.tween_property(node, "modulate:a", 0, 0.4)
		return current_tween

func flip_page_data(amount):
	if is_animating():
		return
	is_busy = true

	var new_index = page_index + amount
	if new_index < 0 or new_index >= enemies.size():
		print("Cannot flip, no more pages in that direction")
		is_busy = false
		return

	page_index = new_index

	var tween = hide_pages()
	if tween:
		await tween.finished

	book_animation.frame = 0
	if amount > 0:
		book_animation.play("LastPage")
	else:
		book_animation.play("TurnBack")

	await book_animation.animation_finished

	update_pages()
	is_busy = false

func _on_exit_button_pressed() -> void:
	if is_animating():
		return
	is_busy = true

	book_animation.stop()
	hide_pages(true)

	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	Global.resume_game(false)

	is_busy = false

func _on_book_animation_finished() -> void:
	update_pages()
	is_busy = false

func is_animating() -> bool:
	return is_busy or (current_tween != null and current_tween.is_running()) or (book_animation and book_animation.is_playing())
