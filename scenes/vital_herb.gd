extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = Sprites.objects["vital_herb"]

func collect():
	GameState.play_sfx("heal")
	GameState.progress_side_quest("vital_herb")
	spawn_gather_particles()

	var rng_herb = RandomNumberGenerator.new()
	var heal = 15 + rng_herb.randi() % 6
	var actual = min(heal, GameState.get_player().max_hp - GameState.get_player().hp)
	GameState.modify_hp(heal)

	var steps = [
		{ "speaker": "System", "avatar": "🌿", "text": "You consumed a Vital Herb on the spot! Restored [b]+" + str(actual) + " HP[/b]." }
	]

	GameState.emit_signal("show_dialogue", steps, func():
		GameState.emit_signal("hud_updated")
		GameState.save_game()
	)

	var game = get_tree().get_first_node_in_group("game")
	if game and game.has_method("remove_vital_herb"):
		game.remove_vital_herb(self)
	queue_free()

func spawn_gather_particles():
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 8
	particles.lifetime = 0.4
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.spread = 360.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 15.0
	particles.initial_velocity_max = 30.0
	particles.color = Color("#00e676")
	particles.direction = Vector2.ZERO
	particles.finished.connect(particles.queue_free)
	get_parent().add_child(particles)
	particles.global_position = global_position
