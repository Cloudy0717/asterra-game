extends CanvasLayer

signal status_closed

var name_lbl: Label
var age_lbl: Label
var rank_lbl: Label
var level_lbl: Label
var exp_lbl: Label
var hp_lbl: Label
var mp_lbl: Label
var atk_lbl: Label
var def_lbl: Label
var rep_lbl: Label

var equip_weapon_btn: Button
var equip_armor_btn: Button
var equip_accessory_btn: Button

func _ready():
	setup_ui()
	hide_screen()
	GameState.hud_updated.connect(render_status)

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	var click_catcher = TextureButton.new()
	click_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_catcher.pressed.connect(on_close)
	root.add_child(click_catcher)
	
	# Modal card
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 360)
	panel.position = Vector2(150, 120)
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
	title.text = "Hero Character Sheet"
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(on_close)
	header.add_child(close_btn)
	
	# Body (HBox splitter: Left is avatar/equipment, Right is stats/lore)
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 24)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body)
	
	# Left Side
	var left_vbox = VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(200, 0)
	body.add_child(left_vbox)
	
	var char_info = HBoxContainer.new()
	left_vbox.add_child(char_info)
	var avatar = Label.new()
	avatar.text = "🛡️"
	avatar.add_theme_font_size_override("font_size", 32)
	char_info.add_child(avatar)
	
	var name_vbox = VBoxContainer.new()
	char_info.add_child(name_vbox)
	name_lbl = Label.new()
	name_lbl.text = "Alex"
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_vbox.add_child(name_lbl)
	age_lbl = Label.new()
	age_lbl.text = "Age: 19"
	age_lbl.add_theme_font_size_override("font_size", 10)
	name_vbox.add_child(age_lbl)
	rank_lbl = Label.new()
	rank_lbl.text = "E Rank"
	rank_lbl.add_theme_font_size_override("font_size", 11)
	rank_lbl.modulate = Color("#ffd700")
	name_vbox.add_child(rank_lbl)
	
	# Equipment
	var equip_title = Label.new()
	equip_title.text = "\nEquipment (click to unequip)"
	equip_title.add_theme_font_size_override("font_size", 11)
	left_vbox.add_child(equip_title)
	
	equip_weapon_btn = Button.new()
	equip_weapon_btn.text = "Weapon: Empty"
	equip_weapon_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	equip_weapon_btn.pressed.connect(func(): GameState.unequip_slot("weapon"))
	left_vbox.add_child(equip_weapon_btn)
	
	equip_armor_btn = Button.new()
	equip_armor_btn.text = "Armor: Empty"
	equip_armor_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	equip_armor_btn.pressed.connect(func(): GameState.unequip_slot("armor"))
	left_vbox.add_child(equip_armor_btn)
	
	equip_accessory_btn = Button.new()
	equip_accessory_btn.text = "Accessory: Empty"
	equip_accessory_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	equip_accessory_btn.pressed.connect(func(): GameState.unequip_slot("accessory"))
	left_vbox.add_child(equip_accessory_btn)
	
	# Right Side
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right_vbox)
	
	var attr_title = Label.new()
	attr_title.text = "Attributes"
	attr_title.add_theme_font_size_override("font_size", 12)
	right_vbox.add_child(attr_title)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	right_vbox.add_child(grid)
	
	# Setup attr fields
	level_lbl = add_grid_row(grid, "Level")
	exp_lbl = add_grid_row(grid, "EXP")
	hp_lbl = add_grid_row(grid, "HP")
	mp_lbl = add_grid_row(grid, "MP")
	atk_lbl = add_grid_row(grid, "ATK")
	def_lbl = add_grid_row(grid, "DEF")
	rep_lbl = add_grid_row(grid, "Reputation")
	
	var lore_title = Label.new()
	lore_title.text = "\nBio & Goal"
	lore_title.add_theme_font_size_override("font_size", 12)
	right_vbox.add_child(lore_title)
	
	var lore_text = Label.new()
	lore_text.text = "A young rookie adventurer from a destroyed village in Asterra continent. Striving to survive, protect his sister Lina, earn money, and ultimately climb the mercenary ranks to become the \"World's Strongest Mercenary\"."
	lore_text.add_theme_font_size_override("font_size", 10)
	lore_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_text.modulate = Color("#b0bec5")
	right_vbox.add_child(lore_text)

func add_grid_row(grid: GridContainer, label_text: String) -> Label:
	var lbl = Label.new()
	lbl.text = label_text + ":"
	lbl.add_theme_font_size_override("font_size", 11)
	grid.add_child(lbl)
	
	var val = Label.new()
	val.text = "0"
	val.add_theme_font_size_override("font_size", 11)
	grid.add_child(val)
	return val

func render_status():
	if not visible:
		return
		
	var p = GameState.player
	name_lbl.text = p.name
	rank_lbl.text = p.rank
	
	equip_weapon_btn.text = "Weapon: " + (p.equipment.weapon.name if p.equipment.weapon else "Empty")
	equip_armor_btn.text = "Armor: " + (p.equipment.armor.name if p.equipment.armor else "Empty")
	equip_accessory_btn.text = "Accessory: " + (p.equipment.accessory.name if p.equipment.accessory else "Empty")
	
	level_lbl.text = str(p.level)
	exp_lbl.text = str(p.exp) + " / " + str(p.max_exp)
	hp_lbl.text = str(int(p.hp)) + " / " + str(int(p.max_hp))
	mp_lbl.text = str(int(p.mp)) + " / " + str(int(p.max_mp))
	
	var weapon_bonus = p.equipment.weapon.value if p.equipment.weapon else 0
	var armor_bonus = p.equipment.armor.value if p.equipment.armor else 0
	var acc_bonus = p.equipment.accessory.value if p.equipment.accessory else 0
	
	atk_lbl.text = str(p.base_atk) + " (+" + str(weapon_bonus) + ")"
	def_lbl.text = str(p.base_def) + " (+" + str(armor_bonus + acc_bonus) + ")"
	rep_lbl.text = str(p.reputation)

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
