extends CanvasLayer

signal party_board_closed

@onready var panel = $CenterContainer/PanelContainer
@onready var close_btn = $CenterContainer/PanelContainer/VBoxContainer/HeaderHBox/CloseBtn
@onready var recruit_list = $CenterContainer/PanelContainer/VBoxContainer/ContentHBox/VBoxContainer/RecruitList
@onready var register_btn = $CenterContainer/PanelContainer/VBoxContainer/BottomHBox/RegisterBtn

var mock_notices = [
	{"title": "🛡️ Frontline Tank Needed", "team": "Team Crimson", "role": "Guardian / Paladin", "rank": "D-Rank", "desc": "Seeking a sturdy frontline tank for Stone Claw Mine exploration."},
	{"title": "🌿 Seeking Healer for Patrol", "team": "Wolf Hunters", "role": "Priest / Cleric", "rank": "E-Rank", "desc": "Looking for a healer with Vital Herb spells for forest patrols."},
	{"title": "🔥 Mage Wanted for Golem Raid", "team": "Asterra Vanguard", "role": "Elementalist", "rank": "C-Rank", "desc": "High-level squad recruiting a fire mage to burst down Golem boss."}
]

func _ready():
	_apply_styles()
	close_btn.pressed.connect(on_close)
	register_btn.pressed.connect(on_register_pressed)
	hide_screen()
	render_ui()

func _apply_styles():
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#2a3b4c")
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color("#1565c0")
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)

func render_ui():
	if not visible: return
	
	for child in recruit_list.get_children():
		recruit_list.remove_child(child)
		child.queue_free()
		
	for notice in mock_notices:
		var hbox = HBoxContainer.new()
		
		var lbl = Label.new()
		lbl.text = notice.title + "\n  Team: " + notice.team + "  Role: " + notice.role + " (" + notice.rank + ")"
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.modulate = Color("#81d4fa")
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)
		
		var apply_btn = Button.new()
		apply_btn.text = "Apply"
		apply_btn.add_theme_font_size_override("font_size", 10)
		apply_btn.pressed.connect(func():
			GameState.play_sfx("select")
			var steps = [
				{ "speaker": "System", "avatar": "📜", "text": "Applied to [b]" + notice.team + "[/b]!\nStatus: Awaiting Leader Approval." }
			]
			GameState.emit_signal("show_dialogue", steps, null)
		)
		hbox.add_child(apply_btn)
		
		recruit_list.add_child(hbox)

func on_register_pressed():
	GameState.play_sfx("select")
	var steps = [
		{ "speaker": "System", "avatar": "⚔️", "text": "Registered [b]" + GameState.get_player().name + "[/b] on the Adventurer Recruitment Board!\nOther party leaders can now invite you." }
	]
	GameState.emit_signal("show_dialogue", steps, null)

func show_screen():
	GameState.play_sfx("open_menu")
	visible = true
	render_ui()

func on_close():
	GameState.play_sfx("close_menu")
	hide_screen()
	emit_signal("party_board_closed")

func hide_screen():
	visible = false
