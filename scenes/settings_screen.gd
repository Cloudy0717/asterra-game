extends CanvasLayer

signal settings_closed

var speed_option: OptionButton
var music_toggle: CheckButton
var sfx_slider: HSlider

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_ui()
	hide_screen()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	# Transparent background overlay
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.75)
	root.add_child(bg)
	
	# Modal card with Gold Rim Glassmorphic Style
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 260)
	panel.position = Vector2(220, 160)
	root.add_child(panel)

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.10, 0.14, 0.96)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color("#d4af37")
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.shadow_size = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	# Header
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var title = Label.new()
	title.text = "⚙️  GAME SETTINGS"
	title.add_theme_font_size_override("font_size", 15)
	title.modulate = Color("#ffd700")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.add_theme_font_size_override("font_size", 13)
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Item 1: Dialogue Speed
	var speed_hbox = HBoxContainer.new()
	vbox.add_child(speed_hbox)
	
	var speed_label = Label.new()
	speed_label.text = "Dialogue Speed"
	speed_label.add_theme_font_size_override("font_size", 11)
	speed_label.custom_minimum_size = Vector2(110, 0)
	speed_hbox.add_child(speed_label)
	
	speed_option = OptionButton.new()
	speed_option.add_item("Normal", 0)
	speed_option.add_item("Fast", 1)
	speed_option.add_item("Slow", 2)
	speed_option.add_item("Instant", 3)
	speed_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speed_hbox.add_child(speed_option)
	
	# Item 2: Music Toggle
	var music_hbox = HBoxContainer.new()
	vbox.add_child(music_hbox)
	
	var music_label = Label.new()
	music_label.text = "Ambient Sound"
	music_label.add_theme_font_size_override("font_size", 11)
	music_label.custom_minimum_size = Vector2(110, 0)
	music_hbox.add_child(music_label)
	
	music_toggle = CheckButton.new()
	music_hbox.add_child(music_toggle)
	
	# Item 3: SFX Volume
	var sfx_hbox = HBoxContainer.new()
	vbox.add_child(sfx_hbox)
	
	var sfx_label = Label.new()
	sfx_label.text = "SFX Volume"
	sfx_label.add_theme_font_size_override("font_size", 11)
	sfx_label.custom_minimum_size = Vector2(110, 0)
	sfx_hbox.add_child(sfx_label)
	
	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.value = 80
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_hbox.add_child(sfx_slider)
	
	# Apply Button
	var apply_btn = Button.new()
	apply_btn.text = "💾  Save & Apply Settings"
	apply_btn.custom_minimum_size = Vector2(0, 36)
	apply_btn.add_theme_font_size_override("font_size", 11)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.18, 0.16, 0.10, 0.95)
	btn_style.border_width_left = 1
	btn_style.border_width_right = 1
	btn_style.border_width_top = 1
	btn_style.border_width_bottom = 1
	btn_style.border_color = Color("#ffd700")
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	apply_btn.add_theme_stylebox_override("normal", btn_style)
	
	apply_btn.pressed.connect(on_apply)
	vbox.add_child(apply_btn)

func show_screen():
	# Sync values from GameState
	var speed = GameState.get_settings().text_speed
	if speed == 40: speed_option.select(0)
	elif speed == 15: speed_option.select(1)
	elif speed == 80: speed_option.select(2)
	elif speed == 0: speed_option.select(3)
	
	music_toggle.button_pressed = GameState.get_settings().music_on
	sfx_slider.value = GameState.get_settings().sfx_volume
	
	GameState.play_sfx("open_menu")
	visible = true

func on_apply():
	var speed = 40
	match speed_option.get_selected_id():
		0: speed = 40
		1: speed = 15
		2: speed = 80
		3: speed = 0
		
	var s = GameState.get_settings()
	s.text_speed = speed
	s.music_on = music_toggle.button_pressed
	s.sfx_volume = int(sfx_slider.value)
	
	GameState.play_sfx("select")
	hide_screen()
	emit_signal("settings_closed")

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("settings_closed")

func hide_screen():
	visible = false
