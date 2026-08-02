extends CanvasLayer
class_name LevelUpModal

signal modal_closed

func _ready():
	layer = 18
	visible = false

static func show_level_up(new_level: int, new_rank: String, stat_gains: Dictionary):
	var tree = Engine.get_main_loop() as SceneTree
	if not tree or not tree.current_scene:
		return

	var scene = tree.current_scene
	var modal = scene.get_node_or_null("LevelUpModal")
	if not modal:
		modal = load("res://scenes/level_up_modal.gd").new()
		modal.name = "LevelUpModal"
		scene.add_child(modal)

	modal._display(new_level, new_rank, stat_gains)

func _display(new_level: int, new_rank: String, stat_gains: Dictionary):
	# Clear existing children
	for c in get_children():
		c.queue_free()

	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Dark overlay
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.75)
	root.add_child(bg)

	# Modal panel (Gold Rim)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 280)
	panel.position = Vector2(220, 160)
	root.add_child(panel)

	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.09, 0.10, 0.14, 0.96)
	p_style.border_width_left = 2
	p_style.border_width_right = 2
	p_style.border_width_top = 2
	p_style.border_width_bottom = 2
	p_style.border_color = Color("#ffd700")
	p_style.corner_radius_top_left = 10
	p_style.corner_radius_top_right = 10
	p_style.corner_radius_bottom_left = 10
	p_style.corner_radius_bottom_right = 10
	p_style.shadow_color = Color(1, 0.84, 0, 0.3)
	p_style.shadow_size = 12
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
	var title = Label.new()
	title.text = "✨ LEVEL UP! ✨"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.modulate = Color("#ffd700")
	vbox.add_child(title)

	var level_lbl = Label.new()
	level_lbl.text = "You reached Level " + str(new_level) + " (" + new_rank + ")"
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 12)
	level_lbl.modulate = Color("#81d4fa")
	vbox.add_child(level_lbl)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Stat gains grid
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)

	_add_stat_row(grid, "❤️ Max HP", "+" + str(stat_gains.get("hp", 15)), Color("#ef5350"))
	_add_stat_row(grid, "🔷 Max MP", "+" + str(stat_gains.get("mp", 5)), Color("#42a5f5"))
	_add_stat_row(grid, "⚔️ Base ATK", "+" + str(stat_gains.get("atk", 3)), Color("#ffee58"))
	_add_stat_row(grid, "🛡️ Base DEF", "+" + str(stat_gains.get("def", 2)), Color("#66bb6a"))

	# Close button
	var btn = Button.new()
	btn.text = "🎉 Continue Adventure"
	btn.custom_minimum_size = Vector2(0, 36)
	btn.add_theme_font_size_override("font_size", 12)
	
	var btn_s = StyleBoxFlat.new()
	btn_s.bg_color = Color(0.20, 0.18, 0.10, 0.95)
	btn_s.border_width_left = 1
	btn_s.border_width_right = 1
	btn_s.border_width_top = 1
	btn_s.border_width_bottom = 1
	btn_s.border_color = Color("#ffd700")
	btn_s.corner_radius_top_left = 4
	btn_s.corner_radius_top_right = 4
	btn_s.corner_radius_bottom_left = 4
	btn_s.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", btn_s)

	btn.pressed.connect(func():
		GameState.play_sfx("click")
		visible = false
		emit_signal("modal_closed")
	)
	vbox.add_child(btn)

	visible = true

func _add_stat_row(grid: GridContainer, name_str: String, val_str: String, val_color: Color):
	var l1 = Label.new()
	l1.text = name_str
	l1.add_theme_font_size_override("font_size", 11)
	grid.add_child(l1)

	var l2 = Label.new()
	l2.text = val_str
	l2.add_theme_font_size_override("font_size", 11)
	l2.modulate = val_color
	grid.add_child(l2)
