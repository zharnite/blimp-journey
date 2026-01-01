extends Control

const OPTIONS_MENU_MINI: PackedScene = preload("res://src/ui/maaack/overlaid_menus/mini_options_overlaid_menu.tscn")

@export var next_scene: PackedScene
@export var subscenes: Dictionary

func _ready() -> void:
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%InfoButton.pressed.connect(_on_info_button_pressed)

	%VersionLabel.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	%UIDLabel.text = "Local Mode" # Replaces UID display

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	setup_save_slots_ui()


func setup_save_slots_ui() -> void:
	# Clear existing subscenes
	for child in %Subscenes.get_children():
		child.queue_free()
	
	# Create a simple vertical layout for slots
	var vbox = VBoxContainer.new()
	vbox.layout_mode = 1
	vbox.anchors_preset = Control.PRESET_CENTER
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.add_theme_constant_override("separation", 20)
	%Subscenes.add_child(vbox)
	
	var label = Label.new()
	label.text = "Select a Save Slot"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(label)
	
	# Create 3 buttons
	for i in range(1, 4):
		var btn = Button.new()
		btn.text = "Save Slot %d" % i
		btn.custom_minimum_size = Vector2(200, 60)
		btn.pressed.connect(_on_slot_selected.bind(i))
		vbox.add_child(btn)

func _on_slot_selected(slot_index: int) -> void:
	message_user("Loading Slot %d..." % slot_index)
	SaverLoader.load_game(slot_index)
	switch_to_next_scene()


func message_user(message: String = "") -> void:
	%MessageLabel.text = message


func switch_to_next_scene() -> void:
	# Gives time for the loading message to appear
	await get_tree().create_timer(0.1).timeout
	
	Loading.load_scene("res://src/world/overworld_map/overworld_map.tscn", true)


func _on_settings_button_pressed() -> void:
	var options_scene = OPTIONS_MENU_MINI.instantiate()
	add_child(options_scene)


func _on_info_button_pressed() -> void:
	pass