extends CharacterBody2D

# Wolf stats
var max_hp    = 40.0
var hp        = 40.0
var attack    = 8

# AI
var wander_timer  = 0.0
var wander_vel    = Vector2.ZERO
const AGGRO_RANGE = 90.0
const WANDER_SPEED = 28.0
const AGGRO_SPEED  = 55.0

var player_ref: Node2D = null

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture  = Sprites.characters["wolf"]
	sprite.hframes  = 2
	sprite.vframes  = 1
	sprite.frame    = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_new_wander()

func _physics_process(delta):
	if is_ui_active():
		velocity = Vector2.ZERO
		return

	var aggroed = false
	if player_ref and player_ref.position.distance_to(position) < AGGRO_RANGE:
		aggroed = true

	if aggroed:
		var dir = (player_ref.position - position).normalized()
		velocity = dir * AGGRO_SPEED
		sprite.frame = 1
	else:
		wander_timer -= delta
		if wander_timer <= 0:
			_new_wander()
		velocity = wander_vel
		sprite.frame = 1 if velocity.length() > 1 else 0

	# Flip sprite
	if velocity.x < -0.5:
		sprite.flip_h = true
	elif velocity.x > 0.5:
		sprite.flip_h = false

	move_and_slide()

func _new_wander():
	wander_timer = randf_range(1.8, 4.0)
	if randf() < 0.35:
		wander_vel = Vector2.ZERO          # pause
	else:
		var angle = randf() * TAU
		wander_vel = Vector2(cos(angle), sin(angle)) * WANDER_SPEED

func is_ui_active() -> bool:
	var g = get_tree().get_first_node_in_group("game")
	if g and g.has_method("is_ui_blocked"):
		return g.is_ui_blocked()
	return false

func get_battle_config() -> Dictionary:
	return {
		"name":       "Wild Wolf",
		"icon":       "🐺",
		"hp":         hp,
		"max_hp":     max_hp,
		"attack":     attack,
		"exp_reward": 50,
		"gold_reward": 5,
		"loot": [{ "id": "wolf_pelt", "name": "Wolf Pelt", "qty": 1 }],
		"type":       "wolf"
	}
