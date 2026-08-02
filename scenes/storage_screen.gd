extends CanvasLayer

signal storage_closed

@onready var panel = $CenterContainer/PanelContainer
@onready var close_btn = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/CloseBtn
@onready var inv_list = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/InvVBox/InvList
@onready var storage_list = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/StorageVBox/StorageList

func _ready():
	_apply_styles()
	close_btn.pressed.connect(on_close)
	hide_screen()

func _apply_styles():
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#3e2723")
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color("#8d6e63")
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)

func render_ui():
	if not visible: return
	
	# Clear inventory list
	for child in inv_list.get_children():
		inv_list.remove_child(child)
		child.queue_free()
		
	# Clear storage list
	for child in storage_list.get_children():
		storage_list.remove_child(child)
		child.queue_free()
		
	var inventory = GameState.get_inventory()
	for i in range(inventory.size()):
		var item = inventory[i]
		var btn = Button.new()
		btn.text = " " + item.name + (" (Eq)" if item.get("equipped", false) else "")
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(_on_inv_item_pressed.bind(i))
		inv_list.add_child(btn)
		
	var storage = GameState.get_storage()
	for i in range(storage.size()):
		var item = storage[i]
		var btn = Button.new()
		btn.text = " " + item.name + " (x" + str(item.get("qty", 1)) + ")"
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 10)
		btn.add_theme_color_override("font_color", Color("#ffd54f"))
		btn.pressed.connect(_on_storage_item_pressed.bind(i))
		storage_list.add_child(btn)

func _on_inv_item_pressed(idx: int):
	if GameState.deposit_to_storage(idx):
		GameState.play_sfx("equip")
		render_ui()

func _on_storage_item_pressed(idx: int):
	if GameState.withdraw_from_storage(idx):
		GameState.play_sfx("equip")
		render_ui()

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	render_ui()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("storage_closed")

func hide_screen():
	visible = false
