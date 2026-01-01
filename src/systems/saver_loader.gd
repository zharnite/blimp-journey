extends Node

const DEFAULTS: Dictionary = {
	"metadata": {
		"version": 0,
	},
	"stats": {
		"playtime": 0,
		"times_opened": 0,
		"first_opened": -1,
		"last_opened": -1,
	},
	"player": {
		"first_name": "",
		"last_name": "",
		"username": "",
		"billing": {
			"membership_status": "",
			"stripe_customer_id": "",
		},
		"appearance": {},
		"tags": [],
	},
	"levels": {
		"current_level": "",
	},
}

## Hold data that doesn't need to be saved permanently.
var temp: Dictionary = {}

var current_slot: int = 1
var latest_data: Dictionary = {}

var _save_file_updaters: Array[Callable] = [
	# _v0_to_v1,
]


func _ready() -> void:
	add_to_group("persist")


func get_save_path(slot: int) -> String:
	return "user://save_slot_%d.json" % slot


func save_game() -> void:
	# Use latest_data if available, otherwise start with DEFAULTS copy
	var data_to_save = latest_data.duplicate(true)
	if data_to_save.is_empty():
		data_to_save = DEFAULTS.duplicate(true)
	
	# Update metadata
	set_nested(data_to_save, "metadata.version", DEFAULTS.metadata.version)
	
	# Get data from persistable entities
	for entity: Node in get_tree().get_nodes_in_group("persist"):
		if not entity.has_method("save_data"):
			continue
		
		# We pass the dictionary directly now
		entity.save_data(data_to_save)
	
	latest_data = data_to_save
	
	# Write to disk
	var file = FileAccess.open(get_save_path(current_slot), FileAccess.WRITE)
	if file:
		file.store_string(var_to_str(data_to_save))
		file.close()
		print("Save successful to slot %d." % current_slot)
		EventBus.save_completed.emit()
	else:
		printerr("Failed to open save file for writing.")


func load_game(slot: int = -1) -> void:
	if slot != -1:
		current_slot = slot

	var path = get_save_path(current_slot)
	if not FileAccess.file_exists(path):
		print("No save file found for slot %d. Creating new." % current_slot)
		latest_data = DEFAULTS.duplicate(true)
	else:
		var file = FileAccess.open(path, FileAccess.READ)
		var text = file.get_as_text()
		file.close()
		
		var data = str_to_var(text)
		if data is Dictionary:
			latest_data = data
			print("Loaded save from slot %d." % current_slot)
		else:
			printerr("Save file corrupted or invalid format.")
			latest_data = DEFAULTS.duplicate(true)

	# --- Version Upgrading Logic ---
	var current_version: int = -1
	if latest_data.has("metadata") and latest_data.metadata.has("version"):
		current_version = int(latest_data.metadata.version)
	
	for version in range(current_version, _save_file_updaters.size()):
		var result = _save_file_updaters[version].call(latest_data.duplicate(true))
		if result:
			latest_data = result
			print("Updated save from v%d to v%d" % [current_version, version + 1])

	# Load data into entities
	for entity: Node in get_tree().get_nodes_in_group("persist"):
		if not entity.has_method("load_data"):
			continue
		entity.load_data(latest_data)
	
	print("Load process complete.")


func reset_level(level_code: int) -> void:
	if latest_data.has("levels"):
		var key = "%02d" % level_code
		if latest_data.levels.has(key):
			latest_data.levels.erase(key)
		latest_data.levels.current_level = ""
		
		Inventory.clear()
		save_game()
		print("Level %02d reset." % level_code)


func reset_save_game() -> void:
	latest_data = DEFAULTS.duplicate(true)
	save_game()


func complete_event(event: String) -> void:
	if not EventBus.event_list_updated.is_connected(save_game):
		EventBus.event_list_updated.connect(save_game.unbind(1))

	EventBus.event_completed.emit(event)


# Allow SaverLoader itself to save/load (e.g. for version metadata)
func save_data(data: Dictionary) -> void:
	set_nested(data, "metadata.version", DEFAULTS.metadata.version)

func load_data(data: Dictionary) -> void:
	pass

#region Helpers
func set_nested(data: Dictionary, path: String, value: Variant) -> void:
	var keys = path.split(".")
	var current = data
	for i in range(keys.size() - 1):
		var key = keys[i]
		if not current.has(key) or not (current[key] is Dictionary):
			current[key] = {}
		current = current[key]
	current[keys[-1]] = value

func get_nested(data: Dictionary, path: String, default: Variant = null) -> Variant:
	var keys = path.split(".")
	var current = data
	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return default
	return current
#endregion

#region Save File Updaters
func _v0_to_v1(data: Dictionary) -> Dictionary:
	set_nested(data, "metadata.version", 1)
	return data
#endregion
