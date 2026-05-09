extends Node2D
class_name Option

# Fuck you, for flooding me with editor errors for using NodePaths in a valid way.
# These are so worthless, it literally goes against the use described in docs
@export var setting_path_str: String
@export var setting_path_extra_str: String
var setting_path: NodePath
var setting_path_extra: NodePath
@export var use_engine_singleton: bool = false

enum Type {VALUE, SELECT}
@export var type: Type

@export var value_suffix: String = "%"
@export var select_options: Array[String]

func _ready() -> void:
	setting_path = setting_path_str
	setting_path_extra = setting_path_extra_str
