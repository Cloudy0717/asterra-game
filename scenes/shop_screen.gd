extends CanvasLayer

signal shop_closed
signal item_purchased

var item_grid: GridContainer
var sell_grid: GridContainer

var details_content: VBoxContainer
var detail_icon: Label
var detail_texture_rect: TextureRect
var detail_name: Label
var detail_desc: Label
var detail_price: Label
var detail_effect: Label

var gold_label: Label
var action_btn: Button
var selected_idx = -1
var slot_btns = []
var sell_mode = false

var buy_tab_btn: Button
var sell_tab_btn: Button

var shop_items = []

func _ready():
	setup_ui()
	hide_screen()

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

func _action_btn_style(is_buy: bool) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#4a7a30") if is_buy else Color("#b71c1c")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color("#6b9a40") if is_buy else Color("#e53935")
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
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
	panel.custom_minimum_size = Vector2(600, 390)
	panel.position = Vector2(100, 100)
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
	title.text = "⛺ MERCHANT"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color("#f5f0e1")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_hbox.add_child(title)

	gold_label = Label.new()
	gold_label.text = "💰 0"
	gold_label.add_theme_font_size_override("font_size", 12)
	gold_label.modulate = Color("#ffd700")
	hdr_hbox.add_child(gold_label)

	var close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)

	# ── Body: Left (Tabs + Grid) + Right (Portrait/Details) ──
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(body)

	# ── Left: Tabs & Grid ──
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 0)
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(left_vbox)

	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 4)
	left_vbox.add_child(tabs_hbox)

	buy_tab_btn = Button.new()
	buy_tab_btn.text = " BUY "
	buy_tab_btn.add_theme_font_size_override("font_size", 10)
	buy_tab_btn.custom_minimum_size = Vector2(80, 22)
	buy_tab_btn.pressed.connect(func():
		sell_mode = false
		_update_tab_style()
		render_items()
	)
	tabs_hbox.add_child(buy_tab_btn)

	sell_tab_btn = Button.new()
	sell_tab_btn.text = " SELL "
	sell_tab_btn.add_theme_font_size_override("font_size", 10)
	sell_tab_btn.custom_minimum_size = Vector2(80, 22)
	sell_tab_btn.pressed.connect(func():
		sell_mode = true
		_update_tab_style()
		_render_sell_items()
	)
	tabs_hbox.add_child(sell_tab_btn)

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
	left_vbox.add_child(grid_panel)

	var grid_margin = MarginContainer.new()
	grid_margin.add_theme_constant_override("margin_left", 8)
	grid_margin.add_theme_constant_override("margin_top", 8)
	grid_margin.add_theme_constant_override("margin_right", 8)
	grid_margin.add_theme_constant_override("margin_bottom", 8)
	grid_panel.add_child(grid_margin)

	var grid_scroll = ScrollContainer.new()
	grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	grid_margin.add_child(grid_scroll)

	var grid_stack = MarginContainer.new()
	grid_scroll.add_child(grid_stack)

	item_grid = GridContainer.new()
	item_grid.columns = 4
	item_grid.add_theme_constant_override("h_separation", 4)
	item_grid.add_theme_constant_override("v_separation", 4)
	grid_stack.add_child(item_grid)

	sell_grid = GridContainer.new()
	sell_grid.columns = 4
	sell_grid.add_theme_constant_override("h_separation", 4)
	sell_grid.add_theme_constant_override("v_separation", 4)
	sell_grid.visible = false
	grid_stack.add_child(sell_grid)

	# ── Right: NPC Portrait & Details ──
	var right_panel = PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(200, 0)
	right_panel.add_theme_stylebox_override("panel", _dark_panel_style())
	body.add_child(right_panel)

	var right_margin = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 12)
	right_margin.add_theme_constant_override("margin_top", 12)
	right_margin.add_theme_constant_override("margin_right", 12)
	right_margin.add_theme_constant_override("margin_bottom", 12)
	right_panel.add_child(right_margin)

	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	right_margin.add_child(right_vbox)

	var portrait_container = PanelContainer.new()
	var portrait_bg = StyleBoxFlat.new()
	portrait_bg.bg_color = Color("#12122a")
	portrait_bg.border_width_left = 1
	portrait_bg.border_width_right = 1
	portrait_bg.border_width_top = 1
	portrait_bg.border_width_bottom = 1
	portrait_bg.border_color = Color("#3a3a5a")
	portrait_container.add_theme_stylebox_override("panel", portrait_bg)
	portrait_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	right_vbox.add_child(portrait_container)

	var portrait_rect = TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(80, 96)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Placeholder for merchant portrait, maybe use goblin or generic for now
	if Sprites.portraits.has("protagonist"):
		portrait_rect.texture = Sprites.portraits["protagonist"]
	portrait_container.add_child(portrait_rect)

	var npc_name = Label.new()
	npc_name.text = "MERCHANT"
	npc_name.add_theme_font_size_override("font_size", 10)
	npc_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	npc_name.modulate = Color("#e0e0e0")
	right_vbox.add_child(npc_name)

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
	detail_icon.text = "📦"
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

	detail_price = Label.new()
	detail_price.text = "Price: 0"
	detail_price.add_theme_font_size_override("font_size", 10)
	detail_price.modulate = Color("#ffd700")
	name_col.add_child(detail_price)

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

	action_btn = Button.new()
	action_btn.text = "BUY"
	action_btn.custom_minimum_size = Vector2(80, 32)
	action_btn.add_theme_font_size_override("font_size", 11)
	action_btn.add_theme_stylebox_override("normal", _action_btn_style(true))
	action_btn.modulate = Color("#f5f0e1")
	action_btn.pressed.connect(on_action_clicked)
	action_btn.visible = false
	detail_hbox.add_child(action_btn)

	var default_lbl = Label.new()
	default_lbl.text = "Select an item to view details"
	default_lbl.add_theme_font_size_override("font_size", 10)
	default_lbl.modulate = Color("#a09880")
	default_lbl.name = "default_hint"
	detail_hbox.add_child(default_lbl)

func load_shop_items(items_to_sell: Array):
	shop_items = items_to_sell

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	sell_mode = false
	selected_idx = -1
	_update_tab_style()
	render_items()

func _update_tab_style():
	if sell_mode:
		sell_tab_btn.add_theme_stylebox_override("normal", _tab_active_style())
		sell_tab_btn.modulate = Color("#ffd700")
		buy_tab_btn.add_theme_stylebox_override("normal", _tab_normal_style())
		buy_tab_btn.modulate = Color("#e0d0b0")
	else:
		buy_tab_btn.add_theme_stylebox_override("normal", _tab_active_style())
		buy_tab_btn.modulate = Color("#ffd700")
		sell_tab_btn.add_theme_stylebox_override("normal", _tab_normal_style())
		sell_tab_btn.modulate = Color("#e0d0b0")

func render_items():
	item_grid.visible = true
	sell_grid.visible = false
	gold_label.text = "💰 " + str(GameState.get_player().gold)
	
	for child in item_grid.get_children():
		child.queue_free()
	
	slot_btns = []
	for i in range(max(16, shop_items.size())):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(46, 46)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.add_theme_stylebox_override("normal", _slot_normal_style())
		btn.add_theme_stylebox_override("hover", _slot_hover_style())

		if i < shop_items.size():
			var item = shop_items[i]
			var item_id = item.get("id", "")
			if item_id != "" and Sprites.items.has(item_id):
				btn.icon = Sprites.items[item_id]
				btn.expand_icon = true
			else:
				btn.text = item.get("icon", "📦")
			
			var price = item.get("value", 10)
			var price_lbl = Label.new()
			price_lbl.text = str(price)
			price_lbl.add_theme_font_size_override("font_size", 9)
			price_lbl.position = Vector2(28, 32)
			price_lbl.modulate = Color("#ffd700")
			btn.add_child(price_lbl)
			
			if i == selected_idx:
				btn.add_theme_stylebox_override("normal", _slot_selected_style())
			
			var idx = i
			btn.pressed.connect(func(): on_slot_clicked(idx))
		else:
			btn.add_theme_stylebox_override("normal", _slot_empty_style())
			btn.disabled = true
			
		item_grid.add_child(btn)
		slot_btns.append(btn)
		
	update_details()

func _render_sell_items():
	item_grid.visible = false
	sell_grid.visible = true
	gold_label.text = "💰 " + str(GameState.get_player().gold)
	
	for child in sell_grid.get_children():
		child.queue_free()
		
	var inventory = GameState.get_inventory()
	slot_btns = []
	
	for i in range(max(16, inventory.size())):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(46, 46)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.add_theme_stylebox_override("normal", _slot_normal_style())
		btn.add_theme_stylebox_override("hover", _slot_hover_style())

		if i < inventory.size():
			var item = inventory[i]
			var item_id = item.get("id", "")
			if item_id != "" and Sprites.items.has(item_id):
				btn.icon = Sprites.items[item_id]
				btn.expand_icon = true
			else:
				btn.text = item.get("icon", "📦")
			
			var sell_price = int(item.get("value", 10) / 2)
			var price_lbl = Label.new()
			price_lbl.text = str(sell_price)
			price_lbl.add_theme_font_size_override("font_size", 9)
			price_lbl.position = Vector2(28, 32)
			price_lbl.modulate = Color("#ffd700")
			btn.add_child(price_lbl)
			
			var qty = item.get("qty", 1)
			if qty > 1:
				var qty_label = Label.new()
				qty_label.add_theme_font_size_override("font_size", 9)
				qty_label.position = Vector2(2, 2)
				qty_label.modulate = Color("#ffffff")
				qty_label.text = "x" + str(qty)
				btn.add_child(qty_label)
			
			if i == selected_idx:
				btn.add_theme_stylebox_override("normal", _slot_selected_style())
			
			if item.get("equipped", false):
				btn.modulate = Color(0.5, 0.5, 0.5)
			
			var idx = i
			btn.pressed.connect(func(): on_slot_clicked(idx))
		else:
			btn.add_theme_stylebox_override("normal", _slot_empty_style())
			btn.disabled = true
			
		sell_grid.add_child(btn)
		slot_btns.append(btn)
		
	update_details()

func on_slot_clicked(idx: int):
	GameState.play_sfx("select")
	selected_idx = idx
	if sell_mode:
		_render_sell_items()
	else:
		render_items()

func update_details():
	var detail_hbox = details_content.get_parent()
	var default_hint = detail_hbox.get_node_or_null("default_hint")
	
	var items_arr = GameState.get_inventory() if sell_mode else shop_items
	
	if selected_idx >= 0 and selected_idx < items_arr.size():
		var item = items_arr[selected_idx]
		details_content.visible = true
		action_btn.visible = true
		if default_hint:
			default_hint.visible = false
			
		var item_id = item.get("id", "")
		var item_icon = item.get("icon", "📦")
		var item_name = item.get("name", "Unknown")
		var item_desc = item.get("desc", "")
		var item_effect = item.get("effect", "")
		var value = item.get("value", 10)
		var is_equipped = item.get("equipped", false)
		
		if item_id != "" and Sprites.items.has(item_id):
			detail_texture_rect.texture = Sprites.items[item_id]
			detail_texture_rect.visible = true
			detail_icon.visible = false
		else:
			detail_texture_rect.visible = false
			detail_icon.visible = true
			detail_icon.text = item_icon
			
		detail_name.text = item_name
		detail_desc.text = item_desc
		detail_effect.text = item_effect
		
		if sell_mode:
			var sell_price = int(value / 2)
			detail_price.text = "Sell for: " + str(sell_price) + " Gold"
			action_btn.text = "SELL"
			action_btn.add_theme_stylebox_override("normal", _action_btn_style(false))
			
			if is_equipped:
				action_btn.disabled = true
				detail_price.text += " (Equipped)"
			else:
				action_btn.disabled = false
		else:
			detail_price.text = "Price: " + str(value) + " Gold"
			action_btn.text = "BUY"
			action_btn.add_theme_stylebox_override("normal", _action_btn_style(true))
			
			if GameState.get_player().gold >= value:
				action_btn.disabled = false
			else:
				action_btn.disabled = true
				detail_price.text += " (Not enough gold)"
	else:
		details_content.visible = false
		action_btn.visible = false
		if default_hint:
			default_hint.visible = true

func on_action_clicked():
	var items_arr = GameState.get_inventory() if sell_mode else shop_items
	
	if selected_idx >= 0 and selected_idx < items_arr.size():
		var item = items_arr[selected_idx]
		var player = GameState.get_player()
		
		if sell_mode:
			var sell_price = int(item.get("value", 10) / 2)
			player.gold += sell_price
			GameState.remove_item(selected_idx)
			GameState.play_sfx("buy")
			selected_idx = -1
			_render_sell_items()
			emit_signal("item_purchased")
		else:
			var price = item.get("value", 10)
			if player.gold >= price:
				player.gold -= price
				GameState.add_item(item)
				GameState.play_sfx("buy")
				render_items()
				emit_signal("item_purchased")
			else:
				GameState.play_sfx("error")

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("shop_closed")

func hide_screen():
	visible = false
