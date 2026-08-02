extends CanvasLayer

signal forge_closed

@onready var panel = $CenterContainer/PanelContainer
@onready var close_btn = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/CloseBtn
@onready var content_hbox = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox
@onready var recipes_list = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/VBoxContainer/RecipesList
@onready var gold_lbl = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/GoldLabel
@onready var material_lbl = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/MaterialLabel

@onready var detail_panel = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel
@onready var detail_icon = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/HBoxContainer/IconTexture
@onready var detail_name = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var detail_type = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/HBoxContainer/VBoxContainer/TypeLabel
@onready var detail_desc = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/DescLabel
@onready var detail_reqs = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/ReqsLabel
@onready var action_btn = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/ActionBtn

var selected_recipe = null
var recipes = []

func _ready():
	_apply_styles()
	close_btn.pressed.connect(on_close)
	action_btn.pressed.connect(on_action_pressed)
	hide_screen()
	setup_recipes()

func _apply_styles():
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#d4b896")
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color("#6b4226")
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var detail_style = StyleBoxFlat.new()
	detail_style.bg_color = Color("#2a2a3a")
	detail_style.corner_radius_top_left = 4
	detail_style.corner_radius_top_right = 4
	detail_style.corner_radius_bottom_left = 4
	detail_style.corner_radius_bottom_right = 4
	detail_style.content_margin_left = 10
	detail_style.content_margin_right = 10
	detail_style.content_margin_top = 10
	detail_style.content_margin_bottom = 10
	detail_panel.add_theme_stylebox_override("panel", detail_style)

func setup_recipes():
	recipes = RecipeDatabase.get_all_recipes()

func render_ui():
	if not visible:
		return
	
	gold_lbl.text = "💰 " + str(GameState.get_player().gold)
	
	var copper = GameState.get_item_count("copper_ore")
	var iron = GameState.get_item_count("iron_ore")
	var core = GameState.get_item_count("golem_core")
	material_lbl.text = "⛏️ Cu: " + str(copper) + "  Fe: " + str(iron) + "  🔮 Core: " + str(core)
	
	for child in recipes_list.get_children():
		child.queue_free()
		
	for i in range(recipes.size()):
		var r = recipes[i]
		var btn = Button.new()
		btn.text = " " + r.name
		if Sprites.items.has(r.icon_id):
			btn.icon = Sprites.items[r.icon_id]
			btn.expand_icon = true
			btn.custom_minimum_size = Vector2(0, 32)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_color_override("font_color", Color("#4e342e"))
		btn.add_theme_font_size_override("font_size", 12)
		
		# Selected style
		var style = StyleBoxFlat.new()
		if selected_recipe == r:
			style.bg_color = Color("#b8a060")
			style.border_width_left = 2
			style.border_color = Color("#8a6a3a")
		else:
			style.bg_color = Color("#d4b896")
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(_on_recipe_selected.bind(r))
		recipes_list.add_child(btn)
		
	_update_details()

func _on_recipe_selected(r):
	GameState.play_sfx("select")
	selected_recipe = r
	render_ui()

func _update_details():
	if selected_recipe:
		detail_panel.visible = true
		detail_name.text = selected_recipe.name
		detail_type.text = "[ " + selected_recipe.type.to_upper() + " ]"
		detail_desc.text = selected_recipe.desc + "\n\nStats: " + selected_recipe.base_item.get("effect", "")
		
		if Sprites.items.has(selected_recipe.icon_id):
			detail_icon.texture = Sprites.items[selected_recipe.icon_id]
		
		var req_text = "Requires:\n💰 Gold: " + str(selected_recipe.req_gold) + "\n"
		for item_id in selected_recipe.req_items:
			req_text += "- " + item_id.capitalize().replace("_", " ") + " x" + str(selected_recipe.req_items[item_id]) + "\n"
		
		detail_reqs.text = req_text
		
		var can_craft = GameState.get_player().gold >= selected_recipe.req_gold
		for item_id in selected_recipe.req_items:
			if GameState.get_item_count(item_id) < selected_recipe.req_items[item_id]:
				can_craft = false
				break
				
		action_btn.disabled = not can_craft
	else:
		detail_panel.visible = false

func on_action_pressed():
	if not selected_recipe: return
	
	GameState.play_sfx("equip")
	
	# Deduct gold
	GameState.modify_gold(-selected_recipe.req_gold)
	
	# Deduct items
	for item_id in selected_recipe.req_items:
		GameState.consume_item(item_id, selected_recipe.req_items[item_id])
					
	# Give item
	GameState.add_item(selected_recipe.base_item.duplicate(true))
	
	render_ui()

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	selected_recipe = null
	render_ui()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("forge_closed")

func hide_screen():
	visible = false
