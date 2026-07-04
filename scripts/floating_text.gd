extends Label

var velocity = Vector2(0, -25)
var lifetime = 0.8
var max_life = 0.8
var base_color = Color("#ff5252")

func _ready():
	var settings = LabelSettings.new()
	settings.font_size = 12
	settings.font_color = base_color
	settings.outline_size = 3
	settings.outline_color = Color.BLACK
	label_settings = settings
	
	# Center align
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	modulate.a = max(0.0, lifetime / max_life)
	if lifetime <= 0:
		queue_free()
