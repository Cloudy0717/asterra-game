extends Area2D

@onready var sprite = $Sprite2D
var has_fruit = true

func _ready():
	sprite.frame = randi() % 9

func collect():
	if not has_fruit:
		return
		
	has_fruit = false
	GameState.play_sfx("equip")
	spawn_gather_particles()
	
	# Determine fruit color based on frame or just random
	var fruits = ["Wild Apple", "Blueberry", "Wild Lemon", "Wild Berry", "Wild Orange"]
	var fruit = fruits[randi() % fruits.size()]
	
	GameState.add_item({"id": "wild_fruit", "name": fruit, "type": "potion", "qty": 1, "value": 20, "icon": "🍎", "desc": "A fresh wild fruit. Restores 20 HP."})
	
	var steps = [
		{ "speaker": "System", "avatar": "🍒", "text": "You foraged some " + fruit + " from the bush! (Restores 20 HP)" }
	]
	
	GameState.emit_signal("show_dialogue", steps, func():
		GameState.emit_signal("hud_updated")
		GameState.save_game()
	)
	
	# Fade out or remove after collection
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
	
	var mm = get_parent().get_parent()
	if mm and mm.has_method("remove_fruit_bush"):
		mm.remove_fruit_bush(self)

func spawn_gather_particles():
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 8
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.spread = 360.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.color = Color("#f48fb1") # Pinkish glow
	particles.direction = Vector2.ZERO
	particles.finished.connect(particles.queue_free)
	get_parent().add_child(particles)
	particles.global_position = global_position
