extends Node

const TILE_SIZE = 32

var tiles = {}
var characters = {}
var objects = {}
var portraits = {}
var items = {}
var monsters = {}

func _ready():
	init_sprites()

func init_sprites():
	create_tiles()
	create_objects()
	create_characters()
	create_items()
	create_monsters()

func create_monsters():
	var monster_ids = ["slime_battle", "wolf_battle", "goblin_battle", "goblin_chief_battle", "cave_bat", "rock_spider", "stone_golem"]
	for m_id in monster_ids:
		var tex = load_texture_from_file("res://assets/monsters/" + m_id + ".png")
		if tex:
			monsters[m_id] = tex

func create_items():
	var item_ids = [
		"rusty_sword", "tattered_cloth", "bronze_sword", "iron_sword",
		"oak_staff", "steel_blade", "leather_armor", "guardian_shield",
		"health_potion", "wild_herb", "vital_herb", "linas_amulet",
		"wolf_pelt", "goblin_ear", "bone_crown"
	]
	for item_id in item_ids:
		var tex = load_texture_from_file("res://assets/items/" + item_id + ".png")
		if tex:
			items[item_id] = tex

# --- Helper functions to create textures from images ---
func create_texture_from_image(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

# --- Drawing Helpers ---
func draw_circle(image: Image, center: Vector2i, radius: int, color: Color):
	for x in range(center.x - radius - 1, center.x + radius + 2):
		for y in range(center.y - radius - 1, center.y + radius + 2):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue
			var dist = Vector2(x - center.x, y - center.y).length()
			if dist <= radius:
				var alpha = 1.0
				if dist > radius - 1.0:
					alpha = radius - (dist - 1.0)
				var blended = Color(color.r, color.g, color.b, color.a * alpha)
				var existing = image.get_pixel(x, y)
				image.set_pixel(x, y, blended.blend(existing) if existing.a > 0 else blended)

func draw_ellipse(image: Image, center: Vector2i, rx: int, ry: int, color: Color):
	for x in range(center.x - rx, center.x + rx + 1):
		for y in range(center.y - ry, center.y + ry + 1):
			var dx = float(x - center.x) / rx
			var dy = float(y - center.y) / ry
			if dx*dx + dy*dy <= 1.0:
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

func _draw_boulder(img: Image, cx: int, cy: int, rx: int, ry: int, _c_base: Color, c_hi: Color, c_sh: Color):
	# Outline
	for y in range(cy - ry - 1, cy + ry + 2):
		for x in range(cx - rx - 1, cx + rx + 2):
			if x < 0 or x >= img.get_width() or y < 0 or y >= img.get_height():
				continue
			var dx = float(x - cx) / float(rx + 1)
			var dy = float(y - cy) / float(ry + 1)
			var d_out = dx * dx + dy * dy
			var dx_in = float(x - cx) / float(rx)
			var dy_in = float(y - cy) / float(ry)
			var d_in = dx_in * dx_in + dy_in * dy_in
			if d_out <= 1.0 and d_in > 1.0:
				img.set_pixel(x, y, Color("#2a2a2a"))

	# Fill body
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			if x < 0 or x >= img.get_width() or y < 0 or y >= img.get_height():
				continue
			var dx = float(x - cx) / float(rx)
			var dy = float(y - cy) / float(ry)
			var d = dx * dx + dy * dy
			if d <= 1.0:
				# Gradient: lighter at top, darker at bottom
				var t = (float(y - (cy - ry)) / float(ry * 2))
				var grad = c_hi.lerp(c_sh, t)
				img.set_pixel(x, y, grad)

	# Bright highlight spot (top-left)
	for y in range(cy - ry, cy - int(ry * 0.3)):
		for x in range(cx - rx, cx):
			if x < 0 or x >= img.get_width() or y < 0 or y >= img.get_height():
				continue
			var dx = float(x - cx) / float(rx)
			var dy = float(y - cy) / float(ry)
			var d = dx * dx + dy * dy
			if d <= 0.7:
				img.set_pixel(x, y, c_hi)

func outline_sprite(img: Image, color: Color = Color(0, 0, 0, 0.3)):
	var w = img.get_width()
	var h = img.get_height()
	for x in range(w):
		for y in range(h):
			var px = img.get_pixel(x, y)
			if px.a > 0.1:
				var has_transparent_neighbor = false
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						if dx == 0 and dy == 0: continue
						var nx = x + dx
						var ny = y + dy
						if nx < 0 or nx >= w or ny < 0 or ny >= h: continue
						if img.get_pixel(nx, ny).a < 0.1:
							has_transparent_neighbor = true
							break
					if has_transparent_neighbor: break
				if has_transparent_neighbor:
					img.set_pixel(x, y, color.blend(px))

func draw_rect_outline(image: Image, rect: Rect2i, color: Color):
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, rect.size.x, 1), color)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y + rect.size.y - 1, rect.size.x, 1), color)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, 1, rect.size.y), color)
	image.fill_rect(Rect2i(rect.position.x + rect.size.x - 1, rect.position.y, 1, rect.size.y), color)

# --- Procedural Generators ---
func create_tiles():
	var sz = TILE_SIZE
	var tile_names = ["grass", "flower", "dirt", "wood_floor", "brick_wall", "roof", "stone", "tree", "cave_floor", "cave_wall", "stairs_down"]

	for t_name in tile_names:
		var tex = load_texture_from_file("res://assets/tiles/" + t_name + ".png")
		if tex:
			tiles[t_name] = tex

	if not tiles.has("grass"):
		var grass_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		grass_img.fill(Color("#448f30"))
		grass_img.fill_rect(Rect2i(4, 8, 2, 6), Color("#307020"))
		grass_img.fill_rect(Rect2i(6, 10, 2, 4), Color("#307020"))
		grass_img.fill_rect(Rect2i(20, 4, 2, 4), Color("#307020"))
		grass_img.fill_rect(Rect2i(18, 6, 2, 2), Color("#307020"))
		grass_img.fill_rect(Rect2i(12, 22, 2, 6), Color("#307020"))
		grass_img.fill_rect(Rect2i(14, 24, 2, 4), Color("#307020"))
		grass_img.fill_rect(Rect2i(26, 18, 2, 5), Color("#307020"))
		grass_img.fill_rect(Rect2i(24, 20, 2, 3), Color("#307020"))
		grass_img.fill_rect(Rect2i(28, 8, 2, 5), Color("#307020"))
		grass_img.fill_rect(Rect2i(8, 28, 2, 4), Color("#307020"))
		grass_img.fill_rect(Rect2i(2, 2, 3, 3), Color("#3d8b28"))
		grass_img.fill_rect(Rect2i(26, 26, 3, 3), Color("#3d8b28"))
		tiles["grass"] = create_texture_from_image(grass_img)

	if not tiles.has("flower"):
		var grass_img = tiles["grass"].get_image() if tiles.has("grass") else Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		var flower_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		flower_img.blit_rect(grass_img, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
		flower_img.fill_rect(Rect2i(10, 8, 4, 4), Color("#ffeb3b"))
		flower_img.fill_rect(Rect2i(11, 7, 2, 2), Color("#f44336"))
		flower_img.fill_rect(Rect2i(22, 20, 4, 4), Color("#e91e63"))
		flower_img.fill_rect(Rect2i(23, 19, 2, 2), Color("#ffffff"))
		tiles["flower"] = create_texture_from_image(flower_img)

	if not tiles.has("dirt"):
		var dirt_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		dirt_img.fill(Color("#8d6e63"))
		dirt_img.fill_rect(Rect2i(2, 6, 4, 2), Color("#6d4c41"))
		dirt_img.fill_rect(Rect2i(16, 12, 6, 2), Color("#6d4c41"))
		dirt_img.fill_rect(Rect2i(10, 24, 5, 2), Color("#6d4c41"))
		dirt_img.fill_rect(Rect2i(22, 4, 3, 2), Color("#6d4c41"))
		dirt_img.fill_rect(Rect2i(8, 16, 2, 2), Color("#a1887f"))
		dirt_img.fill_rect(Rect2i(24, 26, 2, 2), Color("#a1887f"))
		tiles["dirt"] = create_texture_from_image(dirt_img)

	if not tiles.has("wood_floor"):
		var wood_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		wood_img.fill(Color("#8a664c"))
		wood_img.fill_rect(Rect2i(0, 0, sz, 1), Color("#76563e"))
		wood_img.fill_rect(Rect2i(0, 8, sz, 1), Color("#76563e"))
		wood_img.fill_rect(Rect2i(0, 16, sz, 1), Color("#76563e"))
		wood_img.fill_rect(Rect2i(0, 24, sz, 1), Color("#76563e"))
		wood_img.fill_rect(Rect2i(12, 0, 1, 8), Color("#76563e"))
		wood_img.fill_rect(Rect2i(24, 8, 1, 8), Color("#76563e"))
		wood_img.fill_rect(Rect2i(8, 16, 1, 8), Color("#76563e"))
		wood_img.fill_rect(Rect2i(20, 24, 1, 8), Color("#76563e"))
		tiles["wood_floor"] = create_texture_from_image(wood_img)

	if not tiles.has("brick_wall"):
		var brick_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		brick_img.fill(Color("#4e342e"))
		brick_img.fill_rect(Rect2i(0, 0, sz, 2), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(0, 10, sz, 2), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(0, 20, sz, 2), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(0, 30, sz, 2), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(8, 0, 2, 10), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(24, 0, 2, 10), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(16, 10, 2, 10), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(4, 20, 2, 10), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(20, 20, 2, 10), Color("#2d1e18"))
		brick_img.fill_rect(Rect2i(1, 3, 6, 2), Color("#5d4037"))
		brick_img.fill_rect(Rect2i(11, 13, 8, 2), Color("#5d4037"))
		brick_img.fill_rect(Rect2i(7, 23, 10, 2), Color("#5d4037"))
		tiles["brick_wall"] = create_texture_from_image(brick_img)

	if not tiles.has("roof"):
		var roof_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		roof_img.fill(Color("#37474f"))
		roof_img.fill_rect(Rect2i(0, 0, sz, 4), Color("#263238"))
		roof_img.fill_rect(Rect2i(0, 16, sz, 4), Color("#263238"))
		roof_img.fill_rect(Rect2i(4, 4, 8, 12), Color("#455a64"))
		roof_img.fill_rect(Rect2i(20, 4, 8, 12), Color("#455a64"))
		tiles["roof"] = create_texture_from_image(roof_img)

	if not tiles.has("stone"):
		var grass_img = tiles["grass"].get_image() if tiles.has("grass") else Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		var stone_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		stone_img.blit_rect(grass_img, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
		_draw_boulder(stone_img, 16, 14, 11, 8, Color("#6a6a6a"), Color("#b0b0b0"), Color("#383838"))
		_draw_boulder(stone_img, 11, 23, 9, 6, Color("#7a7a7a"), Color("#c8c8c8"), Color("#404040"))
		_draw_boulder(stone_img, 22, 22, 8, 6, Color("#727272"), Color("#bebebe"), Color("#3c3c3c"))
		stone_img.set_pixel(7, 27, Color("#558b2f"))
		tiles["stone"] = create_texture_from_image(stone_img)

	if not tiles.has("tree"):
		var tree_img = Image.create(sz * 2, sz * 2, true, Image.FORMAT_RGBA8)
		draw_circle(tree_img, Vector2i(sz, sz - 4), sz - 6, Color("#1b5e20"))
		draw_circle(tree_img, Vector2i(sz - 4, sz - 8), sz - 10, Color("#2e7d32"))
		tree_img.fill_rect(Rect2i(sz - 4, sz + 6, 8, 16), Color("#5d4037"))
		tree_img.fill_rect(Rect2i(sz, sz + 6, 4, 16), Color("#3e2723"))
		tiles["tree"] = create_texture_from_image(tree_img)

func create_objects():
	var sz = TILE_SIZE
	var obj_names = [
		"bed", "table", "fireplace", "bulletin_board", "herb", "vital_herb",
		"guild_counter", "tree", "copper_ore", "iron_ore", "stairs_down", "stairs_up",
		"broadcast_horn", "party_board", "bar_counter", "training_dummy", "storage_chest",
		"weapon_rack", "honor_wall", "potion_shelf"
	]

	for o_name in obj_names:
		var tex = load_texture_from_file("res://assets/objects/" + o_name + ".png")
		if tex:
			objects[o_name] = tex

	if not objects.has("bed"):
		var bed_img = Image.create(sz, sz * 2, true, Image.FORMAT_RGBA8)
		bed_img.fill_rect(Rect2i(2, 4, sz - 4, sz * 2 - 8), Color("#5d4037"))
		bed_img.fill_rect(Rect2i(4, 20, sz - 8, sz * 2 - 26), Color("#c62828"))
		bed_img.fill_rect(Rect2i(6, 8, sz - 12, 10), Color("#eceff1"))
		bed_img.fill_rect(Rect2i(4, 40, sz - 8, 4), Color("#b71c1c"))
		objects["bed"] = create_texture_from_image(bed_img)

	if not objects.has("table"):
		var table_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		table_img.fill_rect(Rect2i(4, 4, sz - 8, sz - 8), Color("#8d6e63"))
		table_img.fill_rect(Rect2i(6, 6, 4, 4), Color("#5d4037"))
		table_img.fill_rect(Rect2i(sz - 10, 6, 4, 4), Color("#5d4037"))
		table_img.fill_rect(Rect2i(4, sz - 4, 4, 4), Color("#3e2723"))
		table_img.fill_rect(Rect2i(sz - 8, sz - 4, 4, 4), Color("#3e2723"))
		objects["table"] = create_texture_from_image(table_img)

	if not objects.has("fireplace"):
		var fp_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
		fp_img.fill_rect(Rect2i(4, 0, sz * 2 - 8, sz), Color("#4e342e"))
		fp_img.fill_rect(Rect2i(16, 12, 32, 20), Color("#263238"))
		fp_img.fill_rect(Rect2i(24, 22, 16, 10), Color("#ff3d00"))
		fp_img.fill_rect(Rect2i(28, 20, 8, 4), Color("#ffea00"))
		objects["fireplace"] = create_texture_from_image(fp_img)

	if not objects.has("bulletin_board"):
		var board_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		var grass_tex = tiles["grass"].get_image() if tiles.has("grass") else Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		board_img.blit_rect(grass_tex, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
		board_img.fill_rect(Rect2i(14, 16, 4, 16), Color("#5d4037"))
		board_img.fill_rect(Rect2i(2, 4, sz - 4, 14), Color("#8d6e63"))
		draw_rect_outline(board_img, Rect2i(2, 4, sz - 4, 14), Color("#3e2723"))
		board_img.fill_rect(Rect2i(6, 7, 8, 8), Color("#f5f5f5"))
		board_img.fill_rect(Rect2i(18, 8, 8, 6), Color("#f5f5f5"))
		board_img.fill_rect(Rect2i(8, 9, 4, 1), Color("#212121"))
		board_img.fill_rect(Rect2i(8, 11, 4, 1), Color("#212121"))
		board_img.fill_rect(Rect2i(20, 11, 4, 1), Color("#212121"))
		objects["bulletin_board"] = create_texture_from_image(board_img)

	if not objects.has("herb"):
		var herb_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		var grass_tex = tiles["grass"].get_image() if tiles.has("grass") else Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		herb_img.blit_rect(grass_tex, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
		draw_circle(herb_img, Vector2i(10, 20), 6, Color("#00e676"))
		draw_circle(herb_img, Vector2i(22, 18), 5, Color("#00e676"))
		draw_circle(herb_img, Vector2i(16, 12), 7, Color("#00e676"))
		draw_circle(herb_img, Vector2i(16, 14), 3, Color("#2979ff"))
		herb_img.fill_rect(Rect2i(15, 13, 2, 2), Color("#00e5ff"))
		objects["herb"] = create_texture_from_image(herb_img)

	if not objects.has("vital_herb"):
		var vherb_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		var grass_tex = tiles["grass"].get_image() if tiles.has("grass") else Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		vherb_img.blit_rect(grass_tex, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
		draw_circle(vherb_img, Vector2i(10, 20), 5, Color("#76ff03"))
		draw_circle(vherb_img, Vector2i(22, 18), 5, Color("#76ff03"))
		draw_circle(vherb_img, Vector2i(16, 12), 6, Color("#76ff03"))
		draw_circle(vherb_img, Vector2i(16, 14), 3, Color("#00e676"))
		vherb_img.fill_rect(Rect2i(15, 13, 2, 2), Color("#ffffff"))
		objects["vital_herb"] = create_texture_from_image(vherb_img)

	if not objects.has("guild_counter"):
		var counter_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
		counter_img.fill_rect(Rect2i(0, 0, 64, 32), Color("#5d4037"))
		counter_img.fill_rect(Rect2i(4, 4, 56, 24), Color("#795548"))
		counter_img.fill_rect(Rect2i(0, 28, 64, 4), Color("#3e2723"))
		objects["guild_counter"] = create_texture_from_image(counter_img)

	if not objects.has("tree"):
		var tree_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		tree_img.fill(Color(0, 0, 0, 0))
		draw_circle(tree_img, Vector2i(16, 14), 12, Color("#1b5e20"))
		draw_circle(tree_img, Vector2i(16, 12), 10, Color("#2e7d32"))
		draw_circle(tree_img, Vector2i(14, 10), 7, Color("#388e3c"))
		tree_img.fill_rect(Rect2i(14, 22, 4, 10), Color("#5d4037"))
		tree_img.fill_rect(Rect2i(15, 22, 2, 10), Color("#4e342e"))
		objects["tree"] = create_texture_from_image(tree_img)

	if not objects.has("stairs_down"):
		var sd_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		sd_img.fill(Color("#1a1a1a"))
		for r in range(4):
			sd_img.fill_rect(Rect2i(4, r * 7 + 2, 24, 4), Color("#424242").darkened(r * 0.15))
		objects["stairs_down"] = create_texture_from_image(sd_img)

	if not objects.has("stairs_up"):
		var su_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
		su_img.fill(Color("#1a1a1a"))
		for r in range(4):
			su_img.fill_rect(Rect2i(4, r * 7 + 2, 24, 4), Color("#757575").lightened(r * 0.1))
		objects["stairs_up"] = create_texture_from_image(su_img)

func create_characters():
	var sz = TILE_SIZE

	# 1. Hero Sheet (96x128) - 3 frames (cols) by 4 directions (rows)
	var hero_tex = load_texture_from_file("res://assets/characters/hero.png")
	if hero_tex:
		characters["hero"] = hero_tex
	else:
		var hero_img = Image.create(sz * 3, sz * 4, true, Image.FORMAT_RGBA8)
		draw_hero_sheet(hero_img, sz)
		characters["hero"] = create_texture_from_image(hero_img)

	# 2. Lina Sheet (96x128)
	var lina_tex = load_texture_from_file("res://assets/characters/lina.png")
	if lina_tex:
		characters["lina"] = lina_tex
	else:
		var lina_img = Image.create(sz * 3, sz * 4, true, Image.FORMAT_RGBA8)
		draw_lina_sheet(lina_img, sz)
		characters["lina"] = create_texture_from_image(lina_img)

	# 3. Slime (64x32) - 2 frames: 0 (flat), 1 (jump/stretched)
	var slime_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
	# Frame 1: resting
	draw_ellipse(slime_img, Vector2i(16, 22), 12, 8, Color(0, 0.9, 0.46, 0.85))
	slime_img.fill_rect(Rect2i(10, 20, 2, 2), Color("#004d40"))
	slime_img.fill_rect(Rect2i(18, 20, 2, 2), Color("#004d40"))
	draw_circle(slime_img, Vector2i(16, 18), 4, Color("#b9f6ca"))
	
	# Frame 2: jumping/stretched
	draw_ellipse(slime_img, Vector2i(48, 16), 9, 13, Color(0, 0.9, 0.46, 0.85))
	slime_img.fill_rect(Rect2i(44, 12, 2, 2), Color("#004d40"))
	slime_img.fill_rect(Rect2i(50, 12, 2, 2), Color("#004d40"))
	draw_circle(slime_img, Vector2i(48, 14), 3, Color("#b9f6ca"))
	characters["slime"] = create_texture_from_image(slime_img)

	# 4. Wolf (64x32) - 2 frames: 0 (idle), 1 (run)
	var wolf_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
	# Frame 1: resting wolf
	draw_ellipse(wolf_img, Vector2i(16, 20), 10, 6, Color("#455a64"))
	draw_circle(wolf_img, Vector2i(22, 14), 6, Color("#37474f"))
	wolf_img.fill_rect(Rect2i(24, 14, 5, 3), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(21, 8, 2, 4), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(10, 24, 2, 6), Color("#263238"))
	wolf_img.fill_rect(Rect2i(14, 24, 2, 6), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(18, 24, 2, 6), Color("#263238"))
	wolf_img.fill_rect(Rect2i(22, 24, 2, 6), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(4, 18, 5, 2), Color("#37474f"))
	
	# Frame 2: running wolf
	draw_ellipse(wolf_img, Vector2i(48, 20), 12, 5, Color("#455a64"))
	draw_circle(wolf_img, Vector2i(56, 15), 6, Color("#37474f"))
	wolf_img.fill_rect(Rect2i(58, 15, 5, 3), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(55, 9, 2, 4), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(40, 22, 3, 5), Color("#263238"))
	wolf_img.fill_rect(Rect2i(45, 23, 2, 6), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(50, 22, 3, 5), Color("#263238"))
	wolf_img.fill_rect(Rect2i(55, 23, 2, 6), Color("#37474f"))
	wolf_img.fill_rect(Rect2i(35, 14, 4, 3), Color("#37474f"))
	characters["wolf"] = create_texture_from_image(wolf_img)

	# 5. Goblin (64x32) - 2 frames: 0 (idle), 1 (agitated)
	var goblin_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
	# Frame 1: idle
	draw_ellipse(goblin_img, Vector2i(16, 20), 10, 5, Color("#558b2f"))
	draw_circle(goblin_img, Vector2i(22, 14), 6, Color("#33691e"))
	goblin_img.fill_rect(Rect2i(24, 14, 5, 3), Color("#33691e"))
	goblin_img.fill_rect(Rect2i(21, 8, 2, 4), Color("#33691e"))
	goblin_img.fill_rect(Rect2i(20, 14, 2, 2), Color("#ff1744"))
	goblin_img.fill_rect(Rect2i(10, 24, 2, 6), Color("#1b5e20"))
	goblin_img.fill_rect(Rect2i(14, 24, 2, 6), Color("#1b5e20"))
	goblin_img.fill_rect(Rect2i(18, 24, 2, 6), Color("#1b5e20"))
	goblin_img.fill_rect(Rect2i(22, 24, 2, 6), Color("#1b5e20"))
	# Frame 2: agitated
	draw_ellipse(goblin_img, Vector2i(48, 20), 11, 6, Color("#558b2f"))
	draw_circle(goblin_img, Vector2i(55, 14), 7, Color("#33691e"))
	goblin_img.fill_rect(Rect2i(58, 14, 5, 3), Color("#33691e"))
	goblin_img.fill_rect(Rect2i(54, 8, 2, 4), Color("#33691e"))
	goblin_img.fill_rect(Rect2i(53, 14, 2, 2), Color("#ff1744"))
	goblin_img.fill_rect(Rect2i(40, 22, 3, 5), Color("#1b5e20"))
	goblin_img.fill_rect(Rect2i(45, 23, 2, 6), Color("#1b5e20"))
	goblin_img.fill_rect(Rect2i(50, 22, 3, 5), Color("#1b5e20"))
	goblin_img.fill_rect(Rect2i(55, 23, 2, 6), Color("#1b5e20"))
	characters["goblin"] = create_texture_from_image(goblin_img)

	# 6. Guild NPCs & Characters
	var npc_list = [
		"receptionist", "garrick", "shopkeeper", "blacksmith", "bartender",
		"appraiser", "merchant_hans", "clara", "apprentice_pip", "mage_lily",
		"ranger_tom", "information_broker", "bard_orpheus"
	]
	for npc in npc_list:
		var tex = load_texture_from_file("res://assets/npc_" + npc + ".png")
		if tex:
			characters[npc] = tex

	# 7. Portraits
	create_portraits()

func load_texture_from_file(path: String) -> Texture2D:
	var global_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_path):
		var img = Image.load_from_file(global_path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)

	if ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		if res is Texture2D:
			return res

	return null

func create_portraits():
	var p_tex = load_texture_from_file("res://assets/portraits/protagonist.png")
	if p_tex:
		portraits["protagonist"] = p_tex
	else:
		_create_procedural_hero_portrait()

	var l_tex = load_texture_from_file("res://assets/portraits/lina.png")
	if l_tex:
		portraits["lina"] = l_tex
	else:
		_create_procedural_lina_portrait()

func _create_procedural_hero_portrait():
	var pw = 80
	var ph = 96
	var hero_portrait = Image.create(pw, ph, true, Image.FORMAT_RGBA8)
	hero_portrait.fill(Color(0, 0, 0, 0))
	draw_circle(hero_portrait, Vector2i(40, 40), 32, Color(0.12, 0.12, 0.14, 0.5))

	hero_portrait.fill_rect(Rect2i(20, 8, 40, 40), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(16, 14, 8, 30), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(56, 14, 8, 30), Color("#2d1e18"))

	hero_portrait.fill_rect(Rect2i(24, 18, 32, 28), Color("#ffcc80"))
	hero_portrait.fill_rect(Rect2i(26, 44, 28, 4), Color("#ffcc80"))
	hero_portrait.fill_rect(Rect2i(28, 46, 24, 2), Color("#f5b775"))

	hero_portrait.fill_rect(Rect2i(22, 12, 36, 10), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(24, 10, 32, 4), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(24, 20, 4, 6), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(52, 20, 4, 6), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(28, 14, 2, 2), Color("#4e342e"))
	hero_portrait.fill_rect(Rect2i(50, 14, 2, 2), Color("#4e342e"))
	hero_portrait.fill_rect(Rect2i(26, 16, 2, 2), Color("#4e342e"))
	hero_portrait.fill_rect(Rect2i(52, 16, 2, 2), Color("#4e342e"))

	hero_portrait.fill_rect(Rect2i(30, 26, 6, 4), Color("#ffffff"))
	hero_portrait.fill_rect(Rect2i(44, 26, 6, 4), Color("#ffffff"))
	hero_portrait.fill_rect(Rect2i(32, 27, 4, 3), Color("#1a1a1a"))
	hero_portrait.fill_rect(Rect2i(46, 27, 4, 3), Color("#1a1a1a"))
	hero_portrait.fill_rect(Rect2i(33, 28, 2, 1), Color("#8d6e63"))
	hero_portrait.fill_rect(Rect2i(47, 28, 2, 1), Color("#8d6e63"))
	hero_portrait.fill_rect(Rect2i(38, 30, 4, 8), Color("#d47a6a"))
	hero_portrait.fill_rect(Rect2i(39, 28, 2, 4), Color("#d47a6a"))
	hero_portrait.fill_rect(Rect2i(39, 34, 2, 2), Color("#ffe0b2"))
	hero_portrait.fill_rect(Rect2i(28, 22, 10, 2), Color("#2d1e18"))
	hero_portrait.fill_rect(Rect2i(42, 22, 10, 2), Color("#2d1e18"))

	hero_portrait.fill_rect(Rect2i(22, 44, 36, 8), Color("#607d8b"))
	hero_portrait.fill_rect(Rect2i(24, 44, 32, 2), Color("#78909c"))
	hero_portrait.fill_rect(Rect2i(20, 48, 40, 6), Color("#546e7a"))

	hero_portrait.fill_rect(Rect2i(14, 52, 52, 20), Color("#6d4c41"))
	hero_portrait.fill_rect(Rect2i(12, 52, 6, 14), Color("#5d4037"))
	hero_portrait.fill_rect(Rect2i(62, 52, 6, 14), Color("#5d4037"))
	hero_portrait.fill_rect(Rect2i(14, 52, 52, 2), Color("#4e342e"))
	hero_portrait.fill_rect(Rect2i(14, 68, 52, 2), Color("#4e342e"))
	hero_portrait.fill_rect(Rect2i(28, 58, 2, 1), Color("#5d4037"))
	hero_portrait.fill_rect(Rect2i(50, 62, 2, 1), Color("#5d4037"))

	hero_portrait.fill_rect(Rect2i(24, 48, 32, 4), Color("#37474f"))

	hero_portrait.fill_rect(Rect2i(60, 14, 8, 10), Color("#455a64"))
	hero_portrait.fill_rect(Rect2i(62, 10, 4, 6), Color("#b71c1c"))
	hero_portrait.fill_rect(Rect2i(64, 22, 4, 2), Color("#90a4ae"))

	portraits["protagonist"] = create_texture_from_image(hero_portrait)

func _create_procedural_lina_portrait():
	var pw = 80
	var ph = 96
	var lina_portrait = Image.create(pw, ph, true, Image.FORMAT_RGBA8)
	lina_portrait.fill(Color(0, 0, 0, 0))
	draw_circle(lina_portrait, Vector2i(40, 40), 32, Color(0.12, 0.12, 0.14, 0.5))

	lina_portrait.fill_rect(Rect2i(22, 12, 36, 48), Color("#6d4c41"))
	lina_portrait.fill_rect(Rect2i(18, 20, 8, 36), Color("#6d4c41"))
	lina_portrait.fill_rect(Rect2i(54, 20, 8, 36), Color("#6d4c41"))

	lina_portrait.fill_rect(Rect2i(26, 22, 28, 26), Color("#ffe0b2"))
	lina_portrait.fill_rect(Rect2i(28, 46, 24, 4), Color("#ffe0b2"))

	lina_portrait.fill_rect(Rect2i(24, 16, 32, 10), Color("#6d4c41"))
	lina_portrait.fill_rect(Rect2i(26, 14, 28, 4), Color("#6d4c41"))
	lina_portrait.fill_rect(Rect2i(26, 24, 4, 8), Color("#6d4c41"))
	lina_portrait.fill_rect(Rect2i(50, 24, 4, 8), Color("#6d4c41"))
	lina_portrait.fill_rect(Rect2i(30, 18, 2, 2), Color("#5d4037"))
	lina_portrait.fill_rect(Rect2i(48, 18, 2, 2), Color("#5d4037"))

	lina_portrait.fill_rect(Rect2i(30, 30, 8, 6), Color("#ffffff"))
	lina_portrait.fill_rect(Rect2i(42, 30, 8, 6), Color("#ffffff"))
	lina_portrait.fill_rect(Rect2i(32, 31, 6, 5), Color("#4e342e"))
	lina_portrait.fill_rect(Rect2i(44, 31, 6, 5), Color("#4e342e"))
	lina_portrait.fill_rect(Rect2i(34, 33, 2, 2), Color("#8d6e63"))
	lina_portrait.fill_rect(Rect2i(46, 33, 2, 2), Color("#8d6e63"))
	lina_portrait.fill_rect(Rect2i(30, 29, 8, 1), Color("#4e342e"))
	lina_portrait.fill_rect(Rect2i(42, 29, 8, 1), Color("#4e342e"))

	lina_portrait.fill_rect(Rect2i(28, 38, 6, 3), Color("#ffcdd2"))
	lina_portrait.fill_rect(Rect2i(46, 38, 6, 3), Color("#ffcdd2"))

	lina_portrait.fill_rect(Rect2i(34, 42, 12, 2), Color("#ef9a9a"))
	lina_portrait.fill_rect(Rect2i(36, 40, 8, 2), Color("#ffe0b2"))

	lina_portrait.fill_rect(Rect2i(24, 48, 32, 8), Color("#e8e0d8"))
	lina_portrait.fill_rect(Rect2i(22, 48, 36, 4), Color("#d7ccc8"))
	lina_portrait.fill_rect(Rect2i(20, 52, 40, 16), Color("#e8e0d8"))
	lina_portrait.fill_rect(Rect2i(18, 52, 44, 2), Color("#d7ccc8"))
	lina_portrait.fill_rect(Rect2i(18, 64, 44, 2), Color("#bcaaa4"))

	portraits["lina"] = create_texture_from_image(lina_portrait)

func draw_hero_sheet(img: Image, sz: int):
	var directions = ["down", "up", "left", "right"]
	for d in range(4):
		var dir = directions[d]
		for f in range(3):
			var ox = f * sz
			var oy = d * sz
			var sway = -1 if f == 1 else (1 if f == 2 else 0)
			var leg = 2 if f == 1 else (-2 if f == 2 else 0)

			# Shadow
			draw_ellipse(img, Vector2i(ox + 16, oy + 29), 10, 4, Color(0, 0, 0, 0.25))

			# == Legs ==
			if dir == "left" or dir == "right":
				img.fill_rect(Rect2i(ox + 11 + leg, oy + 22, 4, 7), Color("#2c2c2c"))
				img.fill_rect(Rect2i(ox + 17 - leg, oy + 22, 4, 7), Color("#2c2c2c"))
			else:
				img.fill_rect(Rect2i(ox + 10 + leg, oy + 22, 5, 7), Color("#2c2c2c"))
				img.fill_rect(Rect2i(ox + 17 - leg, oy + 22, 5, 7), Color("#2c2c2c"))

			# Boots
			img.fill_rect(Rect2i(ox + 10 + leg, oy + 27, 5, 3), Color("#4e342e"))
			img.fill_rect(Rect2i(ox + 17 - leg, oy + 27, 5, 3), Color("#4e342e"))

			# == Pouches on belt ==
			img.fill_rect(Rect2i(ox + 7, oy + 20, 3, 3), Color("#5d4037"))
			img.fill_rect(Rect2i(ox + 22, oy + 20, 3, 3), Color("#5d4037"))

			# == Torso: Dark inner shirt ==
			img.fill_rect(Rect2i(ox + 9, oy + 11 + sway, 14, 4), Color("#37474f"))
			# Scarf around neck
			img.fill_rect(Rect2i(ox + 8, oy + 12 + sway, 16, 2), Color("#607d8b"))
			# Leather armor overlay
			img.fill_rect(Rect2i(ox + 8, oy + 14 + sway, 16, 9), Color("#6d4c41"))
			img.fill_rect(Rect2i(ox + 8, oy + 14 + sway, 16, 1), Color("#4e342e"))
			img.fill_rect(Rect2i(ox + 8, oy + 21 + sway, 16, 1), Color("#4e342e"))
			img.fill_rect(Rect2i(ox + 8, oy + 14 + sway, 1, 8), Color("#4e342e"))
			img.fill_rect(Rect2i(ox + 23, oy + 14 + sway, 1, 8), Color("#4e342e"))
			# Armor wear/scratches
			img.fill_rect(Rect2i(ox + 11, oy + 16 + sway, 1, 1), Color("#5d4037"))
			img.fill_rect(Rect2i(ox + 20, oy + 18 + sway, 1, 1), Color("#5d4037"))
			img.fill_rect(Rect2i(ox + 15, oy + 15 + sway, 2, 1), Color("#4e342e"))
			# Belt
			img.fill_rect(Rect2i(ox + 8, oy + 20 + sway, 16, 1), Color("#3e2723"))
			img.fill_rect(Rect2i(ox + 14, oy + 19 + sway, 4, 3), Color("#fdd835"))

			# == Shoulder armor ==
			img.fill_rect(Rect2i(ox + 6, oy + 12 + sway, 3, 3), Color("#5d4037"))
			img.fill_rect(Rect2i(ox + 23, oy + 12 + sway, 3, 3), Color("#5d4037"))

			# == Arms ==
			if dir == "down":
				img.fill_rect(Rect2i(ox + 6, oy + 15 + sway, 2, 5), Color("#37474f"))
				img.fill_rect(Rect2i(ox + 24, oy + 15 + sway, 2, 6), Color("#37474f"))
			elif dir == "up":
				img.fill_rect(Rect2i(ox + 6, oy + 12 + sway, 2, 6), Color("#37474f"))
				img.fill_rect(Rect2i(ox + 24, oy + 12 + sway, 2, 7), Color("#37474f"))

			# == Head ==
			img.fill_rect(Rect2i(ox + 10, oy + 3 + sway, 12, 9), Color("#ffcc80"))

			# == Hair ==
			if dir == "down":
				img.fill_rect(Rect2i(ox + 8, oy + 1 + sway, 16, 4), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 8, oy + 5 + sway, 2, 5), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 22, oy + 5 + sway, 2, 5), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 9, oy + 4 + sway, 2, 1), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 21, oy + 4 + sway, 2, 1), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 10, oy + 2 + sway, 1, 1), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 21, oy + 2 + sway, 1, 1), Color("#4e342e"))
				# Eyes
				img.fill_rect(Rect2i(ox + 12, oy + 7 + sway, 2, 2), Color("#1a1a1a"))
				img.fill_rect(Rect2i(ox + 18, oy + 7 + sway, 2, 2), Color("#1a1a1a"))
				img.fill_rect(Rect2i(ox + 13, oy + 8 + sway, 1, 1), Color("#8d6e63"))
				img.fill_rect(Rect2i(ox + 19, oy + 8 + sway, 1, 1), Color("#8d6e63"))
				# Mouth
				img.fill_rect(Rect2i(ox + 14, oy + 10 + sway, 4, 1), Color("#d47a6a"))
			elif dir == "up":
				img.fill_rect(Rect2i(ox + 8, oy + 1 + sway, 16, 11), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 9, oy + 5 + sway, 2, 2), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 21, oy + 5 + sway, 2, 2), Color("#4e342e"))
				# Sword hilt visible over right shoulder
				img.fill_rect(Rect2i(ox + 22, oy + 1 + sway, 4, 5), Color("#455a64"))
				img.fill_rect(Rect2i(ox + 23, oy + 0 + sway, 2, 2), Color("#b71c1c"))
			elif dir == "left":
				img.fill_rect(Rect2i(ox + 7, oy + 1 + sway, 16, 5), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 7, oy + 6 + sway, 6, 6), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 8, oy + 3 + sway, 1, 1), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 10, oy + 7 + sway, 2, 2), Color("#1a1a1a"))
				img.fill_rect(Rect2i(ox + 11, oy + 8 + sway, 1, 1), Color("#8d6e63"))
				# Sword on right side
				img.fill_rect(Rect2i(ox + 24, oy + 2 + sway, 3, 2), Color("#455a64"))
				img.fill_rect(Rect2i(ox + 25, oy + 4 + sway, 2, 10), Color("#78909c"))
			elif dir == "right":
				img.fill_rect(Rect2i(ox + 9, oy + 1 + sway, 16, 5), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 19, oy + 6 + sway, 6, 6), Color("#2d1e18"))
				img.fill_rect(Rect2i(ox + 22, oy + 3 + sway, 1, 1), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 20, oy + 7 + sway, 2, 2), Color("#1a1a1a"))
				img.fill_rect(Rect2i(ox + 20, oy + 8 + sway, 1, 1), Color("#8d6e63"))
				# Sword on right side (visible)
				img.fill_rect(Rect2i(ox + 24, oy + 2 + sway, 3, 2), Color("#455a64"))
				img.fill_rect(Rect2i(ox + 25, oy + 4 + sway, 2, 10), Color("#78909c"))

func draw_lina_sheet(img: Image, sz: int):
	var directions = ["down", "up", "left", "right"]
	for d in range(4):
		var dir = directions[d]
		for f in range(3):
			var ox = f * sz
			var oy = d * sz
			var sway = -1 if f == 1 else (1 if f == 2 else 0)
			var leg = 2 if f == 1 else (-2 if f == 2 else 0)

			# Shadow
			draw_ellipse(img, Vector2i(ox + 16, oy + 28), 8, 4, Color(0, 0, 0, 0.3))

			# == Robe body (off-white) ==
			img.fill_rect(Rect2i(ox + 9, oy + 13 + sway, 14, 14), Color("#e8e0d8"))
			img.fill_rect(Rect2i(ox + 8, oy + 13 + sway, 2, 14), Color("#d7ccc8"))
			img.fill_rect(Rect2i(ox + 22, oy + 13 + sway, 2, 14), Color("#d7ccc8"))
			# Robe trim
			img.fill_rect(Rect2i(ox + 9, oy + 23 + sway, 14, 2), Color("#bcaaa4"))
			# Small belt/ribbon at waist
			img.fill_rect(Rect2i(ox + 12, oy + 18 + sway, 8, 1), Color("#8d6e63"))

			# == Feet (shoes peeking under robe) ==
			img.fill_rect(Rect2i(ox + 11 + leg, oy + 26, 4, 3), Color("#6d4c41"))
			img.fill_rect(Rect2i(ox + 17 - leg, oy + 26, 4, 3), Color("#6d4c41"))

			# == Head ==
			img.fill_rect(Rect2i(ox + 11, oy + 5 + sway, 10, 9), Color("#ffe0b2"))

			# == Hair (brown, long) ==
			if dir == "down":
				img.fill_rect(Rect2i(ox + 10, oy + 2 + sway, 12, 5), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 9, oy + 6 + sway, 2, 10), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 21, oy + 6 + sway, 2, 10), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 9, oy + 8 + sway, 1, 6), Color("#5d4037"))
				img.fill_rect(Rect2i(ox + 22, oy + 8 + sway, 1, 6), Color("#5d4037"))
				# Eyes
				img.fill_rect(Rect2i(ox + 13, oy + 8 + sway, 2, 2), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 17, oy + 8 + sway, 2, 2), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 14, oy + 9 + sway, 1, 1), Color("#8d6e63"))
				img.fill_rect(Rect2i(ox + 18, oy + 9 + sway, 1, 1), Color("#8d6e63"))
				# Blush
				img.fill_rect(Rect2i(ox + 11, oy + 10 + sway, 2, 1), Color("#ffcdd2"))
				img.fill_rect(Rect2i(ox + 19, oy + 10 + sway, 2, 1), Color("#ffcdd2"))
				# Mouth (small smile)
				img.fill_rect(Rect2i(ox + 14, oy + 11 + sway, 4, 1), Color("#ef9a9a"))
			elif dir == "up":
				img.fill_rect(Rect2i(ox + 10, oy + 2 + sway, 12, 3), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 9, oy + 5 + sway, 14, 12), Color("#6d4c41"))
			elif dir == "left":
				img.fill_rect(Rect2i(ox + 10, oy + 2 + sway, 12, 4), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 16, oy + 6 + sway, 6, 10), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 12, oy + 7 + sway, 2, 2), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 13, oy + 8 + sway, 1, 1), Color("#8d6e63"))
			elif dir == "right":
				img.fill_rect(Rect2i(ox + 10, oy + 2 + sway, 12, 4), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 10, oy + 6 + sway, 6, 10), Color("#6d4c41"))
				img.fill_rect(Rect2i(ox + 18, oy + 7 + sway, 2, 2), Color("#4e342e"))
				img.fill_rect(Rect2i(ox + 18, oy + 8 + sway, 1, 1), Color("#8d6e63"))

var _light_tex_cache = {}
func get_light_texture(radius: int = 128) -> ImageTexture:
	if _light_tex_cache.has(radius):
		return _light_tex_cache[radius]
	var sz = radius * 2
	var img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	var center = Vector2(radius, radius)
	for x in range(sz):
		for y in range(sz):
			var dist = Vector2(x, y).distance_to(center)
			if dist < radius:
				var alpha = clampf(1.0 - (dist / float(radius)), 0.0, 1.0)
				alpha = pow(alpha, 2.0)
				img.set_pixel(x, y, Color(1, 1, 1, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	var tex = create_texture_from_image(img)
	_light_tex_cache[radius] = tex
	return tex
