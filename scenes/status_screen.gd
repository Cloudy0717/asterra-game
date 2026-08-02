extends CanvasLayer

signal status_closed

var name_lbl: Label
var rank_lbl: Label
var level_lbl: Label
var hp_lbl: Label
var mp_lbl: Label
var exp_lbl: Label
var atk_lbl: Label
var def_lbl: Label
var rep_lbl: Label

var hp_bar: ProgressBar
var mp_bar: ProgressBar
var exp_bar: ProgressBar
var portrait_rect: TextureRect

var equip_weapon_lbl: Label
var equip_armor_lbl: Label
var equip_accessory_lbl: Label

func _ready():
	setup_ui()
	hide_screen()
	GameState.hud_updated.connect(render_status)

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

func _nameplate_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#4a4a5a")
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = Color("#8a8a9a")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 2
	s.content_margin_bottom = 2
	return s

func _stat_bar_bg_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#2a2a3a")
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = Color("#4a4a5a")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	return s

func _stat_row_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#b09870")
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = Color("#8b6914")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 3
	s.content_margin_bottom = 3
	return s

func _equip_row_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#5d3a1a")
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = Color("#8b6914")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 3
	s.content_margin_bottom = 3
	return s

# ─── UI Setup ────────────────────────────────────────────────
func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Dark overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			on_close()
	)
	root.add_child(overlay)

	# ── Main Wood-Frame Panel ──
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 400)
	panel.position = Vector2(90, 100)
	panel.add_theme_stylebox_override("panel", _wood_frame_style())
	root.add_child(panel)

	var outer_margin = MarginContainer.new()
	outer_margin.add_theme_constant_override("margin_left", 8)
	outer_margin.add_theme_constant_override("margin_top", 6)
	outer_margin.add_theme_constant_override("margin_right", 8)
	outer_margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(outer_margin)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 6)
	outer_margin.add_child(main_vbox)

	# ── Header Bar ──
	var header_bg = PanelContainer.new()
	var hdr_style = StyleBoxFlat.new()
	hdr_style.bg_color = Color("#5d3a1a")
	hdr_style.corner_radius_top_left = 3
	hdr_style.corner_radius_top_right = 3
	hdr_style.corner_radius_bottom_left = 3
	hdr_style.corner_radius_bottom_right = 3
	header_bg.add_theme_stylebox_override("panel", hdr_style)
	main_vbox.add_child(header_bg)

	var hdr_margin = MarginContainer.new()
	hdr_margin.add_theme_constant_override("margin_left", 10)
	hdr_margin.add_theme_constant_override("margin_right", 10)
	hdr_margin.add_theme_constant_override("margin_top", 4)
	hdr_margin.add_theme_constant_override("margin_bottom", 4)
	header_bg.add_child(hdr_margin)

	var hdr_hbox = HBoxContainer.new()
	hdr_margin.add_child(hdr_hbox)

	var title = Label.new()
	title.text = "⚔️  STATUS"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color("#f5f0e1")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_hbox.add_child(title)

	var close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(on_close)
	hdr_hbox.add_child(close_btn)

	# ── Body: Left (Character) + Right (Stats) ──
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(body)

	# ─────── LEFT PANEL: Character Portrait + Name ───────
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(180, 0)
	left_panel.add_theme_stylebox_override("panel", _dark_panel_style())
	body.add_child(left_panel)

	var left_margin = MarginContainer.new()
	left_margin.add_theme_constant_override("margin_left", 12)
	left_margin.add_theme_constant_override("margin_top", 12)
	left_margin.add_theme_constant_override("margin_right", 12)
	left_margin.add_theme_constant_override("margin_bottom", 10)
	left_panel.add_child(left_margin)

	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 8)
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_margin.add_child(left_vbox)

	# Portrait
	var portrait_container = PanelContainer.new()
	var portrait_bg = StyleBoxFlat.new()
	portrait_bg.bg_color = Color("#12122a")
	portrait_bg.border_width_left = 2
	portrait_bg.border_width_right = 2
	portrait_bg.border_width_top = 2
	portrait_bg.border_width_bottom = 2
	portrait_bg.border_color = Color("#3a3a5a")
	portrait_bg.corner_radius_top_left = 3
	portrait_bg.corner_radius_top_right = 3
	portrait_bg.corner_radius_bottom_left = 3
	portrait_bg.corner_radius_bottom_right = 3
	portrait_container.add_theme_stylebox_override("panel", portrait_bg)
	portrait_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(portrait_container)

	portrait_rect = TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(96, 115)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if Sprites.portraits.has("protagonist"):
		portrait_rect.texture = Sprites.portraits["protagonist"]
	portrait_container.add_child(portrait_rect)

	# Nameplate
	var nameplate = PanelContainer.new()
	nameplate.add_theme_stylebox_override("panel", _nameplate_style())
	nameplate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(nameplate)

	name_lbl = Label.new()
	name_lbl.text = "ALEX"
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.modulate = Color("#e0e0e0")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nameplate.add_child(name_lbl)

	# Rank badge
	var rank_badge = PanelContainer.new()
	var rank_style = StyleBoxFlat.new()
	rank_style.bg_color = Color("#3a3020")
	rank_style.border_width_left = 1
	rank_style.border_width_right = 1
	rank_style.border_width_top = 1
	rank_style.border_width_bottom = 1
	rank_style.border_color = Color("#ffd700")
	rank_style.corner_radius_top_left = 3
	rank_style.corner_radius_top_right = 3
	rank_style.corner_radius_bottom_left = 3
	rank_style.corner_radius_bottom_right = 3
	rank_style.content_margin_left = 8
	rank_style.content_margin_right = 8
	rank_style.content_margin_top = 2
	rank_style.content_margin_bottom = 2
	rank_badge.add_theme_stylebox_override("panel", rank_style)
	rank_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(rank_badge)

	rank_lbl = Label.new()
	rank_lbl.text = "E RANK"
	rank_lbl.add_theme_font_size_override("font_size", 10)
	rank_lbl.modulate = Color("#ffd700")
	rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_badge.add_child(rank_lbl)

	# Bio text
	var bio_panel = PanelContainer.new()
	var bio_style = StyleBoxFlat.new()
	bio_style.bg_color = Color("#1a1a2e")
	bio_style.corner_radius_top_left = 2
	bio_style.corner_radius_top_right = 2
	bio_style.corner_radius_bottom_left = 2
	bio_style.corner_radius_bottom_right = 2
	bio_style.content_margin_left = 6
	bio_style.content_margin_right = 6
	bio_style.content_margin_top = 4
	bio_style.content_margin_bottom = 4
	bio_panel.add_theme_stylebox_override("panel", bio_style)
	bio_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(bio_panel)

	var bio_text = Label.new()
	bio_text.text = "Striving to protect his sister Lina and climb the mercenary ranks."
	bio_text.add_theme_font_size_override("font_size", 8)
	bio_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio_text.modulate = Color("#8888aa")
	bio_panel.add_child(bio_text)

	# ─────── RIGHT PANEL: Stats + Bars + Equipment ───────
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 5)
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right_vbox)

	# ── Vitality Section (HP / MP / EXP bars) ──
	var vitality_title = Label.new()
	vitality_title.text = "💖 VITALITY"
	vitality_title.add_theme_font_size_override("font_size", 11)
	vitality_title.modulate = Color("#5d3a1a")
	right_vbox.add_child(vitality_title)

	hp_lbl = Label.new()
	hp_bar = _create_stat_bar(right_vbox, hp_lbl, "HP", Color("#c62828"), Color("#ef5350"))
	mp_lbl = Label.new()
	mp_bar = _create_stat_bar(right_vbox, mp_lbl, "MP", Color("#1565c0"), Color("#42a5f5"))
	exp_lbl = Label.new()
	exp_bar = _create_stat_bar(right_vbox, exp_lbl, "EXP", Color("#7b1fa2"), Color("#ab47bc"))

	# ── Attributes Section ──
	var attr_title = Label.new()
	attr_title.text = "⚔️ ATTRIBUTES"
	attr_title.add_theme_font_size_override("font_size", 11)
	attr_title.modulate = Color("#5d3a1a")
	right_vbox.add_child(attr_title)

	var attr_grid = GridContainer.new()
	attr_grid.columns = 2
	attr_grid.add_theme_constant_override("h_separation", 8)
	attr_grid.add_theme_constant_override("v_separation", 4)
	right_vbox.add_child(attr_grid)

	level_lbl = _create_attr_row(attr_grid, "⭐ Level")
	atk_lbl = _create_attr_row(attr_grid, "⚔️ ATK")
	def_lbl = _create_attr_row(attr_grid, "🛡️ DEF")
	rep_lbl = _create_attr_row(attr_grid, "🏅 Rep")

	# ── Equipment Section ──
	var equip_title = Label.new()
	equip_title.text = "🗡️ EQUIPMENT"
	equip_title.add_theme_font_size_override("font_size", 11)
	equip_title.modulate = Color("#5d3a1a")
	right_vbox.add_child(equip_title)

	equip_weapon_lbl = _create_equip_row(right_vbox, "⚔️ Weapon")
	equip_armor_lbl = _create_equip_row(right_vbox, "🛡️ Armor")
	equip_accessory_lbl = _create_equip_row(right_vbox, "📿 Acc")

func _create_stat_bar(parent: VBoxContainer, lbl: Label, bar_name: String, fill_color: Color, fill_light: Color) -> ProgressBar:
	var bar_panel = PanelContainer.new()
	bar_panel.add_theme_stylebox_override("panel", _stat_bar_bg_style())
	parent.add_child(bar_panel)

	var bar_margin = MarginContainer.new()
	bar_margin.add_theme_constant_override("margin_left", 6)
	bar_margin.add_theme_constant_override("margin_right", 6)
	bar_margin.add_theme_constant_override("margin_top", 3)
	bar_margin.add_theme_constant_override("margin_bottom", 3)
	bar_panel.add_child(bar_margin)

	var bar_vbox = VBoxContainer.new()
	bar_vbox.add_theme_constant_override("separation", 2)
	bar_margin.add_child(bar_vbox)

	var bar_header = HBoxContainer.new()
	bar_vbox.add_child(bar_header)

	var name_label = Label.new()
	name_label.text = bar_name
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.modulate = fill_light
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_header.add_child(name_label)

	lbl.text = "0/0"
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.modulate = Color("#e0e0e0")
	bar_header.add_child(lbl)

	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 8)
	bar.show_percentage = false
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.corner_radius_top_left = 1
	fill_style.corner_radius_top_right = 1
	fill_style.corner_radius_bottom_left = 1
	fill_style.corner_radius_bottom_right = 1
	bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color("#1a1a2a")
	bg_style.corner_radius_top_left = 1
	bg_style.corner_radius_top_right = 1
	bg_style.corner_radius_bottom_left = 1
	bg_style.corner_radius_bottom_right = 1
	bar.add_theme_stylebox_override("background", bg_style)

	bar_vbox.add_child(bar)
	return bar

func _create_attr_row(grid: GridContainer, label_text: String) -> Label:
	var row = PanelContainer.new()
	row.add_theme_stylebox_override("panel", _stat_row_style())
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(row)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	row.add_child(hbox)

	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.modulate = Color("#5d3a1a")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var val = Label.new()
	val.text = "0"
	val.add_theme_font_size_override("font_size", 10)
	val.modulate = Color("#3e2415")
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(val)

	return val

func _create_equip_row(parent: VBoxContainer, label_text: String) -> Label:
	var row = PanelContainer.new()
	row.add_theme_stylebox_override("panel", _equip_row_style())
	parent.add_child(row)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	row.add_child(hbox)

	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.modulate = Color("#c4a878")
	lbl.custom_minimum_size = Vector2(75, 0)
	hbox.add_child(lbl)

	var val = Label.new()
	val.text = "— Empty —"
	val.add_theme_font_size_override("font_size", 10)
	val.modulate = Color("#8a7a60")
	val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(val)

	return val

# ─── Render ──────────────────────────────────────────────────
func render_status():
	if not visible:
		return

	var p = GameState.get_player()
	name_lbl.text = p.name.to_upper()
	rank_lbl.text = p.rank.to_upper()

	if Sprites.portraits.has("protagonist"):
		portrait_rect.texture = Sprites.portraits["protagonist"]

	level_lbl.text = str(p.level)

	hp_lbl.text = str(int(p.hp)) + "/" + str(int(p.max_hp))
	hp_bar.max_value = p.max_hp
	hp_bar.value = p.hp

	mp_lbl.text = str(int(p.mp)) + "/" + str(int(p.max_mp))
	mp_bar.max_value = p.max_mp
	mp_bar.value = p.mp

	exp_lbl.text = str(p.exp) + "/" + str(p.max_exp)
	exp_bar.max_value = p.max_exp
	exp_bar.value = p.exp

	var weapon_bonus = p.equipment.weapon.value if p.equipment.weapon else 0
	var armor_bonus = p.equipment.armor.value if p.equipment.armor else 0
	var acc_bonus = p.equipment.accessory.value if p.equipment.accessory else 0

	atk_lbl.text = str(p.base_atk) + " (+" + str(weapon_bonus) + ")"
	def_lbl.text = str(p.base_def) + " (+" + str(armor_bonus + acc_bonus) + ")"
	rep_lbl.text = str(p.reputation)

	# Equipment display
	_update_equip_label(equip_weapon_lbl, p.equipment.weapon)
	_update_equip_label(equip_armor_lbl, p.equipment.armor)
	_update_equip_label(equip_accessory_lbl, p.equipment.accessory)

func _update_equip_label(lbl: Label, item):
	if item:
		lbl.text = item.name + " (+" + str(item.value) + ")"
		lbl.modulate = Color("#ffd700")
	else:
		lbl.text = "— Empty —"
		lbl.modulate = Color("#8a7a60")

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	render_status()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("status_closed")

func hide_screen():
	visible = false
