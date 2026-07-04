extends CanvasLayer

signal inventory_closed

var grid_container: GridContainer
var no_item_lbl: Label
var details_content: VBoxContainer

var detail_icon: Label
var detail_name: Label
var detail_type: Label
var detail_desc: Label
var detail_effect: Label
var action_btn: Button

var selected_idx = -1

func _ready():
	setup_ui()
	hide_screen()
	GameState.hud_updated.connect(render_inventory)

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	var click_catcher = TextureButton.new()
	click_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_catcher.pressed.connect(on_close)
	root.add_child(click_catcher)
	
	# Modal Container
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 360)
	panel.position = Vector2(140, 120)
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
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	# Header
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var title = Label.new()
	title.text = "Backpack Inventory"
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)
	
	# Body Splitter
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 24)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body)
	
	# Left: 15 Grid slots (5 cols x 3 rows)
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(250, 240)
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
	
	grid_container = GridContainer.new()
	grid_container.columns = 5
	grid_container.add_theme_constant_override("h_separation", 8)
	grid_container.add_theme_constant_override("v_separation", 8)
	grid_margin.add_child(grid_container)
	
	# Right: Details panel
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
	
	# Details content catcher
	no_item_lbl = Label.new()
	no_item_lbl.text = "Select an item to view details."
	no_item_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_item_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	no_item_lbl.add_theme_font_size_override("font_size", 11)
	right_margin.add_child(no_item_lbl)
	
	details_content = VBoxContainer.new()
	details_content.add_theme_constant_override("separation", 10)
	details_content.visible = false
	right_margin.add_child(details_content)
	
	detail_icon = Label.new()
	detail_icon.text = "⚔️"
	detail_icon.add_theme_font_size_override("font_size", 32)
	detail_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_content.add_child(detail_icon)
	
	detail_name = Label.new()
	detail_name.text = "Rusty Sword"
	detail_name.add_theme_font_size_override("font_size", 13)
	detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_content.add_child(detail_name)
	
	detail_type = Label.new()
	detail_type.text = "weapon"
	detail_type.add_theme_font_size_override("font_size", 9)
	detail_type.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_type.modulate = Color("#e0b034")
	details_content.add_child(detail_type)
	
	detail_desc = Label.new()
	detail_desc.text = "A worn-out rusty sword."
	detail_desc.add_theme_font_size_override("font_size", 10)
	detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_content.add_child(detail_desc)
	
	detail_effect = Label.new()
	detail_effect.text = "Effect: +5 Attack"
	detail_effect.add_theme_font_size_override("font_size", 10)
	detail_effect.modulate = Color("#26a69a")
	details_content.add_child(detail_effect)
	
	action_btn = Button.new()
	action_btn.text = "Equip"
	action_btn.pressed.connect(on_action_clicked)
	details_content.add_child(action_btn)

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	selected_idx = -1
	render_inventory()

func render_inventory():
	if not visible:
		return
		
	# Clear grid
	for child in grid_container.get_children():
		child.queue_free()
		
	# Build 15 slots
	for i in range(15):
		var slot_btn = Button.new()
		slot_btn.custom_minimum_size = Vector2(40, 40)
		
		# Define slot styles
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.12, 0.15, 0.8)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.3, 0.3, 0.3, 0.5)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		
		if i == selected_idx:
			style.border_color = Color("#8d6e63")
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			
		slot_btn.add_theme_stylebox_override("normal", style)
		slot_btn.add_theme_stylebox_override("hover", style)
		slot_btn.add_theme_stylebox_override("pressed", style)
		
		# Add item contents
		if i < GameState.inventory.size():
			var item = GameState.inventory[i]
			slot_btn.text = item.icon
			slot_btn.add_theme_font_size_override("font_size", 18)
			
			# Quantity badge if > 1
			if item.qty > 1:
				var qty_lbl = Label.new()
				qty_lbl.text = str(item.qty)
				qty_lbl.add_theme_font_size_override("font_size", 9)
				qty_lbl.position = Vector2(24, 24)
				slot_btn.add_child(qty_lbl)
				
			# Equipped glow
			if item.equipped:
				style.bg_color = Color(0.3, 0.25, 0.1, 0.4)
				style.border_color = Color("#ffd700")
		
		# Connect press event
		var idx = i
		slot_btn.pressed.connect(func(): on_slot_clicked(idx))
		grid_container.add_child(slot_btn)
		
	# Update selected details
	update_details()

func on_slot_clicked(idx: int):
	GameState.play_sfx("select")
	selected_idx = idx
	# Redraw slots (triggers selected_idx check)
	render_inventory()

func update_details():
	if selected_idx >= 0 and selected_idx < GameState.inventory.size():
		var item = GameState.inventory[selected_idx]
		no_item_lbl.visible = false
		details_content.visible = true
		
		detail_icon.text = item.icon
		detail_name.text = item.name
		detail_type.text = item.type
		detail_desc.text = item.desc
		detail_effect.text = "Effect: " + item.effect
		
		if item.type == "potion":
			action_btn.text = "Consume Potion"
		else:
			action_btn.text = "Unequip Item" if item.equipped else "Equip Item"
	else:
		no_item_lbl.visible = true
		details_content.visible = false

func on_action_clicked():
	if selected_idx >= 0 and selected_idx < GameState.inventory.size():
		var err = GameState.use_item(selected_idx)
		if err != "":
			# Print error or notify player
			print("[Inventory Error] ", err)
		else:
			# If potion is fully consumed and removed, reset selection
			if selected_idx >= GameState.inventory.size():
				selected_idx = -1
			render_inventory()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("inventory_closed")

func hide_screen():
	visible = false
