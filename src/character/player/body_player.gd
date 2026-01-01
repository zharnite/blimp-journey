@tool
extends Body

const BASE_PATH: String = "player.appearance."
const BASE_STYLE: Style = preload("res://src/character/styles/base/base.tres")


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	add_to_group("persist")

	if SaverLoader.temp.has("style"):
		set_style(SaverLoader.temp.style)
	else:
		set_style(owner.style)


func set_style(style: Style) -> void:
	super(style)

	if Engine.is_editor_hint():
		return
	
	SaverLoader.temp.style = style


func save_data(data: Dictionary) -> void:
	for part_key: String in _style.get_all_style_attributes().keys():
		var part_value: Variant = _style.get_all_style_attributes().get(part_key)

		if part_value is StylePart:
			SaverLoader.set_nested(data, BASE_PATH + part_key, part_value.style_name)
		elif part_value is Color:
			SaverLoader.set_nested(data, BASE_PATH + part_key, part_value)
		elif part_value == null:
			SaverLoader.set_nested(data, BASE_PATH + part_key, null)
		else:
			printerr("[BodyPlayer] Unknown type for part: ", part_key, " with value: ", part_value)
			continue


func load_data(data: Dictionary) -> void:
	# Check if the appearance object exists
	var appearance = SaverLoader.get_nested(data, BASE_PATH.trim_suffix("."), {})
	if appearance.is_empty():
		printerr("[BodyPlayer] No style found in document. Aborting load...")
		return
	
	var style: Style = Style.new()

	for part_key: String in _style.get_all_style_attributes().keys():
		var part_value: Variant = SaverLoader.get_nested(data, BASE_PATH + part_key)

		if part_value is String:
			var style_part: StylePart = CharacterParts.get_style_part_from_style_name(part_value)
			style.set(part_key, style_part)
		elif part_value is Color:
			style.set(part_key, part_value)
		elif part_value == null:
			style.set(part_key, null)
		else:
			# It might be missing in the save file, which is fine, we just skip it
			# printerr("[BodyPlayer] Unknown type for part: ", part_key, " with value: ", part_value)
			continue

	set_style(style)
