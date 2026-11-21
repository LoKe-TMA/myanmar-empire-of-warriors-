extends Node2D

const COLS := 7
const ROWS := 7
const HEX_W := 65.0
const HEX_H := 58.0
const BOARD_ORIGIN := Vector2(90, 330)
const HEX_RADIUS := 32.0

var units: Array[Dictionary] = []
var selected_unit := -1
var player_turn := true
var turn_number := 1
var message := "Select a RED unit, then tap an adjacent hex."
var game_over := false

func _ready() -> void:
	_reset_units()
	queue_redraw()

func _reset_units() -> void:
	units = [
		{"id": "red_inf", "side": "red", "kind": "INF", "q": 1, "r": 4, "hp": 3, "max_hp": 3},
		{"id": "red_cav", "side": "red", "kind": "CAV", "q": 0, "r": 5, "hp": 3, "max_hp": 3},
		{"id": "red_ele", "side": "red", "kind": "ELE", "q": 2, "r": 5, "hp": 5, "max_hp": 5},
		{"id": "gold_inf", "side": "gold", "kind": "INF", "q": 4, "r": 1, "hp": 3, "max_hp": 3},
		{"id": "gold_cav", "side": "gold", "kind": "CAV", "q": 6, "r": 1, "hp": 3, "max_hp": 3},
		{"id": "gold_ele", "side": "gold", "kind": "ELE", "q": 5, "r": 2, "hp": 5, "max_hp": 5}
	]

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color("#18232b"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 58), "MYANMAR: EMPIRE OF WARRIORS", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#f1d49b"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 96), "BATTLE 01  •  KONBAUNG (RED) vs HANTHAWADDY (GOLD)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c5ced5"))
	_draw_status_panel()
	_draw_board()
	_draw_units()
	_draw_buttons()
	if game_over:
		draw_rect(Rect2(35, 520, 650, 210), Color(0, 0, 0, 0.88))
		draw_string(ThemeDB.fallback_font, Vector2(75, 605), message, HORIZONTAL_ALIGNMENT_LEFT, 570, 27, Color("#ffe0a0"))
		draw_string(ThemeDB.fallback_font, Vector2(75, 660), "Tap RESTART to play again.", HORIZONTAL_ALIGNMENT_LEFT, 570, 19, Color.WHITE)

func _draw_status_panel() -> void:
	draw_rect(Rect2(25, 125, 670, 120), Color("#26343d"))
	draw_string(ThemeDB.fallback_font, Vector2(48, 165), "TURN %d  •  %s" % [turn_number, "YOUR TURN" if player_turn else "ENEMY TURN"], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f5e7c8"))
	draw_string(ThemeDB.fallback_font, Vector2(48, 205), message, HORIZONTAL_ALIGNMENT_LEFT, 610, 16, Color("#d1dbe1"))

func _draw_board() -> void:
	for r in range(ROWS):
		for q in range(COLS):
			var center := _hex_center(q, r)
			var fill := Color("#667d59")
			if (q + r) % 5 == 0:
				fill = Color("#71866a")
			if q == 3 and r in [2, 3, 4]:
				fill = Color("#477b91")
			if q in [0, 6] and r in [2, 5]:
				fill = Color("#77745e")
			var points := _hex_points(center)
			draw_colored_polygon(points, fill)
			var outline := points.duplicate()
			outline.append(points[0])
			draw_polyline(outline, Color("#263b35"), 2.0, true)
			if q == 3 and r in [2, 3, 4]:
				draw_string(ThemeDB.fallback_font, center + Vector2(-8, 5), "≈", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#d6eef5"))

func _draw_units() -> void:
	for i in range(units.size()):
		var unit: Dictionary = units[i]
		var center := _hex_center(int(unit.q), int(unit.r))
		var body_color := Color("#a33e35") if unit.side == "red" else Color("#d6ad45")
		draw_circle(center, 23, body_color)
		draw_arc(center, 23, 0.0, TAU, 32, Color("#f7e9c8"), 3.0)
		if i == selected_unit:
			draw_arc(center, 30, 0.0, TAU, 32, Color("#fff2a6"), 4.0)
		draw_string(ThemeDB.fallback_font, center + Vector2(-15, 6), str(unit.kind), HORIZONTAL_ALIGNMENT_LEFT, 32, 14, Color.WHITE)
		draw_string(ThemeDB.fallback_font, center + Vector2(-17, 40), "HP " + str(unit.hp), HORIZONTAL_ALIGNMENT_LEFT, 50, 11, Color.WHITE)

func _draw_buttons() -> void:
	draw_rect(Rect2(420, 1110, 260, 82), Color("#8f342d") if player_turn else Color("#555b60"))
	draw_string(ThemeDB.fallback_font, Vector2(454, 1160), "END TURN", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)
	draw_rect(Rect2(35, 1110, 260, 82), Color("#34434b"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 1160), "RESTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)

func _hex_center(q: int, r: int) -> Vector2:
	return BOARD_ORIGIN + Vector2(q * HEX_W + r * HEX_W * 0.5, r * HEX_H)

func _hex_points(center: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(6):
		var angle := deg_to_rad(60.0 * i - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * HEX_RADIUS)
	return points

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_tap(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_tap(event.position)

func _handle_tap(pos: Vector2) -> void:
	if pos.y >= 1100 and pos.x >= 400 and not game_over:
		_end_player_turn()
		return
	if pos.y >= 1100 and pos.x <= 310:
		_restart()
		return
	if game_over or not player_turn:
		return
	var cell := _nearest_cell(pos)
	if cell.is_empty():
		return
	var tapped_unit := _unit_at(int(cell.q), int(cell.r))
	if tapped_unit != -1:
		if units[tapped_unit].side == "red":
			selected_unit = tapped_unit
			message = "Selected %s. Tap a neighboring empty hex or enemy." % units[tapped_unit].kind
		elif selected_unit != -1 and _hex_distance(units[selected_unit], units[tapped_unit]) == 1:
			_attack(selected_unit, tapped_unit)
		queue_redraw()
		return
	if selected_unit != -1 and _hex_distance(units[selected_unit], cell) == 1:
		units[selected_unit].q = cell.q
		units[selected_unit].r = cell.r
		message = "Unit moved. Select another unit or end your turn."
		selected_unit = -1
	queue_redraw()

func _nearest_cell(pos: Vector2) -> Dictionary:
	var best_distance := 999999.0
	var best := {}
	for r in range(ROWS):
		for q in range(COLS):
			var d := pos.distance_to(_hex_center(q, r))
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
	message = "%s attacked %s!" % [units[attacker_index].kind, units[defender_index].kind]
	if int(units[defender_index].hp) <= 0:
		units.remove_at(defender_index)
		if defender_index < selected_unit:
			selected_unit -= 1
		message += " Enemy unit defeated."
	selected_unit = -1
	_check_game_over()

func _end_player_turn() -> void:
	if game_over:
		return
	player_turn = false
	selected_unit = -1
	message = "Enemy army is taking its turn..."
	queue_redraw()
	_enemy_turn()
	if not game_over:
		player_turn = true
		turn_number += 1
		message = "Your turn. Select a RED unit."
	queue_redraw()

func _enemy_turn() -> void:
	var acted_ids: Array[String] = []
	while true:
		var enemy_index := -1
		for i in range(units.size()):
			if units[i].side == "gold" and not acted_ids.has(str(units[i].id)):
				enemy_index = i
				break
		if enemy_index == -1:
			break
		var enemy_id := str(units[enemy_index].id)
		acted_ids.append(enemy_id)
		var target_index := _closest_player(enemy_index)
		if target_index == -1:
			break
		if _hex_distance(units[enemy_index], units[target_index]) == 1:
			_attack(enemy_index, target_index)
		else:
			_move_enemy_toward(enemy_index, target_index)
		if game_over:
			return

func _closest_player(from_index: int) -> int:
	var best := -1
	var best_distance := 999
	for i in range(units.size()):
		if units[i].side == "red":
			var d := _hex_distance(units[from_index], units[i])
			if d < best_distance:
				best_distance = d
				best = i
	return best

func _move_enemy_toward(enemy_index: int, target_index: int) -> void:
	var current: Dictionary = units[enemy_index]
	var target: Dictionary = units[target_index]
	var candidates := [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
		Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)
	]
	var best_cell := Vector2i(int(current.q), int(current.r))
	var best_distance := _hex_distance(current, target)
	for step in candidates:
		var q: int = int(current.q) + step.x
		var r: int = int(current.r) + step.y
		if q < 0 or q >= COLS or r < 0 or r >= ROWS or _unit_at(q, r) != -1:
			continue
		var d := _hex_distance({"q": q, "r": r}, target)
		if d < best_distance:
			best_distance = d
			best_cell = Vector2i(q, r)
	units[enemy_index].q = best_cell.x
	units[enemy_index].r = best_cell.y

func _check_game_over() -> void:
	var red_count := 0
	var gold_count := 0
	for unit in units:
		if unit.side == "red":
			red_count += 1
		else:
			gold_count += 1
	if gold_count == 0:
		game_over = true
		message = "VICTORY! The Gold Army has been defeated."
	elif red_count == 0:
		game_over = true
		message = "DEFEAT! The Red Army has fallen."

func _restart() -> void:
	selected_unit = -1
	player_turn = true
	turn_number = 1
	game_over = false
	message = "Select a RED unit, then tap an adjacent hex."
	_reset_units()
	queue_redraw()
