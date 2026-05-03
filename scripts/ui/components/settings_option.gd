extends Node2D
class_name Option

@export var setting_path: NodePath
@export var setting_path_extra: NodePath
@export var use_engine_singleton: bool = false

enum Type {VALUE, SELECT}
@export var type: Type

@export var value_suffix: String = "%"
@export var select_options: Array[String]
