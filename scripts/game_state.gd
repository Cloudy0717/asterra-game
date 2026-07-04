extends Node

signal hud_updated
signal sfx_played(type)
signal show_dialogue(steps, callback)
signal dialogue_ended

var player = {
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
	}
}

var inventory = [
	{
		"id": "rusty_sword",
		"name": "Rusty Sword",
		"type": "weapon",
		"icon": "⚔️",
		"desc": "A worn-out rusty sword. Better than nothing.",
		"effect": "+5 Attack",
		"value": 5,
		"qty": 1,
		"equipped": true
	},
	{
		"id": "tattered_cloth",
		"name": "Tattered Armor",
		"type": "armor",
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
		"type": "potion",
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

var quest = {
	"state": 0,
	"slimes_killed": 0,
	"slimes_required": 3,
	"goblins_killed": 0,
	"goblins_required": 3
}

var settings = {
	"text_speed": 40, # ms per character
	"music_on": true,
	"sfx_volume": 80
}

func _ready():
	check_saved_game()

func save_game():
	var file = ConfigFile.new()
	file.set_value("player", "data", player)
	file.set_value("inventory", "items", inventory)
	file.set_value("quest", "data", quest)
	file.save("user://asterra_savegame.cfg")

func load_game() -> bool:
	var file = ConfigFile.new()
	var err = file.load("user://asterra_savegame.cfg")
	if err == OK:
		player = file.get_value("player", "data", player)
		inventory = file.get_value("inventory", "items", inventory)
		quest = file.get_value("quest", "data", quest)
		# Ensure new fields exist on old saves
		if not quest.has("goblins_killed"): quest.goblins_killed = 0
		if not quest.has("goblins_required"): quest.goblins_required = 3
		emit_signal("hud_updated")
		return true
	return false

func check_saved_game() -> bool:
	var file = ConfigFile.new()
	var err = file.load("user://asterra_savegame.cfg")
	return err == OK

func delete_save():
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("asterra_savegame.cfg")

func play_sfx(type: String):
	emit_signal("sfx_played", type)
	if Audio:
		Audio.play(type)

func add_exp(amount: int):
	player.exp += amount
	play_sfx("exp")
	
	if player.exp >= player.max_exp:
		player.level += 1
		player.exp -= player.max_exp
		player.max_hp += 15
		player.hp = player.max_hp
		player.max_mp += 5
		player.mp = player.max_mp
		player.base_atk += 3
		player.base_def += 2
		
		play_sfx("levelup")
		
		if player.level == 2:
			player.rank = "D Rank"
		
		# Delay trigger level up dialog to let UI update first
		get_tree().create_timer(0.5).timeout.connect(func():
			var steps = [
				{ "speaker": "System", "avatar": "✨", "text": "Congratulations! You leveled up to Level " + str(player.level) + "!" },
				{ "speaker": "System", "avatar": "✨", "text": "Your attributes increased! Mercenary Rank upgraded to " + player.rank + "!" }
			]
			emit_signal("show_dialogue", steps, func():
				emit_signal("hud_updated")
				save_game()
			)
		)
	
	emit_signal("hud_updated")
	save_game()

func get_total_atk() -> int:
	var bonus = 0
	if player.equipment.weapon:
		bonus += player.equipment.weapon.value
	return player.base_atk + bonus

func get_total_def() -> int:
	var bonus = 0
	if player.equipment.armor:
		bonus += player.equipment.armor.value
	if player.equipment.accessory:
		bonus += player.equipment.accessory.value
	return player.base_def + bonus

func use_item(index: int) -> String:
	if index < 0 or index >= inventory.size():
		return "Invalid index"
	
	var item = inventory[index]
	play_sfx("equip")
	
	if item.type == "potion":
		if player.hp >= player.max_hp:
			return "Your health is already full!"
		player.hp = min(player.max_hp, player.hp + item.value)
		item.qty -= 1
		if item.qty <= 0:
			inventory.remove_at(index)
	else:
		var slot = item.type # "weapon", "armor", "accessory"
		if item.equipped:
			item.equipped = false
			player.equipment[slot] = null
		else:
			# Unequip existing
			for inv_item in inventory:
				if inv_item.type == slot and inv_item.equipped:
					inv_item.equipped = false
			
			item.equipped = true
			player.equipment[slot] = item
	
	emit_signal("hud_updated")
	save_game()
	return ""

func unequip_slot(slot: String):
	var item = player.equipment[slot]
	if item:
		play_sfx("equip")
		item.equipped = false
		player.equipment[slot] = null
		emit_signal("hud_updated")
		save_game()
