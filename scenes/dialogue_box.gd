extends CanvasLayer

signal choice_selected(idx)

var speaker_label: Label
var text_label: RichTextLabel
var avatar_label: Label
var portrait_rect: TextureRect
var choices_container: VBoxContainer
var next_indicator: Label

var current_steps = []
var step_index = 0
var current_callback

var typing_text = ""
var display_text = ""
var char_idx = 0
var char_timer = 0.0

func _ready():
	setup_ui()
	hide_box()
	GameState.show_dialogue.connect(start_dialogue)

func setup_ui():
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	
	# Transparent overlay catcher to prevent character movement clicks
	var click_catcher = TextureButton.new()
	click_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_catcher.pressed.connect(on_dialogue_clicked)
	root.add_child(click_catcher)
	
	# Dialogue main panel (Bottom Glassmorphic Card style)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(650, 150)
	panel.position = Vector2(75, 420)
	root.add_child(panel)
	
	# Add a modern stylebox flat
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.85)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color("#8d6e63")
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)
	
	# Avatar Container
	var avatar_panel = PanelContainer.new()
	avatar_panel.custom_minimum_size = Vector2(80, 80)
	avatar_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var avatar_style = StyleBoxFlat.new()
	avatar_style.bg_color = Color(0.15, 0.15, 0.17, 1.0)
	avatar_style.border_width_left = 1
	avatar_style.border_width_right = 1
	avatar_style.border_width_top = 1
	avatar_style.border_width_bottom = 1
	avatar_style.border_color = Color("#5d4037")
	avatar_panel.add_theme_stylebox_override("panel", avatar_style)
	hbox.add_child(avatar_panel)
	
	avatar_label = Label.new()
	avatar_label.text = "👧"
	avatar_label.add_theme_font_size_override("font_size", 36)
	avatar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar_panel.add_child(avatar_label)

	portrait_rect = TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(80, 80)
	portrait_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_rect.visible = false
	avatar_panel.add_child(portrait_rect)
	
	# Dialogue Content VBox
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(content_vbox)
	
	speaker_label = Label.new()
	speaker_label.text = "Speaker"
	speaker_label.add_theme_font_size_override("font_size", 16)
	speaker_label.modulate = Color("#e0b034") # gold/yellow
	content_vbox.add_child(speaker_label)
	
	text_label = RichTextLabel.new()
	text_label.text = "Hello there!"
	text_label.add_theme_font_size_override("font_size", 13)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.bbcode_enabled = true
	content_vbox.add_child(text_label)
	
	# Choice Buttons Container
	choices_container = VBoxContainer.new()
	choices_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_child(choices_container)
	
	# Next Indicator ▼
	next_indicator = Label.new()
	next_indicator.text = "▼"
	next_indicator.add_theme_font_size_override("font_size", 10)
	next_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	next_indicator.size_flags_vertical = Control.SIZE_SHRINK_END
	content_vbox.add_child(next_indicator)

func _process(delta):
	if not visible:
		return
		
	# Typewriter effect
	if char_idx < typing_text.length():
		char_timer += delta
		var speed = float(GameState.settings.text_speed) / 1000.0
		if speed <= 0.0:
			# Instant
			char_idx = typing_text.length()
			text_label.text = typing_text
			on_text_complete()
		elif char_timer >= speed:
			char_timer = 0.0
			char_idx += 1
			text_label.text = typing_text.substr(0, char_idx)
			if char_idx >= typing_text.length():
				on_text_complete()

func start_dialogue(steps: Array, callback):
	print("[DialogueBox] start_dialogue received! Steps count: ", steps.size())
	GameState.play_sfx("talk")
	current_steps = steps
	step_index = 0
	current_callback = callback
	show_box()
	render_step()

func render_step():
	print("[DialogueBox] Rendering step: ", step_index)
	if step_index >= current_steps.size():
		close_dialogue()
		return
		
	var step = current_steps[step_index]
	speaker_label.text = step.get("speaker", "System")
	var avatar_key = step.get("avatar", "👤")
	avatar_label.text = avatar_key
	if Sprites.portraits.has(avatar_key):
		portrait_rect.texture = Sprites.portraits[avatar_key]
		portrait_rect.visible = true
		avatar_label.visible = false
	else:
		portrait_rect.visible = false
		avatar_label.visible = true
	
	# Clear choices
	for child in choices_container.get_children():
		child.queue_free()
	choices_container.visible = false
	next_indicator.visible = false
	
	typing_text = step.get("text", "")
	char_idx = 0
	char_timer = 0.0
	text_label.text = ""

func on_text_complete():
	var step = current_steps[step_index]
	var choices = step.get("choices", [])
	
	if choices.size() > 0:
		next_indicator.visible = false
		choices_container.visible = true
		for i in range(choices.size()):
			var choice = choices[i]
			var btn = Button.new()
			btn.text = choice.get("text", "")
			btn.pressed.connect(func():
				GameState.play_sfx("select")
				# Run the choice action
				var act = choice.get("action")
				if act is Callable:
					act.call()
				# Advance step
				step_index += 1
				render_step()
			)
			choices_container.add_child(btn)
	else:
		next_indicator.visible = true

func on_dialogue_clicked():
	# If choices are active, force player to pick a choice button, ignore click catcher
	var step = current_steps[step_index]
	var choices = step.get("choices", [])
	if choices.size() > 0 and char_idx >= typing_text.length():
		return
		
	# Skip typewriter if typing
	if char_idx < typing_text.length():
		char_idx = typing_text.length()
		text_label.text = typing_text
		on_text_complete()
	else:
		# Advance
		step_index += 1
		render_step()

func close_dialogue():
	if not visible:
		return
	hide_box()
	GameState.play_sfx("close_menu")
	if current_callback is Callable:
		current_callback.call()
	GameState.emit_signal("dialogue_ended")

func show_box():
	print("[DialogueBox] show_box() setting visible to true")
	visible = true

func hide_box():
	print("[DialogueBox] hide_box() setting visible to false")
	visible = false
