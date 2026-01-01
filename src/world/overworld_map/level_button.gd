class_name LevelButton
extends Area2D

## Maximum outline width for hover effect
const OUTLINE_WIDTH_MAX: float = 5
## Minimum outline width for hover effect
const OUTLINE_WIDTH_MIN: float = 3

static var is_processing_level: bool

## Path to the scene file that will be loaded
@export_file("*.tscn") var level_path: String
## Unique identifier for the level
@export var level_code: String
## Region ID. Setting to -1 means it's already active
@export var region: int = -1

func _ready() -> void:
	EventBus.clouds_cleared.connect(_on_clouds_cleared)
	
	# Make material unique so outlines don't share state
	if $Sprite2D.material:
		$Sprite2D.material = $Sprite2D.material.duplicate()
	
	# Hide and disable interaction if the level is not yet active
	if region != -1:
		input_pickable = false
		hide()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not Maid.is_left_click(event) or is_processing_level:
		return
	
	is_processing_level = true
	
	load_level()

	is_processing_level = false


# Loads the level scene directly
func load_level() -> void:
	print("[LevelButton] Loading level...")
	get_tree().change_scene_to_file(level_path)


func _mouse_enter() -> void:
	if $Sprite2D.material:
		$Sprite2D.material.set_shader_parameter("minLineWidth", OUTLINE_WIDTH_MIN)
		$Sprite2D.material.set_shader_parameter("maxLineWidth", OUTLINE_WIDTH_MAX)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _mouse_exit() -> void:
	if $Sprite2D.material:
		$Sprite2D.material.set_shader_parameter("minLineWidth", 0)
		$Sprite2D.material.set_shader_parameter("maxLineWidth", 0)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


## Becomes active when the clouds disappear for this region
func _on_clouds_cleared(p_region: int) -> void:
	if p_region == region:
		input_pickable = true
		show()
		region = -1
