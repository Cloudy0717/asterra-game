extends Node

const TILE_SIZE = 32

var tiles = {}
var characters = {}
var objects = {}
var portraits = {}

func _ready():
	init_sprites()

func init_sprites():
	create_tiles()
	create_objects()
	create_characters()

# --- Helper functions to create textures from images ---
func create_texture_from_image(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

# --- Drawing Helpers ---
func draw_circle(image: Image, center: Vector2i, radius: int, color: Color):
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			if Vector2(x - center.x, y - center.y).length() <= radius:
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

func draw_ellipse(image: Image, center: Vector2i, rx: int, ry: int, color: Color):
	for x in range(center.x - rx, center.x + rx + 1):
		for y in range(center.y - ry, center.y + ry + 1):
			var dx = float(x - center.x) / rx
			var dy = float(y - center.y) / ry
			if dx*dx + dy*dy <= 1.0:
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

func draw_rect_outline(image: Image, rect: Rect2i, color: Color):
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, rect.size.x, 1), color)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y + rect.size.y - 1, rect.size.x, 1), color)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, 1, rect.size.y), color)
	image.fill_rect(Rect2i(rect.position.x + rect.size.x - 1, rect.position.y, 1, rect.size.y), color)

# --- Procedural Generators ---
func create_tiles():
	var sz = TILE_SIZE

	# 1. Grass
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
	tiles["grass"] = create_texture_from_image(grass_img)

	# 2. Flower Grass
	var flower_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	flower_img.blit_rect(grass_img, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
	flower_img.fill_rect(Rect2i(10, 8, 4, 4), Color("#ffeb3b"))
	flower_img.fill_rect(Rect2i(11, 7, 2, 2), Color("#f44336"))
	flower_img.fill_rect(Rect2i(22, 20, 4, 4), Color("#e91e63"))
	flower_img.fill_rect(Rect2i(23, 19, 2, 2), Color("#ffffff"))
	tiles["flower"] = create_texture_from_image(flower_img)

	# 3. Dirt
	var dirt_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	dirt_img.fill(Color("#8d6e63"))
	dirt_img.fill_rect(Rect2i(2, 6, 4, 2), Color("#6d4c41"))
	dirt_img.fill_rect(Rect2i(16, 12, 6, 2), Color("#6d4c41"))
	dirt_img.fill_rect(Rect2i(10, 24, 5, 2), Color("#6d4c41"))
	dirt_img.fill_rect(Rect2i(22, 4, 3, 2), Color("#6d4c41"))
	dirt_img.fill_rect(Rect2i(8, 16, 2, 2), Color("#a1887f"))
	dirt_img.fill_rect(Rect2i(24, 26, 2, 2), Color("#a1887f"))
	tiles["dirt"] = create_texture_from_image(dirt_img)

	# 4. Wood Floor
	var wood_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	wood_img.fill(Color("#d7ccc8"))
	wood_img.fill_rect(Rect2i(0, 0, sz, 2), Color("#a1887f"))
	wood_img.fill_rect(Rect2i(0, 10, sz, 2), Color("#a1887f"))
	wood_img.fill_rect(Rect2i(0, 21, sz, 2), Color("#a1887f"))
	wood_img.fill_rect(Rect2i(0, 31, sz, 2), Color("#a1887f"))
	wood_img.fill_rect(Rect2i(12, 0, 1, 10), Color("#8d6e63"))
	wood_img.fill_rect(Rect2i(24, 10, 1, 11), Color("#8d6e63"))
	wood_img.fill_rect(Rect2i(8, 21, 1, 10), Color("#8d6e63"))
	tiles["wood_floor"] = create_texture_from_image(wood_img)

	# 5. Brick Wall
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

	# 6. Roof / Shingles
	var roof_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	roof_img.fill(Color("#37474f"))
	roof_img.fill_rect(Rect2i(0, 0, sz, 4), Color("#263238"))
	roof_img.fill_rect(Rect2i(0, 16, sz, 4), Color("#263238"))
	roof_img.fill_rect(Rect2i(4, 4, 8, 12), Color("#455a64"))
	roof_img.fill_rect(Rect2i(20, 4, 8, 12), Color("#455a64"))
	tiles["roof"] = create_texture_from_image(roof_img)

	# 7. Stone
	var stone_img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	stone_img.blit_rect(grass_img, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
	# draw stone circle
	draw_circle(stone_img, Vector2i(sz/2, sz/2 + 2), 12, Color("#90a4ae"))
	draw_circle(stone_img, Vector2i(sz/2 + 3, sz/2 + 5), 8, Color("#78909c"))
	stone_img.fill_rect(Rect2i(10, 12, 4, 3), Color("#cfd8dc"))
	tiles["stone"] = create_texture_from_image(stone_img)

	# 8. Tree (64x64, single-tile base + canopy)
	var tree_img = Image.create(sz * 2, sz * 2, true, Image.FORMAT_RGBA8)
	# Canopy (Green circle)
	draw_circle(tree_img, Vector2i(sz, sz - 4), sz - 6, Color("#1b5e20"))
	draw_circle(tree_img, Vector2i(sz - 4, sz - 8), sz - 10, Color("#2e7d32"))
	# Trunk
	tree_img.fill_rect(Rect2i(sz - 4, sz + 6, 8, 16), Color("#5d4037"))
	tree_img.fill_rect(Rect2i(sz, sz + 6, 4, 16), Color("#3e2723")) # Shadow
	tiles["tree"] = create_texture_from_image(tree_img)

func create_objects():
	var sz = TILE_SIZE

	# 1. Bed (32x64)
	var bed_img = Image.create(sz, sz * 2, true, Image.FORMAT_RGBA8)
	bed_img.fill_rect(Rect2i(2, 4, sz - 4, sz * 2 - 8), Color("#5d4037")) # Frame
	bed_img.fill_rect(Rect2i(4, 20, sz - 8, sz * 2 - 26), Color("#c62828")) # Blanket
	bed_img.fill_rect(Rect2i(6, 8, sz - 12, 10), Color("#eceff1")) # Pillow
	bed_img.fill_rect(Rect2i(4, 40, sz - 8, 4), Color("#b71c1c")) # Blanket detail
	objects["bed"] = create_texture_from_image(bed_img)

	# 2. Table (32x32)
	var table_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
	table_img.fill_rect(Rect2i(4, 4, sz - 8, sz - 8), Color("#8d6e63"))
	table_img.fill_rect(Rect2i(6, 6, 4, 4), Color("#5d4037"))
	table_img.fill_rect(Rect2i(sz - 10, 6, 4, 4), Color("#5d4037"))
	table_img.fill_rect(Rect2i(4, sz - 4, 4, 4), Color("#3e2723")) # Legs
	table_img.fill_rect(Rect2i(sz - 8, sz - 4, 4, 4), Color("#3e2723"))
	objects["table"] = create_texture_from_image(table_img)

	# 3. Fireplace (64x32)
	var fp_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
	fp_img.fill_rect(Rect2i(4, 0, sz * 2 - 8, sz), Color("#4e342e"))
	fp_img.fill_rect(Rect2i(16, 12, 32, 20), Color("#263238")) # Open space
	fp_img.fill_rect(Rect2i(24, 22, 16, 10), Color("#ff3d00")) # Coals
	fp_img.fill_rect(Rect2i(28, 20, 8, 4), Color("#ffea00")) # Core
	objects["fireplace"] = create_texture_from_image(fp_img)

	# 4. Bulletin Board (32x32)
	var board_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
	# Draw grass background first
	var grass_tex = tiles["grass"].get_image()
	board_img.blit_rect(grass_tex, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
	# Post
	board_img.fill_rect(Rect2i(14, 16, 4, 16), Color("#5d4037"))
	# Board
	board_img.fill_rect(Rect2i(2, 4, sz - 4, 14), Color("#8d6e63"))
	draw_rect_outline(board_img, Rect2i(2, 4, sz - 4, 14), Color("#3e2723"))
	# Notices
	board_img.fill_rect(Rect2i(6, 7, 8, 8), Color("#f5f5f5"))
	board_img.fill_rect(Rect2i(18, 8, 8, 6), Color("#f5f5f5"))
	board_img.fill_rect(Rect2i(8, 9, 4, 1), Color("#212121"))
	board_img.fill_rect(Rect2i(8, 11, 4, 1), Color("#212121"))
	board_img.fill_rect(Rect2i(20, 11, 4, 1), Color("#212121"))
	objects["bulletin_board"] = create_texture_from_image(board_img)

	# 5. Herb (32x32)
	var herb_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
	herb_img.blit_rect(grass_tex, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
	# Leaves
	draw_circle(herb_img, Vector2i(10, 20), 6, Color("#00e676"))
	draw_circle(herb_img, Vector2i(22, 18), 5, Color("#00e676"))
	draw_circle(herb_img, Vector2i(16, 12), 7, Color("#00e676"))
	# Glow flower
	draw_circle(herb_img, Vector2i(16, 14), 3, Color("#2979ff"))
	herb_img.fill_rect(Rect2i(15, 13, 2, 2), Color("#00e5ff"))
	objects["herb"] = create_texture_from_image(herb_img)

	# 6. Vital Herb (32x32) - green glow, directly edible
	var vherb_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
	vherb_img.blit_rect(grass_tex, Rect2i(0, 0, sz, sz), Vector2i.ZERO)
	draw_circle(vherb_img, Vector2i(10, 20), 5, Color("#76ff03"))
	draw_circle(vherb_img, Vector2i(22, 18), 5, Color("#76ff03"))
	draw_circle(vherb_img, Vector2i(16, 12), 6, Color("#76ff03"))
	draw_circle(vherb_img, Vector2i(16, 14), 3, Color("#00e676"))
	vherb_img.fill_rect(Rect2i(15, 13, 2, 2), Color("#ffffff"))
	objects["vital_herb"] = create_texture_from_image(vherb_img)

	# 7. Guild Counter (64x32)
	var counter_img = Image.create(sz * 2, sz, true, Image.FORMAT_RGBA8)
	counter_img.fill_rect(Rect2i(0, 0, 64, 32), Color("#5d4037"))
	counter_img.fill_rect(Rect2i(4, 4, 56, 24), Color("#795548"))
	counter_img.fill_rect(Rect2i(0, 28, 64, 4), Color("#3e2723"))
	objects["guild_counter"] = create_texture_from_image(counter_img)

	# 8. Tree Decoration (32x32) - small forest tree
	var tree_img = Image.create(sz, sz, true, Image.FORMAT_RGBA8)
	tree_img.fill(Color(0, 0, 0, 0))
	draw_circle(tree_img, Vector2i(16, 14), 12, Color("#1b5e20"))
	draw_circle(tree_img, Vector2i(16, 12), 10, Color("#2e7d32"))
	draw_circle(tree_img, Vector2i(14, 10), 7, Color("#388e3c"))
	tree_img.fill_rect(Rect2i(14, 22, 4, 10), Color("#5d4037"))
	tree_img.fill_rect(Rect2i(15, 22, 2, 10), Color("#4e342e"))
	objects["tree"] = create_texture_from_image(tree_img)

func create_characters():
	var sz = TILE_SIZE

	# 1. Hero Sheet (96x128) - 3 frames (cols) by 4 directions (rows)
	var hero_img = Image.create(sz * 3, sz * 4, true, Image.FORMAT_RGBA8)
	draw_hero_sheet(hero_img, sz)
	characters["hero"] = create_texture_from_image(hero_img)

	# 2. Lina Sheet (96x128)
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

	# 6. Guild NPCs (simple 32x32 down-facing sprites)
	var sz2 = sz
	# Receptionist (blue dress, brown hair)
	var recp_img = Image.create(sz2, sz2, true, Image.FORMAT_RGBA8)
	recp_img.fill(Color(0, 0, 0, 0))
	draw_ellipse(recp_img, Vector2i(16, 28), 10, 4, Color(0, 0, 0, 0.25))
	recp_img.fill_rect(Rect2i(11, 20, 2, 6), Color("#4e342e"))
	recp_img.fill_rect(Rect2i(19, 20, 2, 6), Color("#4e342e"))
	recp_img.fill_rect(Rect2i(10, 25, 12, 7), Color("#1565c0"))
	recp_img.fill_rect(Rect2i(10, 25, 12, 1), Color("#0d47a1"))
	recp_img.fill_rect(Rect2i(10, 30, 12, 1), Color("#0d47a1"))
	recp_img.fill_rect(Rect2i(10, 12, 12, 9), Color("#ffe0b2"))
	recp_img.fill_rect(Rect2i(9, 10, 14, 4), Color("#5d4037"))
	recp_img.fill_rect(Rect2i(9, 13, 2, 6), Color("#5d4037"))
	recp_img.fill_rect(Rect2i(21, 13, 2, 6), Color("#5d4037"))
	recp_img.fill_rect(Rect2i(13, 15, 2, 2), Color("#1a1a1a"))
	recp_img.fill_rect(Rect2i(17, 15, 2, 2), Color("#1a1a1a"))
	recp_img.fill_rect(Rect2i(12, 18, 8, 1), Color("#ef9a9a"))
	characters["receptionist"] = create_texture_from_image(recp_img)

	# Garrick (rugged veteran, grey hair, brown armor, red cape)
	var garrick_img = Image.create(sz2, sz2, true, Image.FORMAT_RGBA8)
	garrick_img.fill(Color(0, 0, 0, 0))
	draw_ellipse(garrick_img, Vector2i(16, 28), 10, 4, Color(0, 0, 0, 0.25))
	garrick_img.fill_rect(Rect2i(22, 1, 5, 10), Color("#8d0000"))
	garrick_img.fill_rect(Rect2i(22, 1, 5, 2), Color("#660000"))
	garrick_img.fill_rect(Rect2i(11, 21, 2, 6), Color("#3e2723"))
	garrick_img.fill_rect(Rect2i(19, 21, 2, 6), Color("#3e2723"))
	garrick_img.fill_rect(Rect2i(10, 26, 12, 2), Color("#4e342e"))
	garrick_img.fill_rect(Rect2i(9, 12, 14, 11), Color("#6d4c41"))
	garrick_img.fill_rect(Rect2i(9, 12, 14, 1), Color("#4e342e"))
	garrick_img.fill_rect(Rect2i(9, 21, 14, 1), Color("#4e342e"))
	garrick_img.fill_rect(Rect2i(9, 12, 1, 10), Color("#4e342e"))
	garrick_img.fill_rect(Rect2i(22, 12, 1, 10), Color("#4e342e"))
	garrick_img.fill_rect(Rect2i(12, 16, 2, 1), Color("#5d4037"))
	garrick_img.fill_rect(Rect2i(10, 13, 3, 3), Color("#5d4037"))
	garrick_img.fill_rect(Rect2i(19, 13, 3, 3), Color("#5d4037"))
	garrick_img.fill_rect(Rect2i(10, 3, 12, 9), Color("#ffcc80"))
	garrick_img.fill_rect(Rect2i(9, 1, 14, 4), Color("#78909c"))
	garrick_img.fill_rect(Rect2i(9, 4, 2, 6), Color("#78909c"))
	garrick_img.fill_rect(Rect2i(21, 4, 2, 6), Color("#78909c"))
	garrick_img.fill_rect(Rect2i(13, 6, 2, 2), Color("#1a1a1a"))
	garrick_img.fill_rect(Rect2i(17, 6, 2, 2), Color("#1a1a1a"))
	garrick_img.fill_rect(Rect2i(13, 9, 6, 1), Color("#8d6e63"))
	garrick_img.fill_rect(Rect2i(11, 8, 2, 1), Color("#b71c1c"))
	characters["garrick"] = create_texture_from_image(garrick_img)

	# Shopkeeper (green vest, white shirt, merchant)
	var shop_img = Image.create(sz2, sz2, true, Image.FORMAT_RGBA8)
	shop_img.fill(Color(0, 0, 0, 0))
	draw_ellipse(shop_img, Vector2i(16, 28), 10, 4, Color(0, 0, 0, 0.25))
	shop_img.fill_rect(Rect2i(11, 20, 2, 6), Color("#3e2723"))
	shop_img.fill_rect(Rect2i(19, 20, 2, 6), Color("#3e2723"))
	shop_img.fill_rect(Rect2i(10, 25, 12, 7), Color("#ffffff"))
	shop_img.fill_rect(Rect2i(10, 12, 12, 13), Color("#2e7d32"))
	shop_img.fill_rect(Rect2i(10, 12, 12, 1), Color("#1b5e20"))
	shop_img.fill_rect(Rect2i(10, 23, 12, 1), Color("#1b5e20"))
	shop_img.fill_rect(Rect2i(10, 12, 1, 12), Color("#1b5e20"))
	shop_img.fill_rect(Rect2i(21, 12, 1, 12), Color("#1b5e20"))
	shop_img.fill_rect(Rect2i(13, 16, 6, 1), Color("#fdd835"))
	shop_img.fill_rect(Rect2i(11, 3, 10, 9), Color("#ffe0b2"))
	shop_img.fill_rect(Rect2i(10, 1, 12, 4), Color("#4e342e"))
	shop_img.fill_rect(Rect2i(10, 4, 2, 6), Color("#4e342e"))
	shop_img.fill_rect(Rect2i(20, 4, 2, 6), Color("#4e342e"))
	shop_img.fill_rect(Rect2i(13, 6, 2, 2), Color("#1a1a1a"))
	shop_img.fill_rect(Rect2i(17, 6, 2, 2), Color("#1a1a1a"))
	shop_img.fill_rect(Rect2i(14, 9, 4, 1), Color("#d47a6a"))
	characters["shopkeeper"] = create_texture_from_image(shop_img)

	# 7. Portraits
	create_portraits()

func create_portraits():
	var pw = 80
	var ph = 96

	# === Hero Portrait ===
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

	# === Lina Portrait ===
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
