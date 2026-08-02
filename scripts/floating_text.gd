extends Label
class_name FloatingText

enum Type { DAMAGE, HEAL, EXP, SYSTEM, ITEM, CRIT }

var velocity := Vector2(0, -40)
var lifetime := 0.8
var max_life := 0.8

static var _shared_settings: LabelSettings = null
static var _crit_settings: LabelSettings = null

static func _get_settings() -> LabelSettings:
	if not _shared_settings:
		_shared_settings = LabelSettings.new()
		_shared_settings.font_size = 16
		_shared_settings.outline_size = 3
		_shared_settings.outline_color = Color.BLACK
	return _shared_settings

static func _get_crit_settings() -> LabelSettings:
	if not _crit_settings:
		_crit_settings = LabelSettings.new()
		_crit_settings.font_size = 22
		_crit_settings.outline_size = 4
		_crit_settings.outline_color = Color(0.2, 0.1, 0, 1)
	return _crit_settings

static func spawn(msg: String, pos: Vector2, type: Type = Type.DAMAGE) -> FloatingText:
	var instance = FloatingText.new()
	instance.text = msg
	instance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Random X offset to prevent stacking
	var x_offset = randf_range(-25, 25)
	instance.global_position = pos + Vector2(x_offset, 0)

	if type == Type.CRIT:
		instance.label_settings = _get_crit_settings()
		instance.label_settings.font_color = Color("#ffd700")
		instance.velocity = Vector2(randf_range(-15, 15), -55)
		instance.lifetime = 1.1
		instance.max_life = 1.1
		instance.scale = Vector2(1.3, 1.3)
	else:
		instance.label_settings = _get_settings()
		match type:
			Type.DAMAGE:
				instance.label_settings.font_color = Color("#ff5252")
				instance.velocity = Vector2(randf_range(-10, 10), -40)
			Type.HEAL:
				instance.label_settings.font_color = Color("#69f0ae")
				instance.velocity = Vector2(randf_range(-8, 8), -35)
			Type.EXP:
				instance.label_settings.font_color = Color("#ffd740")
			Type.SYSTEM:
				instance.label_settings.font_color = Color("#81d4fa")
			Type.ITEM:
				instance.label_settings.font_color = Color("#ffab40")

	var scene = Engine.get_main_loop().current_scene
	if scene:
		scene.add_child(instance)
	return instance

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	modulate.a = clampf(lifetime / max_life, 0.0, 1.0)
	if lifetime <= 0:
		queue_free()
