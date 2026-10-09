extends Control

signal closed

const MENU_FONT: Font = preload("res://ui/fonts/Silkscreen-Bold.ttf")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 200
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.78)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -360.0
	panel.offset_top = -250.0
	panel.offset_right = 360.0
	panel.offset_bottom = 250.0
	backdrop.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "OPTIONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", MENU_FONT)
	title.add_theme_font_size_override("font_size", 38)
	layout.add_child(title)

	var volume_label := _add_setting_label(layout)
	var volume_slider := HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = Global.master_volume
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(volume_slider)
	volume_label.text = "Volume: %d%%" % roundi(volume_slider.value * 100.0)
	volume_slider.value_changed.connect(_on_volume_changed.bind(volume_label))

	var speed_label := _add_setting_label(layout)
	var speed_slider := HSlider.new()
	speed_slider.min_value = Global.MIN_DIALOGUE_TEXT_SPEED
	speed_slider.max_value = Global.MAX_DIALOGUE_TEXT_SPEED
	speed_slider.step = 1.0
	speed_slider.value = Global.dialogue_text_speed
	speed_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(speed_slider)
	speed_label.text = "Text Speed: %d" % roundi(speed_slider.value)
	speed_slider.value_changed.connect(_on_text_speed_changed.bind(speed_label))

	var speed_hint := Label.new()
	speed_hint.text = "Characters per second"
	speed_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(speed_hint)

	var back_button := Button.new()
	back_button.text = "BACK"
	back_button.custom_minimum_size = Vector2(300.0, 58.0)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.add_theme_font_override("font", MENU_FONT)
	back_button.add_theme_font_size_override("font_size", 24)
	back_button.pressed.connect(_close)
	layout.add_child(back_button)

func _add_setting_label(layout: VBoxContainer) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", MENU_FONT)
	label.add_theme_font_size_override("font_size", 22)
	layout.add_child(label)
	return label

func _on_volume_changed(value: float, label: Label) -> void:
	Global.set_master_volume(value)
	label.text = "Volume: %d%%" % roundi(value * 100.0)

func _on_text_speed_changed(value: float, label: Label) -> void:
	Global.set_dialogue_text_speed(value)
	label.text = "Text Speed: %d" % roundi(value)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	closed.emit()
	queue_free()
