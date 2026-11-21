extends Node2D

# Phase 2: large-map kingdom base defense prototype.
const COLS := 15
const ROWS := 15
const HEX_W := 65.0
const HEX_H := 58.0
const BOARD_ORIGIN := Vector2(80, 260)
const HEX_RADIUS := 31.0
const BASE_CELL := Vector2i(7, 7)

var camera_offset := Vector2(-420, 0)
var units: Array[Dictionary] = []
var selected_unit := -1
var turn_number := 1
var wave_number := 1
var base_hp := 20
var base_max_hp := 20
var message := "Select a RED defender. Protect the royal base!"
var game_over := false
var touch_start := Vector2.ZERO
var touch_last := Vector2.ZERO
var touch_moved := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_reset_battle()
	queue_redraw()

func _reset_battle() -> void:
	units = [
		{"id": "red_inf_1", "side": "red", "kind": "INF", "q": 6, "r": 7, "hp": 4, "max_hp": 4},
		{"id": "red_cav_1", "side": "red", "kind": "CAV", "q": 8, "r": 7, "hp": 3, "max_hp": 3},
		{"id": "red_ele_1", "side": "red", "kind": "ELE", "q": 7, "r": 8, "hp": 6, "max_hp": 6}
	]
	selected_unit = -1
	turn_number = 1
	wave_number = 1
	base_hp = base_max_hp
	game_over = false
	message = "Select a RED defender. Protect the royal base!"
	_spawn_wave(2)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color("#18232b"))
	_draw_board()
	_draw_base()
	_draw_units()
	_draw_hud()
	if game_over:
		draw_rect(Rect2(35, 490, 650, 250), Color(0, 0, 0, 0.9))
		draw_string(ThemeDB.fallback_font, Vector2(75, 585), "KINGDOM FALLEN", HORIZONTAL_ALIGNMENT_LEFT, 570, 34, Color("#ffe0a0"))
		draw_string(ThemeDB.fallback_font, Vector2(75, 645), "The royal base has been destroyed.", HORIZONTAL_ALIGNMENT_LEFT, 570, 19, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(75, 690), "Tap RESTART to defend again.", HORIZONTAL_ALIGNMENT_LEFT, 570, 17, Color.WHITE)

func _draw_board() -> void:
	for r in range(ROWS):
		for q in range(COLS):
			var center := _screen_hex_center(q, r)
			if center.x < -60 or center.x > 780 or center.y < 220 or center.y > 1100:
				continue
			var fill := Color("#667d59")
			if (q * 3 + r * 5) % 7 == 0:
				fill = Color("#71866a")
			if (q + r) % 11 == 0:
				fill = Color("#77745e")
			var points := _hex_points(center)
			draw_colored_polygon(points, fill)
			var outline := points.duplicate()
			outline.append(points[0])
			draw_polyline(outline, Color("#263b35"), 2.0, true)
			if (q * 3 + r * 5) % 7 == 0:
				draw_circle(center + Vector2(0, -8), 5, Color("#8ca57a"))

func _draw_base() -> void:
	var center := _screen_hex_center(BASE_CELL.x, BASE_CELL.y)
	draw_circle(center, 42, Color("#7d302b"))
	draw_circle(center, 34, Color("#bd9145"))
	draw_rect(Rect2(center + Vector2(-19, -24), Vector2(38, 48)), Color("#e4c98b"))
	draw_rect(Rect2(center + Vector2(-7, -38), Vector2(14, 20)), Color("#a33e35"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-20, 58), "ROYAL BASE", HORIZONTAL_ALIGNMENT_LEFT, 100, 13, Color("#ffe6b0"))

func _draw_units() -> void:
	for i in range(units.size()):
		var unit: Dictionary = units[i]
		var center := _screen_hex_center(int(unit.q), int(unit.r))
		if center.x < -60 or center.x > 780 or center.y < 220 or center.y > 1100:
			continue
		var body_color := Color("#a33e35") if unit.side == "red" else Color("#d6ad45")
		draw_circle(center, 22, body_color)
		draw_arc(center, 22, 0.0, TAU, 32, Color("#f7e9c8"), 3.0)
		if i == selected_unit:
			draw_arc(center, 29, 0.0, TAU, 32, Color("#fff2a6"), 4.0)
		draw_string(ThemeDB.fallback_font, center + Vector2(-15, 5), str(unit.kind), HORIZONTAL_ALIGNMENT_LEFT, 32, 13, Color.WHITE)
		draw_string(ThemeDB.fallback_font, center + Vector2(-17, 38), str(unit.hp) + " HP", HORIZONTAL_ALIGNMENT_LEFT, 50, 11, Color.WHITE)

func _draw_hud() -> void:
	draw_rect(Rect2(18, 18, 684, 190), Color("#202d36"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 53), "MYANMAR: EMPIRE OF WARRIORS", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f1d49b"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 84), "KINGDOM DEFENSE  •  KONBAUNG (RED)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c5ced5"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 122), "BASE HP: %d / %d" % [base_hp, base_max_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#ffe0a0"))
	draw_rect(Rect2(260, 105, 390, 17), Color("#4b555c"))
	draw_rect(Rect2(260, 105, 390.0 * float(base_hp) / float(base_max_hp), 17), Color("#a33e35"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 158), "WAVE %d   •   TURN %d   •   ENEMIES %d" % [wave_number, turn_number, _enemy_count()], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#e5e9eb"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 188), message, HORIZONTAL_ALIGNMENT_LEFT, 650, 14, Color("#d1dbe1"))
	draw_rect(Rect2(25, 1110, 260, 82), Color("#34434b"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 1160), "RESTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)
	draw_rect(Rect2(420, 1110, 275, 82), Color("#8f342d") if not game_over else Color("#555b60"))
	draw_string(ThemeDB.fallback_font, Vector2(454, 1160), "END WAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(260, 1090), "DRAG MAP TO SCROLL", HORIZONTAL_ALIGNMENT_CENTER, 200, 12, Color("#c5ced5"))

func _screen_hex_center(q: int, r: int) -> Vector2:
	return _world_hex_center(q, r) + camera_offset

func _world_hex_center(q: int, r: int) -> Vector2:
	return BOARD_ORIGIN + Vector2(q * HEX_W + r * HEX_W * 0.5, r * HEX_H)

func _hex_points(center: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(6):
		var angle := deg_to_rad(60.0 * i - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * HEX_RADIUS)
	return points

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_last = event.position
			touch_moved = false
		else:
			if not touch_moved:
				_handle_tap(event.position)
	elif event is InputEventScreenDrag:
		if touch_start.y > 210 and touch_start.y < 1090:
			if event.position.distance_to(touch_start) > 10:
				touch_moved = true
			if touch_moved:
				camera_offset += event.relative
				_clamp_camera()
				queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			touch_start = event.position
			touch_last = event.position
			touch_moved = false
		elif not touch_moved:
			_handle_tap(event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if touch_start.y > 210 and touch_start.y < 1090:
			if event.position.distance_to(touch_start) > 10:
				touch_moved = true
			if touch_moved:
				camera_offset += event.relative
				_clamp_camera()
				queue_redraw()

func _clamp_camera() -> void:
	camera_offset.x = clampf(camera_offset.x, -900.0, 0.0)
	camera_offset.y = clampf(camera_offset.y, -180.0, 120.0)

func _handle_tap(pos: Vector2) -> void:
	if pos.y >= 1100 and pos.x <= 310:
		_restart()
		return
	if pos.y >= 1100 and pos.x >= 400 and not game_over:
		_end_wave()
		return
	if pos.y < 220 or pos.y > 1090 or game_over:
		return
	var world_pos := pos - camera_offset
	var cell := _nearest_cell(world_pos)
	if cell.is_empty():
		return
	var q := int(cell.q)
	var r := int(cell.r)
	var tapped_unit := _unit_at(q, r)
	if tapped_unit != -1:
		if units[tapped_unit].side == "red":
			selected_unit = tapped_unit
			message = "Selected %s. Move one hex or attack an adjacent raider." % units[tapped_unit].kind
		elif selected_unit != -1 and _hex_distance(units[selected_unit], units[tapped_unit]) == 1:
			_attack(selected_unit, tapped_unit)
		queue_redraw()
		return
	if selected_unit != -1 and _hex_distance(units[selected_unit], cell) == 1 and Vector2i(q, r) != BASE_CELL:
		units[selected_unit].q = q
		units[selected_unit].r = r
		message = "Defender repositioned. Protect the royal base!"
		selected_unit = -1
	queue_redraw()

func _nearest_cell(pos: Vector2) -> Dictionary:
	var best_distance := 999999.0
	var best := {}
	for r in range(ROWS):
		for q in range(COLS):
			var d := pos.distance_to(_world_hex_center(q, r))
			if d < best_distance:
				best_distance = d
				best = {"q": q, "r": r}
	if best_distance <= HEX_RADIUS + 12.0:
		return best
	return {}

func _unit_at(q: int, r: int) -> int:
	for i in range(units.size()):
		if int(units[i].q) == q and int(units[i].r) == r:
			return i
	return -1

func _hex_distance(a: Dictionary, b: Dictionary) -> int:
	var aq := int(a.q)
	var ar := int(a.r)
	var bq := int(b.q)
	var br := int(b.r)
	return int((abs(aq - bq) + abs(aq + ar - bq - br) + abs(ar - br)) / 2)

func _attack(attacker_index: int, defender_index: int) -> void:
	units[defender_index].hp -= 1
	message = "%s struck a raider!" % units[attacker_index].kind
	if int(units[defender_index].hp) <= 0:
		units.remove_at(defender_index)
		if defender_index < selected_unit:
			selected_unit -= 1
		message += " Enemy defeated."
	selected_unit = -1
	queue_redraw()

func _end_wave() -> void:
	if game_over:
		return
	selected_unit = -1
	turn_number += 1
	_enemy_phase()
	if game_over:
		queue_redraw()
		return
	wave_number += 1
	var spawn_count := 1 if wave_number < 3 else 2
	_spawn_wave(spawn_count)
	message = "Wave %d incoming! Raiders appeared across the wilderness." % wave_number
	queue_redraw()

func _enemy_phase() -> void:
	var i := 0
	while i < units.size():
		if units[i].side != "gold":
			i += 1
			continue
		var enemy: Dictionary = units[i]
		var base_cell := {"q": BASE_CELL.x, "r": BASE_CELL.y}
		if _hex_distance(enemy, base_cell) <= 1:
			base_hp -= 2 if enemy.kind == "ELE" else 1
			units.remove_at(i)
			message = "Raiders attacked the royal base!"
			if base_hp <= 0:
				base_hp = 0
				game_over = true
				message = "The royal base has fallen."
				return
			continue
		_move_enemy_toward_base(i)
		i += 1

func _move_enemy_toward_base(index: int) -> void:
	var current: Dictionary = units[index]
	var best_cell := Vector2i(int(current.q), int(current.r))
	var base_cell := {"q": BASE_CELL.x, "r": BASE_CELL.y}
	var best_distance := _hex_distance(current, base_cell)
	var steps := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]
	for step in steps:
		var q := int(current.q) + step.x
		var r := int(current.r) + step.y
		if q < 0 or q >= COLS or r < 0 or r >= ROWS or _unit_at(q, r) != -1 or Vector2i(q, r) == BASE_CELL:
			continue
		var d := _hex_distance({"q": q, "r": r}, base_cell)
		if d < best_distance:
			best_distance = d
			best_cell = Vector2i(q, r)
	units[index].q = best_cell.x
	units[index].r = best_cell.y

func _spawn_wave(count: int) -> void:
	for n in range(count):
		var tries := 0
		while tries < 100:
			tries += 1
			var q := rng.randi_range(0, COLS - 1)
			var r := rng.randi_range(0, ROWS - 1)
			var cell := {"q": q, "r": r}
			var base_cell := {"q": BASE_CELL.x, "r": BASE_CELL.y}
			if _hex_distance(cell, base_cell) < 4 or _unit_at(q, r) != -1 or Vector2i(q, r) == BASE_CELL:
				continue
			var kind := "INF"
			var hp := 3
			if wave_number >= 3 and rng.randf() < 0.25:
				kind = "CAV"
				hp = 2
			units.append({"id": "raider_%d_%d" % [wave_number, n], "side": "gold", "kind": kind, "q": q, "r": r, "hp": hp, "max_hp": hp})
			break

func _enemy_count() -> int:
	var count := 0
	for unit in units:
		if unit.side == "gold":
			count += 1
	return count

func _restart() -> void:
	camera_offset = Vector2(-420, 0)
	_reset_battle()
	queue_redraw()
