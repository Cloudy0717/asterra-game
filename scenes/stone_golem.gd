extends CharacterBody2D

# Golem Boss stats
var max_hp    = 250.0
var hp        = 250.0
var attack    = 25

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture  = Sprites.monsters["stone_golem"]
	sprite.hframes  = 2
	sprite.vframes  = 1
	sprite.frame    = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

# The golem boss doesn't wander, it just sits at the altar waiting.
func _physics_process(_delta):
	# Optional: Add a slow breathing animation
	if int(Time.get_ticks_msec() / 800) % 2 == 0:
		sprite.frame = 1
	else:
		sprite.frame = 0

func get_battle_config() -> Dictionary:
	return {
		"name":       "Giant Stone Golem",
		"icon":       "🗿",
		"hp":         hp,
		"max_hp":     max_hp,
		"attack":     attack,
		"exp_reward": 250,
		"gold_reward": 100,
		"loot": [
			{
				"id": "golem_core",
				"name": "Golem Core",
				"type": "material",
				"icon": "🔮",
				"desc": "The magical heart of a stone golem. Immensely valuable.",
				"effect": "Legendary Material",
				"value": 200,
				"qty": 1,
				"equipped": false
			}
		],
		"type":       "stone_golem",
		"boss":       true
	}
