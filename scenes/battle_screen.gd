extends CanvasLayer

signal battle_ended(won: bool, rewards: Dictionary)

# ---- UI references ----
var player_hp_bar: ProgressBar
var player_mp_bar: ProgressBar
var player_hp_label: Label
var player_mp_label: Label
var enemy_sprite_label: Label
var enemy_name_label: Label
var enemy_hp_bar: ProgressBar
var enemy_hp_label: Label
var battle_log: RichTextLabel
var action_buttons: HBoxContainer
var turn_label: Label

# ---- State ----
var current_enemy_node = null
var enemy_data: Dictionary = {}
var battle_active = false

# ---- Setup ----
func _ready():
	layer = 15
	setup_ui()
	visible = false

# ========================= UI CONSTRUCTION =========================
func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Dark semi-transparent bg
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.78)
	root.add_child(bg)

	# Main panel — centred 640x460
	var panel = PanelContainer.new()
	panel.position = Vector2(80, 70)
	panel.custom_minimum_size = Vector2(640, 460)
	root.add_child(panel)

	var ps = StyleBoxFlat.new()
	ps.bg_color        = Color(0.1, 0.1, 0.12, 0.97)
	ps.border_width_left   = 2
	ps.border_width_right  = 2
	ps.border_width_top    = 2
	ps.border_width_bottom = 2
	ps.border_color = Color("#8d6e63")
	ps.corner_radius_top_left     = 12
	ps.corner_radius_top_right    = 12
	ps.corner_radius_bottom_left  = 12
	ps.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", ps)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   20)
	margin.add_theme_constant_override("margin_top",    16)
	margin.add_theme_constant_override("margin_right",  20)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# ----- Header row -----
	var header = HBoxContainer.new()
	vbox.add_child(header)

	var title = Label.new()
	title.text = "⚔️  BATTLE"
	title.add_theme_font_size_override("font_size", 18)
	title.modulate = Color("#ffeb3b")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	turn_label = Label.new()
	turn_label.text = "Your Turn"
	turn_label.add_theme_font_size_override("font_size", 11)
	turn_label.modulate = Color("#81d4fa")
	header.add_child(turn_label)

	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# ----- Stats row -----
	var stats_row = HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 10)
	stats_row.custom_minimum_size = Vector2(0, 110)
	vbox.add_child(stats_row)

	# Player card
	var pc = _make_stat_card()
	stats_row.add_child(pc)
	var pv = pc.get_child(0).get_child(0)

	var p_title = Label.new()
	p_title.text = "🛡️  " + GameState.player.name
	p_title.add_theme_font_size_override("font_size", 13)
	p_title.modulate = Color("#aed581")
	pv.add_child(p_title)

	var phbox = HBoxContainer.new()
	pv.add_child(phbox)
	var phl = Label.new(); phl.text = "HP "; phl.add_theme_font_size_override("font_size", 10)
	phbox.add_child(phl)
	player_hp_bar = _make_bar(Color("#b71c1c"))
	phbox.add_child(player_hp_bar)
	player_hp_label = Label.new(); player_hp_label.add_theme_font_size_override("font_size", 9)
	phbox.add_child(player_hp_label)

	var pmbox = HBoxContainer.new()
	pv.add_child(pmbox)
	var pml2 = Label.new(); pml2.text = "MP "; pml2.add_theme_font_size_override("font_size", 10)
	pmbox.add_child(pml2)
	player_mp_bar = _make_bar(Color("#0d47a1"))
	pmbox.add_child(player_mp_bar)
	player_mp_label = Label.new(); player_mp_label.add_theme_font_size_override("font_size", 9)
	pmbox.add_child(player_mp_label)

	# VS
	var vs = Label.new()
	vs.text = "VS"
	vs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	vs.add_theme_font_size_override("font_size", 22)
	vs.modulate = Color("#ff7043")
	vs.custom_minimum_size = Vector2(50, 0)
	stats_row.add_child(vs)

	# Enemy card
	var ec = _make_stat_card()
	stats_row.add_child(ec)
	var ev = ec.get_child(0).get_child(0)

	enemy_sprite_label = Label.new()
	enemy_sprite_label.text = "👾"
	enemy_sprite_label.add_theme_font_size_override("font_size", 28)
	ev.add_child(enemy_sprite_label)

	enemy_name_label = Label.new()
	enemy_name_label.text = "Enemy"
	enemy_name_label.add_theme_font_size_override("font_size", 13)
	enemy_name_label.modulate = Color("#ef9a9a")
	ev.add_child(enemy_name_label)

	var ehbox = HBoxContainer.new()
	ev.add_child(ehbox)
	var ehl = Label.new(); ehl.text = "HP "; ehl.add_theme_font_size_override("font_size", 10)
	ehbox.add_child(ehl)
	enemy_hp_bar = _make_bar(Color("#c62828"))
	ehbox.add_child(enemy_hp_bar)
	enemy_hp_label = Label.new(); enemy_hp_label.add_theme_font_size_override("font_size", 9)
	ehbox.add_child(enemy_hp_label)

	# ----- Battle Log -----
	battle_log = RichTextLabel.new()
	battle_log.bbcode_enabled   = true
	battle_log.scroll_following = true
	battle_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	battle_log.custom_minimum_size = Vector2(0, 160)
	var log_style = StyleBoxFlat.new()
	log_style.bg_color      = Color(0.06, 0.06, 0.08, 0.9)
	log_style.border_width_left   = 1
	log_style.border_width_right  = 1
	log_style.border_width_top    = 1
	log_style.border_width_bottom = 1
	log_style.border_color  = Color(0.3, 0.3, 0.3, 0.4)
	log_style.corner_radius_top_left     = 4
	log_style.corner_radius_top_right    = 4
	log_style.corner_radius_bottom_left  = 4
	log_style.corner_radius_bottom_right = 4
	battle_log.add_theme_stylebox_override("normal", log_style)
	vbox.add_child(battle_log)

	# ----- Action Buttons -----
	action_buttons = HBoxContainer.new()
	action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	action_buttons.add_theme_constant_override("separation", 14)
	vbox.add_child(action_buttons)

	_add_action_btn("⚔️  Attack",   player_attack)
	_add_action_btn("🧪  Use Item", player_use_item)
	_add_action_btn("💨  Run",      player_run)

func _make_stat_card() -> PanelContainer:
	var pc = PanelContainer.new()
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color      = Color(0.08, 0.08, 0.10, 0.85)
	s.border_width_left   = 1
	s.border_width_right  = 1
	s.border_width_top    = 1
	s.border_width_bottom = 1
	s.border_color  = Color(0.3, 0.3, 0.3, 0.45)
	s.corner_radius_top_left     = 6
	s.corner_radius_top_right    = 6
	s.corner_radius_bottom_left  = 6
	s.corner_radius_bottom_right = 6
	pc.add_theme_stylebox_override("panel", s)
	var m = MarginContainer.new()
	m.add_theme_constant_override("margin_left",   10)
	m.add_theme_constant_override("margin_top",     8)
	m.add_theme_constant_override("margin_right",  10)
	m.add_theme_constant_override("margin_bottom",  8)
	pc.add_child(m)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	m.add_child(v)
	return pc

func _make_bar(fill_color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 13)
	var fs = StyleBoxFlat.new()
	fs.bg_color = fill_color
	bar.add_theme_stylebox_override("fill", fs)
	return bar

func _add_action_btn(label: String, callback: Callable):
	var btn = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(130, 42)
	btn.pressed.connect(callback)
	action_buttons.add_child(btn)

# ========================= BATTLE LOGIC =========================
func start_battle(enemy_node, config: Dictionary):
	current_enemy_node = enemy_node
	enemy_data = config.duplicate(true)
	battle_active = true

	# Refresh player card
	_refresh_player_ui()

	enemy_sprite_label.text = enemy_data.get("icon", "👾")
	enemy_name_label.text   = enemy_data.get("name", "Enemy")
	enemy_hp_bar.max_value  = enemy_data.get("max_hp", 20)
	enemy_hp_bar.value      = enemy_data.get("hp", 20)
	_refresh_enemy_ui()

	battle_log.clear()
	_log("[color=#ffd700]⚔️  A [b]" + enemy_data.get("name", "Enemy") + "[/b] appears![/color]")
	_log("[color=#81d4fa]Your turn — choose an action.[/color]")

	turn_label.text = "Your Turn"
	_set_btns_disabled(false)
	visible = true

func _refresh_player_ui():
	var p = GameState.player
	player_hp_bar.max_value = p.max_hp
	player_hp_bar.value     = p.hp
	player_hp_label.text    = str(int(p.hp)) + "/" + str(int(p.max_hp))
	player_mp_bar.max_value = p.max_mp
	player_mp_bar.value     = p.mp
	player_mp_label.text    = str(int(p.mp)) + "/" + str(int(p.max_mp))

func _refresh_enemy_ui():
	enemy_hp_bar.value   = max(0, enemy_data.get("hp", 0))
	enemy_hp_label.text  = str(int(max(0, enemy_data.get("hp", 0)))) + "/" + str(int(enemy_data.get("max_hp", 0)))

func _log(text: String):
	battle_log.append_text(text + "\n")

func _set_btns_disabled(disabled: bool):
	for btn in action_buttons.get_children():
		if btn is Button:
			btn.disabled = disabled

# ----- Player Actions -----
func player_attack():
	if not battle_active: return
	_set_btns_disabled(true)

	var dmg = GameState.get_total_atk() + randi_range(-2, 3)
	dmg = max(1, dmg)
	enemy_data.hp -= dmg
	_refresh_enemy_ui()
	_log("[color=#ff5252]You strike! Dealt [b]" + str(dmg) + "[/b] damage to [b]" + enemy_data.name + "[/b].[/color]")

	GameState.play_sfx("hit")

	if enemy_data.hp <= 0:
		await get_tree().create_timer(0.5).timeout
		_end_battle(true)
		return

	await get_tree().create_timer(0.7).timeout
	_enemy_turn()

func player_use_item():
	if not battle_active: return

	# Find first usable potion
	var potion = null
	for item in GameState.inventory:
		if item.type == "potion" and item.qty > 0:
			potion = item
			break

	if not potion:
		_log("[color=#90a4ae]You have no usable items![/color]")
		_set_btns_disabled(false)
		return

	_set_btns_disabled(true)
	var healed = min(potion.value, GameState.player.max_hp - GameState.player.hp)
	GameState.player.hp = min(GameState.player.max_hp, GameState.player.hp + potion.value)
	potion.qty -= 1
	if potion.qty <= 0:
		GameState.inventory.erase(potion)
	_refresh_player_ui()
	_log("[color=#80cbc4]Used [b]" + potion.name + "[/b] — restored [b]" + str(healed) + "[/b] HP.[/color]")

	await get_tree().create_timer(0.8).timeout
	_enemy_turn()

func player_run():
	if not battle_active: return
	_set_btns_disabled(true)

	if randf() < 0.45:
		_log("[color=#ce93d8]You fled the battle successfully![/color]")
		await get_tree().create_timer(0.5).timeout
		_end_battle(false)
	else:
		_log("[color=#ef9a9a]Failed to escape![/color]")
		await get_tree().create_timer(0.6).timeout
		_enemy_turn()

# ----- Enemy Turn -----
func _enemy_turn():
	if not battle_active: return
	turn_label.text = "Enemy Turn"

	var e_atk  = enemy_data.get("attack", 5)
	var p_def  = GameState.get_total_def()
	var dmg    = max(1, e_atk - p_def + randi_range(-1, 2))
	GameState.player.hp = max(0.0, GameState.player.hp - dmg)
	_refresh_player_ui()
	_log("[color=#ffcc80][b]" + enemy_data.get("name", "Enemy") + "[/b] attacks! You took [b]" + str(dmg) + "[/b] damage.[/color]")
	GameState.play_sfx("hit")

	if GameState.player.hp <= 0:
		await get_tree().create_timer(0.8).timeout
		_log("[color=#ef5350]You were defeated… Lina heals you back.[/color]")
		await get_tree().create_timer(1.0).timeout
		GameState.player.hp = GameState.player.max_hp * 0.3
		_end_battle(false)
		return

	turn_label.text = "Your Turn"
	_log("[color=#81d4fa]Your turn — choose an action.[/color]")
	_set_btns_disabled(false)

# ----- End Battle -----
func _end_battle(won: bool):
	battle_active = false
	var rewards: Dictionary = {}

	if won:
		rewards["exp"]  = enemy_data.get("exp_reward", 0)
		rewards["gold"] = enemy_data.get("gold_reward", 0)
		rewards["loot"] = enemy_data.get("loot", [])
		rewards["type"] = enemy_data.get("type", "")

		GameState.player.gold += rewards.gold
		GameState.add_exp(rewards.exp)

		# Grant loot items
		for drop in rewards.loot:
			_grant_loot_item(drop)

		var loot_names = []
		for drop in rewards.loot:
			loot_names.append(drop.get("name", "?"))

		var loot_str = ", ".join(loot_names) if loot_names.size() > 0 else "none"
		_log("[color=#ffd700]✨ Victory! EXP+" + str(rewards.exp) +
			"  Gold+" + str(rewards.gold) +
			"  Drops: " + loot_str + "[/color]")

		await get_tree().create_timer(1.8).timeout
	else:
		await get_tree().create_timer(0.4).timeout

	GameState.emit_signal("hud_updated")
	GameState.save_game()

	# Remove enemy from world if won
	if won and is_instance_valid(current_enemy_node):
		current_enemy_node.queue_free()

	visible = false
	emit_signal("battle_ended", won, rewards)

func _grant_loot_item(drop: Dictionary):
	var drop_id = drop.get("id", "")
	# Try to stack
	for item in GameState.inventory:
		if item.id == drop_id:
			item.qty += drop.get("qty", 1)
			return
	# Otherwise add new entry
	match drop_id:
		"wolf_pelt":
			GameState.inventory.append({
				"id": "wolf_pelt",
				"name": "Wolf Pelt",
				"type": "material",
				"icon": "🐺",
				"desc": "A coarse grey pelt from a wild wolf. Can be sold at the guild for a good price.",
				"effect": "Sell value: 15 Gold",
				"value": 15,
				"qty": drop.get("qty", 1),
				"equipped": false
			})
		"goblin_ear":
			GameState.inventory.append({
				"id": "goblin_ear",
				"name": "Goblin Ear",
				"type": "material",
				"icon": "👂",
				"desc": "A grotesque trophy from a goblin. Proof of your triumph at Stone Claw Pass.",
				"effect": "Sell value: 8 Gold",
				"value": 8,
				"qty": drop.get("qty", 1),
				"equipped": false
			})
		_:
			pass
