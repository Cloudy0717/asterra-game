extends Node2D

# Animated fireplace with flickering flames

var time = 0.0
var flame_particles = []
var light_node: PointLight2D

func _ready():
	z_index = 5
	# Pre-generate some random flame particle data
	for i in range(12):
		flame_particles.append({
			"x_off": randf_range(-10, 10),
			"speed": randf_range(18.0, 40.0),
			"size": randf_range(2.5, 5.0),
			"phase": randf() * TAU,
			"hue_shift": randf_range(0.0, 0.12)
		})
	
	light_node = PointLight2D.new()
	light_node.texture = Sprites.get_light_texture(120)
	light_node.color = Color("#ffaa33")
	light_node.energy = 1.3
	add_child(light_node)

func _process(delta):
	time += delta
	if is_instance_valid(light_node):
		light_node.energy = 1.1 + 0.3 * sin(time * 5.0) + randf_range(-0.06, 0.06)
	queue_redraw()

func _draw():
	# -- Fireplace stone frame --
	# Outer frame (dark brown stone)
	draw_rect(Rect2(-32, -16, 64, 32), Color("#3e2723"))
	# Inner arch (dark cavity)
	draw_rect(Rect2(-16, -6, 32, 22), Color("#1a1a1a"))
	# Top arch detail
	draw_rect(Rect2(-18, -8, 36, 4), Color("#4e342e"))
	# Side pillars
	draw_rect(Rect2(-32, -16, 6, 32), Color("#5d4037"))
	draw_rect(Rect2(26, -16, 6, 32), Color("#5d4037"))
	# Mantle top
	draw_rect(Rect2(-30, -16, 60, 4), Color("#6d4c41"))
	
	# -- Glowing embers at the base --
	var ember_glow = 0.7 + 0.3 * sin(time * 3.0)
	draw_rect(Rect2(-12, 8, 24, 6), Color(0.9, 0.2, 0.0, ember_glow))
	draw_rect(Rect2(-8, 6, 16, 4), Color(1.0, 0.5, 0.0, ember_glow * 0.8))
	
	# -- Logs --
	draw_rect(Rect2(-10, 10, 8, 4), Color("#4e342e"))
	draw_rect(Rect2(2, 10, 8, 4), Color("#3e2723"))
	
	# -- Animated flame particles --
	for p in flame_particles:
		var y_offset = fmod((time * p.speed + p.phase), 22.0)
		var x_wave = sin(time * 2.5 + p.phase) * 3.0 + p.x_off * 0.5
		var alpha = clampf(1.0 - y_offset / 22.0, 0.0, 1.0)
		var size = p.size * alpha
		
		if size < 0.5:
			continue
		
		var fx = x_wave
		var fy = 6.0 - y_offset
		
		# Color gradient: white core → yellow → orange → red tip
		var t = clampf(y_offset / 22.0, 0.0, 1.0)
		var color: Color
		if t < 0.2:
			color = Color(1.0, 1.0, 0.9, alpha * 0.95)  # white-hot core
		elif t < 0.45:
			color = Color(1.0, 0.85 - p.hue_shift, 0.1, alpha * 0.9)  # yellow
		elif t < 0.7:
			color = Color(1.0, 0.45 - p.hue_shift, 0.0, alpha * 0.75)  # orange
		else:
			color = Color(0.8, 0.15, 0.0, alpha * 0.5)  # red tip
		
		draw_rect(Rect2(fx - size/2, fy - size/2, size, size), color)
	
	# -- Ambient glow circle on floor --
	var glow_alpha = 0.08 + 0.04 * sin(time * 2.0)
	draw_circle(Vector2(0, 20), 28, Color(1.0, 0.5, 0.1, glow_alpha))
