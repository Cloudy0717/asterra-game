extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = Sprites.objects["herb"]

func collect():
	GameState.play_sfx("equip")
	spawn_gather_particles()
	
	GameState.add_item({"id": "health_potion", "type": "potion", "qty": 1})
	
	var steps = [
		{ "speaker": "System", "avatar": "🌿", "text": "You collected a glowing Wild Herb! The materials can be brewed into a Health Potion (Potion quantity +1)." }
	]
	
	GameState.emit_signal("show_dialogue", steps, func():
		GameState.emit_signal("hud_updated")
		GameState.save_game()
	)
	
	var game = get_tree().get_first_node_in_group("game")
	if game and game.has_method("remove_herb"):
		game.remove_herb(self)
	queue_free()

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
	particles.color = Color("#29b6f6") # Blue glow
	particles.direction = Vector2.ZERO
	particles.finished.connect(particles.queue_free)
	get_parent().add_child(particles)
	particles.global_position = global_position
