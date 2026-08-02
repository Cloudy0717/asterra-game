extends CanvasLayer
class_name ToastManager

var toast_container: VBoxContainer

func _ready():
	layer = 20
	set_process(false)

	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	toast_container = VBoxContainer.new()
	toast_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	toast_container.position = Vector2(-280, -180)
	toast_container.custom_minimum_size = Vector2(260, 0)
	toast_container.add_theme_constant_override("separation", 6)
	toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(toast_container)

static func show_toast(text: String, icon_emoji: String = "📦", duration: float = 2.5):
	var tree = Engine.get_main_loop() as SceneTree
	if not tree or not tree.current_scene:
		return

	# Ensure toast manager node exists
	var scene = tree.current_scene
	var mgr = scene.get_node_or_null("ToastManager")
	if not mgr:
		mgr = load("res://scripts/toast_manager.gd").new()
		mgr.name = "ToastManager"
		scene.add_child(mgr)

	mgr._create_toast_item(text, icon_emoji, duration)

func _create_toast_item(text: String, icon_emoji: String, duration: float):
	var panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.13, 0.92)
	style.border_width_left = 2
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color("#d4af37")
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_top = 6
	style.content_margin_right = 12
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	panel.add_child(hbox)

	var icon = Label.new()
	icon.text = icon_emoji
	icon.add_theme_font_size_override("font_size", 14)
	hbox.add_child(icon)

	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 11)
	label.modulate = Color("#ffecb3")
	hbox.add_child(label)

	toast_container.add_child(panel)

	# Animation: slide in & fade out
	panel.modulate.a = 0.0
	panel.position.x += 30
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position:x", panel.position.x - 30, 0.25).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(duration).timeout
	if is_instance_valid(panel):
		var fade_tween = create_tween()
		fade_tween.tween_property(panel, "modulate:a", 0.0, 0.35)
		fade_tween.tween_callback(panel.queue_free)
