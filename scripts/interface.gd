extends Control
var game
var buttons: Array[Button] = []
var font = SystemFont.new()
var title_font = SystemFont.new()
var ink = Color("10272d")
var cream = Color("f1ead7")
var gold = Color("efbd71")
var muted = Color("a3bab5")

func setup(g):
	game = g
	font.font_names = PackedStringArray(["Segoe UI","Arial"])
	title_font.font_names = PackedStringArray(["Georgia","Times New Roman"])
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta): queue_redraw()

func text(at: Vector2, value: String, size: int = 18, color: Color = cream, fancy: bool = false):
	draw_string(title_font if fancy else font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func panel(rect: Rect2, alpha: float = 0.88):
	draw_style_box(style(Color(0.035,0.09,0.105,alpha)),rect)

func style(color: Color, border: bool = false) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left=8
	s.corner_radius_top_right=8
	s.corner_radius_bottom_left=8
	s.corner_radius_bottom_right=8
	if border:
		s.set_border_width_all(1)
		s.border_color=Color("657a70")
	return s

func clear_buttons():
	for b in buttons: b.queue_free()
	buttons.clear()

func button(label: String, pos: Vector2, action: Callable, width: float = 340):
	var b = Button.new()
	b.text=label
	b.position=pos
	b.size=Vector2(width,43)
	b.add_theme_font_override("font",font)
	b.add_theme_font_size_override("font_size",17)
	b.add_theme_stylebox_override("normal",style(Color("183a3e"),true))
	b.add_theme_stylebox_override("hover",style(Color("345b57"),true))
	b.add_theme_stylebox_override("pressed",style(Color("967749")))
	b.add_theme_color_override("font_color",cream)
	b.pressed.connect(func(): game.sound.play("click"); action.call())
	add_child(b)
	buttons.append(b)

func show_menu():
	clear_buttons()
	button("BEGIN THE STORY    →",Vector2(78,434),game.start_intro)
	button("CONTINUE SAVED JOURNEY",Vector2(78,486),game.load_game)
	button("HOW TO PLAY",Vector2(78,538),game.show_help)
	button("QUIT",Vector2(78,590),func(): get_tree().quit())

func show_pause():
	clear_buttons()
	button("RESUME",Vector2(470,242),game.resume_game)
	button("SAVE JOURNEY",Vector2(470,294),game.save_game)
	button("LOAD SAVED JOURNEY",Vector2(470,346),game.load_game)
	button("MUSIC ON / OFF",Vector2(470,398),game.sound.toggle_music)
	button("HOW TO PLAY",Vector2(470,450),game.show_help)
	button("RESTART / TITLE",Vector2(470,502),game.restart)

func show_dialogue(npc):
	clear_buttons()
	var options = []
	match npc.person:
		"Maya": options = [["What happened to our flight?","story"],["Repair the transmitter · ask Finn for help","repair"],["Collect wood for camp","wood"]]
		"Finn": options = [["How do we survive here?","story"],["Catch fish and deliver it to Rowan","fish"],["Bring the radio module to Maya","parts"]]
		"Rowan": options = [["How is everyone doing?","story"],["Cook fish or meat for the camp","cook"],["Collect wood for camp","wood"]]
	if not game.shelter.complete(): options[2]=["Help gather supplies and build our shelter","shelter"]
	options.append(["Follow me","follow"])
	options.append(["Wait here / cancel task","wait"])
	options.append(["Resume your own duties","routine"])
	for i in range(options.size()):
		var action: String = options[i][1]
		button(options[i][0],Vector2(728,267+i*48),func(): game.choose_dialogue(npc,action),512)
	button("BACK TO ISLAND  ·  Esc",Vector2(728,567),game.resume_game,512)

func show_end():
	clear_buttons()
	button("KEEP EXPLORING",Vector2(470,442),game.resume_game)
	button("SAVE JOURNEY",Vector2(470,494),game.save_game)
	button("START AGAIN",Vector2(470,546),game.restart)

func _draw():
	if not game: return
	if game.mode=="play" and game.actions.asleep:
		draw_sleep()
		return
	match game.mode:
		"menu": draw_title()
		"intro": draw_intro()
		"dialogue":
			draw_rect(Rect2(0,0,1280,76),Color("07171d"))
			panel(Rect2(704,90,560,545),0.94)
			text(Vector2(728,130),"SURVIVOR / "+game.active_npc.role.to_upper(),13,gold)
			text(Vector2(728,180),game.active_npc.person,38,cream,true)
			wrapped(game.dialogue_line,Vector2(728,216),63,18)
		"pause":
			draw_rect(Rect2(0,0,1280,720),Color(0.02,0.05,0.06,0.72))
			panel(Rect2(430,120,420,455),0.95)
			text(Vector2(478,183),"Take a breath.",36,cream,true)
			text(Vector2(478,214),"KESTREL ISLAND / PAUSED",13,gold)
		"help": draw_help()
		"ending":
			draw_rect(Rect2(0,0,1280,720),Color(0.02,0.07,0.08,0.73))
			text(Vector2(472,182),"CHAPTER ONE / COMPLETE",15,gold)
			text(Vector2(398,260),"You are not alone.",52,cream,true)
			text(Vector2(395,310),"Your signal has been received. Rescue is on its way.",20)
			text(Vector2(395,345),"Four survivors. One camp. A second chance.",20,muted)
			text(Vector2(475,388),"Crew handoffs witnessed: "+str(game.team_events),18,gold)
		_: draw_hud()
	if game.toast_time>0 and game.mode!="intro":
		panel(Rect2(335,627,610,60),0.94)
		wrapped(game.toast.left(130),Vector2(352,650),70,16)
	if game.demo_active and not game.demo_caption.is_empty():
		panel(Rect2(360,112,650,40),0.96)
		text(Vector2(378,139),game.demo_caption,16,gold)
	if game.mode in ["play","dialogue"] and not game.sound.active_line.is_empty():
		var origin=Vector2(24,530) if game.mode=="dialogue" else Vector2(320,468)
		panel(Rect2(origin,Vector2(640,87)),0.94)
		text(origin+Vector2(22,22),game.sound.active_speaker.to_upper(),12,gold)
		var line=game.sound.active_line
		if ": " in line: line=line.substr(line.find(": ")+2)
		wrapped(line,origin+Vector2(22,48),74,18)

func draw_title():
	draw_rect(Rect2(0,0,580,720),Color(0.025,0.08,0.10,0.82))
	text(Vector2(78,97),"AN ISLAND SURVIVAL STORY",14,gold)
	draw_line(Vector2(78,117),Vector2(158,117),gold,2)
	text(Vector2(74,211),"LOST",86,cream,true)
	text(Vector2(74,296),"SIGNAL",86,cream,true)
	text(Vector2(80,339),"K E S T R E L   I S L A N D",19,gold)
	text(Vector2(80,384),"Find your people. Build a camp.",20)
	text(Vector2(80,411),"Give the world a reason to find you.",20,muted)
	text(Vector2(78,687),"CHAPTER 01     /     FOUR SURVIVORS",12,muted)
	text(Vector2(955,681),"ORIGINAL PROCEDURAL WORLD",12,cream)

func draw_intro():
	draw_rect(Rect2(0,0,1280,86),Color("07171d"))
	draw_rect(Rect2(0,592,1280,128),Color("07171d"))
	text(Vector2(52,52),game.intro_phase,15,gold)
	text(Vector2(1060,52),"ENTER · SKIP",14,muted)
	wrapped(game.intro_caption,Vector2(130,633),90,22)
	text(Vector2(175,679),"KESTREL ISLAND  ·  SOMEWHERE IN THE SOUTH PACIFIC",12,gold)
	if game.intro_fade>0:
		draw_rect(Rect2(0,0,1280,720),Color(0.02,0.025,0.025,game.intro_fade))

func draw_hud():
	panel(Rect2(28,26,332,86),0.83)
	text(Vector2(48,52),"LOST SIGNAL",13,gold)
	text(Vector2(48,83),game.location_name(),25,cream,true)
	text(Vector2(48,104),game.day_cycle.label()+" / "+game.day_cycle.period(),12,gold)
	panel(Rect2(28,130,332,191),0.84)
	text(Vector2(48,157),"01 / SURVIVE. THEN SIGNAL.",13,gold)
	var goals = [[game.shelter.complete(),"Build shelter together"],[game.fire_lit,"Build fire · 4 wood + 3 stone"],[game.ate_meal,"Cook and eat a fish"],[game.repaired,"Assemble the ridge radio"],[game.won,"Send the rescue signal"]]
	for i in range(goals.size()):
		text(Vector2(48,186+i*27),("✓  " if goals[i][0] else "○  ")+goals[i][1],16,muted if goals[i][0] else cream)
	draw_map()
	if not game.shelter.complete():
		panel(Rect2(28,334,332,90),0.86)
		text(Vector2(48,359),"OUR FIRST ROOF",12,gold)
		if game.shelter.paid:
			text(Vector2(48,384),"Building: "+str(int(game.shelter.progress*100))+"%",17)
			text(Vector2(48,408),"Two builders needed · B to help nearby",14,muted)
		else:
			text(Vector2(48,384),"Wood %d/6   Cloth %d/2   Rope %d/2" % [mini(game.inventory.Wood,6),mini(game.inventory.Cloth,2),mini(game.inventory.Rope,2)],15)
			text(Vector2(48,408),"Forest wood · X Fabric · S Rope",14,muted)
	panel(Rect2(28,571,275,116),0.85)
	text(Vector2(48,598),"CONDITION",12,gold)
	bar(Vector2(48,614),game.health,Color("dca680"),"HEALTH")
	bar(Vector2(48,649),game.hunger,Color("b3bf7c"),"FOOD")
	panel(Rect2(968,443,284,244),0.87)
	text(Vector2(990,471),"SHARED CAMP SUPPLIES",12,gold)
	var names = ["Wood","Stone","Cloth","Rope","Scrap","Fish","Meal","Ration","Meat","Roast"]
	for i in range(names.size()):
		var x = 990+(i%2)*125
		var y = 502+(i/2)*30
		text(Vector2(x,y),names[i]+"  "+str(game.inventory[names[i]]),16)
	text(Vector2(990,650),"1 Eat   R Craft   F Hunt   G Throw",12,muted)
	text(Vector2(990,673),"Spear: "+("crafted" if game.spear else "2 wood + 1 scrap"),12,gold)
	if not game.prompt.is_empty():
		panel(Rect2(373,571,534,53),0.92)
		text(Vector2(396,603),game.prompt,18)
	panel(Rect2(360,689,578,27),0.88)
	text(Vector2(376,707),"WASD Move   Mouse Look   E Use   H Rest   Tab Journal   Esc Pause",13,cream)
	if game.fishing>0:
		panel(Rect2(415,435,450,92),0.95)
		text(Vector2(442,469),"FISHING / "+game.fishing_action.label(),20,gold)
		draw_rect(Rect2(442,490,390,8),Color("315356"))
		draw_rect(Rect2(442,490,390*minf(game.fishing/5,1),8),gold)
	# Recent crew history stays in the journal; only the current speaker is subtitled.

func bar(p: Vector2, value: float, color: Color, label: String):
	text(p,label,10,muted)
	draw_rect(Rect2(p+Vector2(66,-9),Vector2(151,7)),Color("355055"))
	draw_rect(Rect2(p+Vector2(66,-9),Vector2(151*value/100,7)),color)
	text(p+Vector2(222,0),str(int(value)),12,cream)

func draw_map():
	panel(Rect2(1036,26,216,240),0.9)
	var center = Vector2(1144,124)
	draw_circle(center,76,Color("1d494d"))
	island_outline(map_point(Vector3.ZERO),Vector2(29,26),Color("526347"))
	island_outline(map_point(Vector3(0,0,-130)),Vector2(49,44),Color("526347"))
	for entry in [[game.world.camp,"C"],[game.world.tower,"R"],[game.world.fish_spot,"F"],[game.world.salvage,"X"],[game.world.ship_spot,"S"]]:
		var pos = map_point(entry[0])
		text(pos,str(entry[1]),12,gold)
	for npc in game.npcs:
		draw_circle(map_point(npc.position),2.2,Color("b8d7b9"))
	for animal in game.wildlife.animals:
		if not animal.dead and animal.position.distance_to(game.player.position)<45: draw_circle(map_point(animal.position),2,Color("d8a364"))
	var p = map_point(game.player.position)
	draw_circle(p,4,cream)
	draw_line(p,p+Vector2(-sin(game.player.yaw),-cos(game.player.yaw))*11,cream,2)
	text(Vector2(1138,49),"N",12,gold)
	text(Vector2(1054,211),"C Camp   F Fish   R Radio",12,muted)
	text(Vector2(1054,231),"X Plane   S Shipwreck",12,muted)
	text(Vector2(1054,252),"North: wildlife / hills / marsh",11,gold)

func map_point(point: Vector3) -> Vector2:
	return Vector2(1144,129)+Vector2(point.x,point.z+70)*0.34

func island_outline(center: Vector2, radius: Vector2, color: Color):
	var points = PackedVector2Array()
	for i in range(40):
		var a=i*TAU/40
		points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
	draw_colored_polygon(points,color)

func wrapped(value: String, pos: Vector2, length: int, size: int):
	var line=""
	var y=pos.y
	for word in value.split(" "):
		if line.length()+word.length()>length:
			text(Vector2(pos.x,y),line,size)
			y+=size+6
			line=""
		line+=word+" "
	text(Vector2(pos.x,y),line,size)

func draw_help():
	draw_rect(Rect2(0,0,1280,720),Color(0.025,0.07,0.08,0.96))
	text(Vector2(88,82),"FIELD JOURNAL",14,gold)
	text(Vector2(84,137),"A second chance starts here.",42,cream,true)
	var lines = ["WASD / arrows Move   Mouse Look   Shift Run   Space Jump   E Talk / collect / use", "1 Eat   R Craft spear   F / Left-click Hunt   G Throw   F6 Save   F9 Load   M / N Audio", "First roof: 6 wood, 2 cloth from plane X, 2 rope from shipwreck S. The crew gather these.", "Two people raise the frame and tarp together. B near the entrance lets you help too.", "Then build fire: 4 wood + 3 stone. Finn catches fish, Rowan cooks, and 1 eats a meal.", "To fish yourself: E at cove F, then E when BITE appears. Cook with E at the fire.", "North: hunt wildlife, E collect meat, E cook at fire, 1 eat. Keep away from crocodiles.", "Maya and Finn assemble the ridge radio. Signal at R after shelter, fire and food.", "H: sleep eight hours on a leaf mat or in the tent. Esc pauses the time-passage scene."]
	for i in range(lines.size()): text(Vector2(88,190+i*29),lines[i],18,muted if lines[i].is_empty() else cream)
	text(Vector2(88,465),"RECENT CREW LOG / MOST RECENT FIRST",12,gold)
	for i in range(mini(6,game.events.size())):
		text(Vector2(88,500+i*27),str(game.events[game.events.size()-1-i]).left(122),15,muted)
	text(Vector2(88,687),"TAB / ESC — BACK TO ISLAND",13,gold)

func draw_sleep():
	var a=game.actions
	draw_rect(Rect2(0,0,1280,76),Color("07121e"))
	draw_rect(Rect2(0,594,1280,126),Color("07121e"))
	text(Vector2(48,46),"RESTING / EIGHT HOURS PASS",16,gold)
	text(Vector2(1100,46),"ESC / PAUSE",13,muted)
	text(Vector2(430,628),game.day_cycle.label()+" / "+game.day_cycle.period(),24,cream,true)
	text(Vector2(400,657),game.day_cycle.label(a.sleep_start)+"  →  "+game.day_cycle.label(a.sleep_start+a.SLEEP_HOURS),15,muted)
	draw_rect(Rect2(400,679,480,4),Color("304957"))
	draw_rect(Rect2(400,679,480*a.sleep_elapsed/a.SLEEP_SECONDS,4),gold)
	if game.demo_active: text(Vector2(420,46),"AUTOMATED STAGED REVIEW",13,gold)
	var fade=game.day_cycle.sleep_fade(a.sleep_elapsed)
	if fade>0: draw_rect(Rect2(0,0,1280,720),Color(0.02,0.03,0.04,fade))

