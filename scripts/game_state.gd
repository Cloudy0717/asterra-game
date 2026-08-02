extends Node

signal hud_updated
signal sfx_played(type)
@warning_ignore("unused_signal")
signal show_dialogue(steps, callback)
@warning_ignore("unused_signal")
signal dialogue_ended

var _player = {
	"name": "Alex",
	"age": 19,
	"level": 1,
	"exp": 0,
	"max_exp": 100,
	"hp": 100,
	"max_hp": 100,
	"mp": 20,
	"max_mp": 20,
	"base_atk": 10,
	"base_def": 4,
	"gold": 15,
	"reputation": 0,
	"rank": "E Rank",
	"equipment": {
		"weapon": null,
		"armor": null,
		"accessory": null
	},
	"skills": [
		{
			"id": "heavy_strike",
			"name": "Heavy Strike",
			"icon": "⚔️",
			"desc": "A powerful physical strike dealing 1.5x damage.",
			"mp_cost": 10,
			"type": "attack"
		},
		{
			"id": "heal_light",
			"name": "Heal Light",
			"icon": "✨",
			"desc": "A basic healing spell restoring 30% Max HP.",
			"mp_cost": 15,
			"type": "heal"
		}
	],
	"buffs": {}
}

var _enemy_stun_turns: int = 0

func apply_enemy_stun(turns: int = 1) -> void:
	_enemy_stun_turns = maxi(0, turns)

func get_enemy_stun_turns() -> int:
	return _enemy_stun_turns

func consume_enemy_stun() -> bool:
	if _enemy_stun_turns > 0:
		_enemy_stun_turns -= 1
		return true
	return false

var _inventory = [
	{
		"id": "rusty_sword",
		"name": "Rusty Sword",
		"type": Constants.ITEM_TYPE_WEAPON,
		"icon": "⚔️",
		"desc": "A worn-out rusty sword. Better than nothing.",
		"effect": "+5 Attack",
		"value": 5,
		"qty": 1,
		"equipped": true,
		"skill": {"name": "Rusty Scratch", "mp_cost": 2, "damage_mult": 1.2, "description": "A wild rusty scratch — 1.2x damage"}
	},
	{
		"id": "tattered_cloth",
		"name": "Tattered Armor",
		"type": Constants.ITEM_TYPE_ARMOR,
		"icon": "👕",
		"desc": "A patched piece of cloth. Offers minor physical protection.",
		"effect": "+4 Defense",
		"value": 4,
		"qty": 1,
		"equipped": true
	},
	{
		"id": "health_potion",
		"name": "Health Potion",
		"type": Constants.ITEM_TYPE_POTION,
		"icon": "🧪",
		"desc": "A herbal potion cooked by your village elder. Restores 50 HP.",
		"effect": "Heals 50 HP",
		"value": 50,
		"qty": 2,
		"equipped": false
	},
	{
		"id": "linas_amulet",
		"name": "Lina's Amulet",
		"type": "accessory",
		"icon": "📿",
		"desc": "A handmade woven amulet from your sister. Keeps you warm in the wilderness.",
		"effect": "+2 Defense, +5 Rep",
		"value": 2,
		"qty": 1,
		"equipped": false
	}
]

var _quest = {
	"state": 0,
	"slimes_killed": 0,
	"slimes_required": 3,
	"goblins_killed": 0,
	"goblins_required": 3
}

var _side_quests: Array = []
# Side quest format: { id, title, type, target_type, target_qty, current_qty, gold_reward, exp_reward, completed }

var _settings = {
	"text_speed": 40,
	"music_on": true,
	"sfx_volume": 80
}

func _ready():
	check_saved_game()

func get_player() -> Dictionary:
	return _player

func get_inventory() -> Array:
	return _inventory

func get_quest() -> Dictionary:
	return _quest

func get_settings() -> Dictionary:
	return _settings

func modify_hp(amount: float) -> void:
	_player.hp = clamp(_player.hp + amount, 0.0, _player.max_hp)

func modify_mp(amount: float) -> void:
	_player.mp = clamp(_player.mp + amount, 0.0, _player.max_mp)

func modify_gold(amount: int) -> void:
	_player.gold = max(0, _player.gold + amount)
	if amount > 0:
		_show_toast("Gold +" + str(amount), "💰")

func add_item(item_def: Dictionary) -> void:
	var item_name = item_def.get("name", "Item")
	var item_icon = item_def.get("icon", "📦")
	if item_def.has("id") and item_def.get("type") == Constants.ITEM_TYPE_POTION:
		for item in _inventory:
			if item.id == item_def.id:
				item.qty += item_def.get("qty", 1)
				emit_signal("hud_updated")
				_show_toast("Acquired: " + item_name + " x" + str(item_def.get("qty", 1)), item_icon)
				return
	_inventory.append(item_def.duplicate())
	emit_signal("hud_updated")
	_show_toast("Acquired: " + item_name, item_icon)

func remove_item(index: int) -> void:
	if index >= 0 and index < _inventory.size():
		_inventory.remove_at(index)
		emit_signal("hud_updated")

func has_item(item_id: String) -> bool:
	for item in _inventory:
		if item.id == item_id:
			return true
	return false

func get_item_count(item_id: String) -> int:
	var count = 0
	for item in _inventory:
		if item.id == item_id:
			count += item.get("qty", 1)
	return count

var _location = {
	"map": "cabin",
	"x": 176.0,
	"y": 176.0,
	"dir": "down"
}

func set_location(map_name: String, pos: Vector2, facing_dir: String = "down") -> void:
	_location["map"] = map_name
	_location["x"] = pos.x
	_location["y"] = pos.y
	_location["dir"] = facing_dir

func get_location() -> Dictionary:
	return _location

func save_game():
	var scene = Engine.get_main_loop().current_scene
	if scene:
		var p_node = scene.get_node_or_null("Player")
		var m_mgr = scene.get_node_or_null("Maps/MapManager")
		if p_node and m_mgr:
			var p_dir = str(p_node.get("dir")) if p_node.get("dir") != null else "down"
			set_location(m_mgr.current_map, p_node.position, p_dir)

	var file = ConfigFile.new()
	file.set_value("player", "data", _player)
	file.set_value("inventory", "items", _inventory)
	file.set_value("quest", "data", _quest)
	file.set_value("side_quests", "data", _side_quests)
	file.set_value("location", "data", _location)
	file.save("user://asterra_savegame.cfg")

func load_game() -> bool:
	var file = ConfigFile.new()
	var err = file.load("user://asterra_savegame.cfg")
	if err == OK:
		var saved_player = file.get_value("player", "data", {})
		_deep_merge(_player, saved_player)
		
		_inventory = file.get_value("inventory", "items", _inventory)
		
		var saved_quest = file.get_value("quest", "data", {})
		_deep_merge(_quest, saved_quest)
		
		_side_quests = file.get_value("side_quests", "data", _side_quests)
		
		var saved_location = file.get_value("location", "data", {})
		_deep_merge(_location, saved_location)
		
		emit_signal("hud_updated")
		return true
	return false

func _deep_merge(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		if target.has(key) and typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
			_deep_merge(target[key], source[key])
		else:
			target[key] = source[key]

func check_saved_game() -> bool:
	var file = ConfigFile.new()
	var err = file.load("user://asterra_savegame.cfg")
	return err == OK

func delete_save():
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("asterra_savegame.cfg")

func get_available_skills() -> Array:
	var skills = []
	if _player.has("skills"):
		skills.append_array(_player.skills)
	
	# Weapon skill
	if _player.equipment.weapon and _player.equipment.weapon.has("skill"):
		skills.append(_player.equipment.weapon.skill)
	if _player.equipment.armor and _player.equipment.armor.has("skill"):
		skills.append(_player.equipment.armor.skill)
		
	return skills

func reset_player(hp_pct: float = 1.0):
	_player.hp = int(_player.max_hp * hp_pct)
	_player.mp = _player.max_mp

func play_sfx(type: String):
	emit_signal("sfx_played", type)
	if Audio:
		Audio.play(type)

func add_exp(amount: int):
	_player.exp += amount
	play_sfx("exp")
	var scene = Engine.get_main_loop().current_scene
	if scene:
		var vp = scene.get_viewport().get_visible_rect().size
		FloatingText.spawn("+" + str(amount) + " EXP", Vector2(vp.x * 0.5, 80), FloatingText.Type.EXP)

	if _player.exp >= _player.max_exp:
		_player.level += 1
		_player.exp -= _player.max_exp
		_player.max_hp += 15
		_player.hp = _player.max_hp
		_player.max_mp += 5
		_player.mp = _player.max_mp
		_player.base_atk += 3
		_player.base_def += 2

		play_sfx("levelup")

		if _player.level == 2:
			_player.rank = "D Rank"

		get_tree().create_timer(0.4).timeout.connect(func():
			_show_level_up(_player.level, _player.rank, { "hp": 15, "mp": 5, "atk": 3, "def": 2 })
			emit_signal("hud_updated")
			save_game()
		)

	emit_signal("hud_updated")
	save_game()

func get_total_atk() -> int:
	var bonus = 0
	if _player.equipment.weapon:
		bonus += _player.equipment.weapon.value
	return _player.base_atk + bonus

func get_total_def() -> int:
	var bonus = 0
	if _player.equipment.armor:
		bonus += _player.equipment.armor.value
	if _player.equipment.accessory:
		bonus += _player.equipment.accessory.value
	return _player.base_def + bonus

func use_item(index: int) -> String:
	if index < 0 or index >= _inventory.size():
		return "Invalid index"

	var item = _inventory[index]
	play_sfx("equip")

	if item.get("type", "") == Constants.ITEM_TYPE_POTION:
		if _player.hp >= _player.max_hp:
			return "Your health is already full!"
		_player.hp = min(_player.max_hp, _player.hp + item.get("value", 0))
		item["qty"] = item.get("qty", 1) - 1
		if item["qty"] <= 0:
			_inventory.remove_at(index)
	else:
		var slot = item.get("type", "")
		if item.get("equipped", false):
			item["equipped"] = false
			_player.equipment[slot] = null
			_remove_item_bonuses(item)
		else:
			for inv_item in _inventory:
				if inv_item.get("type", "") == slot and inv_item.get("equipped", false):
					inv_item["equipped"] = false
					_remove_item_bonuses(inv_item)

			item["equipped"] = true
			_player.equipment[slot] = item
			_apply_item_bonuses(item)

	emit_signal("hud_updated")
	save_game()
	return ""

func _apply_item_bonuses(item: Dictionary) -> void:
	if item.has("max_mp"):
		_player.max_mp += item.get("max_mp", 0)

func _remove_item_bonuses(item: Dictionary) -> void:
	if item.has("max_mp"):
		_player.max_mp = max(1, _player.max_mp - item.get("max_mp", 0))
		_player.mp = min(_player.mp, _player.max_mp)

func unequip_slot(slot: String):
	var item = _player.equipment[slot]
	if item:
		play_sfx("equip")
		item["equipped"] = false
		_player.equipment[slot] = null
		_remove_item_bonuses(item)
		emit_signal("hud_updated")
		save_game()

# ========================= SIDE QUEST SYSTEM =========================

func get_side_quests() -> Array:
	return _side_quests

func get_active_side_quests() -> Array:
	var active = []
	for q in _side_quests:
		if not q.completed:
			active.append(q)
	return active

func has_side_quest(quest_id: String) -> bool:
	for q in _side_quests:
		if q.id == quest_id and not q.completed:
			return true
	return false

func accept_side_quest(quest_def: Dictionary):
	if has_side_quest(quest_def.id):
		return
	var q = quest_def.duplicate(true)
	q["current_qty"] = 0
	q["completed"] = false
	_side_quests.append(q)
	play_sfx("select")
	emit_signal("hud_updated")
	save_game()

func progress_side_quest(target_type: String, amount: int = 1):
	for q in _side_quests:
		if q.completed:
			continue
		if q.target_type == target_type:
			q.current_qty = mini(q.current_qty + amount, q.target_qty)
	emit_signal("hud_updated")
	save_game()

func is_side_quest_complete(quest_id: String) -> bool:
	for q in _side_quests:
		if q.id == quest_id and not q.completed:
			return q.current_qty >= q.target_qty
	return false

func complete_side_quest(quest_id: String) -> Dictionary:
	for q in _side_quests:
		if q.id == quest_id and not q.completed and q.current_qty >= q.target_qty:
			q.completed = true
			modify_gold(q.gold_reward)
			add_exp(q.exp_reward)
			play_sfx("quest_complete")
			emit_signal("hud_updated")
			save_game()
			return q
	return {}

func get_available_bounties() -> Array:
	return [
		{
			"id": "bounty_herbs",
			"title": "Herb Gathering",
			"description": "Collect 3 Vital Herbs from the wilds.",
			"target_type": "vital_herb",
			"target_qty": 3,
			"gold_reward": 40,
			"exp_reward": 30
		},
		{
			"id": "bounty_wolves",
			"title": "Wolf Eradication",
			"description": "Defeat 3 Wolves threatening the village.",
			"target_type": "wolf",
			"target_qty": 3,
			"gold_reward": 70,
			"exp_reward": 50
		},
		{
			"id": "bounty_goblins",
			"title": "Goblin Extermination",
			"description": "Clear 3 Goblins from Stone Claw Pass.",
			"target_type": "goblin",
			"target_qty": 3,
			"gold_reward": 90,
			"exp_reward": 70
		}
	]

func _show_toast(msg: String, icon: String = "📦"):
	var script_res = load("res://scripts/toast_manager.gd")
	if script_res and script_res.has_method("show_toast"):
		script_res.show_toast(msg, icon)

func _show_level_up(level: int, rank: String, gains: Dictionary):
	var script_res = load("res://scenes/level_up_modal.gd")
	if script_res and script_res.has_method("show_level_up"):
		script_res.show_level_up(level, rank, gains)
