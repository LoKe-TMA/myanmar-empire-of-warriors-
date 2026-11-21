extends Control

const BATTLE_SCENE := "res://scenes/battlefield.tscn"

func _ready() -> void:
	_build_menu()

func _build_menu() -> void:
	var background := ColorRect.new()
	background.color = Color("#171d25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-260, -210)
	layout.size = Vector2(520, 420)
	layout.add_theme_constant_override("separation", 28)
	add_child(layout)

	var title := Label.new()
	title.text = "MYANMAR\nEMPIRE OF WARRIORS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("#f1d49b"))
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A HISTORICAL TURN-BASED STRATEGY"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 15)
	subtitle.add_theme_color_override("font_color", Color("#c3cbd4"))
	layout.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 35
	layout.add_child(spacer)

	var start_button := Button.new()
	start_button.text = "START BATTLE"
	start_button.custom_minimum_size = Vector2(0, 76)
	start_button.add_theme_font_size_override("font_size", 24)
	start_button.pressed.connect(_start_battle)
	layout.add_child(start_button)

	var note := Label.new()
	note.text = "PROTOTYPE 01  •  KONBAUNG vs HANTHAWADDY"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", Color("#aab3bd"))
	layout.add_child(note)

func _start_battle() -> void:
	get_tree().change_scene_to_file(BATTLE_SCENE)
