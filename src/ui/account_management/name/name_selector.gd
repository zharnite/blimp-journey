extends Control

const USERNAME_LENGTH_MIN: int = 2
const USERNAME_LENGTH_MAX: int = 32
const NEXT_SCENE: String = "res://src/world/levels/04_volcano/level.tscn"

var first_name: WordList = preload("res://src/ui/account_management/name/names_first.tres")
var last_name: WordList = preload("res://src/ui/account_management/name/names_last.tres")


func _ready() -> void:
	add_to_group("persist")

	first_name.word_changed.connect(_on_first_name_word_changed)
	last_name.word_changed.connect(_on_last_name_word_changed)

	%FirstPreviousButton.pressed.connect(first_name.previous)
	%FirstNextButton.pressed.connect(first_name.next)
	%LastPreviousButton.pressed.connect(last_name.previous)
	%LastNextButton.pressed.connect(last_name.next)

	%UsernameLineEdit.text_changed.connect(_on_username_line_edit_text_changed.unbind(1))
	%UsernameLineEdit.text_submitted.connect(_on_continue_button_pressed.unbind(1))

	%ContinueButton.pressed.connect(_on_continue_button_pressed)

	%FirstNameLabel.text = first_name.any()
	%LastNameLabel.text = last_name.any()

	SaverLoader.load_game()


func show_error_to_user(problem: String) -> void:
	%ErrorLabel.text = problem


func save_data(data: Dictionary) -> void:
	SaverLoader.set_nested(data, "player.first_name", first_name.get_word())
	SaverLoader.set_nested(data, "player.last_name", last_name.get_word())
	SaverLoader.set_nested(data, "player.username", %UsernameLineEdit.text)


func load_data(data: Dictionary) -> void:
	# The field is empty by default, don't load it if it is (new player)
	var fname = SaverLoader.get_nested(data, "player.first_name", "")
	var lname = SaverLoader.get_nested(data, "player.last_name", "")
	
	if fname.is_empty() or lname.is_empty():
		return

	first_name.set_word(fname)
	last_name.set_word(lname)
	%UsernameLineEdit.text = SaverLoader.get_nested(data, "player.username", %UsernameLineEdit.text)


func _on_continue_button_pressed() -> void:
	if %UsernameLineEdit.text.is_empty():
		show_error_to_user("You don't have a username!")
		return
	elif %UsernameLineEdit.text.length() < USERNAME_LENGTH_MIN:
		show_error_to_user("Your username is too short!")
		return
	elif %UsernameLineEdit.text.length() > USERNAME_LENGTH_MAX:
		show_error_to_user("Your username is too long!")
		return

	SaverLoader.save_game()

	#SceneLoader.load_scene(NEXT_SCENE)
	get_tree().change_scene_to_file(NEXT_SCENE)


func _on_first_name_word_changed() -> void:
	%FirstNameLabel.text = first_name.get_word()


func _on_last_name_word_changed() -> void:
	%LastNameLabel.text = last_name.get_word()


func _on_username_line_edit_text_changed() -> void:
	%ErrorLabel.text = ""