extends CanvasLayer

const MENU_FONT: Font = preload("res://ui/fonts/Silkscreen-Bold.ttf")
const OPTIONS_PANEL = preload("res://ui/options_panel.gd")

var status_label: Label
var quit_confirmation: ConfirmationDialog
var options_panel: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.72)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -320.0
	panel.offset_top = -320.0
	panel.offset_right = 320.0
	panel.offset_bottom = 320.0
	backdrop.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", MENU_FONT)
	title.add_theme_font_size_override("font_size", 38)
	layout.add_child(title)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size.y = 54.0
	layout.add_child(status_label)

	_add_button(layout, "RESUME", _resume)
	_add_button(layout, "OPTIONS", _open_options)
	_add_button(layout, "SAVE & MAIN MENU", _save_and_return)
	_add_button(layout, "QUIT WITHOUT SAVING", _confirm_quit)

	quit_confirmation = ConfirmationDialog.new()
	quit_confirmation.title = "Quit without saving?"
	quit_confirmation.dialog_text = "Any progress since the last save will be lost. Are you sure you want to quit?"
	quit_confirmation.ok_button_text = "Quit Without Saving"
	quit_confirmation.confirmed.connect(_quit_without_saving)
	add_child(quit_confirmation)

func _add_button(layout: VBoxContainer, label: String, action: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(440.0, 58.0)
	button.add_theme_font_override("font", MENU_FONT)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(action)
	layout.add_child(button)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not quit_confirmation.visible and options_panel == null:
		_resume()
		get_viewport().set_input_as_handled()

func _open_options() -> void:
	if options_panel:
		return
	options_panel = preload("res://ui/options.tscn").instantiate()
	options_panel.closed.connect(_on_options_closed)
	add_child(options_panel)

func _on_options_closed() -> void:
	options_panel = null

func _resume() -> void:
	get_tree().paused = false
	queue_free()

func _save_and_return() -> void:
	if not Global.save_game():
		status_label.text = Global.last_save_error
		return

	get_tree().paused = false
	var error := get_tree().change_scene_to_file("res://mainmenu.tscn")
	if error != OK:
		status_label.text = "Could not open the main menu (error %d)." % error
		push_error(status_label.text)

func _confirm_quit() -> void:
	quit_confirmation.popup_centered()

func _quit_without_saving() -> void:
	get_tree().paused = false
	get_tree().quit()
