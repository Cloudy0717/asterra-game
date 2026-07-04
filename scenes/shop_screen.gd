extends CanvasLayer

signal shop_closed
signal item_purchased

var item_grid: GridContainer
var no_item_lbl: Label
var details_content: VBoxContainer

var detail_icon: Label
var detail_name: Label
var detail_desc: Label
var detail_price: Label
var gold_label: Label
var buy_btn: Button
var selected_idx = -1

var shop_items = []

func _ready():
	setup_ui()
	hide_screen()

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var click_catcher = TextureButton.new()
	click_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_catcher.pressed.connect(on_close)
	root.add_child(click_catcher)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 380)
	panel.position = Vector2(130, 110)
	root.add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color("#8d6e63")
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var header = HBoxContainer.new()
	vbox.add_child(header)

	var title = Label.new()
	title.text = "Weapon Shop"
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	gold_label = Label.new()
	gold_label.text = "Gold: 0"
	gold_label.add_theme_font_size_override("font_size", 12)
	gold_label.modulate = Color("#ffd700")
	header.add_child(gold_label)

	var close_btn = Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)

	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body)

	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(220, 240)
	var inner_style = StyleBoxFlat.new()
	inner_style.bg_color = Color(0.08, 0.08, 0.1, 0.8)
	inner_style.corner_radius_top_left = 4
	inner_style.corner_radius_top_right = 4
	inner_style.corner_radius_bottom_left = 4
	inner_style.corner_radius_bottom_right = 4
	left_panel.add_theme_stylebox_override("panel", inner_style)
	body.add_child(left_panel)

	var grid_margin = MarginContainer.new()
	grid_margin.add_theme_constant_override("margin_left", 10)
	grid_margin.add_theme_constant_override("margin_top", 10)
	grid_margin.add_theme_constant_override("margin_right", 10)
	grid_margin.add_theme_constant_override("margin_bottom", 10)
	left_panel.add_child(grid_margin)

	item_grid = GridContainer.new()
	item_grid.columns = 3
	item_grid.add_theme_constant_override("h_separation", 8)
	item_grid.add_theme_constant_override("v_separation", 8)
	grid_margin.add_child(item_grid)

	var right_panel = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var detail_style = StyleBoxFlat.new()
	detail_style.bg_color = Color(0.14, 0.14, 0.16, 0.9)
	detail_style.border_width_left = 1
	detail_style.border_width_right = 1
	detail_style.border_width_top = 1
	detail_style.border_width_bottom = 1
	detail_style.border_color = Color("#5d4037")
	detail_style.corner_radius_top_left = 6
	detail_style.corner_radius_top_right = 6
	detail_style.corner_radius_bottom_left = 6
	detail_style.corner_radius_bottom_right = 6
	right_panel.add_theme_stylebox_override("panel", detail_style)
	body.add_child(right_panel)

	var right_margin = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 12)
	right_margin.add_theme_constant_override("margin_top", 12)
	right_margin.add_theme_constant_override("margin_right", 12)
	right_margin.add_theme_constant_override("margin_bottom", 12)
	right_panel.add_child(right_margin)

	no_item_lbl = Label.new()
	no_item_lbl.text = "Select an item."
	no_item_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_item_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	no_item_lbl.add_theme_font_size_override("font_size", 11)
	right_margin.add_child(no_item_lbl)

	details_content = VBoxContainer.new()
	details_content.add_theme_constant_override("separation", 8)
	details_content.visible = false
	right_margin.add_child(details_content)

	detail_icon = Label.new()
	detail_icon.text = "⚔️"
	detail_icon.add_theme_font_size_override("font_size", 28)
	detail_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_content.add_child(detail_icon)

	detail_name = Label.new()
	detail_name.text = "Item"
	detail_name.add_theme_font_size_override("font_size", 13)
	detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_content.add_child(detail_name)

	detail_desc = Label.new()
	detail_desc.text = "Description"
	detail_desc.add_theme_font_size_override("font_size", 10)
	detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_content.add_child(detail_desc)

	detail_price = Label.new()
	detail_price.text = "Price: 0 Gold"
	detail_price.add_theme_font_size_override("font_size", 11)
	detail_price.modulate = Color("#ffd700")
	details_content.add_child(detail_price)

	buy_btn = Button.new()
	buy_btn.text = "Purchase"
	buy_btn.pressed.connect(on_buy_clicked)
	details_content.add_child(buy_btn)

func show_screen():
	GameState.play_sfx("open_menu")
	shop_items = get_shop_items()
	gold_label.text = "Gold: " + str(GameState.player.gold)
	selected_idx = -1
	visible = true
	render_items()

func get_shop_items() -> Array:
	return [
		{
			"id": "bronze_sword",
			"name": "Bronze Sword",
			"type": "weapon",
			"icon": "🗡️",
			"desc": "A solid bronze blade. Sharper and heavier than your rusty one.",
			"effect": "+8 Attack",
			"value": 8,
			"price": 80
		},
		{
			"id": "iron_sword",
			"name": "Iron Sword",
			"type": "weapon",
			"icon": "⚔️",
			"desc": "A well-forged iron longsword. Standard issue for D-rank mercenaries.",
			"effect": "+12 Attack",
			"value": 12,
			"price": 150
		},
		{
			"id": "leather_armor",
			"name": "Leather Armor",
			"type": "armor",
			"icon": "🧥",
			"desc": "Tough boiled leather chest piece. Offers decent protection.",
			"effect": "+6 Defense",
			"value": 6,
			"price": 100
		},
		{
			"id": "health_potion",
			"name": "Health Potion",
			"type": "potion",
			"icon": "🧪",
			"desc": "A standard health potion. Restores 50 HP.",
			"effect": "Heals 50 HP",
			"value": 50,
			"price": 25
		}
	]

func render_items():
	for child in item_grid.get_children():
		child.queue_free()

	for i in range(shop_items.size()):
		var slot_btn = Button.new()
		slot_btn.custom_minimum_size = Vector2(60, 60)

		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.12, 0.12, 0.15, 0.8)
		st.border_width_left = 1
		st.border_width_right = 1
		st.border_width_top = 1
		st.border_width_bottom = 1
		st.border_color = Color(0.3, 0.3, 0.3, 0.5)
		st.corner_radius_top_left = 4
		st.corner_radius_top_right = 4
		st.corner_radius_bottom_left = 4
		st.corner_radius_bottom_right = 4

		if i == selected_idx:
			st.border_color = Color("#ffd700")
			st.border_width_left = 2
			st.border_width_right = 2
			st.border_width_top = 2
			st.border_width_bottom = 2

		slot_btn.add_theme_stylebox_override("normal", st)
		slot_btn.add_theme_stylebox_override("hover", st)
		slot_btn.add_theme_stylebox_override("pressed", st)

		var item = shop_items[i]
		slot_btn.text = item.icon
		slot_btn.add_theme_font_size_override("font_size", 20)

		var idx = i
		slot_btn.pressed.connect(func(): on_slot_clicked(idx))
		item_grid.add_child(slot_btn)

	update_details()

func on_slot_clicked(idx: int):
	GameState.play_sfx("select")
	selected_idx = idx
	render_items()

func update_details():
	if selected_idx >= 0 and selected_idx < shop_items.size():
		var item = shop_items[selected_idx]
		no_item_lbl.visible = false
		details_content.visible = true

		detail_icon.text = item.icon
		detail_name.text = item.name
		detail_desc.text = item.desc + "\n[color=#26a69a]" + item.effect + "[/color]"
		detail_price.text = "Price: " + str(item.price) + " Gold"

		var can_afford = GameState.player.gold >= item.price
		buy_btn.disabled = not can_afford
		buy_btn.text = "Purchase" if can_afford else "Not enough Gold"
	else:
		no_item_lbl.visible = true
		details_content.visible = false

func on_buy_clicked():
	if selected_idx < 0 or selected_idx >= shop_items.size():
		return
	var item = shop_items[selected_idx]
	if GameState.player.gold < item.price:
		return

	GameState.player.gold -= item.price
	gold_label.text = "Gold: " + str(GameState.player.gold)

	var new_item = item.duplicate(true)
	new_item.erase("price")
	new_item.qty = 1
	new_item.equipped = false

	var stacked = false
	for inv_item in GameState.inventory:
		if inv_item.id == new_item.id and inv_item.type == "potion":
			inv_item.qty += 1
			stacked = true
			break

	if not stacked:
		GameState.inventory.append(new_item)

	GameState.play_sfx("equip")
	GameState.emit_signal("hud_updated")
	GameState.save_game()
	emit_signal("item_purchased")
	render_items()

	var steps = [
		{ "speaker": "System", "avatar": "🛒", "text": "Purchased [b]" + item.name + "[/b]! Check your Backpack [I] to equip it." }
	]
	GameState.emit_signal("show_dialogue", steps, null)

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("shop_closed")

func hide_screen():
	visible = false
