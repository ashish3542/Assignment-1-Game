extends RefCounted
func run(g, failures: Array):
	var a=g.actions
	var c=g.day_cycle
	for start in [8.0,16.0,22.0]:
		a.reset()
		g.mode="play"
		g.health=100; g.hunger=80
		g.player.position=g.world.ground(g.world.camp+Vector3(0,0,7))
		g.player.yaw=0
		c.set_hours(start)
		a.toggle_rest()
		a.update(a.REST_DURATION)
		if not a.asleep or not g.cine_camera.current: failures.append("Sleep scene failed to start")
		a.update(a.SLEEP_SECONDS/2)
		if absf(c.hours-start-4)>0.001 or not a.resting: failures.append("Sleep clock jumped instead of progressing")
		a.wake()
		if not a.asleep: failures.append("Committed sleep interrupted")
		g.pause_game()
		var paused_time=c.hours
		c.update(40); a.update(40)
		if c.hours!=paused_time: failures.append("Paused sleep changed island time")
		g.resume_game()
		if not g.cine_camera.current: failures.append("Paused sleep resumed with wrong camera")
		g.save_game()
		c.set_hours(0)
		g.load_game()
		if absf(c.hours-paused_time)>0.001 or not a.asleep: failures.append("Sleep clock / scene save not restored")
		a.update(a.SLEEP_SECONDS/2)
		if absf(c.hours-start-8)>0.001 or a.resting or a.waking<=0: failures.append("Eight-hour wake target / rollover")
		if absf(g.hunger-68)>0.001: failures.append("Sleep food cost duplicated or lost during save/load")
		a.update(a.WAKE_DURATION+0.1)
		if a.busy() or not g.player.camera.current: failures.append("Sleep did not return player control")
	c.set_hours(12)
	# Food-limited recovery must agree for long frames and smaller frame steps.
	for step in [14.0,1.0]:
		a.reset(); g.health=40; g.hunger=6
		g.player.position=g.world.ground(g.world.camp+Vector3(0,0,7))
		a.toggle_rest(); a.update(a.REST_DURATION)
		for frame in range(int(14/step)): a.update(step)
		if absf(g.health-42)>0.001 or g.hunger!=0 or a.resting: failures.append("Low-food sleep depends on frame size / fails to finish")
		a.reset()
	c.set_hours(12)
	var noon=g.world.sun.light_energy
	c.set_hours(0)
	if g.world.sun.light_energy>=noon or g.world.moon.light_energy<=0 or not g.world.moon_mesh.visible: failures.append("Night lighting not distinct from noon")
	c.set_hours(30)
	if c.label()!="Day 2 / 06:00": failures.append("Day / morning clock label")
	g.mode="pause"; c.update(90)
	if c.hours!=30: failures.append("Normal clock changed while paused")
	g.mode="play"; c.update(90)
	if absf(c.hours-31)>0.001: failures.append("Normal play clock rate")
	# Saves before this feature have no time or sleep fields and start in the morning.
	g.save_game()
	var old=JSON.parse_string(FileAccess.get_file_as_string(g.save_path))
	old.erase("time_hours"); old.erase("sleep")
	var file=FileAccess.open(g.save_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(old)); file.close()
	g.load_game()
	if c.hours!=8 or a.busy(): failures.append("Legacy save clock fallback")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(g.save_path))
	print("DAY CYCLE: morning/afternoon/night sleep, eight-hour duration, pause, saved remaining sleep, food cost, lighting and legacy clock checked")
