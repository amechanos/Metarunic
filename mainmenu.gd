extends Control

const OPTIONS_PANEL = preload("res://ui/options_panel.gd")

@onready var continue_button: Button = $Button
@onready var status_label: Label = $Status

var new_game_confirmation: ConfirmationDialog
var options_panel: Control

func _ready() -> void:
	Global.stop_music()
	continue_button.disabled = not Global.has_save_game()
	if continue_button.disabled:
		status_label.text = "No saved game found."
	continue_button.pressed.connect(_on_continue_pressed)
	$Button2.pressed.connect(_on_new_game_pressed)
	$Button3.pressed.connect(_on_quit_pressed)
	$Options.pressed.connect(_open_options)

	new_game_confirmation = ConfirmationDialog.new()
	new_game_confirmation.title = "Start a new game?"
	new_game_confirmation.dialog_text = "Starting a new game will overwrite your current saved game. Continue?"
	new_game_confirmation.ok_button_text = "Start New Game"
	new_game_confirmation.confirmed.connect(_start_new_game)
	add_child(new_game_confirmation)

func _on_continue_pressed() -> void:
	if not Global.load_game():
		status_label.text = Global.last_save_error
		return
	_change_to_game()

func _on_new_game_pressed() -> void:
	if Global.has_save_game():
		new_game_confirmation.popup_centered()
		return
	_start_new_game()

func _start_new_game() -> void:
	Global.start_new_game()
	_change_to_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _open_options() -> void:
	if options_panel:
		return
	options_panel = OPTIONS_PANEL.new()
	options_panel.closed.connect(_on_options_closed)
	add_child(options_panel)

func _on_options_closed() -> void:
	options_panel = null

func _change_to_game() -> void:
	var destination: String = Global.ENDING_SCENE if Global.ending_reached != "" else "res://game.tscn"
	var error := get_tree().change_scene_to_file(destination)
	if error != OK:
		status_label.text = "Could not open the game (error %d)." % error
		push_error(status_label.text)
