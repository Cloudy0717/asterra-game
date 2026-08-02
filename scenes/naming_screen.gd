extends CanvasLayer

signal name_confirmed

var line_edit: LineEdit

func _ready():
	setup_ui()
	hide_screen()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	# Translucent background catcher
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.4)
	root.add_child(bg)
	
	# Modal Box
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 160)
	panel.position = Vector2(250, 220)
	root.add_child(panel)

	var theme_res = load("res://theme/asterra_theme.tres")
	panel.theme = theme_res
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "Create Mercenary Profile"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)
	
	var label = Label.new()
	label.text = "Choose Your Name:"
	label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(label)
	
	line_edit = LineEdit.new()
	line_edit.placeholder_text = "e.g., Alex"
	line_edit.max_length = 12
	vbox.add_child(line_edit)
	
	var btn = Button.new()
	btn.text = "Enter Asterra"
	btn.pressed.connect(on_confirm)
	vbox.add_child(btn)

func on_confirm():
	var name_text = line_edit.text.strip_edges()
	if name_text != "":
		GameState.get_player().name = name_text
	GameState.play_sfx("select")
	hide_screen()
	emit_signal("name_confirmed")

func show_screen():
	visible = true
	line_edit.text = ""
	line_edit.grab_focus()

func hide_screen():
	visible = false
