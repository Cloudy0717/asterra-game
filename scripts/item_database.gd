class_name ItemDatabase

const ITEMS = {
	"rusty_sword": {
		"id": "rusty_sword",
		"name": "Rusty Sword",
		"type": Constants.ITEM_TYPE_WEAPON,
		"icon": "⚔️",
		"desc": "A worn-out rusty sword. Better than nothing.",
		"effect": "+5 Attack",
		"value": 5,
		"atk_bonus": 5,
		"qty": 1
	},
	"bronze_sword": {
		"id": "bronze_sword",
		"name": "Bronze Sword",
		"type": Constants.ITEM_TYPE_WEAPON,
		"icon": "🗡️",
		"desc": "A heavy sword forged from copper ore.",
		"effect": "+10 Attack",
		"value": 25,
		"atk_bonus": 10,
		"qty": 1
	},
	"iron_sword": {
		"id": "iron_sword",
		"name": "Iron Sword",
		"type": Constants.ITEM_TYPE_WEAPON,
		"icon": "🗡️",
		"desc": "A sturdy and sharp blade of solid iron.",
		"effect": "+15 Attack",
		"value": 50,
		"atk_bonus": 15,
		"qty": 1
	},
	"tattered_cloth": {
		"id": "tattered_cloth",
		"name": "Tattered Armor",
		"type": Constants.ITEM_TYPE_ARMOR,
		"icon": "👕",
		"desc": "A patched piece of cloth. Offers minor physical protection.",
		"effect": "+4 Defense",
		"value": 4,
		"def_bonus": 4,
		"qty": 1
	},
	"leather_armor": {
		"id": "leather_armor",
		"name": "Leather Armor",
		"type": Constants.ITEM_TYPE_ARMOR,
		"icon": "👕",
		"desc": "Basic armor crafted from animal pelts.",
		"effect": "+8 Defense",
		"value": 30,
		"def_bonus": 8,
		"qty": 1
	},
	"golem_crusher": {
		"id": "golem_crusher",
		"name": "Golem Crusher",
		"type": Constants.ITEM_TYPE_WEAPON,
		"icon": "🔨",
		"desc": "A legendary hammer infused with golem magic.",
		"effect": "+35 Attack",
		"value": 250,
		"atk_bonus": 35,
		"qty": 1
	},
	"health_potion": {
		"id": "health_potion",
		"name": "Health Potion",
		"type": Constants.ITEM_TYPE_POTION,
		"icon": "🧪",
		"desc": "A herbal potion cooked by your village elder. Restores 50 HP.",
		"effect": "Heals 50 HP",
		"value": 50,
		"qty": 1
	}
}

static func get_item(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id].duplicate(true)
	return {}
