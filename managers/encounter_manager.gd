extends Node

var slimes_list = []
var wolves_list = []
var goblins_list = []
var forest_wolves_list = []
var boss_ref = null
var in_battle = false

signal battle_started(enemy_node, config)

const WOLF_SCENE = preload("res://scenes/wolf.tscn")
const GOBLIN_SCENE = preload("res://scenes/goblin.tscn")
const SLIME_SCENE = preload("res://scenes/slime.tscn")

var player_ref: Node2D

func spawn_boss_goblin_chief(parent_node: Node2D, pos: Vector2):
	if is_instance_valid(boss_ref):
		boss_ref.queue_free()
	boss_ref = null

	var script_res = load("res://scenes/goblin_chief.gd")
	var boss = CharacterBody2D.new()
	boss.name = "GoblinChiefBoss"
	boss.set_script(script_res)
	
	# Add Sprite2D child
	var spr = Sprite2D.new()
	spr.name = "Sprite2D"
	boss.add_child(spr)
	
	# Add CollisionShape2D child
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 16.0
	col.shape = shape
	boss.add_child(col)

	boss.position = pos
	boss.player_ref = player_ref
	parent_node.add_child(boss)
	boss_ref = boss

func spawn_forest_wolves(parent_node: Node2D):
	for wolf in forest_wolves_list:
		if is_instance_valid(wolf):
			wolf.queue_free()
	forest_wolves_list.clear()

	var points = [
		Vector2(5 * 32 + 16, 4 * 32 + 16),
		Vector2(14 * 32 + 16, 3 * 32 + 16),
		Vector2(18 * 32 + 16, 8 * 32 + 16),
		Vector2(12 * 32 + 16, 12 * 32 + 16),
		Vector2(4 * 32 + 16, 13 * 32 + 16),
	]

	for pt in points:
		var wolf = WOLF_SCENE.instantiate()
		wolf.position = pt
		wolf.player_ref = player_ref
		var config = wolf.get_battle_config()
		config.hp = 60
		config.max_hp = 60
		config.attack = 10
		config.exp_reward = 65
		config.gold_reward = 10
		wolf.max_hp = 60
		wolf.hp = 60
		wolf.attack = 10
		parent_node.add_child(wolf)
		forest_wolves_list.append(wolf)

func spawn_wolves(parent_node: Node2D):
	for wolf in wolves_list:
		if is_instance_valid(wolf):
			wolf.queue_free()
	wolves_list.clear()

	var wolf_points = [
		Vector2(5 * 32 + 16, 6 * 32 + 16),
		Vector2(25 * 32 + 16, 8 * 32 + 16),
		Vector2(8 * 32 + 16, 24 * 32 + 16),
		Vector2(26 * 32 + 16, 22 * 32 + 16),
		Vector2(12 * 32 + 16, 18 * 32 + 16),
	]

	for pt in wolf_points:
		var wolf = WOLF_SCENE.instantiate()
		wolf.position = pt
		wolf.player_ref = player_ref
		parent_node.add_child(wolf)
		wolves_list.append(wolf)

func spawn_quest_slimes(parent_node: Node2D):
	for slime in slimes_list:
		if is_instance_valid(slime):
			slime.queue_free()
	slimes_list.clear()

	var points = [
		Vector2(10 * 32 + 16, 15 * 32 + 16),
		Vector2(22 * 32 + 16, 14 * 32 + 16),
		Vector2(15 * 32 + 16, 22 * 32 + 16),
		Vector2(25 * 32 + 16, 18 * 32 + 16)
	]

	for pt in points:
		var slime = SLIME_SCENE.instantiate()
		slime.position = pt
		parent_node.add_child(slime)
		slimes_list.append(slime)

func spawn_quest_goblins(parent_node: Node2D):
	for goblin in goblins_list:
		if is_instance_valid(goblin):
			goblin.queue_free()
	goblins_list.clear()

	var points = [
		Vector2(5 * 32 + 16, 3 * 32 + 16),
		Vector2(14 * 32 + 16, 5 * 32 + 16),
		Vector2(10 * 32 + 16, 8 * 32 + 16),
	]

	for pt in points:
		var goblin = GOBLIN_SCENE.instantiate()
		goblin.position = pt
		goblin.player_ref = player_ref
		parent_node.add_child(goblin)
		goblins_list.append(goblin)

func start_battle(target_node):
	in_battle = true
	var config = target_node.get_battle_config()
	emit_signal("battle_started", target_node, config)

func cleanup_dead():
	for i in range(slimes_list.size() - 1, -1, -1):
		if not is_instance_valid(slimes_list[i]):
			slimes_list.remove_at(i)
	for i in range(wolves_list.size() - 1, -1, -1):
		if not is_instance_valid(wolves_list[i]):
			wolves_list.remove_at(i)
	for i in range(goblins_list.size() - 1, -1, -1):
		if not is_instance_valid(goblins_list[i]):
			goblins_list.remove_at(i)
	for i in range(forest_wolves_list.size() - 1, -1, -1):
		if not is_instance_valid(forest_wolves_list[i]):
			forest_wolves_list.remove_at(i)

func get_respawn_timer(map_name: String) -> float:
	if map_name == "plains" and wolves_list.size() < 2:
		return 15.0
	if map_name == "south_forest" and forest_wolves_list.size() < 2:
		return 15.0
	return -1.0
