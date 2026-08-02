extends Area2D

@onready var sprite = $Sprite2D

var ore_type = "copper" # "copper" or "iron"
var has_ore = true

func _ready():
	if ore_type == "copper":
		sprite.texture = Sprites.objects.get("copper_ore", null)
	else:
		sprite.texture = Sprites.objects.get("iron_ore", null)

func setup(type: String):
	ore_type = type

func collect():
	if not has_ore:
		return
	has_ore = false
	GameState.play_sfx("equip")
	spawn_gather_particles()
	
	var item = {}
	if ore_type == "copper":
		item = {
			"id": "copper_ore", "name": "Copper Ore",
			"type": Constants.ITEM_TYPE_MATERIAL, "qty": 1,
			"value": 15, "icon": "🟠",
			"desc": "A chunk of raw copper ore. Can be used for crafting or sold.",
			"effect": "Crafting Material", "equipped": false
		}
	else:
		item = {
			"id": "iron_ore", "name": "Iron Ore",
			"type": Constants.ITEM_TYPE_MATERIAL, "qty": 1,
			"value": 25, "icon": "⚪",
			"desc": "A chunk of raw iron ore. A valuable crafting material.",
			"effect": "Crafting Material", "equipped": false
		}
	
	GameState.add_item(item)
	
	var steps = [
		{ "speaker": "System", "avatar": "⛏️", "text": "You mined some " + item.name + "! (" + item.name + " +1)" }
	]
	
	GameState.emit_signal("show_dialogue", steps, func():
		GameState.emit_signal("hud_updated")
		GameState.save_game()
	)
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func spawn_gather_particles():
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 10
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.spread = 360.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.color = Color("#ffab40") if ore_type == "copper" else Color("#b0bec5")
	particles.direction = Vector2.ZERO
	particles.finished.connect(particles.queue_free)
	get_parent().add_child(particles)
	particles.global_position = global_position
