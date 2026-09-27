# Run Lost Signal: Kestrel Island

## Requirements and setup

Tested on Windows with **Godot 4.7.2 standard edition**, using the Compatibility renderer. Download Godot from https://godotengine.org/download/windows/ and extract it. No .NET, Python, Node, OpenAI API key or internet connection during play is required. Other operating systems are untested.

1. Open https://github.com/ashish3542/Assignment-1-Game using an account allowed to access it.
2. Select **Code → Download ZIP**, then extract it (or clone with Git).
3. Keep all project folders, including scripts, shaders and audio.
4. Open Godot. Select **Import** and choose `project.godot` from this folder.
5. Open the project, wait for initial import, and press **F5**.
6. Click **Begin the story**. Enter skips the opening.

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

1. Find the camp ahead of you (C on map). Talk to the three survivors if desired.
2. Collect **4 wood** west of camp and **3 stone** east/southeast of camp. Approach loose items and press E. Inventory is shared with the crew.
3. Stand at the stone fire ring and press E to build the fire.
4. Go to the fishing pier (F). Press E to cast, wait for **BITE! PRESS E NOW**, and press E during that window. Retry if missed. A salvaged line is already available; a spear is not needed.
5. Return to the fire and press E to cook the fish. Press **1** to eat. Rations restore hunger but do not satisfy the cooked-fish objective.
6. Talk to Maya and select **Repair the transmitter · ask Finn for help**. She travels to the ridge and asks Finn for a module.
7. Watch Finn retrieve the module from the aircraft and hand it to Maya. She acknowledges him and repairs the transmitter. Travel takes time. If Finn has an ongoing command, let it finish or tell him to wait so he becomes available.
8. Go to the equipment at the tower base (R). Press E after fire, food and repairs are complete to send the rescue signal.

### Another NPC cooperation example

After building the fire, ask Finn to **catch fish and deliver it to Rowan**. He walks to the pier, fishes, returns and hands it over. If Rowan is idle, Rowan cooks it. If busy, ask Rowan to cook afterwards. Eat with 1. Status labels, overhead dialogue, crew log and inventory show the actual handoff.

### Optional exploration

Collect 3 scrap near the aircraft (X), then press E near the yellow buggy by the ranger shelter to repair it. E again enters; E exits. Craft a visible spear with R after gathering extra supplies. There are no combat enemies. Keep three stones for the initial fire.

## Save behavior

F6 writes `kestrel_save.json` to Godot's local user-data directory. On Windows this is normally under `%APPDATA%\Godot\app_userdata\Lost Signal • Kestrel Island\`. F9 restores it. Jobs reset to camp, while carried supplies are restored to shared inventory. Loose thrown stones are not separately saved. Restart/Title starts a new run without deleting an existing save.

## Troubleshooting

- **E does nothing:** move closer and read the prompt. A nearby NPC/pickup can take priority over the campfire.
- **No audio:** check M, N and Windows' output device. Subtitles remain available.
- **NPC is traveling:** watch its status label; jobs use real routes, not instant completion.
- **No save:** save once with F6. Saves belong to the current Windows user.
- **Slow graphics:** use Compatibility rendering. Visual checks used 1280×720 on an RTX 4050 laptop GPU; this is not a minimum-hardware guarantee.
- Automated runs in the restricted assistant environment printed a system certificate-store warning. The offline gameplay tests still passed; the game has no login.

## Demonstration

Show the opening, player movement, conversation, an assigned job, NPC-to-NPC delivery, survival interaction and ending. Explain a real refinement and what you learned. A supplied automated walkthrough must be identified as automated, not presented as your own manual playtest.
