extends Node2D

var current_map = "cabin"

var cabin_map_node: Node2D
var plains_map_node: Node2D
var guild_map_node: Node2D
var stone_claw_map_node: Node2D
var south_forest_map_node: Node2D

var cabin_solids = []
var plains_solids = []
var guild_solids = []
var stone_claw_solids = []
var south_forest_solids = []

var herbs_list = []
var vital_herbs_list = []
var fruit_bushes_list = []

var terrain_tileset: TileSet
const TILE_TYPES = ["grass", "flower", "dirt", "wood_floor", "brick_wall", "roof", "stone"]
var _tile_source_map = {}

const FIREPLACE_SCENE = preload("res://scenes/fireplace.tscn")
const LINA_SCENE = preload("res://scenes/lina.tscn")
const BOARD_SCENE = preload("res://scenes/bulletin_board.tscn")
const HERB_SCENE = preload("res://scenes/herb.tscn")
const VITAL_HERB_SCENE = preload("res://scenes/vital_herb.tscn")
const FRUIT_BUSH_SCENE = preload("res://scenes/fruit_bush.tscn")

func _create_terrain_tileset() -> TileSet:
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)

	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 2)

	for tile_name in TILE_TYPES:
		var texture = Sprites.tiles[tile_name]
		if not texture:
			continue

		var source = TileSetAtlasSource.new()
		source.texture = texture
		source.texture_region_size = Vector2i(32, 32)
		source.create_tile(Vector2i(0, 0), Vector2i(1, 1))

		var src_id = ts.get_next_source_id()
		ts.add_source(source, src_id)

		if tile_name in ["brick_wall", "roof", "stone"]:
			var tile_data = source.get_tile_data(Vector2i(0, 0), 0)
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
			]))

		_tile_source_map[tile_name] = src_id

	return ts

func _ready():
	terrain_tileset = _create_terrain_tileset()

	var p = get_parent()

	cabin_map_node = p.get_node("Cabin")
	plains_map_node = p.get_node("Plains")
	guild_map_node = p.get_node("GuildHall")
	stone_claw_map_node = p.get_node("StoneClawPass")

	south_forest_map_node = Node2D.new()
	south_forest_map_node.name = "SouthForest"
	p.add_child(south_forest_map_node)

	for map_node in [cabin_map_node, plains_map_node, guild_map_node, stone_claw_map_node, south_forest_map_node]:
		var tml = TileMapLayer.new()
		tml.name = "Terrain"
		tml.tile_set = terrain_tileset
		map_node.add_child(tml)

	build_cabin_map()
	build_plains_map()
	build_guild_map()
	build_stone_claw_pass_map()
	build_south_forest_map()

	set_active_map("")

func set_active_map(map_name: String):
	current_map = map_name
	var map_nodes = {
		"cabin": cabin_map_node,
		"plains": plains_map_node,
		"guild": guild_map_node,
		"stone_claw": stone_claw_map_node,
		"south_forest": south_forest_map_node
	}
	for key in map_nodes:
		var node = map_nodes[key]
		if is_instance_valid(node):
			var active = (key == map_name)
			node.visible = active
			node.process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
			_set_node_collisions_active(node, active)

func _set_node_collisions_active(node: Node, active: bool):
	if not is_instance_valid(node):
		return
	if node is TileMapLayer:
		node.enabled = active
		if "collision_enabled" in node:
			node.set("collision_enabled", active)
	elif node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = not active

	for child in node.get_children():
		_set_node_collisions_active(child, active)

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

			if r == rows - 1 and c == 6:
				tile_name = "wood_floor"
				solid = false

			cabin_solids[r][c] = solid
			spawn_tile(cabin_map_node, tile_name, c, r, solid)

	spawn_object(cabin_map_node, "bed", Vector2(2 * 32, 2 * 32), Rect2(0, 0, 32, 64), true)
	spawn_object(cabin_map_node, "table", Vector2(5 * 32, 4 * 32), Rect2(0, 0, 32, 32), true)

	var fireplace = FIREPLACE_SCENE.instantiate()
	fireplace.position = Vector2(8 * 32, 1 * 32 + 16)
	cabin_map_node.add_child(fireplace)
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

			if (r == 0 and c == 16) or (r == rows - 1 and c == 16):
				tile_name = "dirt"
				solid = false
			elif r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
				tile_name = "stone"
				solid = true

			plains_solids[r][c] = solid
			spawn_tile(plains_map_node, tile_name, c, r, solid)

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

	for r in range(7, 12):
		for c in range(13, 20):
			plains_solids[r][c] = true
			var tile_name = "brick_wall"
			if r == 7 or r == 8:
				tile_name = "roof"
			if r == 11 and c == 16:
				tile_name = "wood_floor"
				plains_solids[r][c] = false

			spawn_tile(plains_map_node, tile_name, c, r, plains_solids[r][c])

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
			
	for i in range(8):
		var hx = (2 + rng_herb.randi() % 28) * 32
		var hy = (2 + rng_herb.randi() % 28) * 32
		@warning_ignore("integer_division")
		var tx = hx / 32
		@warning_ignore("integer_division")
		var ty = hy / 32
		if not plains_solids[ty][tx]:
			var bush = FRUIT_BUSH_SCENE.instantiate()
			bush.position = Vector2(hx + 16, hy + 16)
			plains_map_node.add_child(bush)
			fruit_bushes_list.append(bush)

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

	spawn_object(guild_map_node, "guild_counter", Vector2(5 * 32, 2 * 32), Rect2(0, 0, 64, 32), true)
	spawn_object(guild_map_node, "table", Vector2(11 * 32, 4 * 32), Rect2(0, 0, 32, 32), true)
	spawn_object(guild_map_node, "table", Vector2(11 * 32, 7 * 32), Rect2(0, 0, 32, 32), true)
	spawn_object(guild_map_node, "bulletin_board", Vector2(2 * 32, 2 * 32), Rect2(0, 0, 32, 32), false)
	spawn_object(guild_map_node, "guild_counter", Vector2(12 * 32, 8 * 32), Rect2(0, 0, 64, 32), true)

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

			if c == 10 and r >= rows - 3:
				tile_name = "dirt"
				solid = false

			if not solid and tile_name == "grass":
				var rand = rng_sc.randf()
				if rand < 0.25:
					tile_name = "stone"
					solid = true
				elif rand < 0.35:
					tile_name = "dirt"

			stone_claw_solids[r][c] = solid
			spawn_tile(stone_claw_map_node, tile_name, c, r, solid)

	spawn_object(stone_claw_map_node, "bulletin_board", Vector2(8 * 32, 9 * 32), Rect2(0, 0, 32, 32), false)

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

			if c >= 4 and c <= 8 and r >= 5 and r <= 9:
				tile_name = "stone"
				solid = true

			if c >= 5 and c <= 7 and r >= 6 and r <= 8:
				tile_name = "dirt"
				solid = false

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

	for i in range(10):
		var tx = 2 + rng.randi() % (cols - 4)
		var ty = 2 + rng.randi() % (rows - 4)
		if tx == 10 or tx == 9 or tx == 11:
			continue
		if not south_forest_solids[ty][tx]:
			spawn_object(south_forest_map_node, "tree", Vector2(tx * 32, ty * 32), Rect2(0, 0, 32, 32), false)

	spawn_object(south_forest_map_node, "bulletin_board", Vector2(8 * 32, 1 * 32), Rect2(0, 0, 32, 32), false)

func spawn_tile(parent_node: Node2D, tile_name: String, c: int, r: int, solid: bool):
	if tile_name in TILE_TYPES:
		var tml = parent_node.get_node_or_null("Terrain") as TileMapLayer
		if tml:
			var src_id = _tile_source_map.get(tile_name, -1)
			if src_id >= 0:
				tml.set_cell(Vector2i(c, r), src_id, Vector2i(0, 0), 0)
		return

	var sprite = Sprite2D.new()
	sprite.texture = Sprites.tiles[tile_name]
	sprite.position = Vector2(c * 32 + 16, r * 32 + 16)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent_node.add_child(sprite)

	if solid:
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

func remove_herb(herb):
	herbs_list.erase(herb)

func remove_vital_herb(herb):
	vital_herbs_list.erase(herb)

func remove_fruit_bush(bush):
	fruit_bushes_list.erase(bush)

func spawn_vital_herbs():
	for herb in vital_herbs_list:
		if is_instance_valid(herb):
			herb.queue_free()
	vital_herbs_list.clear()
	
	for bush in fruit_bushes_list:
		if is_instance_valid(bush):
			bush.queue_free()
	fruit_bushes_list.clear()

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

func configure_camera_limits(camera: Camera2D, cols: int, rows: int):
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = cols * 32
	camera.limit_bottom = rows * 32

func get_map_node(map_name: String) -> Node2D:
	match map_name:
		"cabin": return cabin_map_node
		"plains": return plains_map_node
		"guild": return guild_map_node
		"stone_claw": return stone_claw_map_node
		"south_forest": return south_forest_map_node
	return null
