extends CanvasLayer

signal btn_action_pressed
signal btn_inventory_pressed
signal btn_status_pressed
signal btn_quest_pressed
signal btn_menu_pressed

var hp_bar: ProgressBar
var mp_bar: ProgressBar
var hp_label: Label
var mp_label: Label
var name_label: Label
var rank_label: Label
var gold_label: Label
var rep_label: Label
var quest_label: Label

func _ready():
	setup_ui()
	GameState.hud_updated.connect(update_hud)
	update_hud()

func setup_ui():
	# Root control node
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	# --- Top-Left Panel (Player Status) ---
	var status_bg = PanelContainer.new()
	status_bg.position = Vector2(16, 16)
	status_bg.custom_minimum_size = Vector2(250, 100)
	root.add_child(status_bg)
	
	var status_margin = MarginContainer.new()
	status_margin.add_theme_constant_override("margin_left", 8)
	status_margin.add_theme_constant_override("margin_top", 8)
	status_margin.add_theme_constant_override("margin_right", 8)
	status_margin.add_theme_constant_override("margin_bottom", 8)
	status_bg.add_child(status_margin)
	
	var status_hbox = HBoxContainer.new()
	status_margin.add_child(status_hbox)
	
	# Avatar
	var avatar = Label.new()
	avatar.text = "🛡️"
	avatar.add_theme_font_size_override("font_size", 24)
	avatar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_hbox.add_child(avatar)
	
	# Bars VBox
	var bars_vbox = VBoxContainer.new()
	bars_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_hbox.add_child(bars_vbox)
	
	# Name & Rank
	var name_hbox = HBoxContainer.new()
	bars_vbox.add_child(name_hbox)
	
	name_label = Label.new()
	name_label.text = "Hero"
	name_label.add_theme_font_size_override("font_size", 14)
	name_hbox.add_child(name_label)
	
	rank_label = Label.new()
	rank_label.text = "E Rank"
	rank_label.add_theme_font_size_override("font_size", 10)
	rank_label.modulate = Color("#ffd700")
	name_hbox.add_child(rank_label)
	
	# HP Bar
	var hp_hbox = HBoxContainer.new()
	bars_vbox.add_child(hp_hbox)
	
	var hp_title = Label.new()
	hp_title.text = "HP "
	hp_title.add_theme_font_size_override("font_size", 10)
	hp_hbox.add_child(hp_title)
	
	hp_bar = ProgressBar.new()
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(0, 14)
	# Custom style
	var sb_hp = StyleBoxFlat.new()
	sb_hp.bg_color = Color("#b71c1c")
	hp_bar.add_theme_stylebox_override("fill", sb_hp)
	hp_hbox.add_child(hp_bar)
	
	hp_label = Label.new()
	hp_label.text = "100/100"
	hp_label.add_theme_font_size_override("font_size", 10)
	hp_hbox.add_child(hp_label)
	
	# MP Bar
	var mp_hbox = HBoxContainer.new()
	bars_vbox.add_child(mp_hbox)
	
	var mp_title = Label.new()
	mp_title.text = "MP "
	mp_title.add_theme_font_size_override("font_size", 10)
	mp_hbox.add_child(mp_title)
	
	mp_bar = ProgressBar.new()
	mp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mp_bar.show_percentage = false
	mp_bar.custom_minimum_size = Vector2(0, 14)
	# Custom style
	var sb_mp = StyleBoxFlat.new()
	sb_mp.bg_color = Color("#0d47a1")
	mp_bar.add_theme_stylebox_override("fill", sb_mp)
	mp_hbox.add_child(mp_bar)
	
	mp_label = Label.new()
	mp_label.text = "20/20"
	mp_label.add_theme_font_size_override("font_size", 10)
	mp_hbox.add_child(mp_label)

	# --- Top-Right Panel (Currencies) ---
	var cur_bg = PanelContainer.new()
	cur_bg.position = Vector2(620, 16)
	cur_bg.custom_minimum_size = Vector2(160, 60)
	root.add_child(cur_bg)
	
	var cur_margin = MarginContainer.new()
	cur_margin.add_theme_constant_override("margin_left", 8)
	cur_margin.add_theme_constant_override("margin_top", 8)
	cur_margin.add_theme_constant_override("margin_right", 8)
	cur_margin.add_theme_constant_override("margin_bottom", 8)
	cur_bg.add_child(cur_margin)
	
	var cur_vbox = VBoxContainer.new()
	cur_margin.add_child(cur_vbox)
	
	# Gold Row
	var gold_hbox = HBoxContainer.new()
	cur_vbox.add_child(gold_hbox)
	var gold_icon = Label.new()
	gold_icon.text = "🪙 "
	gold_hbox.add_child(gold_icon)
	gold_label = Label.new()
	gold_label.text = "0 Gold"
	gold_label.add_theme_font_size_override("font_size", 12)
	gold_hbox.add_child(gold_label)
	
	# Rep Row
	var rep_hbox = HBoxContainer.new()
	cur_vbox.add_child(rep_hbox)
	var rep_icon = Label.new()
	rep_icon.text = "⭐ "
	rep_hbox.add_child(rep_icon)
	rep_label = Label.new()
	rep_label.text = "0 Rep"
	rep_label.add_theme_font_size_override("font_size", 12)
	rep_hbox.add_child(rep_label)

	# --- Center-Left Panel (Quest Tracker) ---
	var quest_bg = PanelContainer.new()
	quest_bg.position = Vector2(16, 130)
	quest_bg.custom_minimum_size = Vector2(250, 60)
	root.add_child(quest_bg)
	
	var quest_margin = MarginContainer.new()
	quest_margin.add_theme_constant_override("margin_left", 8)
	quest_margin.add_theme_constant_override("margin_top", 6)
	quest_margin.add_theme_constant_override("margin_right", 8)
	quest_margin.add_theme_constant_override("margin_bottom", 6)
	quest_bg.add_child(quest_margin)
	
	var quest_vbox = VBoxContainer.new()
	quest_margin.add_child(quest_vbox)
	
	var quest_title = Label.new()
	quest_title.text = "📜 Active Quest"
	quest_title.add_theme_font_size_override("font_size", 11)
	quest_title.modulate = Color("#e0e0e0")
	quest_vbox.add_child(quest_title)
	
	quest_label = Label.new()
	quest_label.text = "Talk to your sister Lina."
	quest_label.add_theme_font_size_override("font_size", 10)
	quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_vbox.add_child(quest_label)

	# --- Bottom Action Bar Background ---
	var btn_bg = ColorRect.new()
	btn_bg.position = Vector2(0, 530)
	btn_bg.custom_minimum_size = Vector2(800, 60)
	btn_bg.color = Color(0, 0, 0, 0.55)
	btn_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var btn_bg_style = StyleBoxFlat.new()
	btn_bg_style.bg_color = Color(0, 0, 0, 0.55)
	btn_bg_style.corner_radius_top_left = 8
	btn_bg_style.corner_radius_top_right = 8
	var btn_bg_panel = PanelContainer.new()
	btn_bg_panel.position = Vector2(0, 530)
	btn_bg_panel.custom_minimum_size = Vector2(800, 60)
	btn_bg_panel.add_theme_stylebox_override("panel", btn_bg_style)
	btn_bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(btn_bg_panel)

	# --- Bottom-Right Action Buttons ---
	var btn_hbox = HBoxContainer.new()
	btn_hbox.position = Vector2(340, 538)
	btn_hbox.custom_minimum_size = Vector2(440, 44)
	btn_hbox.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(btn_hbox)
	
	var btn_act = Button.new()
	btn_act.text = "[E] Interact / Attack"
	btn_act.pressed.connect(func(): emit_signal("btn_action_pressed"))
	btn_hbox.add_child(btn_act)
	
	var btn_inv = Button.new()
	btn_inv.text = "[I] Backpack"
	btn_inv.pressed.connect(func(): emit_signal("btn_inventory_pressed"))
	btn_hbox.add_child(btn_inv)
	
	var btn_stat = Button.new()
	btn_stat.text = "[C] Status"
	btn_stat.pressed.connect(func(): emit_signal("btn_status_pressed"))
	btn_hbox.add_child(btn_stat)

	var btn_qst = Button.new()
	btn_qst.text = "[Q] Quests"
	btn_qst.pressed.connect(func(): emit_signal("btn_quest_pressed"))
	btn_hbox.add_child(btn_qst)
	
	var btn_menu = Button.new()
	btn_menu.text = "[Esc] Menu"
	btn_menu.pressed.connect(func(): emit_signal("btn_menu_pressed"))
	btn_hbox.add_child(btn_menu)

func update_hud():
	var p = GameState.get_player()
	name_label.text = p.name
	rank_label.text = "  (" + p.rank + ")"
	
	hp_bar.max_value = p.max_hp
	hp_bar.value = p.hp
	hp_label.text = str(int(p.hp)) + "/" + str(int(p.max_hp))
	
	mp_bar.max_value = p.max_mp
	mp_bar.value = p.mp
	mp_label.text = str(int(p.mp)) + "/" + str(int(p.max_mp))
	
	gold_label.text = str(p.gold) + " Gold"
	rep_label.text = str(p.reputation) + " Rep"
	
	var quest_desc = ""
	match GameState.get_quest().state:
		0:
			quest_desc = "Talk to your sister Lina inside the cabin."
		1:
			quest_desc = "Go outside the cabin and inspect the Bulletin Board."
		2:
			quest_desc = "Commission: Defeat Slimes (" + str(GameState.get_quest().slimes_killed) + "/" + str(GameState.get_quest().slimes_required) + ")."
		3:
			quest_desc = "Commission Completed! Report back to the Bulletin Board."
		4:
			quest_desc = "Go back inside the cabin and tell Lina the good news."
		5:
			quest_desc = "Travel to the large building on the south road (left side of plains) to register as D-Rank."
		6:
			quest_desc = "Talk to the experienced mercenary at the guild hall."
		7:
			quest_desc = "Caravan Escort Accepted! Head north through the plains gate to reach Stone Claw Pass."
		8:
			quest_desc = "Stone Claw Pass: Defeat Goblins (" + str(GameState.get_quest().goblins_killed) + "/" + str(GameState.get_quest().goblins_required) + ")."
		9:
			quest_desc = "Escort Complete! Return to the guild to report."
		10:
			quest_desc = "Talk to the Guild Receptionist about your next step."
		11:
			quest_desc = "Visit the Weapon Shop and gear up."
		12:
			quest_desc = "Return to Lina in the cabin and rest."
		13:
			quest_desc = "Free Play: Chapter 2 Complete! Explore Asterra."
	
	var active_side = GameState.get_active_side_quests()
	if active_side.size() > 0:
		quest_desc += "\n\n📋 Side Bounties:"
		for sq in active_side:
			var status = " (Ready to Turn In!)" if sq.current_qty >= sq.target_qty else " (" + str(sq.current_qty) + "/" + str(sq.target_qty) + ")"
			quest_desc += "\n• " + sq.title + status

	quest_label.text = quest_desc

func show_region_banner(region_title: String):
	var banner_panel = PanelContainer.new()
	banner_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	banner_panel.position = Vector2(banner_panel.position.x - 140, 24)
	banner_panel.custom_minimum_size = Vector2(280, 42)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.13, 0.92)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color("#ffd700")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_top = 8
	style.content_margin_right = 16
	style.content_margin_bottom = 8
	banner_panel.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.text = "📍  " + region_title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color("#ffd700")
	banner_panel.add_child(label)

	add_child(banner_panel)

	banner_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(banner_panel, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(banner_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(banner_panel.queue_free)

