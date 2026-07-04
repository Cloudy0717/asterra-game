extends Node2D

var current_map = "cabin"

@onready var main_menu = $UI/MainMenu
@onready var hud = $UI/HUD
@onready var dialogue_box = $UI/DialogueBox
@onready var naming_screen = $UI/NamingScreen
@onready var inventory_screen = $UI/InventoryScreen
@onready var status_screen = $UI/StatusScreen
@onready var settings_screen = $UI/SettingsScreen
@onready var fade_rect = $UI/FadeLayer/FadeRect
@onready var player = $Player
@onready var camera = $Player/Camera2D

@onready var cabin_map_node = $Maps/Cabin
@onready var plains_map_node = $Maps/Plains
@onready var guild_map_node = $Maps/GuildHall
@onready var stone_claw_map_node = $Maps/StoneClawPass
var south_forest_map_node: Node2D

var cabin_solids = []
var plains_solids = []
var guild_solids = []
var stone_claw_solids = []
var south_forest_solids = []

var herbs_list = []
var vital_herbs_list = []
var slimes_list = []
var wolves_list = []
var goblins_list = []
var forest_wolves_list = []
var in_battle = false

const SLIME_SCENE = preload("res://scenes/slime.tscn")
const HERB_SCENE = preload("res://scenes/herb.tscn")
const VITAL_HERB_SCENE = preload("res://scenes/vital_herb.tscn")

const LINA_SCENE = preload("res://scenes/lina.tscn")
const BOARD_SCENE = preload("res://scenes/bulletin_board.tscn")
const WOLF_SCENE = preload("res://scenes/wolf.tscn")
const GOBLIN_SCENE = preload("res://scenes/goblin.tscn")
const FIREPLACE_SCENE = preload("res://scenes/fireplace.tscn")

@onready var battle_screen = $UI/BattleScreen
@onready var shop_screen = $UI/ShopScreen

func _ready():
	add_to_group("game")
	hud.visible = false
	dialogue_box.visible = false
	naming_screen.visible = false
	inventory_screen.visible = false
	status_screen.visible = false
	settings_screen.visible = false
	battle_screen.visible = false
	shop_screen.visible = false
	fade_rect.color.a = 0.0
	
	# Connect UI actions
	main_menu.new_game_pressed.connect(start_new_game_flow)
	main_menu.continue_pressed.connect(load_saved_game)
	main_menu.settings_pressed.connect(func(): settings_screen.show_screen())
	
	hud.btn_action_pressed.connect(handle_action_press)
	hud.btn_inventory_pressed.connect(func(): inventory_screen.show_screen())
	hud.btn_status_pressed.connect(func(): status_screen.show_screen())
	hud.btn_menu_pressed.connect(return_to_main_menu)
	shop_screen.shop_closed.connect(_on_shop_closed)
	shop_screen.item_purchased.connect(_on_item_purchased)
	
	naming_screen.name_confirmed.connect(start_actual_game)
	
	south_forest_map_node = Node2D.new()
	south_forest_map_node.name = "SouthForest"
	$Maps.add_child(south_forest_map_node)
	build_south_forest_map()

	build_cabin_map()
	build_plains_map()
	build_guild_map()
	build_stone_claw_pass_map()

	main_menu.show_menu()
	player.visible = false
	cabin_map_node.process_mode = PROCESS_MODE_DISABLED
	plains_map_node.process_mode = PROCESS_MODE_DISABLED
	guild_map_node.process_mode = PROCESS_MODE_DISABLED
	stone_claw_map_node.process_mode = PROCESS_MODE_DISABLED
	south_forest_map_node.process_mode = PROCESS_MODE_DISABLED
	cabin_map_node.visible = false
	plains_map_node.visible = false
	guild_map_node.visible = false
	stone_claw_map_node.visible = false
	south_forest_map_node.visible = false

# --- Map Builders ---
func build_cabin_map():
	var rows = 10
	var cols = 12
	cabin_solids.resize(rows)
	for r in range(rows):
		cabin_solids[r] = []
		cabin_solids[r].resize(cols)
		for c in range(cols):
			var tile_name = "wood_floor"
			var solid = false
			
			if r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
				tile_name = "brick_wall"
				solid = true
			
			# Doorway exit
			if r == rows - 1 and c == 6:
				tile_name = "wood_floor"
				solid = false
				
			cabin_solids[r][c] = solid
			spawn_tile(cabin_map_node, tile_name, c, r, solid)
			
	# Spawn Furniture
	spawn_object(cabin_map_node, "bed", Vector2(2 * 32, 2 * 32), Rect2(0, 0, 32, 64), true)
	spawn_object(cabin_map_node, "table", Vector2(5 * 32, 4 * 32), Rect2(0, 0, 32, 32), true)
	
	# Animated Fireplace (scene-based)
	var fireplace = FIREPLACE_SCENE.instantiate()
	fireplace.position = Vector2(8 * 32, 1 * 32 + 16)
	cabin_map_node.add_child(fireplace)
	# Collision for fireplace area
	var fp_body = StaticBody2D.new()
	fp_body.position = fireplace.position
	fp_body.collision_layer = 1
	fp_body.collision_mask = 2
	var fp_shape = CollisionShape2D.new()
	var fp_rect = RectangleShape2D.new()
	fp_rect.size = Vector2(64, 32)
	fp_shape.shape = fp_rect
	fp_body.add_child(fp_shape)
	cabin_map_node.add_child(fp_body)

	var lina = LINA_SCENE.instantiate()
	lina.position = Vector2(6 * 32 + 16, 4 * 32 + 16)
	cabin_map_node.add_child(lina)

func build_plains_map():
	var rows = 32
	var cols = 32
	plains_solids.resize(rows)
	
	# Setup random seed for consistent terrain layout
	var rng_plains = RandomNumberGenerator.new()
	rng_plains.seed = 42
	
	for r in range(rows):
		plains_solids[r] = []
		plains_solids[r].resize(cols)
		for c in range(cols):
			var tile_name = "grass"
			var solid = false
			
			if r == 12 or r == 13:
				tile_name = "dirt"
			if c == 16 and r > 4 and r < 20:
				tile_name = "dirt"
			if c == 4 and r > 4 and r < 28:
				tile_name = "dirt"
				
			if tile_name == "grass":
				var rand = rng_plains.randf()
				if rand < 0.08:
					tile_name = "flower"
				elif rand < 0.12:
					tile_name = "stone"
					solid = true
					
			# Gates: north to Stone Claw Pass, south to future area
			if (r == 0 and c == 16) or (r == rows - 1 and c == 16):
				tile_name = "dirt"
				solid = false
			elif r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
				tile_name = "stone"
				solid = true
				
			plains_solids[r][c] = solid
			spawn_tile(plains_map_node, tile_name, c, r, solid)
			
	# Guild exterior overlay on plains (cols 2 to 6, rows 7 to 11)
	for r in range(7, 12):
		for c in range(2, 7):
			plains_solids[r][c] = true
			var tile_name = "brick_wall"
			if r == 7 or r == 8:
				tile_name = "roof"
			if r == 11 and c == 4:
				tile_name = "wood_floor"
				plains_solids[r][c] = false

			spawn_tile(plains_map_node, tile_name, c, r, plains_solids[r][c])

	# Cabin exterior overlay on plains (cols 13 to 19, rows 7 to 11)
	for r in range(7, 12):
		for c in range(13, 20):
			plains_solids[r][c] = true
			var tile_name = "brick_wall"
			if r == 7 or r == 8:
				tile_name = "roof"
			if r == 11 and c == 16:
				tile_name = "wood_floor"
				plains_solids[r][c] = false
				
			# Spawn brick/roof sprites
			spawn_tile(plains_map_node, tile_name, c, r, plains_solids[r][c])
			
	# Spawn Bulletin Board outside door
	var board = BOARD_SCENE.instantiate()
	board.position = Vector2(18 * 32 + 16, 13 * 32 + 16)
	plains_map_node.add_child(board)
	
	var rng_herb = RandomNumberGenerator.new()
	rng_herb.seed = 999
	for i in range(6):
		var hx = (2 + rng_herb.randi() % 28) * 32
		var hy = (2 + rng_herb.randi() % 28) * 32
		@warning_ignore("integer_division")
		var tx = hx / 32
		@warning_ignore("integer_division")
		var ty = hy / 32
		if not plains_solids[ty][tx]:
			var herb = HERB_SCENE.instantiate()
			herb.position = Vector2(hx + 16, hy + 16)
			plains_map_node.add_child(herb)
			herbs_list.append(herb)
	
	spawn_wolves()
	spawn_vital_herbs()

func build_guild_map():
	var rows = 12
	var cols = 16
	guild_solids.resize(rows)
	for r in range(rows):
		guild_solids[r] = []
		guild_solids[r].resize(cols)
		for c in range(cols):
			var tile_name = "wood_floor"
			var solid = false

			if r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
				tile_name = "brick_wall"
				solid = true

			if r == rows - 1 and c == 8:
				tile_name = "wood_floor"
				solid = false

			guild_solids[r][c] = solid
			spawn_tile(guild_map_node, tile_name, c, r, solid)

	# Counter desk (centre, top)
	spawn_object(guild_map_node, "guild_counter", Vector2(5 * 32, 2 * 32), Rect2(0, 0, 64, 32), true)
	# Tables
	spawn_object(guild_map_node, "table", Vector2(11 * 32, 4 * 32), Rect2(0, 0, 32, 32), true)
	spawn_object(guild_map_node, "table", Vector2(11 * 32, 7 * 32), Rect2(0, 0, 32, 32), true)
	# Notice board on wall
	spawn_object(guild_map_node, "bulletin_board", Vector2(2 * 32, 2 * 32), Rect2(0, 0, 32, 32), false)
	# Shop counter (bottom right)
	spawn_object(guild_map_node, "guild_counter", Vector2(12 * 32, 8 * 32), Rect2(0, 0, 64, 32), true)

	# NPCs
	spawn_npc(guild_map_node, "receptionist", Vector2(5 * 32 + 16, 2 * 32 - 4))
	spawn_npc(guild_map_node, "garrick", Vector2(11 * 32 + 16, 4 * 32 + 8))
	spawn_npc(guild_map_node, "shopkeeper", Vector2(12 * 32 + 32, 8 * 32 - 4))

func build_stone_claw_pass_map():
	var rows = 12
	var cols = 20
	stone_claw_solids.resize(rows)
	var rng_sc = RandomNumberGenerator.new()
	rng_sc.seed = 123
	for r in range(rows):
		stone_claw_solids[r] = []
		stone_claw_solids[r].resize(cols)
		for c in range(cols):
			var tile_name = "grass"
			var solid = false

			if r <= 1 or r >= rows - 2 or c <= 1 or c >= cols - 2:
				tile_name = "stone"
				solid = true

			# Entrance path: col 10, rows 9-11 (clear path from south gate inward)
			if c == 10 and r >= rows - 3:
				tile_name = "dirt"
				solid = false

			# Rocky terrain: more stone inside
			if not solid and tile_name == "grass":
				var rand = rng_sc.randf()
				if rand < 0.25:
					tile_name = "stone"
					solid = true
				elif rand < 0.35:
					tile_name = "dirt"

			stone_claw_solids[r][c] = solid
			spawn_tile(stone_claw_map_node, tile_name, c, r, solid)

	# Sign at entrance (off to the side, not blocking the path)
	spawn_object(stone_claw_map_node, "bulletin_board", Vector2(8 * 32, 9 * 32), Rect2(0, 0, 32, 32), false)

# --- South Forest (formerly "under construction") ---
func build_south_forest_map():
	var rows = 16
	var cols = 20
	south_forest_solids.resize(rows)
	var rng = RandomNumberGenerator.new()
	rng.seed = 456
	for r in range(rows):
		south_forest_solids[r] = []
		south_forest_solids[r].resize(cols)
		for c in range(cols):
			var tile_name = "grass"
			var solid = false

			if r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
				tile_name = "stone"
				solid = true

			if r == 0 and c == 10:
				tile_name = "dirt"
				solid = false

			if r == rows - 1 and c == 10:
				tile_name = "dirt"
				solid = false

			# Pond (cols 4-8, rows 5-9)
			if c >= 4 and c <= 8 and r >= 5 and r <= 9:
				tile_name = "stone"
				solid = true

			if c >= 5 and c <= 7 and r >= 6 and r <= 8:
				tile_name = "dirt"
				solid = false

			# Dirt path along the middle
			if c == 10 and r >= 1 and r <= rows - 2:
				tile_name = "dirt"
				solid = false

			if not solid and tile_name == "grass":
				var rand = rng.randf()
				if rand < 0.12:
					tile_name = "stone"
					solid = true
				elif rand < 0.20:
					tile_name = "flower"

			south_forest_solids[r][c] = solid
			spawn_tile(south_forest_map_node, tile_name, c, r, solid)

	# Tree decorations (avoid path at col 10)
	for i in range(10):
		var tx = 2 + rng.randi() % (cols - 4)
		var ty = 2 + rng.randi() % (rows - 4)
		if tx == 10 or tx == 9 or tx == 11:
			continue
		if not south_forest_solids[ty][tx]:
			spawn_object(south_forest_map_node, "tree", Vector2(tx * 32, ty * 32), Rect2(0, 0, 32, 32), false)

	# Sign at entrance
	spawn_object(south_forest_map_node, "bulletin_board", Vector2(8 * 32, 1 * 32), Rect2(0, 0, 32, 32), false)

func spawn_forest_wolves():
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
		wolf.player_ref = player
		var config = wolf.get_battle_config()
		config.hp = 60
		config.max_hp = 60
		config.attack = 10
		config.exp_reward = 65
		config.gold_reward = 10
		wolf.max_hp = 60
		wolf.hp = 60
		wolf.attack = 10
		south_forest_map_node.add_child(wolf)
		forest_wolves_list.append(wolf)

func spawn_tile(parent_node: Node2D, tile_name: String, c: int, r: int, solid: bool):
	var sprite = Sprite2D.new()
	sprite.texture = Sprites.tiles[tile_name]
	sprite.position = Vector2(c * 32 + 16, r * 32 + 16)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent_node.add_child(sprite)
	
	if solid:
		# Add a StaticBody2D for collision
		var body = StaticBody2D.new()
		body.position = Vector2(c * 32 + 16, r * 32 + 16)
		body.collision_layer = 1
		body.collision_mask = 2
		
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(32, 32)
		shape.shape = rect
		
		body.add_child(shape)
		parent_node.add_child(body)

func remove_herb(herb):
	herbs_list.erase(herb)

func remove_vital_herb(herb):
	vital_herbs_list.erase(herb)

func spawn_npc(parent_node: Node2D, npc_key: String, pos: Vector2):
	var sprite = Sprite2D.new()
	sprite.texture = Sprites.characters.get(npc_key)
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent_node.add_child(sprite)

func spawn_object(parent_node: Node2D, object_name: String, pos: Vector2, rect: Rect2, solid: bool):
	var sprite = Sprite2D.new()
	sprite.texture = Sprites.objects[object_name]
	sprite.position = pos + rect.size / 2
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent_node.add_child(sprite)
	
	if solid:
		var body = StaticBody2D.new()
		body.position = pos + rect.size / 2
		body.collision_layer = 1
		body.collision_mask = 2
		
		var shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = rect.size
		shape.shape = rect_shape
		
		body.add_child(shape)
		parent_node.add_child(body)

# --- Game Flow Controllers ---
func start_new_game_flow():
	main_menu.hide_menu()
	naming_screen.show_screen()

func start_actual_game():
	main_menu.hide_menu()
	naming_screen.hide_screen()
	hud.visible = true
	player.visible = true
	
	# Release keyboard focus from LineEdit/Buttons so game receives inputs
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()
	
	# Setup camera limits for cabin (initial map)
	current_map = "cabin"
	cabin_map_node.process_mode = PROCESS_MODE_INHERIT
	cabin_map_node.visible = true
	plains_map_node.process_mode = PROCESS_MODE_DISABLED
	plains_map_node.visible = false
	
	configure_camera_limits(12, 10)
	
	# Spawn player in cabin
	player.position = Vector2(5 * 32 + 16, 5 * 32 + 16)
	player.dir = "down"
	
	hud.update_hud()
	
	# Trigger Intro Dialogue
	get_tree().create_timer(1.0).timeout.connect(func():
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Morning, " + GameState.player.name + "! You are finally awake." },
			{ "speaker": "Lina", "avatar": "lina", "text": "I was looking at our pantry... we are almost completely out of food, and we only have a few copper coins left." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Since you registered as an E-Rank mercenary, maybe you could go outside to the plains and check the Bulletin Board for a simple job?" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Don't worry, Lina. I will make sure we get through this. I will go check the board right now." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Thank you! Please be careful. There have been reports of wild slimes bouncing around nearby." }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.quest.state = 1
			hud.update_hud()
			GameState.save_game()
		)
	)

func load_saved_game():
	if GameState.load_game():
		main_menu.hide_menu()
		hud.visible = true
		player.visible = true
		
		# Release keyboard focus from UI so game receives inputs
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
		
		# Detect where the player was
		# For this simple game, we spawn them inside the cabin on load
		current_map = "cabin"
		cabin_map_node.process_mode = PROCESS_MODE_INHERIT
		cabin_map_node.visible = true
		plains_map_node.process_mode = PROCESS_MODE_DISABLED
		plains_map_node.visible = false
		
		configure_camera_limits(12, 10)
		player.position = Vector2(5 * 32 + 16, 5 * 32 + 16)
		player.dir = "down"
		
		if GameState.quest.state == 2:
			spawn_quest_slimes()

		hud.update_hud()

func return_to_main_menu():
	GameState.save_game()
	dialogue_box.hide_box()
	hud.visible = false
	player.visible = false
	
	cabin_map_node.process_mode = PROCESS_MODE_DISABLED
	cabin_map_node.visible = false
	plains_map_node.process_mode = PROCESS_MODE_DISABLED
	plains_map_node.visible = false
	guild_map_node.process_mode = PROCESS_MODE_DISABLED
	guild_map_node.visible = false
	stone_claw_map_node.process_mode = PROCESS_MODE_DISABLED
	stone_claw_map_node.visible = false
	south_forest_map_node.process_mode = PROCESS_MODE_DISABLED
	south_forest_map_node.visible = false
	
	main_menu.show_menu()

func configure_camera_limits(cols: int, rows: int):
	# Camera zoom is 2.0x, viewport is 800x600.
	# Viewport width in world coords: 800 / 2 = 400.
	# Viewport height in world coords: 600 / 2 = 300.
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = cols * 32
	camera.limit_bottom = rows * 32

func is_ui_blocked() -> bool:
	return main_menu.visible or dialogue_box.visible or naming_screen.visible or \
		   inventory_screen.visible or status_screen.visible or settings_screen.visible or \
		   shop_screen.visible or in_battle

func _input(event: InputEvent):
	# If player is typing their name, don't trigger game controls
	if naming_screen.visible:
		return

	if event.is_action_pressed("toggle_menu"):
		if inventory_screen.visible:
			inventory_screen.hide_screen()
		elif status_screen.visible:
			status_screen.hide_screen()
		elif settings_screen.visible:
			settings_screen.hide_screen()
		elif not main_menu.visible:
			return_to_main_menu()
	# I: toggle inventory
	elif event.is_action_pressed("toggle_inventory"):
		if not is_ui_blocked():
			inventory_screen.show_screen()
	# C: toggle character status
	elif event.is_action_pressed("toggle_status"):
		if not is_ui_blocked():
			status_screen.show_screen()
	# E or Space: interact / advance dialogue
	elif event.is_action_pressed("interact"):
		if dialogue_box.visible:
			dialogue_box.on_dialogue_clicked()
		elif not is_ui_blocked():
			handle_action_press()

func _physics_process(_delta):
	if is_ui_blocked():
		return
		
	# Check map transitions
	var px = int(player.position.x / 32.0)
	var py = int(player.position.y / 32.0)
	
	if current_map == "cabin":
		if py == 9 and px == 6:
			transition_to_map("plains", Vector2(16 * 32 + 16, 12 * 32 + 16), "down")
	elif current_map == "plains":
		if py == 11 and px == 16:
			transition_to_map("cabin", Vector2(6 * 32 + 16, 8 * 32 + 16), "up")
		if py == 11 and px == 4:
			transition_to_map("guild", Vector2(8 * 32 + 16, 10 * 32 + 16), "up")
		if py == 0 and px == 16:
			transition_to_map("stone_claw", Vector2(10 * 32 + 16, 10 * 32 + 16), "up")
		if py == 31 and px == 16:
			transition_to_map("south_forest", Vector2(10 * 32 + 16, 1 * 32 + 16), "up")

		if not in_battle:
			for slime in slimes_list:
				if is_instance_valid(slime) and player.position.distance_to(slime.position) < 22:
					start_slime_battle(slime)
					break
			if in_battle: return
			for wolf in wolves_list:
				if is_instance_valid(wolf) and player.position.distance_to(wolf.position) < 22:
					start_wolf_battle(wolf)
					break
			if in_battle: return
			for goblin in goblins_list:
				if is_instance_valid(goblin) and player.position.distance_to(goblin.position) < 22:
					start_goblin_battle(goblin)
					break
	elif current_map == "guild":
		if py == 11 and px == 8:
			transition_to_map("plains", Vector2(4 * 32 + 16, 14 * 32 + 16), "up")
	elif current_map == "stone_claw":
		if py == 11 and px == 10:
			transition_to_map("plains", Vector2(16 * 32 + 16, 1 * 32 + 16), "down")

		if not in_battle:
			for goblin in goblins_list:
				if is_instance_valid(goblin) and player.position.distance_to(goblin.position) < 22:
					start_goblin_battle(goblin)
					break
	elif current_map == "south_forest":
		if py == 0 and px == 10:
			transition_to_map("plains", Vector2(16 * 32 + 16, 30 * 32 + 16), "up")

		if not in_battle:
			for wolf in forest_wolves_list:
				if is_instance_valid(wolf) and player.position.distance_to(wolf.position) < 22:
					start_wolf_battle(wolf)
					break

func transition_to_map(map_name: String, new_pos: Vector2, new_dir: String):
	# Play fade in/out sequence
	player.process_mode = PROCESS_MODE_DISABLED
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.2)
	tween.tween_callback(func():
		current_map = map_name
		cabin_map_node.process_mode = PROCESS_MODE_DISABLED
		cabin_map_node.visible = false
		plains_map_node.process_mode = PROCESS_MODE_DISABLED
		plains_map_node.visible = false
		guild_map_node.process_mode = PROCESS_MODE_DISABLED
		guild_map_node.visible = false
		stone_claw_map_node.process_mode = PROCESS_MODE_DISABLED
		stone_claw_map_node.visible = false
		south_forest_map_node.process_mode = PROCESS_MODE_DISABLED
		south_forest_map_node.visible = false

		match map_name:
			"cabin":
				cabin_map_node.process_mode = PROCESS_MODE_INHERIT
				cabin_map_node.visible = true
				configure_camera_limits(12, 10)
			"plains":
				plains_map_node.process_mode = PROCESS_MODE_INHERIT
				plains_map_node.visible = true
				configure_camera_limits(32, 32)
				if vital_herbs_list.is_empty():
					spawn_vital_herbs()
				if GameState.quest.state == 2 and slimes_list.is_empty():
					spawn_quest_slimes()
			"stone_claw":
				stone_claw_map_node.process_mode = PROCESS_MODE_INHERIT
				stone_claw_map_node.visible = true
				configure_camera_limits(20, 12)
				if vital_herbs_list.is_empty():
					spawn_vital_herbs()
				if GameState.quest.state == 7:
					GameState.quest.state = 8
					spawn_quest_goblins()
					hud.update_hud()
					GameState.save_game()
					var msg = [
						{ "speaker": "System", "avatar": "⚔️", "text": "You arrive at Stone Claw Pass. Goblins lurk in the tall grass — defeat 3 to clear the route!" }
					]
					GameState.emit_signal("show_dialogue", msg, null)
				if GameState.quest.state == 8:
					spawn_quest_goblins()
			"guild":
				guild_map_node.process_mode = PROCESS_MODE_INHERIT
				guild_map_node.visible = true
				configure_camera_limits(16, 12)
				if GameState.quest.state == 9:
					GameState.quest.state = 10
					hud.update_hud()
					GameState.save_game()
			"south_forest":
				south_forest_map_node.process_mode = PROCESS_MODE_INHERIT
				south_forest_map_node.visible = true
				configure_camera_limits(20, 16)
				if forest_wolves_list.is_empty():
					spawn_forest_wolves()
				if vital_herbs_list.is_empty():
					spawn_vital_herbs()
				
		player.position = new_pos
		player.dir = new_dir
		player.update_sprite_frame()
	)
	tween.tween_property(fade_rect, "color:a", 0.0, 0.2)
	tween.tween_callback(func():
		player.process_mode = PROCESS_MODE_INHERIT
	)

func spawn_quest_goblins():
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
		goblin.player_ref = player
		stone_claw_map_node.add_child(goblin)
		goblins_list.append(goblin)

func spawn_vital_herbs():
	for herb in vital_herbs_list:
		if is_instance_valid(herb):
			herb.queue_free()
	vital_herbs_list.clear()

	var target_node: Node2D
	var solids_ref: Array
	var map_cols: int
	var map_rows: int

	match current_map:
		"plains":
			target_node = plains_map_node
			solids_ref = plains_solids
			map_cols = 32
			map_rows = 32
		"stone_claw":
			target_node = stone_claw_map_node
			solids_ref = stone_claw_solids
			map_cols = 20
			map_rows = 12
		_:
			return

	var rng_vital = RandomNumberGenerator.new()
	rng_vital.seed = 99
	for i in range(4):
		var hx = (2 + rng_vital.randi() % (map_cols - 4)) * 32
		var hy = (2 + rng_vital.randi() % (map_rows - 4)) * 32
		@warning_ignore("integer_division")
		var tx = hx / 32
		@warning_ignore("integer_division")
		var ty = hy / 32
		if not solids_ref[ty][tx]:
			var herb = VITAL_HERB_SCENE.instantiate()
			herb.position = Vector2(hx + 16, hy + 16)
			target_node.add_child(herb)
			vital_herbs_list.append(herb)

func spawn_quest_slimes():
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
		plains_map_node.add_child(slime)
		slimes_list.append(slime)

# --- Gameplay Interaction Actions ---
func handle_action_press():
	if dialogue_box.visible:
		dialogue_box.on_dialogue_clicked()
	else:
		handle_interaction()

func handle_interaction():
	if current_map == "cabin":
		var lina_pos = Vector2(6 * 32 + 16, 4 * 32 + 16)
		if player.position.distance_to(lina_pos) < 45:
			trigger_lina_dialogue()
			return

		var bed_pos = Vector2(2 * 32 + 16, 2 * 32 + 32)
		if player.position.distance_to(bed_pos) < 40:
			if GameState.player.hp < GameState.player.max_hp or GameState.player.mp < GameState.player.max_mp:
				GameState.player.hp = GameState.player.max_hp
				GameState.player.mp = GameState.player.max_mp
				var msg = [{ "speaker": "System", "avatar": "🛏️", "text": "You lie down and rest. HP and MP fully restored!" }]
				GameState.emit_signal("show_dialogue", msg, func():
					hud.update_hud()
					GameState.save_game()
				)
			else:
				var msg = [{ "speaker": "System", "avatar": "🛏️", "text": "You're not tired yet. Your HP and MP are already full." }]
				GameState.emit_signal("show_dialogue", msg, null)
			return

	elif current_map == "plains":
		var board_pos = Vector2(18 * 32 + 16, 13 * 32 + 16)
		if player.position.distance_to(board_pos) < 45:
			trigger_board_dialogue()
			return

		for herb in herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()
				return

		for herb in vital_herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()
				return

	elif current_map == "guild":
		# Interact with NPCs by proximity
		var receptionist_pos = Vector2(5 * 32 + 16, 2 * 32 - 4)
		if player.position.distance_to(receptionist_pos) < 50:
			trigger_guild_dialogue()
			return

		var garrick_pos = Vector2(11 * 32 + 16, 4 * 32 + 8)
		if player.position.distance_to(garrick_pos) < 45:
			trigger_mentor_dialogue()
			return

		var board_pos = Vector2(2 * 32 + 16, 2 * 32 + 16)
		if player.position.distance_to(board_pos) < 40:
			trigger_board_dialogue()
			return

		var shopkeeper_pos = Vector2(12 * 32 + 32, 8 * 32 - 4)
		if player.position.distance_to(shopkeeper_pos) < 50:
			if GameState.quest.state >= 10:
				shop_screen.show_screen()
			else:
				var msg = [{ "speaker": "Shopkeeper", "avatar": "🛒", "text": "Welcome! Feel free to browse once you've registered with the guild." }]
				GameState.emit_signal("show_dialogue", msg, null)
			return

	elif current_map == "stone_claw":
		var sign_pos = Vector2(8 * 32 + 16, 9 * 32 + 16)
		if player.position.distance_to(sign_pos) < 45:
			var steps = [
				{ "speaker": "Sign", "avatar": "🪧", "text": "[b]Stone Claw Pass[/b]\nElevation: 840m\nWatch for goblin ambushes. Travel in groups recommended.\n— Asterra Territorial Authority" }
			]
			GameState.emit_signal("show_dialogue", steps, null)
			return

		for herb in vital_herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()

	elif current_map == "south_forest":
		var sign_pos = Vector2(8 * 32 + 16, 1 * 32 + 24)
		if player.position.distance_to(sign_pos) < 45:
			var steps = [
				{ "speaker": "Sign", "avatar": "🪧", "text": "[b]Southern Forest[/b]\nWarning: Large wolf packs have been sighted in these woods.\nProceed with caution. — Asterra Territorial Authority" }
			]
			GameState.emit_signal("show_dialogue", steps, null)
			return

		for herb in vital_herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()

func trigger_lina_dialogue():
	var state = GameState.quest.state
	if state == 4:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Welcome back, brother! Did you find a job?" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Yes! I cleared the slimes near the village boundaries. The guild paid me 50 gold coins!" },
			{ "speaker": "Lina", "avatar": "lina", "text": "Wow, 50 gold! That's amazing. We can buy enough bread and dried meat to last for weeks!" },
			{ "speaker": "Lina", "avatar": "lina", "text": "Let me dress your clothes and mend your wear. Please rest for a bit." },
			{ "speaker": "System", "avatar": "✨", "text": "Lina's care has fully restored your HP and MP!" },
			{ "speaker": "Lina", "avatar": "lina", "text": "I believe in you, brother. One day, you will become the World's Strongest Mercenary!" }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.player.hp = GameState.player.max_hp
			GameState.player.mp = GameState.player.max_mp
			GameState.quest.state = 5
			hud.update_hud()
			GameState.save_game()
		)
	elif state == 5:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Take care out there, brother! Remember to equip your gear in the Inventory [I] before fighting monsters!" }
		]
		GameState.emit_signal("show_dialogue", steps, null)
	elif state == 11:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Hey brother! Did you check out the Weapon Shop in town? I heard they have some great deals on iron swords!" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Good idea, Lina. I'll head over and see what they've got before my next job." }
		]
		GameState.emit_signal("show_dialogue", steps, null)
	elif state == 12:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Brother! You're back! I heard from the villagers that you escorted a caravan through Stone Claw Pass!" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Yeah, it was rough — fought off a whole goblin ambush with an old mercenary named Garrick." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Goblins?! Are you hurt?! Let me check your wounds!" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "I'm fine, Lina. Thanks to the new gear I bought with the reward money." },
			{ "speaker": "Lina", "avatar": "lina", "text": "You've changed, brother. You look stronger already. I'm so proud of you." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Promise me you'll keep coming home safe, okay?" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "I promise, Lina. I'll become the World's Strongest Mercenary — for both of us." },
			{ "speaker": "System", "avatar": "✨", "text": "Chapter 2 Complete! Enjoy Free Play.\nTip: Wander the plains, fight monsters, and test your new gear!" }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.player.hp = GameState.player.max_hp
			GameState.player.mp = GameState.player.max_mp
			GameState.quest.state = 13
			hud.update_hud()
			GameState.save_game()
		)
	else:
		# Idle / no-quest greetings — randomized
		var greetings = [
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "Good morning, brother! Did you sleep well? The porridge is on the table if you're hungry." }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "Hey, " + GameState.player.name + "! Be careful out there, okay? Check the Bulletin Board outside to see how we can earn some gold." }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "Brother! I just finished mending your spare cloak. It should keep you warm on long hunts." },
				{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Thanks, Lina. I don't know what I'd do without you." },
				{ "speaker": "Lina", "avatar": "lina", "text": "You'd probably freeze! Now go earn us some gold, hero!" }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "I heard wolves have been spotted near the village. Please be careful if you go out!" }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "You know, one day when you become the World's Strongest Mercenary, we should move to a bigger house!" },
				{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Haha, I'll build you a mansion, Lina. That's a promise." }
			]
		]
		var picked = greetings[randi() % greetings.size()]
		GameState.emit_signal("show_dialogue", picked, null)

func trigger_guild_dialogue():
	var state = GameState.quest.state
	if state == 5:
		var steps = [
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Welcome to the Asterra Mercenary Guild! How can I help you today?" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "I just got promoted to D-Rank. I was told I should check in at the guild." },
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Ah, a fresh D-Rank! Congratulations. D-Rank opens up much better commissions — and bigger risks." },
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Take a look around. You might find a seasoned mercenary willing to show you the ropes. Good luck out there!" },
			{ "speaker": "System", "avatar": "✨", "text": "Quest Updated: Talk to the experienced mercenary at the table." }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.quest.state = 6
			hud.update_hud()
			GameState.save_game()
		)
	elif state == 10:
		var steps = [
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Welcome back! I heard you handled the goblin situation at Stone Claw Pass. Impressive work for a newly-promoted D-Rank!" },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "It was a good fight. The merchant paid well too." },
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Speaking of payment — you should visit the Weapon Shop and upgrade your gear. You'll need better equipment for higher-ranked quests." },
			{ "speaker": "System", "avatar": "✨", "text": "Quest Updated: Visit the Weapon Shop to gear up." }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.quest.state = 11
			hud.update_hud()
			GameState.save_game()
		)
	elif state == 11 or state == 12 or state == 13:
		var steps = [
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Getting stronger every day, I see. Keep it up, and you'll be C-Rank before you know it!" }
		]
		GameState.emit_signal("show_dialogue", steps, null)
	else:
		trigger_idle_guild()

func trigger_idle_guild():
	var greetings = [
		[{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Welcome to the guild. The quest board is on the wall if you need a commission." }],
		[{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Busy day today. Lots of adventurers coming and going." }],
		[{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Make sure to register any completed quests at the counter!" }]
	]
	GameState.emit_signal("show_dialogue", greetings[randi() % greetings.size()], null)

func trigger_mentor_dialogue():
	var state = GameState.quest.state
	if state == 6:
		var steps = [
			{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Hey, kid. You're the new D-Rank, right? Name's Garrick. I've been doing this job for twenty years." },
			{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "I need a hand with a caravan escort to Stone Claw Pass. The merchant pays 60 gold — I'll split it with you." },
			{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Stone Claw Pass? I heard there have been goblin sightings there." },
			{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Exactly why I need backup. A few goblins won't be a problem for two experienced fighters. What do you say?" },
			{
				"speaker": "Veteran Mercenary",
				"avatar": "⚔️",
				"text": "Ready to earn your first real payday?",
				"choices": [
					{ "text": "Accept the Escort Quest", "action": func(): accept_escort_quest() },
					{ "text": "Not yet, maybe later", "action": func(): dialogue_box.close_dialogue() }
				]
			}
		]
		GameState.emit_signal("show_dialogue", steps, null)
	else:
		var idle = [
			[{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Garrick's the name. If you ever need backup on a job, I'm your man." }],
			[{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Stone Claw Pass is no joke. Make sure your gear is up to snuff before heading there." }],
			[{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Hah, I remember my first D-Rank job. Feels like yesterday." }]
		]
		GameState.emit_signal("show_dialogue", idle[randi() % idle.size()], null)

func accept_escort_quest():
	dialogue_box.close_dialogue()
	GameState.quest.state = 7
	GameState.quest.goblins_killed = 0
	hud.update_hud()
	GameState.save_game()

	var steps = [
		{ "speaker": "Veteran Mercenary", "avatar": "⚔️", 		"text": "Good choice, kid! We head out at dawn. Meet me at Stone Claw Pass — head north from here through the plains gate, just past the outer plains." },
		{ "speaker": "System", "avatar": "✨", "text": "Quest Accepted: Caravan Escort to Stone Claw Pass.\nObjective: Head north through the plains gate to Stone Claw Pass. Goblins have been reported in the area." }
	]
	GameState.emit_signal("show_dialogue", steps, null)

func trigger_board_dialogue():
	var state = GameState.quest.state
	if state == 1:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== MERCENARY GUILD COMMISSION ======" },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Commission [E-Rank]: Slime Threat in the Outskirts\nDescription: Defeat 3 annoying wild slimes nearby.\nReward: 50 Gold, +10 Mercenary Reputation." },
			{
				"speaker": "Bulletin Board",
				"avatar": "📜",
				"text": "Do you accept this commission?",
				"choices": [
					{ "text": "Accept Quest", "action": func(): accept_commission() },
					{ "text": "Leave it", "action": func(): dialogue_box.close_dialogue() }
				]
			}
		]
		GameState.emit_signal("show_dialogue", steps, null)
	elif state == 2:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Quest Status: Defeat Slimes (" + str(GameState.quest.slimes_killed) + "/" + str(GameState.quest.slimes_required) + ")." },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Please return after defeating 3 slimes." }
		]
		GameState.emit_signal("show_dialogue", steps, null)
	elif state == 3:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== COMMISSION COMPLETED ======" },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "You have successfully eliminated 3 Slimes. Thank you for your service!" },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Received Reward: 50 Gold, +10 Mercenary Reputation!" }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.player.gold += 50;
			GameState.player.reputation += 10;
			GameState.quest.state = 4
			hud.update_hud()
			GameState.save_game()
		)
	else:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "No active E-rank quests currently available. Great job, rookie!" }
		]
		GameState.emit_signal("show_dialogue", steps, null)

func accept_commission():
	dialogue_box.close_dialogue()
	GameState.quest.state = 2
	GameState.quest.slimes_killed = 0
	hud.update_hud()
	GameState.save_game()
	
	spawn_quest_slimes()
	
	var steps = [
		{ "speaker": GameState.player.name, "avatar": "protagonist", "text": "Alright, 3 slimes. Time to equip my Rusty Sword from the inventory and defeat them!" }
	]
	GameState.emit_signal("show_dialogue", steps, null)

# ========================= WOLVES & TURN-BASED BATTLE =========================
func spawn_wolves():
	# Clear old wolves first
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
		wolf.player_ref = player
		plains_map_node.add_child(wolf)
		wolves_list.append(wolf)

func start_wolf_battle(wolf_node):
	in_battle = true
	var config = wolf_node.get_battle_config()
	battle_screen.start_battle(wolf_node, config)
	battle_screen.battle_ended.connect(on_battle_ended, CONNECT_ONE_SHOT)

func start_slime_battle(slime_node):
	in_battle = true
	var config = slime_node.get_battle_config()
	battle_screen.start_battle(slime_node, config)
	battle_screen.battle_ended.connect(on_battle_ended, CONNECT_ONE_SHOT)

func start_goblin_battle(goblin_node):
	in_battle = true
	var config = goblin_node.get_battle_config()
	battle_screen.start_battle(goblin_node, config)
	battle_screen.battle_ended.connect(on_battle_ended, CONNECT_ONE_SHOT)

func on_battle_ended(won: bool, rewards: Dictionary):
	in_battle = false

	if won:
		if rewards.get("type") == "slime" and GameState.quest.state == 2:
			GameState.quest.slimes_killed += 1
			if GameState.quest.slimes_killed >= GameState.quest.slimes_required:
				GameState.quest.state = 3
			GameState.save_game()

		if rewards.get("type") == "goblin" and GameState.quest.state == 8:
			GameState.quest.goblins_killed += 1
			if GameState.quest.goblins_killed >= GameState.quest.goblins_required:
				GameState.quest.state = 9
				GameState.player.gold += 60
				GameState.add_exp(80)
			GameState.save_game()

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

		var loot_names = []
		for drop in rewards.get("loot", []):
			loot_names.append(drop.get("name", "?"))
		var loot_str = ", ".join(loot_names) if loot_names.size() > 0 else "nothing"

		var steps = [
			{ "speaker": "System", "avatar": "✨", "text": "Victory! Earned " + str(rewards.get("exp", 0)) + " EXP and " + str(rewards.get("gold", 0)) + " Gold!\nLoot: " + loot_str }
		]
		GameState.emit_signal("show_dialogue", steps, null)

		if wolves_list.size() < 2:
			get_tree().create_timer(15.0).timeout.connect(func():
				if current_map == "plains":
					spawn_wolves()
			)

		if forest_wolves_list.size() < 2:
			get_tree().create_timer(15.0).timeout.connect(func():
				if current_map == "south_forest":
					spawn_forest_wolves()
			)

	hud.update_hud()

var _shop_purchased := false

func _on_item_purchased():
	_shop_purchased = true

func _on_shop_closed():
	if GameState.quest.state == 11 and _shop_purchased:
		GameState.quest.state = 12
		hud.update_hud()
		GameState.save_game()
	_shop_purchased = false
