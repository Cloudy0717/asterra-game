extends CanvasLayer

signal quest_log_closed

var quest_list_vbox: VBoxContainer
var details_content: VBoxContainer

var detail_title: Label
var detail_type: Label
var detail_status: Label
var detail_desc: Label
var detail_objective: Label
var detail_reward: Label

var current_tab = "all"
var tab_btns = {}
var selected_quest_id = ""

func _ready():
	setup_ui()
	hide_screen()
	if GameState.has_signal("hud_updated"):
		GameState.hud_updated.connect(render_quest_log)

# ─── Style Helpers ────────────────────────────────────────────
func _wood_frame_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#d4b896")
	s.border_width_left = 4
	s.border_width_right = 4
	s.border_width_top = 4
	s.border_width_bottom = 4
	s.border_color = Color("#6b4226")
	s.corner_radius_top_left = 4
	s.corner_radius_top_right = 4
	s.corner_radius_bottom_left = 4
	s.corner_radius_bottom_right = 4
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = 6
	s.expand_margin_left = 3
	s.expand_margin_right = 3
	s.expand_margin_top = 3
	s.expand_margin_bottom = 3
	return s

func _dark_panel_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#1a1a2e")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#3e2415")
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
	return s

func _tab_normal_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#b09870")
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 0
	s.border_color = Color("#8b6914")
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 0
	s.corner_radius_bottom_right = 0
	return s

func _tab_active_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#d4b896")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 0
	s.border_color = Color("#ffd700")
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 0
	s.corner_radius_bottom_right = 0
	return s

func _quest_item_style(selected: bool) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	if selected:
		s.bg_color = Color("#e8d8b0")
		s.border_color = Color("#ffd700")
		s.border_width_left = 2
		s.border_width_right = 2
		s.border_width_top = 2
		s.border_width_bottom = 2
	else:
		s.bg_color = Color("#c4a878")
		s.border_color = Color("#8b6914")
		s.border_width_left = 1
		s.border_width_right = 1
		s.border_width_top = 1
		s.border_width_bottom = 1
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s

# ─── UI Setup ────────────────────────────────────────────────
func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			on_close()
	)
	root.add_child(overlay)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 400)
	panel.position = Vector2(90, 95)
	panel.add_theme_stylebox_override("panel", _wood_frame_style())
	root.add_child(panel)

	var outer_margin = MarginContainer.new()
	outer_margin.add_theme_constant_override("margin_left", 8)
	outer_margin.add_theme_constant_override("margin_top", 6)
	outer_margin.add_theme_constant_override("margin_right", 8)
	outer_margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(outer_margin)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	outer_margin.add_child(main_vbox)

	# ── Header Bar ──
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	main_vbox.add_child(header)

	var header_bg = PanelContainer.new()
	var hdr_style = StyleBoxFlat.new()
	hdr_style.bg_color = Color("#5d3a1a")
	hdr_style.corner_radius_top_left = 3
	hdr_style.corner_radius_top_right = 3
	hdr_style.corner_radius_bottom_left = 3
	hdr_style.corner_radius_bottom_right = 3
	header_bg.add_theme_stylebox_override("panel", hdr_style)
	header_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_bg)

	var hdr_margin = MarginContainer.new()
	hdr_margin.add_theme_constant_override("margin_left", 10)
	hdr_margin.add_theme_constant_override("margin_right", 10)
	hdr_margin.add_theme_constant_override("margin_top", 4)
	hdr_margin.add_theme_constant_override("margin_bottom", 4)
	header_bg.add_child(hdr_margin)

	var hdr_hbox = HBoxContainer.new()
	hdr_margin.add_child(hdr_hbox)

	var title = Label.new()
	title.text = "📜  QUEST LOG"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color("#f5f0e1")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_hbox.add_child(title)

	var close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)

	# ── Body: Left (Quest List) + Right (Quest Details) ──
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(body)

	# ── Left: Tabs & Quest List ──
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 0)
	left_vbox.custom_minimum_size = Vector2(250, 0)
	body.add_child(left_vbox)

	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 4)
	left_vbox.add_child(tabs_hbox)

	var filter_opts = [
		{"id": "all", "label": " ALL "},
		{"id": "main", "label": " MAIN "},
		{"id": "side", "label": " BOUNTIES "}
	]

	for opt in filter_opts:
		var tab = Button.new()
		tab.text = opt.label
		tab.add_theme_font_size_override("font_size", 10)
		tab.add_theme_stylebox_override("normal", _tab_normal_style())
		tab.custom_minimum_size = Vector2(70, 22)
		var fid = opt.id
		tab.pressed.connect(func(): set_filter(fid))
		tabs_hbox.add_child(tab)
		tab_btns[fid] = tab

	var list_panel = PanelContainer.new()
	var list_bg = StyleBoxFlat.new()
	list_bg.bg_color = Color("#c4a878")
	list_bg.border_width_left = 2
	list_bg.border_width_right = 2
	list_bg.border_width_top = 0
	list_bg.border_width_bottom = 2
	list_bg.border_color = Color("#8b6914")
	list_bg.corner_radius_bottom_left = 3
	list_bg.corner_radius_bottom_right = 3
	list_panel.add_theme_stylebox_override("panel", list_bg)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(list_panel)

	var list_margin = MarginContainer.new()
	list_margin.add_theme_constant_override("margin_left", 6)
	list_margin.add_theme_constant_override("margin_top", 6)
	list_margin.add_theme_constant_override("margin_right", 6)
	list_margin.add_theme_constant_override("margin_bottom", 6)
	list_panel.add_child(list_margin)

	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_margin.add_child(scroll)

	quest_list_vbox = VBoxContainer.new()
	quest_list_vbox.add_theme_constant_override("separation", 4)
	quest_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(quest_list_vbox)

	# ── Right: Quest Details Panel ──
	var right_panel = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_stylebox_override("panel", _dark_panel_style())
	body.add_child(right_panel)

	var right_margin = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 12)
	right_margin.add_theme_constant_override("margin_top", 12)
	right_margin.add_theme_constant_override("margin_right", 12)
	right_margin.add_theme_constant_override("margin_bottom", 12)
	right_panel.add_child(right_margin)

	details_content = VBoxContainer.new()
	details_content.add_theme_constant_override("separation", 8)
	details_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_margin.add_child(details_content)

	detail_title = Label.new()
	detail_title.text = "Quest Title"
	detail_title.add_theme_font_size_override("font_size", 14)
	detail_title.modulate = Color("#ffd700")
	details_content.add_child(detail_title)

	var badge_hbox = HBoxContainer.new()
	badge_hbox.add_theme_constant_override("separation", 8)
	details_content.add_child(badge_hbox)

	detail_type = Label.new()
	detail_type.text = "[ MAIN STORY ]"
	detail_type.add_theme_font_size_override("font_size", 9)
	detail_type.modulate = Color("#80deea")
	badge_hbox.add_child(detail_type)

	detail_status = Label.new()
	detail_status.text = "● IN PROGRESS"
	detail_status.add_theme_font_size_override("font_size", 9)
	detail_status.modulate = Color("#ffb74d")
	badge_hbox.add_child(detail_status)

	var sep1 = HSeparator.new()
	details_content.add_child(sep1)

	detail_desc = Label.new()
	detail_desc.text = "Description..."
	detail_desc.add_theme_font_size_override("font_size", 10)
	detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_desc.modulate = Color("#d4c8b0")
	details_content.add_child(detail_desc)

	var obj_hdr = Label.new()
	obj_hdr.text = "🎯 OBJECTIVE"
	obj_hdr.add_theme_font_size_override("font_size", 10)
	obj_hdr.modulate = Color("#ffd700")
	details_content.add_child(obj_hdr)

	detail_objective = Label.new()
	detail_objective.text = "• Defeat Slimes: 0/3"
	detail_objective.add_theme_font_size_override("font_size", 10)
	detail_objective.modulate = Color("#ffffff")
	details_content.add_child(detail_objective)

	var rwd_hdr = Label.new()
	rwd_hdr.text = "🎁 REWARD"
	rwd_hdr.add_theme_font_size_override("font_size", 10)
	rwd_hdr.modulate = Color("#ffd700")
	details_content.add_child(rwd_hdr)

	detail_reward = Label.new()
	detail_reward.text = "💰 50 Gold  ⭐ 50 EXP"
	detail_reward.add_theme_font_size_override("font_size", 10)
	detail_reward.modulate = Color("#80e880")
	details_content.add_child(detail_reward)

	var default_hint = Label.new()
	default_hint.text = "Select a quest from the list to view details."
	default_hint.add_theme_font_size_override("font_size", 10)
	default_hint.modulate = Color("#a09880")
	default_hint.name = "default_hint"
	right_margin.add_child(default_hint)

# ─── Data Helper ──────────────────────────────────────────────
func _get_all_quests() -> Array:
	var qdata = GameState.get_quest()
	var state = qdata.get("state", 0)

	var quests = []

	# Main Story Quest
	var main_q = {
		"id": "main_story",
		"title": "Mercenary Journey",
		"type": "main",
		"icon": "📜",
		"desc": "Advance your mercenary rank to earn gold and protect your sister Lina.",
		"objective": "",
		"status": "in_progress",
		"reward": "💰 Gold & ⭐ EXP"
	}

	match state:
		0:
			main_q["objective"] = "• Speak to Lina inside the Cabin."
		1:
			main_q["objective"] = "• Inspect the Guild Bulletin Board outside."
		2:
			var killed = qdata.get("slimes_killed", 0)
			var req = qdata.get("slimes_required", 3)
			main_q["objective"] = "• Defeat Slimes near the village: " + str(killed) + "/" + str(req)
		3:
			main_q["objective"] = "• Report back to the Bulletin Board to claim reward!"
			main_q["status"] = "claimable"
		4:
			main_q["objective"] = "• Tell Lina about your successful commission."
		5:
			main_q["objective"] = "• Travel south to the Mercenary Guild Hall to register as D-Rank."
		6:
			main_q["objective"] = "• Speak with Garrick the experienced mercenary."
		7:
			main_q["objective"] = "• Head north through the Plains Gate to Stone Claw Pass."
		8:
			var gkilled = qdata.get("goblins_killed", 0)
			var greq = qdata.get("goblins_required", 3)
			main_q["objective"] = "• Clear Goblins in Stone Claw Pass: " + str(gkilled) + "/" + str(greq)
		9:
			main_q["objective"] = "• Return to the Guild Receptionist to complete escort."
			main_q["status"] = "claimable"
		10:
			main_q["objective"] = "• Talk to the Guild Receptionist."
		11:
			main_q["objective"] = "• Visit the Weapon Shop and gear up."
		12:
			main_q["objective"] = "• Return home to Lina and rest."
		13:
			main_q["objective"] = "• Chapter 2 Complete! Explore Asterra freely."
			main_q["status"] = "completed"

	quests.append(main_q)

	# Side Quest 1: Wolf Hunting
	var wolf_q = {
		"id": "side_wolf",
		"title": "Wild Wolf Bounty",
		"type": "side",
		"icon": "🐺",
		"desc": "Wild wolves threaten travelers near the South Forest. Hunt them down.",
		"objective": "• Defeat Wild Wolves in South Forest.",
		"status": "in_progress",
		"reward": "💰 60 Gold  ⭐ 40 EXP  📦 Wolf Pelt"
	}
	quests.append(wolf_q)

	# Side Quest 2: Goblin Chief Conquest
	var boss_q = {
		"id": "side_boss",
		"title": "Chief of Stone Claw",
		"type": "side",
		"icon": "👹",
		"desc": "Defeat the Goblin Chief lurking deep inside Stone Claw Pass.",
		"objective": "• Defeat the Goblin Chief Boss.",
		"status": "in_progress",
		"reward": "💰 150 Gold  ⭐ 120 EXP  ⚔️ Steel Blade"
	}
	if state >= 8:
		quests.append(boss_q)

	return quests

# ─── Render ──────────────────────────────────────────────────
func set_filter(f_id: String):
	GameState.play_sfx("select")
	current_tab = f_id
	render_quest_log()

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	selected_quest_id = "main_story"
	render_quest_log()

func render_quest_log():
	if not visible:
		return

	# Update tab highlights
	for fid in tab_btns:
		var tab = tab_btns[fid]
		if fid == current_tab:
			tab.add_theme_stylebox_override("normal", _tab_active_style())
			tab.modulate = Color("#ffd700")
		else:
			tab.add_theme_stylebox_override("normal", _tab_normal_style())
			tab.modulate = Color("#e0d0b0")

	for c in quest_list_vbox.get_children():
		c.queue_free()

	var quests = _get_all_quests()
	var filtered = []
	for q in quests:
		if current_tab == "all" or q.type == current_tab:
			filtered.append(q)

	for q in filtered:
		var btn = Button.new()
		var is_sel = (q.id == selected_quest_id)
		btn.add_theme_stylebox_override("normal", _quest_item_style(is_sel))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)
		btn.add_child(hbox)

		var icon_lbl = Label.new()
		icon_lbl.text = q.icon
		icon_lbl.add_theme_font_size_override("font_size", 12)
		hbox.add_child(icon_lbl)

		var qtitle = Label.new()
		qtitle.text = q.title
		qtitle.add_theme_font_size_override("font_size", 10)
		qtitle.modulate = Color("#3e2415") if is_sel else Color("#5d3a1a")
		qtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(qtitle)

		var qstat = Label.new()
		if q.status == "completed":
			qstat.text = "✓"
			qstat.modulate = Color("#2e7d32")
		elif q.status == "claimable":
			qstat.text = "!"
			qstat.modulate = Color("#e65100")
		else:
			qstat.text = "●"
			qstat.modulate = Color("#0277bd")
		qstat.add_theme_font_size_override("font_size", 10)
		hbox.add_child(qstat)

		var q_id = q.id
		btn.pressed.connect(func(): on_quest_selected(q_id))
		quest_list_vbox.add_child(btn)

	update_details(filtered)

func on_quest_selected(q_id: String):
	GameState.play_sfx("select")
	selected_quest_id = q_id
	render_quest_log()

func update_details(filtered: Array):
	var detail_margin = details_content.get_parent()
	var default_hint = detail_margin.get_node_or_null("default_hint")

	var selected_q = null
	for q in filtered:
		if q.id == selected_quest_id:
			selected_q = q
			break

	if selected_q:
		details_content.visible = true
		if default_hint:
			default_hint.visible = false

		detail_title.text = selected_q.title
		detail_type.text = "[ MAIN STORY ]" if selected_q.type == "main" else "[ SIDE BOUNTY ]"
		
		if selected_q.status == "completed":
			detail_status.text = "✓ COMPLETED"
			detail_status.modulate = Color("#81c784")
		elif selected_q.status == "claimable":
			detail_status.text = "! CLAIMABLE"
			detail_status.modulate = Color("#ffb74d")
		else:
			detail_status.text = "● IN PROGRESS"
			detail_status.modulate = Color("#64b5f6")

		detail_desc.text = selected_q.desc
		detail_objective.text = selected_q.objective
		detail_reward.text = selected_q.reward
	else:
		details_content.visible = false
		if default_hint:
			default_hint.visible = true

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("quest_log_closed")

func hide_screen():
	visible = false
