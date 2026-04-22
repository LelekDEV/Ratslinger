extends CanvasLayer

@onready var left_page = $Control/BookRoot/LeftPage
@onready var left_name_label = $Control/LeftLabel/NameLabel
@onready var left_desc_label = $Control/LeftLabel/DescLabel

@onready var right_page = $Control/BookRoot/RightPage
@onready var right_name_label: Label = $Control/RightLabel/NameLabel
@onready var right_desc_label: Label = $Control/RightLabel/DescLabel

const enemies: Array = [
	{ "name": "Fox", "description": "Regular ranged enemy.", "sprite": preload("res://graphics/characters/enemies/fox/fox_frame.png") },
	{ "name": "Beaver", "description": "Directional spreadshot.", "sprite": preload("res://graphics/characters/enemies/beaver/beaver_frame.png") },
	{ "name": "Snake", "description": "Multisegment enemy.", "sprite": preload("res://graphics/characters/enemies/snake/snake_frame.png") },
	{ "name": "Owl", "description": "Flying enemy, leaves a spinning gun.", "sprite": preload("res://graphics/characters/enemies/owl/owl_frame.png") }
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
	page_index = 0
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	Global.pause_game()
	on_entered()

func on_entered():
	if book_animation:
		book_animation.frame = 0
		book_animation.play("FirstPage")
		# print("Playing animation:", book_animation.animation)

func update_pages():
	var left_enemy = enemies[page_index]
	var right_enemy = enemies[page_index + 1] if page_index + 1 < enemies.size() else null
	
	var left_encountered = Global.enemy_stats.get(left_enemy.name, {}).get("encountered", false)
	var right_encountered = Global.enemy_stats.get(right_enemy.name, {}).get("encountered", false)
	var left_killed = Global.enemy_stats[left_enemy.name].kills if left_encountered else 0
	var right_killed = Global.enemy_stats[right_enemy.name].kills if right_encountered else 0
	
	left_page.texture = left_enemy.sprite if left_encountered else question_mark_sprite
	left_name_label.text = left_enemy.name if left_encountered else "Unknown"
	left_desc_label.text = left_enemy.description + " Killed: " + str(left_killed) if left_encountered else ""
	
	right_page.texture = right_enemy.sprite if right_encountered else question_mark_sprite
	right_name_label.text = right_enemy.name if right_encountered else "Unknown"
	right_desc_label.text = right_enemy.description + " Killed: " + str(right_killed) if right_encountered else ""
	
	show_pages()

func show_pages():
	var nodes: Array = [
		left_page, left_name_label, left_desc_label,
		right_page, right_name_label, right_desc_label
	]
	
	current_tween = create_tween()
	for node in nodes:
		current_tween.tween_property(node, "modulate:a", 1.0, 0.2)

func hide_pages(immediate: bool=false) -> Tween:
	var nodes: Array = [
		left_page, left_name_label, left_desc_label,
		right_page, right_name_label, right_desc_label
	]
	
	if immediate:
		for node in nodes:
			node.modulate.a = 0
		current_tween = null
		return null
	else:
		current_tween = create_tween()
		for node in nodes:
			current_tween.tween_property(node, "modulate:a", 0, 0.2)
		return current_tween

func flip_page_data(amount):
	if is_animating():
		return
	is_busy = true

	var new_index = page_index + amount
	if new_index < 0 or new_index >= enemies.size():
		# print("Cannot flip, no more pages in that direction")
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
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	Global.resume_game()

	is_busy = false

func _on_book_animation_finished() -> void:
	update_pages()
	is_busy = false

func is_animating() -> bool:
	return is_busy or (current_tween != null and current_tween.is_running()) or (book_animation and book_animation.is_playing())
