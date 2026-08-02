extends Node

static func make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color("#8d6e63")
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

static func make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = border
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

static func apply_panel_style(node: PanelContainer) -> void:
	node.add_theme_stylebox_override("panel", make_panel_style())

static func apply_button_styles(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", make_button_style(Color(0.12, 0.12, 0.15, 0.8), Color("#5d4037")))
	btn.add_theme_stylebox_override("hover", make_button_style(Color(0.18, 0.18, 0.22, 0.9), Color("#8d6e63")))
	btn.add_theme_stylebox_override("pressed", make_button_style(Color(0.08, 0.08, 0.1, 0.95), Color("#3e2723")))
	btn.add_theme_stylebox_override("disabled", make_button_style(Color(0.06, 0.06, 0.08, 0.5), Color("#37474f")))
