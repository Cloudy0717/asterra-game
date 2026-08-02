extends CanvasLayer

signal inventory_closed

var grid_container: GridContainer
var details_content: VBoxContainer

var detail_icon: Label
var detail_texture_rect: TextureRect
var detail_name: Label
var detail_type: Label
var detail_desc: Label
var detail_effect: Label
var action_btn: Button
var gold_lbl: Label

# Equipment slot buttons (left panel)
var equip_weapon_slot: Button
var equip_armor_slot: Button
var equip_accessory_slot: Button

var selected_idx = -1
var slot_btns = []
var current_filter = "all"
var tab_btns = {}

func _ready():
	setup_ui()
	hide_screen()
	GameState.hud_updated.connect(render_inventory)

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
	# Outer border effect via expand margin
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

func _slot_normal_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#c4a878")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#8b6914")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	return s

func _slot_hover_style() -> StyleBoxFlat:
	var s = _slot_normal_style()
	s.border_color = Color("#ffd700")
	s.bg_color = Color("#d4c498")
	return s

func _slot_selected_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#e8d8b0")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#ffd700")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	return s

func _slot_empty_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#9e8a6a")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#7a6030")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	return s

func _slot_equipped_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#b8a060")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#ffb300")
	s.corner_radius_top_left = 2
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 2
	return s

func _equip_slot_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#2a2a40")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#555580")
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

func _action_btn_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#4a7a30")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#6b9a40")
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
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 2
	s.content_margin_bottom = 2
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
	panel.custom_minimum_size = Vector2(640, 410)
	panel.position = Vector2(80, 95)
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
	title.text = "📦  PACKAGE"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color("#f5f0e1")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_hbox.add_child(title)

	gold_lbl = Label.new()
	gold_lbl.text = "💰 0"
	gold_lbl.add_theme_font_size_override("font_size", 12)
	gold_lbl.modulate = Color("#ffd700")
	hdr_hbox.add_child(gold_lbl)

	var close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)

	# ── Body: Left (Character) + Right (Grid) ──
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(body)

	# ─────── LEFT PANEL: Character + Equipment Slots ───────
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(170, 0)
	left_panel.add_theme_stylebox_override("panel", _dark_panel_style())
	body.add_child(left_panel)

	var left_margin = MarginContainer.new()
	left_margin.add_theme_constant_override("margin_left", 8)
	left_margin.add_theme_constant_override("margin_top", 8)
	left_margin.add_theme_constant_override("margin_right", 8)
	left_margin.add_theme_constant_override("margin_bottom", 6)
	left_panel.add_child(left_margin)

	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 6)
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_margin.add_child(left_vbox)

	# Weapon slot (top)
	equip_weapon_slot = _create_equip_slot("⚔️", Constants.ITEM_TYPE_WEAPON)
	equip_weapon_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(equip_weapon_slot)

	# Portrait
	var portrait_container = PanelContainer.new()
	var portrait_bg = StyleBoxFlat.new()
	portrait_bg.bg_color = Color("#12122a")
	portrait_bg.border_width_left = 1
	portrait_bg.border_width_right = 1
	portrait_bg.border_width_top = 1
	portrait_bg.border_width_bottom = 1
	portrait_bg.border_color = Color("#3a3a5a")
	portrait_bg.corner_radius_top_left = 3
	portrait_bg.corner_radius_top_right = 3
	portrait_bg.corner_radius_bottom_left = 3
	portrait_bg.corner_radius_bottom_right = 3
	portrait_container.add_theme_stylebox_override("panel", portrait_bg)
	portrait_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(portrait_container)

	var portrait_rect = TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(80, 96)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if Sprites.portraits.has("protagonist"):
		portrait_rect.texture = Sprites.portraits["protagonist"]
	portrait_container.add_child(portrait_rect)

	# Armor + Accessory row
	var equip_row = HBoxContainer.new()
	equip_row.add_theme_constant_override("separation", 12)
	equip_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(equip_row)

	equip_armor_slot = _create_equip_slot("🛡️", Constants.ITEM_TYPE_ARMOR)
	equip_row.add_child(equip_armor_slot)
	equip_accessory_slot = _create_equip_slot("📿", "accessory")
	equip_row.add_child(equip_accessory_slot)

	# Nameplate
	var nameplate = PanelContainer.new()
	nameplate.add_theme_stylebox_override("panel", _nameplate_style())
	nameplate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_child(nameplate)

	var name_lbl = Label.new()
	name_lbl.text = "ALEX"
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.modulate = Color("#e0e0e0")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nameplate.add_child(name_lbl)

	# ─────── RIGHT PANEL: Tabs + Grid + Details ───────
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 0)
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right_vbox)

	# Tab row
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 4)
	right_vbox.add_child(tabs_hbox)

	var filter_options = [
		{"id": "all", "label": " ALL "},
		{"id": Constants.ITEM_TYPE_WEAPON, "label": " ARMS "},
		{"id": Constants.ITEM_TYPE_POTION, "label": " POTIONS "}
	]

	for opt in filter_options:
		var tab = Button.new()
		tab.text = opt.label
		tab.add_theme_font_size_override("font_size", 10)
		tab.add_theme_stylebox_override("normal", _tab_normal_style())
		tab.add_theme_stylebox_override("hover", _tab_active_style())
		tab.custom_minimum_size = Vector2(60, 22)
		var fid = opt.id
		tab.pressed.connect(func(): set_filter(fid))
		tabs_hbox.add_child(tab)
		tab_btns[fid] = tab

	# Grid panel (parchment background)
	var grid_panel = PanelContainer.new()
	var grid_bg = StyleBoxFlat.new()
	grid_bg.bg_color = Color("#c4a878")
	grid_bg.border_width_left = 2
	grid_bg.border_width_right = 2
	grid_bg.border_width_top = 0
	grid_bg.border_width_bottom = 2
	grid_bg.border_color = Color("#8b6914")
	grid_bg.corner_radius_bottom_left = 3
	grid_bg.corner_radius_bottom_right = 3
	grid_panel.add_theme_stylebox_override("panel", grid_bg)
	grid_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(grid_panel)

	var grid_margin = MarginContainer.new()
	grid_margin.add_theme_constant_override("margin_left", 8)
	grid_margin.add_theme_constant_override("margin_top", 8)
	grid_margin.add_theme_constant_override("margin_right", 8)
	grid_margin.add_theme_constant_override("margin_bottom", 8)
	grid_panel.add_child(grid_margin)

	grid_container = GridContainer.new()
	grid_container.columns = 5
	grid_container.add_theme_constant_override("h_separation", 4)
	grid_container.add_theme_constant_override("v_separation", 4)
	grid_margin.add_child(grid_container)

	slot_btns = []
	for i in range(25):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(46, 46)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		btn.add_theme_stylebox_override("normal", _slot_normal_style())
		btn.add_theme_stylebox_override("hover", _slot_hover_style())
		btn.set_meta("normal_style", _slot_normal_style())

		var idx = i
		btn.pressed.connect(func(): on_slot_clicked(idx))
		grid_container.add_child(btn)
		slot_btns.append(btn)

	# ── Bottom Detail Panel ──
	var detail_panel = PanelContainer.new()
	var detail_bg = StyleBoxFlat.new()
	detail_bg.bg_color = Color("#5d3a1a")
	detail_bg.corner_radius_top_left = 0
	detail_bg.corner_radius_top_right = 0
	detail_bg.corner_radius_bottom_left = 3
	detail_bg.corner_radius_bottom_right = 3
	detail_bg.content_margin_left = 10
	detail_bg.content_margin_right = 10
	detail_bg.content_margin_top = 6
	detail_bg.content_margin_bottom = 6
	detail_panel.add_theme_stylebox_override("panel", detail_bg)
	main_vbox.add_child(detail_panel)

	var detail_hbox = HBoxContainer.new()
	detail_hbox.add_theme_constant_override("separation", 12)
	detail_panel.add_child(detail_hbox)

	details_content = VBoxContainer.new()
	details_content.add_theme_constant_override("separation", 2)
	details_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_content.visible = false
	detail_hbox.add_child(details_content)

	# Icon row
	var icon_row = HBoxContainer.new()
	icon_row.add_theme_constant_override("separation", 8)
	details_content.add_child(icon_row)

	detail_texture_rect = TextureRect.new()
	detail_texture_rect.custom_minimum_size = Vector2(32, 32)
	detail_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	detail_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail_texture_rect.visible = false
	icon_row.add_child(detail_texture_rect)

	detail_icon = Label.new()
	detail_icon.text = "⚔️"
	detail_icon.add_theme_font_size_override("font_size", 22)
	icon_row.add_child(detail_icon)

	var name_col = VBoxContainer.new()
	name_col.add_theme_constant_override("separation", 0)
	name_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon_row.add_child(name_col)

	detail_name = Label.new()
	detail_name.text = "Item Name"
	detail_name.add_theme_font_size_override("font_size", 12)
	detail_name.modulate = Color("#ffd700")
	name_col.add_child(detail_name)

	detail_type = Label.new()
	detail_type.text = "[ WEAPON ]"
	detail_type.add_theme_font_size_override("font_size", 9)
	detail_type.modulate = Color("#80deea")
	name_col.add_child(detail_type)

	detail_desc = Label.new()
	detail_desc.text = ""
	detail_desc.add_theme_font_size_override("font_size", 9)
	detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_desc.modulate = Color("#d4c8b0")
	details_content.add_child(detail_desc)

	detail_effect = Label.new()
	detail_effect.text = ""
	detail_effect.add_theme_font_size_override("font_size", 10)
	detail_effect.modulate = Color("#80e880")
	details_content.add_child(detail_effect)

	# Action button (right side of detail bar)
	action_btn = Button.new()
	action_btn.text = "EQUIP"
	action_btn.custom_minimum_size = Vector2(80, 32)
	action_btn.add_theme_font_size_override("font_size", 11)
	action_btn.add_theme_stylebox_override("normal", _action_btn_style())
	action_btn.modulate = Color("#f5f0e1")
	action_btn.pressed.connect(on_action_clicked)
	action_btn.visible = false
	detail_hbox.add_child(action_btn)

	# Default message when nothing selected
	var default_lbl = Label.new()
	default_lbl.text = "Select an item to view details"
	default_lbl.add_theme_font_size_override("font_size", 10)
	default_lbl.modulate = Color("#a09880")
	default_lbl.name = "default_hint"
	detail_hbox.add_child(default_lbl)

func _create_equip_slot(icon_text: String, slot_type: String) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(42, 42)
	btn.text = icon_text
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_stylebox_override("normal", _equip_slot_style())
	var hover = _equip_slot_style()
	hover.border_color = Color("#ffd700")
	btn.add_theme_stylebox_override("hover", hover)
	btn.tooltip_text = slot_type.capitalize() + " Slot"
	btn.pressed.connect(func(): _on_equip_slot_clicked(slot_type))
	return btn

func _on_equip_slot_clicked(slot_type: String):
	GameState.play_sfx("select")
	GameState.unequip_slot(slot_type)

# ─── Filter / Display Logic ──────────────────────────────────
func set_filter(f_id: String):
	GameState.play_sfx("select")
	current_filter = f_id
	selected_idx = -1
	render_inventory()

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	selected_idx = -1
	render_inventory()

func render_inventory():
	if not visible:
		return

	var player = GameState.get_player()
	gold_lbl.text = "💰 " + str(player.gold)

	# Update equipment slot displays
	_refresh_equip_slot(equip_weapon_slot, player.equipment.weapon, "⚔️")
	_refresh_equip_slot(equip_armor_slot, player.equipment.armor, "🛡️")
	_refresh_equip_slot(equip_accessory_slot, player.equipment.accessory, "📿")

	# Highlight active filter tab
	for f_id in tab_btns:
		var tab = tab_btns[f_id]
		if f_id == current_filter:
			tab.add_theme_stylebox_override("normal", _tab_active_style())
			tab.modulate = Color("#ffd700")
		else:
			tab.add_theme_stylebox_override("normal", _tab_normal_style())
			tab.modulate = Color("#e0d0b0")

	var raw_inv = GameState.get_inventory()
	var filtered_items = []
	for item in raw_inv:
		var itype = item.get("type", "")
		if current_filter == "all" or itype == current_filter:
			filtered_items.append(item)

	for i in range(slot_btns.size()):
		var btn = slot_btns[i]
		# Clear old quantity labels
		for child in btn.get_children():
			child.queue_free()

		if i < filtered_items.size():
			var item = filtered_items[i]
			btn.visible = true
			btn.disabled = false

			var item_id = item.get("id", "")
			var item_icon = item.get("icon", "📦")
			var item_qty = item.get("qty", 1)
			var item_equipped = item.get("equipped", false)

			if item_id != "" and Sprites.items.has(item_id):
				btn.icon = Sprites.items[item_id]
				btn.expand_icon = true
				btn.text = ""
			else:
				btn.icon = null
				btn.text = item_icon

			if item_qty > 1:
				var qty_label = Label.new()
				qty_label.add_theme_font_size_override("font_size", 9)
				qty_label.position = Vector2(30, 30)
				qty_label.modulate = Color("#ffffff")
				qty_label.text = str(item_qty)
				btn.add_child(qty_label)

			if i == selected_idx:
				btn.add_theme_stylebox_override("normal", _slot_selected_style())
			elif item_equipped:
				btn.add_theme_stylebox_override("normal", _slot_equipped_style())
			else:
				btn.add_theme_stylebox_override("normal", _slot_normal_style())

			btn.modulate = Color.WHITE
		else:
			btn.visible = true
			btn.disabled = true
			btn.icon = null
			btn.text = ""
			btn.add_theme_stylebox_override("normal", _slot_empty_style())
			btn.modulate = Color(0.6, 0.6, 0.6, 0.5)

	update_details(filtered_items)

func _refresh_equip_slot(btn: Button, equip_item, default_icon: String):
	if equip_item:
		var item_id = equip_item.get("id", "") if equip_item is Dictionary else equip_item.id
		var item_name = equip_item.get("name", "") if equip_item is Dictionary else equip_item.name
		if Sprites.items.has(item_id):
			btn.icon = Sprites.items[item_id]
			btn.expand_icon = true
			btn.text = ""
		else:
			btn.icon = null
			btn.text = default_icon
		btn.tooltip_text = item_name
		var active_style = _equip_slot_style()
		active_style.border_color = Color("#ffd700")
		active_style.bg_color = Color("#3a3050")
		btn.add_theme_stylebox_override("normal", active_style)
	else:
		btn.icon = null
		btn.text = default_icon
		btn.tooltip_text = "Empty"
		btn.add_theme_stylebox_override("normal", _equip_slot_style())

func on_slot_clicked(idx: int):
	GameState.play_sfx("select")
	selected_idx = idx
	render_inventory()

func update_details(filtered_items: Array):
	# Find default hint label
	var detail_hbox = details_content.get_parent()
	var default_hint = detail_hbox.get_node_or_null("default_hint")

	if selected_idx >= 0 and selected_idx < filtered_items.size():
		var item = filtered_items[selected_idx]
		details_content.visible = true
		action_btn.visible = true
		if default_hint:
			default_hint.visible = false

		var item_id = item.get("id", "")
		var item_icon = item.get("icon", "📦")
		var item_name = item.get("name", "Unknown Item")
		var item_type = item.get("type", "misc")
		var item_desc = item.get("desc", "")
		var item_effect = item.get("effect", "")
		var item_equipped = item.get("equipped", false)

		if item_id != "" and Sprites.items.has(item_id):
			detail_texture_rect.texture = Sprites.items[item_id]
			detail_texture_rect.visible = true
			detail_icon.visible = false
		else:
			detail_texture_rect.visible = false
			detail_icon.visible = true
			detail_icon.text = item_icon

		detail_name.text = item_name
		detail_type.text = "[ " + item_type.to_upper() + " ]"
		detail_desc.text = item_desc

		var skill_info = item.get("skill", null)
		if skill_info:
			detail_effect.text = item_effect + "  ⚡ " + str(skill_info.get("name", "")) + " (" + str(skill_info.get("mp_cost", 0)) + " MP)"
			detail_effect.modulate = Color("#ffd700")
		else:
			detail_effect.text = item_effect
			detail_effect.modulate = Color("#80e880")

		if item_type == Constants.ITEM_TYPE_POTION:
			action_btn.text = "Use"
			action_btn.disabled = false
		elif item_type in [Constants.ITEM_TYPE_WEAPON, Constants.ITEM_TYPE_ARMOR, "accessory"]:
			action_btn.text = "UNEQUIP" if item_equipped else "EQUIP"
			action_btn.visible = true
		else:
			action_btn.visible = false
	else:
		details_content.visible = false
		action_btn.visible = false
		if default_hint:
			default_hint.visible = true

func on_action_clicked():
	var raw_inv = GameState.get_inventory()
	var filtered_items = []
	for item in raw_inv:
		var itype = item.get("type", "")
		if current_filter == "all" or itype == current_filter:
			filtered_items.append(item)

	if selected_idx >= 0 and selected_idx < filtered_items.size():
		var item = filtered_items[selected_idx]
		var raw_idx = raw_inv.find(item)
		if raw_idx >= 0:
			var err = GameState.use_item(raw_idx)
			if err == "":
				selected_idx = -1
				render_inventory()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("inventory_closed")

func hide_screen():
	visible = false
