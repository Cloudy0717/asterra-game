extends CanvasLayer

signal restart_pressed
signal menu_pressed

func _ready():
	setup_ui()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.85)
	root.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	var title = Label.new()
	title.text = "💀  GAME OVER  💀"
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = Color("#ef5350")
	vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "You have been defeated..."
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color("#b0bec5")
	vbox.add_child(subtitle)

	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(200, 2)
	line.color = Color("#8d6e63")
	vbox.add_child(line)

	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 10)
	btn_vbox.custom_minimum_size = Vector2(200, 0)
	btn_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(btn_vbox)

	var theme_res = load("res://theme/asterra_theme.tres")

	var btn_restart = Button.new()
	btn_restart.text = "Try Again"
	btn_restart.theme = theme_res
	btn_restart.pressed.connect(func():
		emit_signal("restart_pressed")
		visible = false
	)
	btn_vbox.add_child(btn_restart)

	var btn_menu = Button.new()
	btn_menu.text = "Main Menu"
	btn_menu.theme = theme_res
	btn_menu.pressed.connect(func():
		emit_signal("menu_pressed")
		visible = false
	)
	btn_vbox.add_child(btn_menu)

func show_screen():
	visible = true

func hide_screen():
	visible = false
