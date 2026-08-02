extends Node

signal map_changing(map_name)

var player_ref: Node2D
var fade_rect_ref: ColorRect

func transition_to(map_name: String, new_pos: Vector2, new_dir: String):
	player_ref.process_mode = PROCESS_MODE_DISABLED

	var tween = create_tween()
	tween.tween_property(fade_rect_ref, "color:a", 1.0, 0.2)
	tween.tween_callback(func():
		emit_signal("map_changing", map_name)
		player_ref.position = new_pos
		player_ref.dir = new_dir
		player_ref.update_sprite_frame()
	)
	tween.tween_property(fade_rect_ref, "color:a", 0.0, 0.2)
	tween.tween_callback(func():
		player_ref.process_mode = PROCESS_MODE_INHERIT
	)
