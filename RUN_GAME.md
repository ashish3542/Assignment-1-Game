# Run Lost Signal: Kestrel Island

## Requirements and setup

Tested on Windows with **Godot 4.7.2 standard edition**, using the Compatibility renderer. Download Godot from https://godotengine.org/download/windows/ and extract it. No .NET, Python, Node, OpenAI API key or internet connection during play is required. Other operating systems are untested.

1. Open https://github.com/ashish3542/Assignment-1-Game using an account allowed to access it.
2. Select **Code → Download ZIP**, then extract it (or clone with Git).
3. Keep all project folders, including scripts, shaders and audio.
4. Open Godot. Select **Import** and choose `project.godot` from this folder.
5. Open the project, wait for initial import, and press **F5**.
6. Click **Begin the story**. The revised opening lasts about 75 seconds and shows the four survivors escaping and meeting. Enter skips it. Choose a new story to see this; loading an old save goes straight to play.

On the original development PC, double-click `PLAY.cmd` to launch the copy of Godot downloaded in Downloads. If it cannot find Godot, use the Import steps. This launcher is not a standalone exported game executable.

## Controls

| Key | Action |
| --- | --- |
| WASD / arrows | Move; steer buggy relative to camera |
| Mouse | Look around |
| Shift / Space | Run / jump |
| E | Talk, collect, use, fish, enter/exit buggy |
| 1 | Eat meal, or ration if no meal is available |
| R | Craft visible spear: 2 wood + 1 scrap |
| G | Throw one stone; collect it after landing |
| Tab | Open/close journal and walkthrough |
| Esc | Pause, close dialogue, or skip intro |
| M / N | Toggle all audio / spoken dialogue |
| F6 / F9 | Save / load journey |

Mouse capture is released by Escape. Click dialogue and menu buttons with the mouse.

## Complete the chapter

1. Start at camp (C on map). The three survivors begin their own duties after a short pause. Approach them for a spoken greeting; press E to talk or give directions.
2. Collect **3 stone** east/southeast of camp. Rowan gathers the **4 wood** needed for the fire automatically; you can help collect wood west of camp. Approach loose items and press E. Inventory is shared with the crew. Reserved items being collected by an NPC cannot also be picked up by the player.
3. Stand at the stone fire ring and press E to build the fire.
4. Finn retrieves the radio module when Maya needs it, then catches fish. You can also fish yourself at the pier (F): press E to cast, wait for **BITE! PRESS E NOW**, then press E. A salvaged line is already available; a spear is not needed.
5. Once there is fire and fish, Rowan cooks automatically after completing a current job. You can also use E at the fire to cook. Press **1** to eat. Rations restore hunger but do not satisfy the cooked-fish objective.
6. Maya checks the ridge transmitter automatically. You can also talk to her and select **Repair the transmitter · ask Finn for help** to give a direct instruction.
7. Watch Finn retrieve the module and hand it to Maya. She acknowledges him and repairs the transmitter. Travel takes time. **Wait here** and **Follow me** pause that survivor's duties; choose **Resume your own duties** to make them available to the crew again.
8. Go to the equipment at the tower base (R). Press E after fire, food and repairs are complete to send the rescue signal.

### Another NPC cooperation example

After building the fire, watch Finn **catch fish and deliver it to Rowan** as part of his routine, or assign that task yourself. He walks to the pier, fishes, returns and hands it over. Rowan cooks when available. Eat with 1. Status labels, overhead dialogue, crew log and inventory show the actual handoff. A survivor explicitly told to wait remains held until you resume their duties or assign a new task.

### Optional exploration

Collect 3 scrap near the aircraft (X), then press E near the yellow buggy by the ranger shelter to repair it. E again enters; E exits. Craft a visible spear with R after gathering extra supplies. There are no combat enemies. Keep three stones for the initial fire.

## Save behavior

F6 writes `kestrel_save.json` to Godot's local user-data directory. On Windows this is normally under `%APPDATA%\Godot\app_userdata\Lost Signal • Kestrel Island\`. F9 restores it. Jobs reset to camp and independent duties resume, while carried supplies are restored to shared inventory. Held/follow commands and loose thrown stones are not separately saved. Restart/Title starts a new run without deleting an existing save.

## Troubleshooting

- **E does nothing:** move closer and read the prompt. A nearby NPC/pickup can take priority over the campfire.
- **No audio:** check M, N and Windows' output device. Subtitles remain available.
- **NPC is traveling:** watch its status label; jobs use real routes, not instant completion.
- **NPC remains waiting:** talk and select **Resume your own duties**. An explicit Wait command is respected even if another survivor needs help.
- **No repeated greeting:** approach greetings have a 38-second individual cooldown and require you to leave beyond 6 meters before returning within about 4 meters. Crew also space out greetings to avoid talking over each other.
- **No save:** save once with F6. Saves belong to the current Windows user.
- **Slow graphics:** use Compatibility rendering. Visual checks used 1280×720 on an RTX 4050 laptop GPU; this is not a minimum-hardware guarantee.
- Automated runs in the restricted assistant environment printed a system certificate-store warning. The offline gameplay tests still passed; the game has no login.

## Demonstration

Show the opening, player movement, conversation, an assigned job, NPC-to-NPC delivery, survival interaction and ending. Explain a real refinement and what you learned. A supplied automated walkthrough must be identified as automated, not presented as your own manual playtest.
