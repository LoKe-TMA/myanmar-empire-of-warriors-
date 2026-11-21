extends Node2D

# Complete playable vertical-slice: kingdom defense, economy, construction,
# recruitment, upgrades, enemy waves, campaign milestone and local save.
const COLS := 15
const ROWS := 15
const HEX_W := 65.0
const HEX_H := 58.0
const BOARD_ORIGIN := Vector2(80, 260)
const HEX_RADIUS := 30.0
const BASE_CELL := Vector2i(7, 7)
const SAVE_PATH := "user://empire_of_warriors.save"

var camera_offset := Vector2(-420, 0)
var units: Array[Dictionary] = []
var buildings: Array[Dictionary] = []
var selected_unit := -1
var selected_building := -1
var campaign_chapter := 1
var iron := 60
var recruit_count := 0
var turn_number := 1
var wave_number := 1
var base_hp := 30
var base_max_hp := 30
var gold := 180
var wood := 120
var food := 100
var message := "Defend the royal base. Build defenses and recruit troops."
var game_over := false
var campaign_complete := false
var build_mode := ""
var touch_start := Vector2.ZERO
var touch_moved := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_reset_game()
	queue_redraw()

func _reset_game() -> void:
	units = [
		{"id":"red_inf_1","side":"red","kind":"INF","q":6,"r":7,"hp":5,"max_hp":5,"damage":2},
		{"id":"red_cav_1","side":"red","kind":"CAV","q":8,"r":7,"hp":4,"max_hp":4,"damage":2},
		{"id":"red_ele_1","side":"red","kind":"ELE","q":7,"r":8,"hp":8,"max_hp":8,"damage":3}
	]
	buildings = []
	selected_unit = -1
	selected_building = -1
	campaign_chapter = 1
	recruit_count = 0
	iron = 60
	turn_number = 1
	wave_number = 1
	base_hp = base_max_hp
	gold = 180
	wood = 120
	food = 100
	game_over = false
	campaign_complete = false
	build_mode = ""
	message = "Defend the royal base. Build defenses and recruit troops."
	_spawn_wave(3)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color("#18232b"))
	_draw_board()
	_draw_buildings()
	_draw_base()
	_draw_units()
	_draw_hud()
	if game_over or campaign_complete:
		draw_rect(Rect2(35, 470, 650, 290), Color(0,0,0,0.92))
		var heading := "CAMPAIGN CHAPTER CLEARED" if campaign_complete else "KINGDOM FALLEN"
		draw_string(ThemeDB.fallback_font, Vector2(70, 555), heading, HORIZONTAL_ALIGNMENT_LEFT, 590, 30, Color("#ffe0a0"))
		draw_string(ThemeDB.fallback_font, Vector2(70, 620), "Waves survived: %d" % (wave_number - 1), HORIZONTAL_ALIGNMENT_LEFT, 500, 20, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(70, 670), "Tap RESTART to play again.", HORIZONTAL_ALIGNMENT_LEFT, 500, 18, Color.WHITE)

func _draw_board() -> void:
	for r in range(ROWS):
		for q in range(COLS):
			var center := _screen_hex_center(q, r)
			if center.x < -55 or center.x > 775 or center.y < 220 or center.y > 1090:
				continue
			var fill := Color("#667d59")
			if (q * 3 + r * 5) % 7 == 0: fill = Color("#71866a")
			if (q + r) % 11 == 0: fill = Color("#77745e")
			var pts := _hex_points(center)
			draw_colored_polygon(pts, fill)
			var line := pts.duplicate()
			line.append(pts[0])
			draw_polyline(line, Color("#263b35"), 2.0, true)
			if (q * 3 + r * 5) % 7 == 0:
				draw_circle(center + Vector2(0,-8), 4, Color("#8ca57a"))

func _draw_base() -> void:
	var c := _screen_hex_center(BASE_CELL.x, BASE_CELL.y)
	draw_circle(c, 43, Color("#7d302b"))
	draw_circle(c, 34, Color("#bd9145"))
	draw_rect(Rect2(c + Vector2(-19,-23), Vector2(38,46)), Color("#e4c98b"))
	draw_rect(Rect2(c + Vector2(-7,-37), Vector2(14,19)), Color("#a33e35"))
	draw_string(ThemeDB.fallback_font, c + Vector2(-32,57), "ROYAL BASE", HORIZONTAL_ALIGNMENT_LEFT, 110, 12, Color("#ffe6b0"))

func _draw_buildings() -> void:
	for b in buildings:
		var c := _screen_hex_center(int(b.q), int(b.r))
		if c.y < 210 or c.y > 1100: continue
		match str(b.kind):
			"tower":
				draw_rect(Rect2(c + Vector2(-17,-22), Vector2(34,38)), Color("#b9a17b"))
				draw_rect(Rect2(c + Vector2(-11,-31), Vector2(22,12)), Color("#8c3a30"))
				draw_circle(c + Vector2(0,-9), 7, Color("#e9d29a"))
			"wall":
				draw_rect(Rect2(c + Vector2(-25,-12), Vector2(50,24)), Color("#9b8b75"))
				draw_rect(Rect2(c + Vector2(-22,-18), Vector2(12,8)), Color("#c9b99d"))
				draw_rect(Rect2(c + Vector2(-5,-18), Vector2(12,8)), Color("#c9b99d"))
			"barracks":
				draw_rect(Rect2(c + Vector2(-22,-19), Vector2(44,38)), Color("#8f4935"))
				draw_colored_polygon(PackedVector2Array([c+Vector2(-27,-18),c,c+Vector2(27,-18)]), Color("#d2b16d"))
		draw_string(ThemeDB.fallback_font, c + Vector2(-14,36), "LV%d" % int(b.level), HORIZONTAL_ALIGNMENT_LEFT, 40, 10, Color.WHITE)

func _draw_units() -> void:
	for i in range(units.size()):
		var u: Dictionary = units[i]
		var c := _screen_hex_center(int(u.q), int(u.r))
		if c.x < -55 or c.x > 775 or c.y < 210 or c.y > 1100: continue
		var col := Color("#a33e35") if u.side == "red" else Color("#d6ad45")
		draw_circle(c, 21, col)
		draw_arc(c, 21, 0, TAU, 28, Color("#f7e9c8"), 3)
		if i == selected_unit: draw_arc(c, 29, 0, TAU, 32, Color("#fff2a6"), 4)
		draw_string(ThemeDB.fallback_font, c + Vector2(-16,5), str(u.kind), HORIZONTAL_ALIGNMENT_LEFT, 34, 12, Color.WHITE)
		draw_string(ThemeDB.fallback_font, c + Vector2(-17,37), "%dHP" % int(u.hp), HORIZONTAL_ALIGNMENT_LEFT, 45, 10, Color.WHITE)

func _draw_hud() -> void:
	draw_rect(Rect2(14,14,692,194), Color("#202d36"))
	draw_string(ThemeDB.fallback_font, Vector2(30,48), "MYANMAR: EMPIRE OF WARRIORS", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#f1d49b"))
	draw_string(ThemeDB.fallback_font, Vector2(30,78), "KINGDOM DEFENSE  •  KONBAUNG", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c5ced5"))
	draw_string(ThemeDB.fallback_font, Vector2(30,116), "BASE %d/%d" % [base_hp,base_max_hp], HORIZONTAL_ALIGNMENT_LEFT, 150, 18, Color("#ffe0a0"))
	draw_rect(Rect2(170,100,210,15), Color("#4b555c"))
	draw_rect(Rect2(170,100,210.0*float(base_hp)/float(base_max_hp),15), Color("#a33e35"))
	draw_string(ThemeDB.fallback_font, Vector2(405,116), "CH %d  WAVE %d  TURN %d" % [campaign_chapter,wave_number,turn_number], HORIZONTAL_ALIGNMENT_LEFT, 270, 17, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(30,151), "GOLD %d   WOOD %d   IRON %d   FOOD %d" % [gold,wood,iron,food], HORIZONTAL_ALIGNMENT_LEFT, 650, 18, Color("#e8d59f"))
	draw_string(ThemeDB.fallback_font, Vector2(30,184), message, HORIZONTAL_ALIGNMENT_LEFT, 660, 13, Color("#d1dbe1"))
	_draw_button(Rect2(12,1110,132,72),"TOWER 80G",Color("#596b75"))
	_draw_button(Rect2(154,1110,132,72),"WALL / BARR.",Color("#596b75"))
	_draw_button(Rect2(296,1110,132,72),"RECRUIT",Color("#596b75"))
	_draw_button(Rect2(438,1110,132,72),"UPGRADE",Color("#596b75"))
	_draw_button(Rect2(580,1110,128,72),"END WAVE",Color("#963c32"))
	_draw_button(Rect2(12,1192,210,64),"RESTART",Color("#34434b"))
	_draw_button(Rect2(235,1192,210,64),"SAVE",Color("#34434b"))
	_draw_button(Rect2(458,1192,250,64),"LOAD",Color("#34434b"))
	if build_mode != "":
		draw_string(ThemeDB.fallback_font, Vector2(220,1085), "PLACE " + build_mode.to_upper() + " ON AN EMPTY HEX", HORIZONTAL_ALIGNMENT_CENTER, 420, 13, Color("#ffe0a0"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(240,1085), "DRAG MAP • WALL/BARR.: LEFT/RIGHT • BUILD BARRACKS TO RECRUIT", HORIZONTAL_ALIGNMENT_CENTER, 440, 12, Color("#c5ced5"))

func _draw_button(rect: Rect2, label: String, color: Color) -> void:
	draw_rect(rect, color)
	draw_rect(rect, Color("#d9c9a5"), false, 2)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(8,rect.size.y*0.62), label, HORIZONTAL_ALIGNMENT_CENTER, int(rect.size.x-16), 15, Color.WHITE)

func _screen_hex_center(q: int, r: int) -> Vector2:
	return _world_hex_center(q,r) + camera_offset

func _world_hex_center(q: int, r: int) -> Vector2:
	return BOARD_ORIGIN + Vector2(q*HEX_W + r*HEX_W*0.5, r*HEX_H)

func _hex_points(c: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(6):
		var a := deg_to_rad(60.0*i-30.0)
		pts.append(c + Vector2(cos(a),sin(a))*HEX_RADIUS)
	return pts

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_moved = false
		elif not touch_moved:
			_handle_tap(event.position)
	elif event is InputEventScreenDrag:
		if touch_start.y > 210 and touch_start.y < 1090:
			if event.position.distance_to(touch_start)>10: touch_moved=true
			if touch_moved:
				camera_offset += event.relative
				_clamp_camera()
				queue_redraw()
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			touch_start=event.position
			touch_moved=false
		elif not touch_moved:
			_handle_tap(event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if touch_start.y>210 and touch_start.y<1090:
			if event.position.distance_to(touch_start)>10: touch_moved=true
			if touch_moved:
				camera_offset += event.relative
				_clamp_camera()
				queue_redraw()

func _clamp_camera() -> void:
	camera_offset.x=clampf(camera_offset.x,-930.0,0.0)
	camera_offset.y=clampf(camera_offset.y,-200.0,120.0)

func _handle_tap(p: Vector2) -> void:
	if p.y>=1190:
		if p.x<225: _reset_game()
		elif p.x<455: _save_game()
		else: _load_game()
		queue_redraw()
		return
	if p.y>=1100:
		if p.x<148: build_mode="tower"; selected_building=-1
		elif p.x<220: build_mode="wall"; selected_building=-1
		elif p.x<290: build_mode="barracks"; selected_building=-1
		elif p.x<432: _recruit()
		elif p.x<575: _upgrade_base()
		else: _end_wave()
		queue_redraw()
		return
	if p.y<215 or p.y>1090 or game_over or campaign_complete: return
	var cell := _nearest_cell(p-camera_offset)
	if cell.is_empty(): return
	var q:=int(cell.q)
	var r:=int(cell.r)
	var ui:=_unit_at(q,r)
	var bi:=_building_at(q,r)
	if bi!=-1:
		selected_building=bi
		selected_unit=-1
		build_mode=""
		message="Selected %s. Tap UPGRADE to improve it." % str(buildings[bi].kind).to_upper()
		queue_redraw()
		return
	if ui!=-1:
		if units[ui].side=="red":
			selected_unit=ui
			selected_building=-1
			build_mode=""
			message="Selected "+str(units[ui].kind)+". Tap adjacent empty hex to move."
		elif selected_unit!=-1 and _hex_distance(units[selected_unit],units[ui])==1:
			_attack(selected_unit,ui)
		queue_redraw()
		return
	if build_mode!="":
		_place_building(q,r)
		queue_redraw()
		return
	if selected_unit!=-1 and _hex_distance(units[selected_unit],cell)==1 and Vector2i(q,r)!=BASE_CELL and _building_at(q,r)==-1:
		units[selected_unit].q=q
		units[selected_unit].r=r
		message="Unit repositioned."
		selected_unit=-1
	queue_redraw()

func _nearest_cell(p: Vector2) -> Dictionary:
	var best:=999999.0
	var found:={}
	for r in range(ROWS):
		for q in range(COLS):
			var d:=p.distance_to(_world_hex_center(q,r))
			if d<best:
				best=d
				found={"q":q,"r":r}
	return found if best<=HEX_RADIUS+12 else {}

func _hex_distance(a: Dictionary,b: Dictionary)->int:
	var aq:=int(a.q); var ar:=int(a.r); var bq:=int(b.q); var br:=int(b.r)
	return int((abs(aq-bq)+abs(aq+ar-bq-br)+abs(ar-br))/2)

func _unit_at(q:int,r:int)->int:
	for i in range(units.size()):
		if int(units[i].q)==q and int(units[i].r)==r: return i
	return -1

func _building_at(q:int,r:int)->int:
	for i in range(buildings.size()):
		if int(buildings[i].q)==q and int(buildings[i].r)==r: return i
	return -1

func _place_building(q:int,r:int)->void:
	if Vector2i(q,r)==BASE_CELL or _unit_at(q,r)!=-1 or _building_at(q,r)!=-1:
		message="That hex is occupied."
		return
	if _hex_distance({"q":q,"r":r},{"q":BASE_CELL.x,"r":BASE_CELL.y})>5:
		message="Build within the royal base territory."
		return
	if build_mode=="tower":
		if gold<80: message="Not enough gold for an Archer Tower."; return
		gold-=80
		buildings.append({"kind":"tower","q":q,"r":r,"level":1,"hp":5})
		message="Archer Tower built. It fires automatically each wave."
	elif build_mode=="wall":
		if wood<35: message="Not enough wood for a Wall."; return
		wood-=35
		buildings.append({"kind":"wall","q":q,"r":r,"level":1,"hp":8})
		message="Wall built. Raiders must break through it."
	elif build_mode=="barracks":
		if gold<100 or wood<60: message="Barracks needs 100 gold and 60 wood."; return
		gold-=100
		wood-=60
		buildings.append({"kind":"barracks","q":q,"r":r,"level":1,"hp":12})
		message="Barracks built. Troop recruitment is now available."
	build_mode=""

func _recruit()->void:
	if game_over or campaign_complete:return
	if gold<60 or food<25:
		message="Recruitment needs 60 gold and 25 food."
		return
	var spots=[Vector2i(6,6),Vector2i(8,6),Vector2i(6,8),Vector2i(8,8),Vector2i(7,6),Vector2i(7,9),Vector2i(5,7),Vector2i(9,7)]
	var barracks_exists:=false
	for b in buildings:
		if b.kind=="barracks": barracks_exists=true
	if not barracks_exists:
		message="Build a Barracks first to recruit troops."
		return
	var kind:="INF"
	var hp:=5
	var damage:=2
	var cost_gold:=60
	var cost_food:=25
	match recruit_count%3:
		1:
			kind="CAV"; hp=4; damage=3; cost_gold=90; cost_food=35
		2:
			kind="ELE"; hp=9; damage=4; cost_gold=140; cost_food=50
	if gold<cost_gold or food<cost_food:
		message="Not enough supplies for %s recruitment."%kind
		return
	for p in spots:
		if _unit_at(p.x,p.y)==-1 and _building_at(p.x,p.y)==-1:
			gold-=cost_gold
			food-=cost_food
			recruit_count+=1
			units.append({"id":"red_recruit_%d"%turn_number,"side":"red","kind":kind,"q":p.x,"r":p.y,"hp":hp,"max_hp":hp,"damage":damage})
			message="New %s recruited from the Barracks."%kind
			return
	message="No free recruitment space near the base."

func _upgrade_base()->void:
	if selected_building!=-1 and selected_building<buildings.size():
		var b:Dictionary=buildings[selected_building]
		if int(b.level)>=3:
			message="This building is already at maximum level."
			return
		var cost_g:=70*int(b.level)
		var cost_i:=20*int(b.level)
		if gold<cost_g or iron<cost_i:
			message="Building upgrade needs %d gold and %d iron."%[cost_g,cost_i]
			return
		gold-=cost_g; iron-=cost_i
		b.level=int(b.level)+1
		b.hp=int(b.hp)+4
		buildings[selected_building]=b
		message="%s upgraded to level %d."%[str(b.kind).to_upper(),int(b.level)]
		return
	if gold<120 or wood<80:
		message="Base upgrade needs 120 gold and 80 wood."
		return
	gold-=120
	wood-=80
	base_max_hp+=10
	base_hp=min(base_max_hp,base_hp+10)
	message="Royal Base upgraded. Maximum HP increased!"

func _attack(a:int,d:int)->void:
	var damage:=int(units[a].damage)
	units[d].hp=int(units[d].hp)-damage
	message="%s attacked for %d damage."%[units[a].kind,damage]
	if int(units[d].hp)<=0:
		units.remove_at(d)
		if d<selected_unit:selected_unit-=1
		gold+=18
		food+=5
		message+=" Raider defeated: +18 gold, +5 food."
	selected_unit=-1

func _end_wave()->void:
	if game_over or campaign_complete:return
	selected_unit=-1
	turn_number+=1
	_enemy_phase()
	if game_over:return
	_tower_phase()
	wave_number+=1
	gold+=35+wave_number*3
	wood+=18
	iron+=8
	food+=20
	if wave_number>30:
		campaign_complete=true
		message="Victory! All three campaign chapters have been secured."
	elif (wave_number-1)%10==0:
		campaign_chapter+=1
		base_hp=min(base_max_hp,base_hp+8)
		message="Chapter %d unlocked! Royal reinforcements and supplies received."%campaign_chapter
	_spawn_wave(mini(2+int(wave_number/2),7))
	else:
		message="Wave %d incoming. Supplies collected: gold, wood and food."%wave_number
	queue_redraw()

func _enemy_phase()->void:
	var i:=0
	while i<units.size():
		if units[i].side!="gold":
			i+=1
			continue
		var enemy:Dictionary=units[i]
		var target:=_nearest_red_unit(enemy)
		if target!=-1 and _hex_distance(enemy,units[target])<=1:
			units[target].hp=int(units[target].hp)-int(enemy.damage)
			message="Your %s was attacked!"%units[target].kind
			if int(units[target].hp)<=0:
				units.remove_at(target)
				if target<i:i-=1
			i+=1
			continue
		var base={"q":BASE_CELL.x,"r":BASE_CELL.y}
		if _hex_distance(enemy,base)<=1:
			var wall_idx:=_building_adjacent_to_base(enemy)
			if wall_idx!=-1 and buildings[wall_idx].kind=="wall":
				buildings[wall_idx].hp=int(buildings[wall_idx].hp)-int(enemy.damage)
				if int(buildings[wall_idx].hp)<=0:buildings.remove_at(wall_idx)
			else:
				base_hp-=int(enemy.damage)
				if base_hp<=0:
					base_hp=0
					game_over=true
					message="The royal base has fallen."
					return
			i+=1
			continue
		_move_enemy(i)
		i+=1

func _nearest_red_unit(enemy:Dictionary)->int:
	var best:=999
	var idx:=-1
	for i in range(units.size()):
		if units[i].side!="red":continue
		var d:=_hex_distance(enemy,units[i])
		if d<best:best=d;idx=i
	return idx

func _building_adjacent_to_base(enemy:Dictionary)->int:
	for i in range(buildings.size()):
		if buildings[i].kind=="wall" and _hex_distance(enemy,buildings[i])<=1:return i
	return -1

func _move_enemy(index:int)->void:
	var current:Dictionary=units[index]
	var target:=_nearest_red_unit(current)
	var goal:Dictionary={"q":BASE_CELL.x,"r":BASE_CELL.y}
	if target!=-1:goal=units[target]
	var best:=_hex_distance(current,goal)
	var chosen:=Vector2i(int(current.q),int(current.r))
	var steps=[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),Vector2i(1,-1),Vector2i(-1,1)]
	for s in steps:
		var q:=int(current.q)+s.x
		var r:=int(current.r)+s.y
		if q<0 or q>=COLS or r<0 or r>=ROWS or _unit_at(q,r)!=-1 or _building_at(q,r)!=-1:continue
		if Vector2i(q,r)==BASE_CELL:continue
		var dist:=_hex_distance({"q":q,"r":r},goal)
		if dist<best:best=dist;chosen=Vector2i(q,r)
	units[index].q=chosen.x
	units[index].r=chosen.y

func _tower_phase()->void:
	for b in buildings:
		if b.kind!="tower":continue
		var target:=-1
		var best:=4
		for i in range(units.size()):
			if units[i].side!="gold":continue
			var d:=_hex_distance(b,units[i])
			if d<=best:best=d;target=i
		if target!=-1:
			units[target].hp-=int(b.level)*2
			if int(units[target].hp)<=0:
				units.remove_at(target)
				gold+=12

func _spawn_wave(count:int)->void:
	for n in range(count):
		for attempt in range(120):
			var q:=rng.randi_range(0,COLS-1)
			var r:=rng.randi_range(0,ROWS-1)
			var cell={"q":q,"r":r}
			var base={"q":BASE_CELL.x,"r":BASE_CELL.y}
			if _hex_distance(cell,base)<5 or _unit_at(q,r)!=-1 or _building_at(q,r)!=-1:continue
			var kind:="INF"
			var hp:=3+int(wave_number/3)
			var dmg:=1+int(wave_number/5)
			if wave_number>=3 and rng.randf()<0.3:kind="CAV";hp+=1
			if wave_number>=6 and rng.randf()<0.18:kind="ELE";hp+=4;dmg+=1
			units.append({"id":"raider_%d_%d"%(wave_number,n),"side":"gold","kind":kind,"q":q,"r":r,"hp":hp,"max_hp":hp,"damage":dmg})
			break

func _enemy_count()->int:
	var n:=0
	for u in units:
		if u.side=="gold":n+=1
	return n

func _save_game()->void:
	var cfg:=ConfigFile.new()
	cfg.set_value("kingdom","units",units)
	cfg.set_value("kingdom","buildings",buildings)
	cfg.set_value("kingdom","wave",wave_number)
	cfg.set_value("kingdom","turn",turn_number)
	cfg.set_value("kingdom","base_hp",base_hp)
	cfg.set_value("kingdom","base_max_hp",base_max_hp)
	cfg.set_value("kingdom","gold",gold)
	cfg.set_value("kingdom","wood",wood)
	cfg.set_value("kingdom","food",food)
	cfg.set_value("kingdom","iron",iron)
	cfg.set_value("kingdom","chapter",campaign_chapter)
	cfg.set_value("kingdom","recruit_count",recruit_count)
	var err:=cfg.save(SAVE_PATH)
	message="Game saved on this device." if err==OK else "Save failed."
	queue_redraw()

func _load_game()->void:
	var cfg:=ConfigFile.new()
	var err:=cfg.load(SAVE_PATH)
	if err!=OK:
		message="No saved kingdom found yet."
		queue_redraw()
		return
	units=cfg.get_value("kingdom","units",units)
	buildings=cfg.get_value("kingdom","buildings",buildings)
	wave_number=int(cfg.get_value("kingdom","wave",1))
	turn_number=int(cfg.get_value("kingdom","turn",1))
	base_hp=int(cfg.get_value("kingdom","base_hp",base_max_hp))
	base_max_hp=int(cfg.get_value("kingdom","base_max_hp",30))
	gold=int(cfg.get_value("kingdom","gold",100))
	wood=int(cfg.get_value("kingdom","wood",100))
	food=int(cfg.get_value("kingdom","food",100))
	iron=int(cfg.get_value("kingdom","iron",60))
	campaign_chapter=int(cfg.get_value("kingdom","chapter",1))
	recruit_count=int(cfg.get_value("kingdom","recruit_count",0))
	game_over=false
	campaign_complete=false
	message="Saved kingdom loaded."
	queue_redraw()
