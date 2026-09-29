# Run Lost Signal: Kestrel Island

## Requirements and setup

Tested on Windows with **Godot 4.7.2 standard edition**, using the Compatibility renderer. Download Godot from https://godotengine.org/download/windows/ and extract it. No .NET, Python, Node, OpenAI API key or internet connection during play is required. Other operating systems are untested.

1. Open https://github.com/ashish3542/Assignment-1-Game using an account allowed to access it.
2. Select **Code → Download ZIP**, then extract it (or clone with Git).
3. Keep all project folders, including scripts, shaders and audio.
4. Open Godot. Select **Import** and choose `project.godot` from this folder.
5. Open the project, wait for initial import, and press **F5**.
6. Click **Begin the story**. Start a new story to experience the empty beach and shelter-building progression; older saves retain their established shelter. The revised opening lasts about 75 seconds and shows the four survivors escaping and meeting. Enter skips it. Choose a new story to see this; loading an old save goes straight to play.

On the original development PC, double-click `PLAY.cmd` to launch the copy of Godot downloaded in Downloads. If it cannot find Godot, use the Import steps. This launcher is not a standalone exported game executable.

From **VS Code**, open this project folder, choose **Terminal → New Terminal**, and run `./PLAY.cmd` in the Windows terminal. Edit/save the GDScript files in VS Code, close the running game, and launch again to load changes. Alternatively, keep the project open in Godot and use Godot's F5. VS Code's own F5 is not configured as a Godot debugger in this project.

## Controls

| Key | Action |
| --- | --- |
| WASD / arrows | Move; cancel collection or settling before sleep |
| Mouse | Look around |
| Shift / Space | Run / jump |
| E | Talk, collect, use, fish; cancel settling before sleep |
| H | Sleep eight island hours on ground / inside the tent; cancel only before falling asleep |
| B | Help build for six seconds while near the shelter entrance; press again to continue |
| 1 | Eat fish meal, then roast, then ration (first available) |
| R | Craft hunting spear: 2 wood + 1 scrap |
| F / left mouse click | Thrust spear at an animal in front of you |
| G | Throw one stone; it can hurt wildlife and can be recovered after landing |
| Tab | Open/close journal and walkthrough |
| Esc | Pause, close dialogue, or skip intro |
| M / N | Toggle all audio / spoken dialogue |
| F6 / F9 | Save / load journey |

Mouse capture is released by Escape. Click dialogue and menu buttons with the mouse.

Tent sides and the rear, the bench, crates and workbench block movement. Enter the tent through its open front; the character moves slowly and ducks inside. Jumping inside the tent is disabled. These are simple footprint collisions, not a full climbing/physics system.

Only the current speaker gets a subtitle and talking gesture. Voices take turns with a short gap. Ordinary crew speech is heard within 22 meters; recent job messages remain in the Tab journal. Opening a direct conversation clears unrelated speech and pauses other jobs. Turning voices off with N retains timed subtitles. Pause/Journal also pauses the conversation.

The current version includes 53 Kokoro neural voice recordings, replacing the old Windows speech voices. Close an already running game and launch this updated project to hear them. No extra voice software or download is needed for playback. Earlier demo videos still contain the previous voices.

## Complete the chapter

1. **Start on an empty beach (C).** The crew begin their own tasks after a short pause. There is no ready-made tent, bench, workbench, fire ring, pier or outpost.
2. **Recover shelter supplies: 6 wood, 2 cloth and 2 rope.** Rowan gathers fallen wood at the forest edge northwest of camp. Maya recovers folded fabric beside the larger aircraft (X). Finn searches the older shipwreck (S) for rope coils. You can help by approaching loose supplies and pressing E. Inventory is shared; reserved NPC pickups cannot be taken twice.
3. **Watch them return and build together.** Once all supplies are delivered, their cost is deducted once. The frame rises, the tarp unfolds, and the finished camp gains sleeping mats, a bench and a basic workbench. At least two people must be at the shelter to advance construction. To contribute, stand near its open front and press **B**; remain nearby and press again after six seconds. Crew build without requiring your participation. Travel and gathering take several minutes.
4. **Build the campfire:** collect **3 stone** east/southeast of camp. Rowan collects the next **4 wood** after the shelter is done; you can gather it too. Press E at the camp center. The stones/logs and fire appear only after you build it.
5. **Get a meal.** Finn catches fish and carries them to Rowan, who cooks when the fire is ready. Press **1** to eat. To fish yourself, press E at the natural cove (F), wait for **BITE! PRESS E NOW**, then press E again. Cook with E at the fire. A salvaged fishing line is already available; a spear is not needed. Rations restore hunger and 8 health but do not satisfy the cooked-fish objective.
6. **Build the rescue radio.** After the shelter, Maya heads to the ridge and requests an aircraft radio module. Finn retrieves it and hands it over. Maya completes the signal equipment; no functioning station exists at the start. The dialogue button **Repair the transmitter** also requests this task directly.
7. **Send the signal at R** once shelter, fire, a cooked meal and radio are complete.

Talk with E for story and job choices. **Help gather supplies and build our shelter** is available until the shelter is complete. **Wait here** and **Follow me** pause that survivor's duties; **Resume your own duties** restores their participation. If fewer than two builders are available at the site, construction waits without losing supplies or progress.

### Restore health and rest

Press **1** to eat: a cooked fish meal gives **15 health / 45 food**, roast gives **12 health / 40 food**, or a ration gives **8 health / 25 food**. Raw meat cannot be eaten directly. Health does not regenerate merely from standing with a full food bar.

Press **H** on flat, clear ground to lie on a leaf mat, or enter the completed tent through its open front and press H to use its bedding. Keep away from water, trees, wrecks and the unfinished building site.

Sleep lasts **eight island hours**: 08:00 → 16:00, 16:00 → midnight, or 22:00 → 06:00 the next day. The character settles for 3.8 seconds, stays asleep through a **14-second scene** showing the island's changing light and clock, then gets up over 3.2 seconds. Full health does not end sleep early. H, E, movement or Space cancels only while settling; once asleep, wait for the scene. **Escape pauses** it and Resume continues at the same point.

A full sleep uses **12 food**, plus ordinary hunger during the whole sequence. It can restore up to **24 health on the ground** or **48 in the tent**, capped at 100. You need more than 5 food to begin; recovery stops if food drops to 5, but the time-passage scene still finishes. Eat first for the full benefit. NPCs keep working at their normal simulation speed during the scene; eight hours of off-screen work is not simulated.

The HUD shows day and time. During ordinary play, one island hour takes 90 real seconds (36 minutes per full day). The clock pauses in menus, dialogue and the journal, and stays fixed while settling/getting up. Sunrise, sunset, moonlight and ambience follow that same saved clock.

Collection is animated: E approaches the item, crouches and reaches before adding it to shared supplies. Movement cancels the action. Before hand contact the item stays available; after contact it remains yours even if you interrupt standing up.

### Optional salvage and exploration

The aircraft offers cloth, scrap, rations and the quest radio module. The Tidebreak shipwreck offers rope, timber, scrap and a ration; recover them from the accessible landward side. The hulls are scenery with obstacle footprints, not walk-through interiors. Extra fallen wood is scattered at the forest edge. Trees cannot be chopped down in this version.

### Northern wilderness and hunting

Head north past Signal Ridge into the Northern Meadows. The expanded land includes northern woodland, Highland Ridge to the northeast and Reed Marsh to the northwest. The map marks nearby living animals in orange. There are **42 animals, six of each species**: deer, boar, goat, rabbit, junglefowl, monitor lizard and crocodile.

1. Gather extra materials and press **R** to craft a spear (2 wood + 1 scrap). Keep supplies for shelter and fire as well.
2. Aim toward a nearby animal and press **F or left-click**. The thrust reaches about 2.9 meters in front, deals 40 damage at contact, and takes 0.75 seconds before another thrust. Large animals need several hits. **G** throws a stone for 15 damage if it hits.
3. Approach the downed animal and press **E**. The crouch-and-reach action collects its raw meat once: rabbit/junglefowl 1, goat/monitor 2, deer/boar 3, crocodile 4.
4. Return to a built fire and press **E**: one raw Meat becomes one Roast. Fish takes priority if both are available. Rowan also cooks fish or meat automatically after shelter construction, or when asked.
5. Press **1** to eat. Roast heals and feeds you, but the original rescue objective still requires eating a cooked fish.

Passive animals flee; boars, monitors and crocodiles can defend themselves when approached closely or hit. Back away to escape. Camp's 22-meter area and committed player actions such as gathering/sleeping prevent animal attacks. Health has the existing forgiving floor of 10; this is not a lethal combat system.

Animals are finite and do not respawn in a saved journey. Distant animals stop simulating beyond 95 meters and hide beyond 140 meters. They have simplified land movement and animated shapes, not realistic skeletal animation, swimming, flight, breeding or a predator food chain. The marsh pool is blocked scenery.

## Save behavior

F6 writes `kestrel_save.json` to Godot's local user-data directory. On Windows this is normally under `%APPDATA%\Godot\app_userdata\Lost Signal • Kestrel Island\`. F9 restores it. Jobs reset to camp and independent duties resume, while carried supplies are restored to shared inventory. Version-2 saves also preserve paid materials and partial shelter progress, so loading does not charge the building cost again. Version-1 saves are supported and keep a completed shelter; begin a new story to see construction. Held/follow commands and loose thrown stones are not separately saved. Saving cancels an unfinished player pickup without losing or duplicating it. Saves preserve animal health, positions and harvested status so meat cannot be collected repeatedly by reloading. Older saves without wildlife start with the new population. Saves preserve the island clock. Saving during committed sleep also preserves the remaining scene, mat/bedding and already-earned health/food changes; loading resumes from that point. Saving while only settling or getting up returns the player to their feet on load. Older saves without a clock begin at Day 1, 08:00. Old vehicle fields are ignored: the buggy has been removed. Restart/Title starts a new run without deleting an existing save.

## Troubleshooting

- **E does nothing:** move closer and read the prompt. A nearby NPC/pickup can take priority over the campfire.
- **No audio:** check M, N and Windows' output device. Subtitles remain available.
- **Shelter waiting:** check the wood/cloth/rope panel. Materials count only after delivery. Once paid, two people must work at the site; resume any held survivors or help with B.
- **NPC is traveling:** watch its status label; jobs use real routes, not instant completion.
- **NPC remains waiting:** talk and select **Resume your own duties**. An explicit Wait command is respected even if another survivor needs help.
- **No repeated greeting:** approach greetings have a 38-second individual cooldown and require you to leave beyond 6 meters before returning within about 4 meters. Crew also space out greetings to avoid talking over each other.
- **No save:** save once with F6. Saves belong to the current Windows user.
- **Old camp appears immediately:** you loaded an older save. Choose Restart / Title, then Begin the story for the empty-beach start.
- **Slow graphics:** use Compatibility rendering. Visual checks used 1280×720 on an RTX 4050 laptop GPU; this is not a minimum-hardware guarantee.
- Automated runs in the restricted assistant environment printed a system certificate-store warning. The offline gameplay tests still passed; the game has no login.

## Demonstration

Use **Lost-Signal-Assignment-Demo.mp4** in the `Assignment-Submission` folder alongside this project for the current combined demonstration: 8 minutes 7 seconds, about 133 MB. It shows the current opening, actual shelter/resource progression, dialogue, task assignment, NPC radio-module cooperation and rescue, followed by the labeled staged wildlife tour. It contains audio and is an automated walkthrough, not a recording of the student's manual playtest.

Show the opening, empty beach, plane/ship salvage, cooperative shelter construction, player movement, conversation, an assigned job, NPC-to-NPC delivery, survival interaction and ending. The survival preview covers construction; the newer Comfort preview is a staged check of collection and recovery; older videos show earlier layouts and progression. Explain a real refinement and what you learned. A supplied automated walkthrough must be identified as automated, not presented as your own manual playtest.

The Wildlife preview is a 33-second automated habitat tour plus a staged hunt, harvest, cooking and eating sequence. It supplements the chapter demonstrations; it is not a student manual playtest.
