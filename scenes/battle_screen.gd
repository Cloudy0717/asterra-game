extends CanvasLayer

signal battle_ended(won: bool, rewards: Dictionary)
signal player_defeated

# ---- UI references ----
var player_hp_bar: ProgressBar
var player_mp_bar: ProgressBar
var player_hp_label: Label
var player_mp_label: Label
var enemy_sprite_rect: TextureRect     # NEW: pixel art monster
var enemy_sprite_label: Label          # FALLBACK: emoji label
var enemy_name_label: Label
var enemy_hp_bar: ProgressBar
var enemy_hp_label: Label
var battle_log: RichTextLabel
var action_buttons: HBoxContainer
var turn_label: Label
var player_card: PanelContainer
var enemy_card: PanelContainer
var player_buff_label: Label
var enemy_buff_label: Label
var skills_panel_ref: PanelContainer
var main_panel: PanelContainer          # for screen shake

# ---- State ----
var current_enemy_node = null
var enemy_data: Dictionary = {}
var battle_active = false
var _defending = false

# ---- Setup ----
func _ready():
	layer = 15
	setup_ui()
	visible = false

func _tween_bar(bar: ProgressBar, target_value: float, duration: float = 0.3):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "value", target_value, duration)

# ========================= UI CONSTRUCTION =========================
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

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.78)
	root.add_child(bg)

	main_panel = PanelContainer.new()
	main_panel.position = Vector2(80, 70)
	main_panel.custom_minimum_size = Vector2(640, 460)
	main_panel.add_theme_stylebox_override("panel", _wood_frame_style())
	root.add_child(main_panel)

	var outer_margin = MarginContainer.new()
	outer_margin.add_theme_constant_override("margin_left", 12)
	outer_margin.add_theme_constant_override("margin_top", 10)
	outer_margin.add_theme_constant_override("margin_right", 12)
	outer_margin.add_theme_constant_override("margin_bottom", 10)
	main_panel.add_child(outer_margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	outer_margin.add_child(vbox)

	# ----- Header row -----
	var header_bg = PanelContainer.new()
	var hdr_style = StyleBoxFlat.new()
	hdr_style.bg_color = Color("#5d3a1a")
	hdr_style.corner_radius_top_left = 3
	hdr_style.corner_radius_top_right = 3
	hdr_style.corner_radius_bottom_left = 3
	hdr_style.corner_radius_bottom_right = 3
	header_bg.add_theme_stylebox_override("panel", hdr_style)
	vbox.add_child(header_bg)
	
	var hdr_margin = MarginContainer.new()
	hdr_margin.add_theme_constant_override("margin_left", 12)
	hdr_margin.add_theme_constant_override("margin_right", 12)
	hdr_margin.add_theme_constant_override("margin_top", 6)
	hdr_margin.add_theme_constant_override("margin_bottom", 6)
	header_bg.add_child(hdr_margin)
	
	var header = HBoxContainer.new()
	hdr_margin.add_child(header)

	var title = Label.new()
	title.text = "⚔️ BATTLE"
	title.add_theme_font_size_override("font_size", 16)
	title.modulate = Color("#f5f0e1")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	turn_label = Label.new()
	turn_label.text = "Your Turn"
	turn_label.add_theme_font_size_override("font_size", 12)
	turn_label.modulate = Color("#ffd700")
	header.add_child(turn_label)

	# ----- Stats row -----
	var stats_row = HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 10)
	stats_row.custom_minimum_size = Vector2(0, 130)
	vbox.add_child(stats_row)

	# Player card
	player_card = _make_stat_card()
	stats_row.add_child(player_card)
	var pv = player_card.get_child(0).get_child(0)

	var p_title = Label.new()
	p_title.text = "🛡️  " + GameState.get_player().name
	p_title.add_theme_font_size_override("font_size", 13)
	p_title.modulate = Color("#aed581")
	pv.add_child(p_title)

	var phbox = HBoxContainer.new()
	pv.add_child(phbox)
	var phl = Label.new(); phl.text = "HP "; phl.add_theme_font_size_override("font_size", 10)
	phl.modulate = Color("#ef9a9a")
	phbox.add_child(phl)
	player_hp_bar = _make_bar(Color("#e53935"))
	phbox.add_child(player_hp_bar)
	player_hp_label = Label.new(); player_hp_label.add_theme_font_size_override("font_size", 9)
	phbox.add_child(player_hp_label)

	var pmbox = HBoxContainer.new()
	pv.add_child(pmbox)
	var pml2 = Label.new(); pml2.text = "MP "; pml2.add_theme_font_size_override("font_size", 10)
	pml2.modulate = Color("#64b5f6")
	pmbox.add_child(pml2)
	player_mp_bar = _make_bar(Color("#1e88e5"))
	pmbox.add_child(player_mp_bar)
	player_mp_label = Label.new(); player_mp_label.add_theme_font_size_override("font_size", 9)
	pmbox.add_child(player_mp_label)

	player_buff_label = Label.new()
	player_buff_label.add_theme_font_size_override("font_size", 9)
	player_buff_label.modulate = Color("#81d4fa")
	pv.add_child(player_buff_label)

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
	enemy_card = _make_stat_card()
	stats_row.add_child(enemy_card)
	var ev = enemy_card.get_child(0).get_child(0)

	# Monster pixel art texture (primary)
	enemy_sprite_rect = TextureRect.new()
	enemy_sprite_rect.custom_minimum_size = Vector2(64, 64)
	enemy_sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	enemy_sprite_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ev.add_child(enemy_sprite_rect)

	# Emoji fallback label (hidden when texture available)
	enemy_sprite_label = Label.new()
	enemy_sprite_label.text = "👾"
	enemy_sprite_label.add_theme_font_size_override("font_size", 28)
	enemy_sprite_label.visible = false
	ev.add_child(enemy_sprite_label)

	enemy_name_label = Label.new()
	enemy_name_label.text = "Enemy"
	enemy_name_label.add_theme_font_size_override("font_size", 13)
	enemy_name_label.modulate = Color("#ef9a9a")
	ev.add_child(enemy_name_label)

	var ehbox = HBoxContainer.new()
	ev.add_child(ehbox)
	var ehl = Label.new(); ehl.text = "HP "; ehl.add_theme_font_size_override("font_size", 10)
	ehl.modulate = Color("#ef9a9a")
	ehbox.add_child(ehl)
	enemy_hp_bar = _make_bar(Color("#c62828"))
	ehbox.add_child(enemy_hp_bar)
	enemy_hp_label = Label.new(); enemy_hp_label.add_theme_font_size_override("font_size", 9)
	ehbox.add_child(enemy_hp_label)

	enemy_buff_label = Label.new()
	enemy_buff_label.add_theme_font_size_override("font_size", 9)
	enemy_buff_label.modulate = Color("#ffee58")
	ev.add_child(enemy_buff_label)

	# ----- Battle Log -----
	battle_log = RichTextLabel.new()
	battle_log.bbcode_enabled   = true
	battle_log.scroll_following = true
	battle_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	battle_log.custom_minimum_size = Vector2(0, 140)
	var log_style = StyleBoxFlat.new()
	log_style.bg_color = Color("#2a2a3a")
	log_style.border_width_left = 2
	log_style.border_width_right = 2
	log_style.border_width_top = 2
	log_style.border_width_bottom = 2
	log_style.border_color = Color("#4a4a5a")
	log_style.corner_radius_top_left = 4
	log_style.corner_radius_top_right = 4
	log_style.corner_radius_bottom_left = 4
	log_style.corner_radius_bottom_right = 4
	log_style.content_margin_left = 10
	log_style.content_margin_top = 8
	log_style.content_margin_right = 10
	log_style.content_margin_bottom = 8
	battle_log.add_theme_stylebox_override("normal", log_style)
	vbox.add_child(battle_log)

	# ----- Action Buttons -----
	action_buttons = HBoxContainer.new()
	action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	action_buttons.add_theme_constant_override("separation", 10)
	vbox.add_child(action_buttons)

	_add_action_btn("⚔️ Attack",   player_attack)
	_add_action_btn("💠 Skills",   player_skills)
	_add_action_btn("🧪 Item",     player_use_item)
	_add_action_btn("🛡️ Defend",   player_defend)
	_add_action_btn("💨 Run",      player_run)

	# ----- Skills Panel (hidden by default) -----
	skills_panel_ref = PanelContainer.new()
	skills_panel_ref.visible = false
	skills_panel_ref.custom_minimum_size = Vector2(0, 100)
	var sp_style = StyleBoxFlat.new()
	sp_style.bg_color = Color(0.08, 0.08, 0.10, 0.9)
	sp_style.border_width_left = 1
	sp_style.border_width_right = 1
	sp_style.border_width_top = 1
	sp_style.border_width_bottom = 1
	sp_style.border_color = Color("#5d3a1a")
	sp_style.corner_radius_top_left = 4
	sp_style.corner_radius_top_right = 4
	sp_style.corner_radius_bottom_left = 4
	sp_style.corner_radius_bottom_right = 4
	skills_panel_ref.add_theme_stylebox_override("panel", sp_style)
	vbox.add_child(skills_panel_ref)

	var skills_vbox = VBoxContainer.new()
	skills_panel_ref.add_child(skills_vbox)

func _make_stat_card() -> PanelContainer:
	var pc = PanelContainer.new()
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pc.add_theme_stylebox_override("panel", _dark_panel_style())
	var m = MarginContainer.new()
	m.add_theme_constant_override("margin_left",   12)
	m.add_theme_constant_override("margin_top",     10)
	m.add_theme_constant_override("margin_right",  12)
	m.add_theme_constant_override("margin_bottom",  10)
	pc.add_child(m)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	m.add_child(v)
	return pc

func _make_bar(fill_color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	var bg_s = StyleBoxFlat.new()
	bg_s.bg_color = Color("#2a2a3a")
	bg_s.border_width_left = 1
	bg_s.border_width_right = 1
	bg_s.border_width_top = 1
	bg_s.border_width_bottom = 1
	bg_s.border_color = Color("#4a4a5a")
	bg_s.corner_radius_top_left = 2
	bg_s.corner_radius_top_right = 2
	bg_s.corner_radius_bottom_left = 2
	bg_s.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg_s)
	var fs = StyleBoxFlat.new()
	fs.bg_color = fill_color
	fs.corner_radius_top_left = 1
	fs.corner_radius_top_right = 1
	fs.corner_radius_bottom_left = 1
	fs.corner_radius_bottom_right = 1
	bar.add_theme_stylebox_override("fill", fs)
	return bar

func _add_action_btn(label: String, callback: Callable):
	var btn = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(110, 38)
	# Action button style
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#4a7a30") if "Item" not in label and "Run" not in label else Color("#b71c1c") if "Run" in label else Color("#d4b896")
	if "Item" in label:
		btn_normal.bg_color = Color("#b09870")
	btn_normal.border_width_left = 2
	btn_normal.border_width_right = 2
	btn_normal.border_width_top = 2
	btn_normal.border_width_bottom = 2
	btn_normal.border_color = Color("#6b9a40") if "Item" not in label and "Run" not in label else Color("#e53935") if "Run" in label else Color("#8b6914")
	if "Item" in label:
		btn_normal.border_color = Color("#8b6914")
	btn_normal.corner_radius_top_left = 3
	btn_normal.corner_radius_top_right = 3
	btn_normal.corner_radius_bottom_left = 3
	btn_normal.corner_radius_bottom_right = 3
	btn.add_theme_stylebox_override("normal", btn_normal)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = btn_hover.bg_color.lightened(0.2)
	btn_hover.border_color = Color("#ffd700")
	btn.add_theme_stylebox_override("hover", btn_hover)

	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = btn_pressed.bg_color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", btn_pressed)

	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func():
		GameState.play_sfx("click")
		callback.call()
	)
	action_buttons.add_child(btn)

# ========================= MONSTER SPRITE HELPER =========================
func _set_enemy_sprite(enemy_type: String, icon_emoji: String):
	var sprite_key = ""
	match enemy_type:
		"slime": sprite_key = "slime_battle"
		"wolf":  sprite_key = "wolf_battle"
		"goblin": sprite_key = "goblin_battle"
		"goblin_chief": sprite_key = "goblin_chief_battle"

	if enemy_type == "goblin_chief":
		enemy_sprite_rect.custom_minimum_size = Vector2(96, 96)
	else:
		enemy_sprite_rect.custom_minimum_size = Vector2(64, 64)

	if sprite_key != "" and Sprites.monsters.has(sprite_key):
		enemy_sprite_rect.texture = Sprites.monsters[sprite_key]
		enemy_sprite_rect.visible = true
		enemy_sprite_label.visible = false
	else:
		enemy_sprite_rect.visible = false
		enemy_sprite_label.visible = true
		enemy_sprite_label.text = icon_emoji

# ========================= BATTLE LOGIC =========================
func start_battle(enemy_node, config: Dictionary):
	current_enemy_node = enemy_node
	enemy_data = config.duplicate(true)
	if not enemy_data.has("buffs"):
		enemy_data["buffs"] = {}
	
	if not GameState.get_player().has("buffs"):
		GameState.get_player()["buffs"] = {}
	else:
		GameState.get_player()["buffs"].clear()
		
	battle_active = true
	_defending = false

	# Refresh player card
	_refresh_player_ui()

	# Set enemy sprite (pixel art or emoji fallback)
	_set_enemy_sprite(enemy_data.get("type", ""), enemy_data.get("icon", "👾"))
	enemy_name_label.text   = enemy_data.get("name", "Enemy")
	enemy_hp_bar.max_value  = enemy_data.get("max_hp", 20)
	_tween_bar(enemy_hp_bar, enemy_data.get("hp", 20))
	_refresh_enemy_ui()

	battle_log.clear()
	_log("[color=#ffd700]⚔️  A [b]" + enemy_data.get("name", "Enemy") + "[/b] appears![/color]")
	_log("[color=#81d4fa]Your turn — choose an action.[/color]")

	turn_label.text = "Your Turn"
	_set_btns_disabled(false)
	visible = true

func _refresh_player_ui():
	var p = GameState.get_player()
	player_hp_bar.max_value = p.max_hp
	_tween_bar(player_hp_bar, p.hp)
	player_hp_label.text    = str(int(p.hp)) + "/" + str(int(p.max_hp))
	player_mp_bar.max_value = p.max_mp
	_tween_bar(player_mp_bar, p.mp)
	player_mp_label.text    = str(int(p.mp)) + "/" + str(int(p.max_mp))
	var buffs_text = ""
	if _defending:
		buffs_text += "🛡️ DEF +50% "
	var p_buffs = GameState.get_player().get("buffs", {})
	if p_buffs.has("poison") and p_buffs["poison"] > 0:
		buffs_text += "☠️ POISON "
	if p_buffs.has("shield") and p_buffs["shield"] > 0:
		buffs_text += "🛡️ SHIELD "
		
	if player_buff_label:
		player_buff_label.text = buffs_text.strip_edges()

func _refresh_enemy_ui():
	_tween_bar(enemy_hp_bar, max(0, enemy_data.get("hp", 0)))
	enemy_hp_label.text  = str(int(max(0, enemy_data.get("hp", 0)))) + "/" + str(int(enemy_data.get("max_hp", 0)))
	
	var buffs_text = ""
	if GameState.get_enemy_stun_turns() > 0:
		buffs_text += "💫 STUNNED "
	var e_buffs = enemy_data.get("buffs", {})
	if e_buffs.has("poison") and e_buffs["poison"] > 0:
		buffs_text += "☠️ POISON "
	if e_buffs.has("weaken") and e_buffs["weaken"] > 0:
		buffs_text += "⚔️ WEAKEN "
		
	if enemy_buff_label:
		enemy_buff_label.text = buffs_text.strip_edges()

func _log(text: String):
	battle_log.append_text(text + "\n")

func _set_btns_disabled(disabled: bool):
	for btn in action_buttons.get_children():
		if btn is Button:
			btn.disabled = disabled

func _process_buffs(is_player: bool) -> bool:
	# Process DoT and turn-based effects
	var target = GameState.get_player() if is_player else enemy_data
	var buffs = target.get("buffs", {})
	var card = player_card if is_player else enemy_card
	var target_name = target.get("name", "Player" if is_player else "Enemy")
	var is_dead = false
	
	var active_keys = buffs.keys()
	for key in active_keys:
		if buffs[key] > 0:
			if key == "poison":
				var dmg = max(1, int(target.get("max_hp", 20) * 0.05))
				if is_player:
					GameState.modify_hp(-dmg)
				else:
					target["hp"] -= dmg
				
				_log("[color=#aed581]☠️ Poison ticks for [b]" + str(dmg) + "[/b] damage on [b]" + target_name + "[/b]![/color]")
				FloatingText.spawn(str(dmg), card.global_position + Vector2(card.size.x * 0.5, 0), FloatingText.Type.DAMAGE)
				BattleVFX.hit_flash(card)
				
				if target.get("hp", 0) <= 0:
					is_dead = true
					
			buffs[key] -= 1
			if buffs[key] <= 0:
				buffs.erase(key)
				_log("[color=#90a4ae]" + target_name + " recovered from " + key + "![/color]")
				
	if is_player:
		_refresh_player_ui()
	else:
		_refresh_enemy_ui()
		
	return is_dead

# ----- Player Actions -----
func player_attack():
	if not battle_active: return
	_set_btns_disabled(true)

	# Crit check (10% chance)
	var is_crit = randf() < 0.10
	var dmg = GameState.get_total_atk() + randi_range(-2, 3)
	if is_crit:
		dmg = int(dmg * 1.5)
	dmg = max(1, dmg)
	enemy_data.hp -= dmg
	_refresh_enemy_ui()

	if is_crit:
		_log("[color=#ffd700]💥 CRITICAL HIT! You strike for [b]" + str(dmg) + "[/b] damage![/color]")
		FloatingText.spawn("CRIT! " + str(dmg), enemy_card.global_position + Vector2(enemy_card.size.x * 0.5, 0), FloatingText.Type.CRIT)
		BattleVFX.screen_shake(main_panel, 8.0, 0.35)
	else:
		_log("[color=#ff5252]You strike! Dealt [b]" + str(dmg) + "[/b] damage to [b]" + enemy_data.name + "[/b].[/color]")
		FloatingText.spawn(str(dmg), enemy_card.global_position + Vector2(enemy_card.size.x * 0.5, 0), FloatingText.Type.DAMAGE)
		BattleVFX.screen_shake(main_panel, 4.0, 0.25)

	# VFX
	BattleVFX.slash_arc(main_panel, enemy_card, false)
	BattleVFX.hit_flash(enemy_card)
	GameState.play_sfx("hit")

	if enemy_data.hp <= 0:
		await get_tree().create_timer(0.5).timeout
		_end_battle(true)
		return

	await get_tree().create_timer(0.7).timeout
	_enemy_turn()

func player_use_item():
	if not battle_active: return

	var potion = null
	for item in GameState.get_inventory():
		if item.get("type", "") == "potion" and item.get("qty", 0) > 0:
			potion = item
			break

	if not potion:
		_log("[color=#90a4ae]You have no usable items![/color]")
		_set_btns_disabled(false)
		return

	_set_btns_disabled(true)
	var value = potion.get("value", 0)
	var healed = min(value, GameState.get_player().max_hp - GameState.get_player().hp)
	GameState.modify_hp(value)
	potion["qty"] = potion.get("qty", 1) - 1
	if potion["qty"] <= 0:
		var idx = GameState.get_inventory().find(potion)
		if idx >= 0:
			GameState.remove_item(idx)
	_refresh_player_ui()
	_log("[color=#80cbc4]Used [b]" + potion.name + "[/b] — restored [b]" + str(healed) + "[/b] HP.[/color]")
	FloatingText.spawn("+" + str(healed) + " HP", player_card.global_position + Vector2(player_card.size.x * 0.5, 0), FloatingText.Type.HEAL)

	await get_tree().create_timer(0.8).timeout
	_enemy_turn()

func player_run():
	if not battle_active: return
	_set_btns_disabled(true)

	if randf() < 0.45:
		_log("[color=#ce93d8]You fled the battle successfully![/color]")
		GameState.play_sfx("flee")
		await get_tree().create_timer(0.5).timeout
		_end_battle(false)
	else:
		_log("[color=#ef9a9a]Failed to escape![/color]")
		await get_tree().create_timer(0.6).timeout
		_enemy_turn()

func player_defend():
	if not battle_active: return
	_set_btns_disabled(true)
	_log("[color=#81d4fa]You brace yourself and raise your guard! Defense +50% this turn.[/color]")
	GameState.play_sfx("equip")
	_defending = true
	await get_tree().create_timer(0.5).timeout
	_enemy_turn()

# ----- Skills -----
func player_skills():
	if not battle_active: return
	_set_btns_disabled(true)

	for c in skills_panel_ref.get_child(0).get_children():
		c.queue_free()

	var available = GameState.get_available_skills()
	var p = GameState.get_player()
	for skill in available:
		var btn = Button.new()
		btn.text = skill.name + " (" + str(skill.mp_cost) + " MP)"
		btn.disabled = p.mp < skill.mp_cost
		btn.pressed.connect(_use_skill.bind(skill))
		skills_panel_ref.get_child(0).add_child(btn)

	var close_btn = Button.new()
	close_btn.text = "Back"
	close_btn.pressed.connect(func():
		skills_panel_ref.visible = false
		_set_btns_disabled(false)
	)
	skills_panel_ref.get_child(0).add_child(close_btn)

	skills_panel_ref.visible = true

func _use_skill(skill: Dictionary):
	skills_panel_ref.visible = false
	_set_btns_disabled(true)

	# Handle heal skill
	if skill.has("heal_amount") and skill.heal_amount > 0:
		var healed = mini(skill.heal_amount, GameState.get_player().max_hp - GameState.get_player().hp)
		if healed <= 0:
			_log("[color=#90a4ae]Your HP is already full! The spell fizzles.[/color]")
			skills_panel_ref.visible = true
			_set_btns_disabled(false)
			return
		if skill.mp_cost > 0:
			GameState.modify_mp(-skill.mp_cost)
		GameState.modify_hp(healed)
		_refresh_player_ui()
		_log("[color=#80cbc4]You cast [b]" + skill.name + "[/b]! Restored [b]" + str(healed) + "[/b] HP.[/color]")
		FloatingText.spawn("+" + str(healed) + " HP", player_card.global_position + Vector2(player_card.size.x * 0.5, 0), FloatingText.Type.HEAL)
		GameState.play_sfx(skill.get("sfx", "heal"))
		await get_tree().create_timer(0.7).timeout
		_enemy_turn()
		return

	# Handle damage skill
	if skill.mp_cost > 0:
		GameState.modify_mp(-skill.mp_cost)

	var base_dmg = GameState.get_total_atk()
	# Crit check for skills (10%)
	var is_crit = randf() < 0.10
	var dmg = max(1, int(base_dmg * skill.damage_mult) + randi_range(-2, 3))
	if is_crit:
		dmg = int(dmg * 1.5)
	enemy_data.hp -= dmg
	_refresh_enemy_ui()
	_refresh_player_ui()

	var color = "#ce93d8"
	if skill.has("element"):
		match skill.element:
			"fire": color = "#ff7043"
			"lightning": color = "#ffee58"

	if is_crit:
		_log("[color=#ffd700]💥 CRITICAL! [b]" + skill.name + "[/b] strikes for [b]" + str(dmg) + "[/b] damage![/color]")
		FloatingText.spawn("CRIT! " + str(dmg), enemy_card.global_position + Vector2(enemy_card.size.x * 0.5, 0), FloatingText.Type.CRIT)
		BattleVFX.screen_shake(main_panel, 10.0, 0.4)
	else:
		_log("[color=" + color + "]You cast [b]" + skill.name + "[/b]! Dealt [b]" + str(dmg) + "[/b] damage![/color]")
		FloatingText.spawn(str(dmg), enemy_card.global_position + Vector2(enemy_card.size.x * 0.5, 0), FloatingText.Type.DAMAGE)
		BattleVFX.screen_shake(main_panel, 6.0, 0.3)

	# VFX — skill uses double slash arc
	BattleVFX.slash_arc(main_panel, enemy_card, true)
	BattleVFX.hit_flash(enemy_card)
	GameState.play_sfx(skill.get("sfx", "hit"))

	if skill.name == "Heavy Strike":
		if randf() < 0.35:
			GameState.apply_enemy_stun(1)
			_log("[color=#81d4fa]The enemy is stunned![/color]")

	if enemy_data.hp <= 0:
		await get_tree().create_timer(0.5).timeout
		_end_battle(true)
		return

	await get_tree().create_timer(0.7).timeout
	_enemy_turn()

# ----- Enemy Turn -----
func _enemy_turn():
	if not battle_active: return

	if _process_buffs(false):
		if enemy_data.hp <= 0:
			await get_tree().create_timer(0.5).timeout
			_end_battle(true)
			return

	if GameState.consume_enemy_stun():
		_log("[color=#81d4fa]The enemy is stunned and can't act![/color]")
		turn_label.text = "Your Turn"
		_log("[color=#81d4fa]Your turn — choose an action.[/color]")
		_set_btns_disabled(false)
		_defending = false
		return

	turn_label.text = "Enemy Turn"

	var is_boss = enemy_data.get("is_boss", false)
	var is_boss_special = is_boss and randf() < 0.45

	var e_atk  = enemy_data.get("attack", 5)
	if is_boss_special:
		e_atk = int(e_atk * 1.5)

	var p_def  = GameState.get_total_def()
	if _defending:
		p_def = int(p_def * 1.5)
	var dmg    = max(1, e_atk - p_def + randi_range(-1, 2))
	GameState.modify_hp(-dmg)
	_refresh_player_ui()

	if is_boss_special:
		_log("[color=#ff1744]💥 [b]" + enemy_data.get("name", "Enemy") + "[/b] casts [b]Ground Slam[/b]! Dealt [b]" + str(dmg) + "[/b] heavy damage![/color]")
		FloatingText.spawn("SLAM! " + str(dmg), player_card.global_position + Vector2(player_card.size.x * 0.5, 0), FloatingText.Type.CRIT)
		BattleVFX.screen_shake(main_panel, 12.0, 0.45)
	else:
		_log("[color=#ffcc80][b]" + enemy_data.get("name", "Enemy") + "[/b] attacks! You took [b]" + str(dmg) + "[/b] damage.[/color]")
		FloatingText.spawn(str(dmg), player_card.global_position + Vector2(player_card.size.x * 0.5, 0), FloatingText.Type.DAMAGE)
		BattleVFX.screen_shake(main_panel, 4.0, 0.2)

	# VFX on player
	BattleVFX.hit_flash(player_card)
	GameState.play_sfx("hit")
	_defending = false

	if GameState.get_player().hp <= 0:
		await get_tree().create_timer(0.8).timeout
		_log("[color=#ef5350]You were defeated…[/color]")
		await get_tree().create_timer(1.0).timeout
		_set_btns_disabled(true)
		battle_active = false
		emit_signal("player_defeated")
		return

	turn_label.text = "Your Turn"
	
	if _process_buffs(true):
		if GameState.get_player().hp <= 0:
			await get_tree().create_timer(0.8).timeout
			_log("[color=#ef5350]You were defeated by poison…[/color]")
			await get_tree().create_timer(1.0).timeout
			_set_btns_disabled(true)
			battle_active = false
			emit_signal("player_defeated")
			return
			
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

		GameState.modify_gold(rewards.gold)
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

		GameState.play_sfx("victory")

		# Track side quest progress
		var enemy_type = rewards.get("type", "")
		if enemy_type != "":
			GameState.progress_side_quest(enemy_type)

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
	GameState.add_item(drop)
