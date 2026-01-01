class_name Scene
extends Node

## Should match the scene name in the scenes folder
## and the key in the scenes dictionary in the level.
@export var scene_name: String


func _ready() -> void:
	var _level: Level = get_tree().get_first_node_in_group("level")
