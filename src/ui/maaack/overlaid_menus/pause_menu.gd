extends Control

const OPTIONS_MENU_MINI: PackedScene = preload("res://src/ui/maaack/overlaid_menus/mini_options_overlaid_menu.tscn")

var authenticate_scene: PackedScene


func _ready() -> void:
	%ResumeButton.pressed.connect(_on_resume_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%ExitButton.pressed.connect(_on_exit_button_pressed)
	
	var container = %ResumeButton.get_parent()
	var current_index = %ResumeButton.get_index()
	
	# Create Save Button dynamically
	var save_btn = %ResumeButton.duplicate()
	save_btn.text = "Save Game"
	save_btn.pressed.connect(_on_save_button_pressed)
	container.add_child(save_btn)
	container.move_child(save_btn, current_index + 1)
	
	# Create Map Button dynamically
	var map_btn = %ResumeButton.duplicate()
	map_btn.text = "Go to Map"
	map_btn.pressed.connect(_on_map_button_pressed)
	container.add_child(map_btn)
	container.move_child(map_btn, current_index + 2)
	
	# For some reason, I can't preload this scene
	# My guess is that there's a cyclical dependency
	authenticate_scene = load("res://src/ui/account_management/authentication/authenticate.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		_on_resume_button_pressed()
		get_viewport().set_input_as_handled()


func _on_resume_button_pressed() -> void:
	visible = false
	EventBus.about_to_resume.emit("pause_menu")
	get_tree().paused = false


func _on_settings_button_pressed() -> void:
	var options_scene = OPTIONS_MENU_MINI.instantiate()
	add_child(options_scene)


func _on_save_button_pressed() -> void:
	SaverLoader.save_game()
	# Simple feedback
	# We need to find the button again since we didn't store it in a persistent variable
	var container = %ResumeButton.get_parent()
	# Save button is at resume_index + 1
	var btn = container.get_child(%ResumeButton.get_index() + 1)
	
	btn.text = "Saved!"
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(btn):
		btn.text = "Save Game"


func _on_map_button_pressed() -> void:
	get_tree().paused = false
	Dialogic.end_timeline()
	Loading.load_scene("res://src/world/overworld_map/overworld_map.tscn", true)


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	Dialogic.end_timeline()
	get_tree().change_scene_to_packed(authenticate_scene)
