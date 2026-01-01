extends Node

signal updated(item: String, amount: int)

@export var slots: Dictionary = {}

## String (item) : Item
var available_items: Dictionary = {}


func _ready() -> void:
	add_to_group("persist")


func add_item(item: String, amount: int = 1) -> void:
	if is_item_invalid(item):
		return
	
	if item in slots:
		slots[item] += amount
	else:
		slots[item] = amount
	print(item, ": ", slots[item])
	updated.emit(item, slots[item])

	SaverLoader.save_game()


func remove_item(item: String, amount: int = 1) -> void:
	if is_item_invalid(item):
		return
	
	if item in slots and slots[item] >= amount:
		slots[item] -= amount
		
		if slots[item] <= 0:
			slots.erase(item)
			updated.emit(item, 0)
			SaverLoader.save_game()
			return

		updated.emit(item, slots[item])
		SaverLoader.save_game()
		return


func get_amount(item: String) -> int:
	if is_item_invalid(item):
		return 0
	
	if not item in slots:
		return 0
	
	return slots[item]


func has_item(item: String) -> bool:
	if is_item_invalid(item):
		return false

	return item in slots


func has_all_items(items: Array[String]) -> bool:
	for item: String in items:
		if is_item_invalid(item) or not has_item(item):
			return false
	
	return true


func is_item_invalid(item: String) -> bool:
	if not item in available_items.keys():
		push_error(item, " -> You either misspelled the item or didn't put it in the available_items list.")
		return true
	
	return false


## Clear the inventory.
func clear() -> void:
	slots.clear()


func load_level_items(level_code: int) -> void:
	var item_resource_group: ResourceGroup = load("res://src/systems/item/item_group.tres")
	var all_items: Array[Item] = []
	item_resource_group.load_matching_into(all_items, ["**%02d_**" % level_code], [])
	for card: Item in all_items:
		available_items[card.name] = card


func save_data(data: Dictionary) -> void:
	var current_level: String = SaverLoader.get_nested(data, "levels.current_level", "")

	if current_level.is_empty():
		# No level loaded yet, nothing to save for inventory
		return
	
	SaverLoader.set_nested(data, "levels.%s.inventory" % current_level, slots)


func load_data(data: Dictionary) -> void:
	var current_level: String = SaverLoader.get_nested(data, "levels.current_level", "")

	if current_level.is_empty():
		# No level loaded yet, nothing to load for inventory
		return
	
	slots = SaverLoader.get_nested(data, "levels.%s.inventory" % current_level, {})

	for item: String in slots.keys():
		updated.emit(item, slots[item])
