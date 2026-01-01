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
	# Clear existing subscenes/buttons
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
	
	# Create 3 slots
	for i in range(1, 4):
		var slot_container = HBoxContainer.new()
		slot_container.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_child(slot_container)
		
		# Metadata
		var meta = SaverLoader.get_slot_metadata(i)
		var is_empty = meta.get("empty", true)
		var date_str = meta.get("date_string", "Unknown Date")
		
		# Main Slot Button
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(300, 60)
		
		if is_empty:
			btn.text = "Slot %d: New Game" % i
		else:
			btn.text = "Slot %d: %s" % [i, date_str]
			
		btn.pressed.connect(_on_slot_selected.bind(i))
		slot_container.add_child(btn)
		
		# Delete Button (Only if not empty)
		if not is_empty:
			var delete_btn = Button.new()
			delete_btn.text = "Delete" # Could use an icon here if available
			delete_btn.modulate = Color.INDIAN_RED
			delete_btn.custom_minimum_size = Vector2(80, 60)
			delete_btn.pressed.connect(_on_delete_pressed.bind(i))
			slot_container.add_child(delete_btn)


func _on_slot_selected(slot_index: int) -> void:
	message_user("Loading Slot %d..." % slot_index)
	SaverLoader.load_game(slot_index)
	switch_to_next_scene()


func _on_delete_pressed(slot_index: int) -> void:
	SaverLoader.delete_save(slot_index)
	setup_save_slots_ui() # Refresh the UI
	message_user("Slot %d deleted." % slot_index)


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
