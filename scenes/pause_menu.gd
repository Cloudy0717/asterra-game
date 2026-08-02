extends CanvasLayer

signal menu_closed

var bgm_slider: HSlider
var sfx_slider: HSlider

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 25
	visible = false
	setup_ui()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Dark semi-transparent background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.75)
	root.add_child(bg)

	# Main Panel (Gold Rim Glassmorphic)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 360)
	panel.position = Vector2(170, 120)
	root.add_child(panel)

	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.09, 0.10, 0.14, 0.96)
	p_style.border_width_left = 2
	p_style.border_width_right = 2
	p_style.border_width_top = 2
	p_style.border_width_bottom = 2
	p_style.border_color = Color("#d4af37")
	p_style.corner_radius_top_left = 8
	p_style.corner_radius_top_right = 8
	p_style.corner_radius_bottom_left = 8
	p_style.corner_radius_bottom_right = 8
	p_style.shadow_color = Color(0, 0, 0, 0.6)
	p_style.shadow_size = 10
	panel.add_theme_stylebox_override("panel", p_style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Header
	var header = HBoxContainer.new()
	vbox.add_child(header)

	var title = Label.new()
	title.text = "⚙️  GAME PAUSED"
	title.add_theme_font_size_override("font_size", 16)
	title.modulate = Color("#ffd700")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.pressed.connect(close_menu)
	header.add_child(close_btn)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Body Split (Left: Save/Load/Volume, Right: Controls Guide)
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body)

	# Left Column — Actions & Volume
	var left_vbox = VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(220, 0)
	left_vbox.add_theme_constant_override("separation", 10)
	body.add_child(left_vbox)

	var save_btn = _create_styled_btn("💾  Save Game", func():
		GameState.save_game()
		ToastManager.show_toast("Game progress saved!", "💾")
	)
	left_vbox.add_child(save_btn)

	var load_btn = _create_styled_btn("📂  Load Game", func():
		GameState.load_game()
		ToastManager.show_toast("Save game loaded!", "📂")
		close_menu()
	)
	left_vbox.add_child(load_btn)

	# Volume Sliders
	var vol_label = Label.new()
	vol_label.text = "🔊 Sound Options"
	vol_label.add_theme_font_size_override("font_size", 11)
	vol_label.modulate = Color("#81d4fa")
	left_vbox.add_child(vol_label)

	# BGM Slider
	var bgm_hbox = HBoxContainer.new()
	left_vbox.add_child(bgm_hbox)
	var bgm_lbl = Label.new(); bgm_lbl.text = "BGM"; bgm_lbl.add_theme_font_size_override("font_size", 10); bgm_lbl.custom_minimum_size = Vector2(36, 0)
	bgm_hbox.add_child(bgm_lbl)
	bgm_slider = HSlider.new()
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.05
	bgm_slider.value = 0.8
	bgm_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bgm_hbox.add_child(bgm_slider)

	# SFX Slider
	var sfx_hbox = HBoxContainer.new()
	left_vbox.add_child(sfx_hbox)
	var sfx_lbl = Label.new(); sfx_lbl.text = "SFX"; sfx_lbl.add_theme_font_size_override("font_size", 10); sfx_lbl.custom_minimum_size = Vector2(36, 0)
	sfx_hbox.add_child(sfx_lbl)
	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = 0.9
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_hbox.add_child(sfx_slider)

	# Right Column — Controls Guide
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 6)
	body.add_child(right_vbox)

	var ctrl_title = Label.new()
	ctrl_title.text = "🎮 Controls Guide"
	ctrl_title.add_theme_font_size_override("font_size", 11)
	ctrl_title.modulate = Color("#ffd700")
	right_vbox.add_child(ctrl_title)

	var guide_box = PanelContainer.new()
	guide_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var g_style = StyleBoxFlat.new()
	g_style.bg_color = Color(0.06, 0.06, 0.08, 0.9)
	g_style.border_width_left = 1
	g_style.border_width_right = 1
	g_style.border_width_top = 1
	g_style.border_width_bottom = 1
	g_style.border_color = Color(0.3, 0.3, 0.3, 0.4)
	g_style.corner_radius_top_left = 4
	g_style.corner_radius_top_right = 4
	g_style.corner_radius_bottom_left = 4
	g_style.corner_radius_bottom_right = 4
	g_style.content_margin_left = 8
	g_style.content_margin_top = 8
	g_style.content_margin_right = 8
	g_style.content_margin_bottom = 8
	guide_box.add_theme_stylebox_override("panel", g_style)
	right_vbox.add_child(guide_box)

	var ctrl_txt = Label.new()
	ctrl_txt.text = "• WASD / Arrows : Move\n• SPACE / E : Interact\n• I : Inventory\n• C : Status Sheet\n• ESC : Pause Menu"
	ctrl_txt.add_theme_font_size_override("font_size", 10)
	ctrl_txt.modulate = Color("#b0bec5")
	guide_box.add_child(ctrl_txt)

	# Bottom Footer
	var resume_btn = _create_styled_btn("▶  Resume Game", close_menu)
	vbox.add_child(resume_btn)

func _create_styled_btn(text_str: String, callback: Callable) -> Button:
	var btn = Button.new()
	btn.text = text_str
	btn.custom_minimum_size = Vector2(0, 34)
	btn.add_theme_font_size_override("font_size", 11)

	var btn_n = StyleBoxFlat.new()
	btn_n.bg_color = Color(0.12, 0.12, 0.16, 0.9)
	btn_n.border_width_left = 1
	btn_n.border_width_right = 1
	btn_n.border_width_top = 1
	btn_n.border_width_bottom = 1
	btn_n.border_color = Color("#d4af37", 0.4)
	btn_n.corner_radius_top_left = 4
	btn_n.corner_radius_top_right = 4
	btn_n.corner_radius_bottom_left = 4
	btn_n.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", btn_n)

	var btn_h = StyleBoxFlat.new()
	btn_h.bg_color = Color(0.18, 0.16, 0.10, 0.95)
	btn_h.border_width_left = 2
	btn_h.border_width_right = 2
	btn_h.border_width_top = 2
	btn_h.border_width_bottom = 2
	btn_h.border_color = Color("#ffd700")
	btn_h.corner_radius_top_left = 4
	btn_h.corner_radius_top_right = 4
	btn_h.corner_radius_bottom_left = 4
	btn_h.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("hover", btn_h)

	btn.pressed.connect(func():
		GameState.play_sfx("click")
		callback.call()
	)
	return btn

func open_menu():
	visible = true
	get_tree().paused = true

func close_menu():
	visible = false
	get_tree().paused = false
	emit_signal("menu_closed")
