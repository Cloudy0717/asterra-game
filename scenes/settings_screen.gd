extends CanvasLayer

signal settings_closed

var speed_option: OptionButton
var music_toggle: CheckButton
var sfx_slider: HSlider

func _ready():
	setup_ui()
	hide_screen()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	# Transparent catcher
	var click_catcher = TextureButton.new()
	click_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_catcher.pressed.connect(on_close)
	root.add_child(click_catcher)
	
	# Modal card
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 240)
	panel.position = Vector2(240, 180)
	root.add_child(panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.14, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color("#8d6e63")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	# Header
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var title = Label.new()
	title.text = "Game Settings"
	title.add_theme_font_size_override("font_size", 14)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)
	
	# Item 1: Dialogue Speed
	var speed_hbox = HBoxContainer.new()
	vbox.add_child(speed_hbox)
	
	var speed_label = Label.new()
	speed_label.text = "Dialogue Speed "
	speed_label.add_theme_font_size_override("font_size", 11)
	speed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speed_hbox.add_child(speed_label)
	
	speed_option = OptionButton.new()
	speed_option.add_item("Normal", 0)
	speed_option.add_item("Fast", 1)
	speed_option.add_item("Slow", 2)
	speed_option.add_item("Instant", 3)
	speed_hbox.add_child(speed_option)
	
	# Item 2: Music
	var music_hbox = HBoxContainer.new()
	vbox.add_child(music_hbox)
	
	var music_label = Label.new()
	music_label.text = "Ambient Sound "
	music_label.add_theme_font_size_override("font_size", 11)
	music_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_hbox.add_child(music_label)
	
	music_toggle = CheckButton.new()
	music_hbox.add_child(music_toggle)
	
	# Item 3: SFX Volume
	var sfx_hbox = HBoxContainer.new()
	vbox.add_child(sfx_hbox)
	
	var sfx_label = Label.new()
	sfx_label.text = "SFX Volume "
	sfx_label.add_theme_font_size_override("font_size", 11)
	sfx_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_hbox.add_child(sfx_label)
	
	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.value = 80
	sfx_slider.custom_minimum_size = Vector2(100, 16)
	sfx_hbox.add_child(sfx_slider)
	
	# Apply Button
	var apply_btn = Button.new()
	apply_btn.text = "Apply Settings"
	apply_btn.pressed.connect(on_apply)
	vbox.add_child(apply_btn)

func show_screen():
	# Sync values from GameState
	var speed = GameState.settings.text_speed
	if speed == 40: speed_option.select(0)
	elif speed == 15: speed_option.select(1)
	elif speed == 80: speed_option.select(2)
	elif speed == 0: speed_option.select(3)
	
	music_toggle.button_pressed = GameState.settings.music_on
	sfx_slider.value = GameState.settings.sfx_volume
	
	GameState.play_sfx("open_menu")
	visible = true

func on_apply():
	var speed = 40
	match speed_option.get_selected_id():
		0: speed = 40
		1: speed = 15
		2: speed = 80
		3: speed = 0
		
	GameState.settings.text_speed = speed
	GameState.settings.music_on = music_toggle.button_pressed
	GameState.settings.sfx_volume = int(sfx_slider.value)
	
	GameState.play_sfx("select")
	hide_screen()
	emit_signal("settings_closed")

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("settings_closed")

func hide_screen():
	visible = false
