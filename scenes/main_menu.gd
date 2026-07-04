extends CanvasLayer

signal new_game_pressed
signal continue_pressed
signal settings_pressed

var btn_continue: Button

func _ready():
	setup_ui()
	check_saved_game()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	# Dark decorative backing
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.08, 0.1, 1.0)
	root.add_child(bg)
	
	# Menu container (Centered layout)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)
	
	# Title group
	var title_vbox = VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(title_vbox)
	
	var title = Label.new()
	title.text = "ASTERRA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color("#ffeb3b") # Golden yellow glow
	title_vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "The Legend of World's Strongest Mercenary"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.modulate = Color("#b0bec5")
	title_vbox.add_child(subtitle)
	
	# Divider line
	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(300, 2)
	line.color = Color("#8d6e63")
	line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(line)
	
	# Button list
	var btns_vbox = VBoxContainer.new()
	btns_vbox.add_theme_constant_override("separation", 10)
	btns_vbox.custom_minimum_size = Vector2(200, 0)
	btns_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(btns_vbox)
	
	var btn_new = Button.new()
	btn_new.text = "New Game"
	btn_new.pressed.connect(func():
		GameState.play_sfx("select")
		emit_signal("new_game_pressed")
	)
	btns_vbox.add_child(btn_new)
	
	btn_continue = Button.new()
	btn_continue.text = "Continue"
	btn_continue.pressed.connect(func():
		GameState.play_sfx("select")
		emit_signal("continue_pressed")
	)
	btns_vbox.add_child(btn_continue)
	
	var btn_settings = Button.new()
	btn_settings.text = "Settings"
	btn_settings.pressed.connect(func():
		GameState.play_sfx("select")
		emit_signal("settings_pressed")
	)
	btns_vbox.add_child(btn_settings)
	
	var btn_exit = Button.new()
	btn_exit.text = "Exit Game"
	btn_exit.pressed.connect(func():
		GameState.play_sfx("select")
		# Exit
		get_tree().quit()
	)
	btns_vbox.add_child(btn_exit)
	
	# Footer info
	var footer = Label.new()
	footer.text = "\nPress WASD/Arrows to walk, Space/E to interact in game"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 9)
	footer.modulate = Color("#78909c")
	vbox.add_child(footer)

func check_saved_game():
	if GameState.check_saved_game():
		btn_continue.disabled = false
	else:
		btn_continue.disabled = true

func show_menu():
	check_saved_game()
	visible = true

func hide_menu():
	visible = false
