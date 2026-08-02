extends RefCounted
class_name BattleVFX

## ============================================================
##  Slash Arc — draws an animated arc across a target node
## ============================================================
static func slash_arc(parent: Node, target: Control, is_skill: bool = false):
	if not is_instance_valid(parent) or not is_instance_valid(target):
		return

	var center = target.global_position + target.size * 0.5
	var arc_count = 2 if is_skill else 1

	for i in range(arc_count):
		var line = Line2D.new()
		line.width = 3.0
		line.default_color = Color("#ffd700") if is_skill else Color(1, 1, 1, 0.9)
		line.z_index = 100
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND

		# Build arc points
		var radius = 30.0
		var start_angle = -2.2 + i * 1.4
		var end_angle = start_angle + 2.8
		var segments = 12
		for s in range(segments + 1):
			var t = float(s) / float(segments)
			var angle = lerp(start_angle, end_angle, t)
			var pt = center + Vector2(cos(angle), sin(angle)) * radius
			line.add_point(pt - parent.global_position if parent is Control else pt)

		parent.add_child(line)

		# Fade out
		var tween = parent.create_tween()
		tween.tween_property(line, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_OUT)
		tween.tween_callback(line.queue_free)

## ============================================================
##  Hit Flash — flashes a control red then white then back
## ============================================================
static func hit_flash(target: Control, duration: float = 0.3):
	if not is_instance_valid(target):
		return

	var original = target.modulate
	var tween = target.create_tween()
	tween.tween_property(target, "modulate", Color(1.5, 0.3, 0.3, 1), duration * 0.2)
	tween.tween_property(target, "modulate", Color(2.0, 2.0, 2.0, 1), duration * 0.15)
	tween.tween_property(target, "modulate", original, duration * 0.65)

## ============================================================
##  Screen Shake — shakes a control's position briefly
## ============================================================
static func screen_shake(target: Control, intensity: float = 4.0, duration: float = 0.25):
	if not is_instance_valid(target):
		return

	var original_pos = target.position
	var tween = target.create_tween()
	var steps = 6
	var step_dur = duration / float(steps)

	for s in range(steps):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		# Dampen over time
		var dampen = 1.0 - float(s) / float(steps)
		tween.tween_property(target, "position", original_pos + offset * dampen, step_dur)

	tween.tween_property(target, "position", original_pos, step_dur)
