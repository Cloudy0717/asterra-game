class_name RecipeDatabase

const RECIPES = [
	{
		"id": "bronze_sword",
		"name": "Bronze Sword",
		"type": "weapon",
		"icon_id": "bronze_sword",
		"desc": "A heavy sword forged from copper ore.",
		"base_item": {
			"id": "bronze_sword", "name": "Bronze Sword", "type": "weapon", "icon": "🗡️",
			"desc": "A heavy sword forged from copper ore.", "effect": "+10 Attack", "value": 25, "atk_bonus": 10
		},
		"req_gold": 20,
		"req_items": {"copper_ore": 3}
	},
	{
		"id": "iron_sword",
		"name": "Iron Sword",
		"type": "weapon",
		"icon_id": "iron_sword",
		"desc": "A sturdy and sharp blade of solid iron.",
		"base_item": {
			"id": "iron_sword", "name": "Iron Sword", "type": "weapon", "icon": "🗡️",
			"desc": "A sturdy and sharp blade of solid iron.", "effect": "+15 Attack", "value": 50, "atk_bonus": 15
		},
		"req_gold": 60,
		"req_items": {"iron_ore": 3}
	},
	{
		"id": "leather_armor",
		"name": "Leather Armor",
		"type": "armor",
		"icon_id": "leather_armor",
		"desc": "Basic armor crafted from animal pelts.",
		"base_item": {
			"id": "leather_armor", "name": "Leather Armor", "type": "armor", "icon": "👕",
			"desc": "Basic armor crafted from animal pelts.", "effect": "+8 Defense", "value": 30, "def_bonus": 8
		},
		"req_gold": 15,
		"req_items": {"wolf_pelt": 2}
	},
	{
		"id": "golem_crusher",
		"name": "Golem Crusher",
		"type": "weapon",
		"icon_id": "steel_blade",
		"desc": "A legendary hammer infused with golem magic.",
		"base_item": {
			"id": "golem_crusher", "name": "Golem Crusher", "type": "weapon", "icon": "🔨",
			"desc": "A legendary hammer infused with golem magic.", "effect": "+35 Attack", "value": 250, "atk_bonus": 35
		},
		"req_gold": 200,
		"req_items": {"golem_core": 1, "iron_ore": 10}
	}
]

static func get_all_recipes() -> Array:
	return RECIPES.duplicate(true)
