extends CharacterBody2D

var max_hp = 20.0
var hp = 20.0
var state = "idle"
var anim_time = 0.0
var jump_velocity = Vector2.ZERO

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = Sprites.characters["slime"]
	sprite.hframes = 2
	sprite.vframes = 1
	sprite.frame = 0
	anim_time = randf() * 1.5

func _physics_process(delta):
	if is_ui_active():
		velocity = Vector2.ZERO
		return

	anim_time += delta

	if state == "idle":
		sprite.frame = 0
		velocity = Vector2.ZERO
		if anim_time > 1.8:
			state = "jump"
			anim_time = 0.0
			var angle = randf() * PI * 2
			jump_velocity = Vector2(cos(angle), sin(angle)) * 40.0

	elif state == "jump":
		sprite.frame = 1
		velocity = jump_velocity
		if anim_time > 0.4:
			state = "idle"
			anim_time = 0.0
			velocity = Vector2.ZERO

	move_and_slide()

func is_ui_active() -> bool:
	var game_node = get_tree().get_first_node_in_group("game")
	if game_node and game_node.has_method("is_ui_blocked"):
		return game_node.is_ui_blocked()
	return false

func get_battle_config() -> Dictionary:
	return {
		"name":       "Wild Slime",
		"icon":       "🟢",
		"hp":         hp,
		"max_hp":     max_hp,
		"attack":     5,
		"exp_reward": 35,
		"gold_reward": 10,
		"loot":       [],
		"type":       "slime"
	}
