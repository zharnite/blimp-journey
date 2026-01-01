class_name CommandCenterLevel
extends CommandCenter

@onready var _level: Level = get_parent()


func _register_console_commands() -> void:
	super()

	# Prevents re-registering commands when reloading the entire world (which causes errors)
	if LimboConsole.has_command("give"):
		return

	# give [item] [amount]
	LimboConsole.register_command(Inventory.add_item, "give", "Gives the player items")
	LimboConsole.add_argument_autocomplete_source("give", 1, func(): return Inventory.available_items.keys())
	LimboConsole.add_alias("add", "give")

	# take [item] [amount]
	LimboConsole.register_command(Inventory.remove_item, "take", "Takes away player items")
	LimboConsole.add_argument_autocomplete_source("take", 1, func(): return Inventory.available_items.keys())
	LimboConsole.add_alias("remove", "take")

	# state [character]
	LimboConsole.register_command(_enable_statechart_debugger_for, "state", "Inspect the state of the chosen entity. Use `statehide` to hide debugger")
	LimboConsole.add_argument_autocomplete_source("state", 1, func(): return _level.scene.find_children("*", "Character", true, false).map(func(character): return character.name))

	# statehide
	LimboConsole.register_command(_hide_statechart, "statehide", "Hide the statechart")

	# path [show|hide]
	LimboConsole.register_command(_set_pathbuilder_visibility, "path", "Show/Hide debug path")
	LimboConsole.add_argument_autocomplete_source("path", 1, func(): return ["show", "hide"])

	# scene [scene]
	LimboConsole.register_command(_level.change_scene, "scene", "Change to the specified scene")
	LimboConsole.add_argument_autocomplete_source("scene", 1, func(): return _level.scenes.keys())
	LimboConsole.add_alias("changescene", "scene")

	# event [event]
	LimboConsole.register_command(_event_completed, "event", "Complete the specified event")

	# tp [rel|abs] [x] [y]
	LimboConsole.register_command(_teleport_player, "tp", "Teleport the player to the specified location")
	LimboConsole.add_argument_autocomplete_source("tp", 1, func(): return ["rel", "abs"])

	# reset
	LimboConsole.register_command(_reset, "reset", "Reset the save file for the current level")


func _enable_statechart_debugger_for(character_name: String) -> void:
	var character: Character = _level.scene.find_children(character_name.to_pascal_case(), "Character").front()

	if not is_instance_valid(character):
		printerr("Character could not be found. Aborting...")
		return

	%StateChartDebugger.enabled = true
	%StateChartDebugger.debug_node(character)


func _hide_statechart() -> void:
	%StateChartDebugger.enabled = false


func _set_pathbuilder_visibility(visibility: String) -> void:
	var path_builder: PathBuilder = _level.scene.get_node_or_null("%PathBuilder")

	if not is_instance_valid(path_builder):
		printerr("PathBuilder could not be found.")
		return

	match visibility:
		"hide":
			path_builder.hide()
		_:
			path_builder.show()


func _event_completed(event: String) -> void:
	EventBus.event_completed.emit(event)


func _teleport_player(mode: String, x: int, y: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")

	if not is_instance_valid(player):
		printerr("Player could not be found. Aborting...")
		return

	match mode:
		"rel":
			player.global_position += Vector2(x, y)
		"abs":
			player.global_position = Vector2(x, y)
		_:
			printerr("Invalid teleport mode. Use `rel` or `abs`.")


func _reset() -> void:
	var level_code: int = _level.level_code

	SaverLoader.reset_level(level_code)

	get_tree().reload_current_scene()


func _on_tree_exiting() -> void:
	LimboConsole.unregister_command("give")
	LimboConsole.unregister_command("take")
	LimboConsole.unregister_command("state")
	LimboConsole.unregister_command("statehide")
	LimboConsole.unregister_command("path")
	LimboConsole.unregister_command("scene")
	LimboConsole.unregister_command("event")
	LimboConsole.unregister_command("tp")
	LimboConsole.unregister_command("reset")

	LimboConsole.remove_alias("add")
	LimboConsole.remove_alias("remove")
	LimboConsole.remove_alias("changescene")
