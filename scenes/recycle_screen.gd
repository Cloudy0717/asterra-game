extends CanvasLayer

signal recycle_closed

@onready var panel = $CenterContainer/PanelContainer
@onready var close_btn = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/CloseBtn
@onready var items_list = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/VBoxContainer/ItemsList
@onready var gold_lbl = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/GoldLabel

@onready var detail_panel = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel
@onready var detail_name = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/NameLabel
@onready var detail_desc = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/DescLabel
@onready var detail_price = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/PriceLabel
@onready var sell_btn = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/DetailPanel/VBoxContainer/SellBtn

var selected_item: Dictionary = {}
var selected_index: int = -1

# Appraisal prices & rep bonuses for recyclable items
const APPRAISAL_PRICES = {
	"wolf_pelt": {"gold": 12, "rep": 2},
	"goblin_ear": {"gold": 15, "rep": 3},
	"golem_core": {"gold": 150, "rep": 25},
	"vital_herb": {"gold": 8, "rep": 1},
	"bone_crown": {"gold": 100, "rep": 15}
}

func _ready():
	_apply_styles()
	close_btn.pressed.connect(on_close)
	sell_btn.pressed.connect(on_sell_pressed)
	hide_screen()

func _apply_styles():
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#4a148c")
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color("#7b1fa2")
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var detail_style = StyleBoxFlat.new()
	detail_style.bg_color = Color("#2a1b3d")
	detail_style.corner_radius_top_left = 4
	detail_style.corner_radius_top_right = 4
	detail_style.corner_radius_bottom_left = 4
	detail_style.corner_radius_bottom_right = 4
	detail_style.content_margin_left = 10
	detail_style.content_margin_right = 10
	detail_style.content_margin_top = 10
	detail_style.content_margin_bottom = 10
	detail_panel.add_theme_stylebox_override("panel", detail_style)

func render_ui():
	if not visible: return
	
	gold_lbl.text = "💰 " + str(GameState.get_player().gold)
	
	for child in items_list.get_children():
		items_list.remove_child(child)
		child.queue_free()
		
	var inventory = GameState.get_inventory()
	var has_recyclables = false
	
	for i in range(inventory.size()):
		var item = inventory[i]
		if APPRAISAL_PRICES.has(item.id):
			has_recyclables = true
			var btn = Button.new()
			btn.text = " " + item.name + " (x" + str(item.get("qty", 1)) + ")"
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.add_theme_color_override("font_color", Color("#e1bee7"))
			btn.add_theme_font_size_override("font_size", 12)
			
			var style = StyleBoxFlat.new()
			if selected_index == i:
				style.bg_color = Color("#7b1fa2")
			else:
				style.bg_color = Color("#38006b")
			btn.add_theme_stylebox_override("normal", style)
			
			btn.pressed.connect(_on_item_selected.bind(item, i))
			items_list.add_child(btn)
			
	if not has_recyclables:
		var empty_lbl = Label.new()
		empty_lbl.text = "No recyclable materials in inventory."
		empty_lbl.add_theme_font_size_override("font_size", 10)
		empty_lbl.modulate = Color("#b388ff")
		items_list.add_child(empty_lbl)
		
	_update_details()

func _on_item_selected(item: Dictionary, idx: int):
	GameState.play_sfx("select")
	selected_item = item
	selected_index = idx
	render_ui()

func _update_details():
	if not selected_item.is_empty() and APPRAISAL_PRICES.has(selected_item.id):
		detail_panel.visible = true
		var app = APPRAISAL_PRICES[selected_item.id]
		detail_name.text = selected_item.name
		detail_desc.text = selected_item.get("desc", "Raw adventurer material.")
		detail_price.text = "Appraisal Value:\n💰 +" + str(app.gold) + " Gold\n✨ +" + str(app.rep) + " Guild Rep"
		sell_btn.disabled = false
	else:
		detail_panel.visible = false

func on_sell_pressed():
	if selected_item.is_empty() or not APPRAISAL_PRICES.has(selected_item.id): return
	
	GameState.play_sfx("equip")
	var app = APPRAISAL_PRICES[selected_item.id]
	GameState.modify_gold(app.gold)
	GameState.get_player().reputation += app.rep
	
	# Consume 1 from inventory
	GameState.consume_item(selected_item.id, 1)
	
	selected_item = {}
	selected_index = -1
	render_ui()

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	selected_item = {}
	selected_index = -1
	render_ui()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("recycle_closed")

func hide_screen():
	visible = false
