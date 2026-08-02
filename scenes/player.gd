extends CharacterBody2D

const WALK_SPEED = 132.0
const SPRINT_SPEED = 286.0

var dir = "down"
var anim_frame = 0
var anim_time = 0.0
var is_walking = false

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = Sprites.characters["hero"]
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.frame = 0

func _physics_process(delta):
	if is_ui_active():
		velocity = Vector2.ZERO
		is_walking = false
		anim_frame = 0
		update_sprite_frame()
		return

	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
		dir = "up"
	elif Input.is_action_pressed("move_down"):
		input_vector.y += 1
		dir = "down"
	
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
		dir = "left"
	elif Input.is_action_pressed("move_right"):
		input_vector.x += 1
		dir = "right"
		
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		var is_sprinting = Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL)
		var current_speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
		velocity = input_vector * current_speed
		is_walking = true
		
		var anim_step_time = 0.08 if is_sprinting else 0.12
		anim_time += delta
		if anim_time >= anim_step_time:
			anim_frame = (anim_frame + 1) % 4
			anim_time = 0.0
	else:
		velocity = Vector2.ZERO
		is_walking = false
		anim_frame = 0
		anim_time = 0.0
		
	move_and_slide()
	update_sprite_frame()

func is_ui_active() -> bool:
	var game_node = get_parent()
	if game_node and game_node.has_method("is_ui_blocked"):
		return game_node.is_ui_blocked()
	return false

func update_sprite_frame():
	var row = 0
	match dir:
		"down": row = 0
		"right": row = 1
		"left": row = 2
		"up": row = 3
	
	var col = 0
	if is_walking:
		var cycle = [1, 0, 2, 0] # Step left, Idle, Step right, Idle
		col = cycle[anim_frame]
	
	sprite.frame = row * 3 + col


