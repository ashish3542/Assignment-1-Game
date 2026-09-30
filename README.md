# Lost Signal: Kestrel Island

A playable first chapter of a single-player 3D island survival adventure, made with **Godot 4.7.2 and GDScript**.

Flight 408 crashes on a remote island. Four survivors establish a camp, build a shelter, find food, and assemble a salvaged transmitter. Talk to Maya, Finn and Rowan; assign jobs; and watch the crew request help, carry supplies and hand items to one another.

## Play

Import `project.godot` into Godot 4.7.2 **standard edition**, then press **F5**. On the development PC, `PLAY.cmd` can launch the downloaded Godot directly. See [RUN_GAME.md](RUN_GAME.md).

## Features

- A 75-second skippable opening: flight, impact, four survivors escaping the emergency exit, regrouping and choosing duties, then walking to camp. Wreckage appears only after impact.
- An empty beach at the start: no tent, furniture, campfire, pier or ranger outpost. Dense palms and broadleaf forest cover the inland areas.
- A shared first-shelter task: 6 wood, 2 aircraft cloth and 2 shipwreck rope. Maya, Finn and Rowan recover and carry materials, then at least two people raise the frame and tarp. The player can collect supplies and press B near the entrance to help.
- A 65% larger aircraft and an older Tidebreak shipwreck, each with recoverable supplies. The ship also has salvage timber, scrap, rations.
- A saved day/night clock with changing sun, sky, fog, moonlight and day/night ambience. The sleep scene shows the hours passing across the island before returning to the player.
- Third-person movement, mouse camera, sprint and jump on an expanded freely explorable island, including northern meadows, forest, highland ridge and a reed marsh.
- Solid tent sides/rear and camp furniture; an accessible tent entrance. Player and NPC routes share obstacle rules. Movement substeps prevent running through thin obstacles; the camera retracts at camp walls.
- Original procedural terrain, wind-swayed grass, palms, instanced broadleaf canopies, shoreline foam, soft smoke, wrecks and a camp that appears as the survivors build it.
- Collect wood, stone, scrap and rations; build fire; catch, cook and eat fish. Player and Finn visibly cast a rod and line, watch a bobber, reel and land a fish before it enters supplies.
- Health and hunger with a forgiving health floor. Fish meals restore 15 health, roast restores 12, and rations restore 8. H sleeps for eight island hours on a leaf mat (up to +24 health) or inside a finished tent (up to +48 health). Sleep uses 12 food, needs some food remaining to heal, and includes a roughly 21-second settling / time-passage / waking sequence.
- Player and NPC pickups crouch at the knees, reach, collect at hand contact, then stand. Moving cancels a player pickup; reservations prevent duplicates.
- Three NPCs with approach greetings, dialogue, articulated walking/working/gesturing animations and visible tools. Their first priority is shelter: Maya recovers cloth, Finn recovers rope, and Rowan gathers wood. After construction, Maya assembles the radio, Finn retrieves parts and catches fish, and Rowan gathers firewood and cooks.
- Follow/wait commands pause that survivor's duties. **Resume your own duties** restores autonomy. Other NPCs respect held commands.
- One shared speaking turn controls voice, subtitles and talking gestures. NPC speech is local, incidental chatter is limited, and direct conversations clear unrelated chatter and use a closer camera. Subtitles also work with voices disabled.
- **Finn → Rowan:** catch, carry and deliver a fish; Rowan cooks it.
- **Maya → Finn → Maya:** request, retrieve and hand over a radio module, then assemble the transmitter.
- Forty-two animals across seven species: deer, boar, goat, rabbit, junglefowl, monitor lizard and crocodile. They graze, roam, flee or defend themselves. Hunt with a crafted spear or thrown stones, collect raw meat and cook it into roast. Rowan can cook the shared meat too. The island has no vehicle.
- Objectives, island map, journal, pause, save/load and rescue ending.
- Softer changing music that lowers during speech; ocean/birds, footsteps, interaction sounds, fire and crash audio; 53 locally generated neural voice recordings with distinct voices for Maya, Finn, Rowan, the pilot and the coast guard. Playback is offline.

## Scope

This is a prototype chapter, not a GTA-scale game. Characters and props are simplified procedural models, not photorealistic assets. Construction is a fixed shared shelter site with staged procedural animation, not unrestricted base building, tree chopping or detailed hand-to-tool simulation. Wreck supplies are recovered on foot around the hulls; there is no explorable ship interior. Wildlife uses simple procedural models and behavior, not a Far Cry-scale ecosystem. There are no human combat enemies, swimming, other passengers, multiplayer or live AI NPC calls. The seven-species population is finite, with no respawning, breeding or predator food chain. NPC dialogue and decisions work offline. The opening uses an exterior flight sequence and impact cut to black, followed by animated survivors; the crash itself is not physically simulated. Speech is still synthetic, not performed by voice actors.

Save/load preserves paid building materials, partial/completed shelter progress, chapter progress and carried/delivered supplies; active NPC tasks restart at camp. Animal health, positions and harvested carcasses persist, as do the clock and remaining committed sleep scene. Older saves without wildlife start with the full animal population. Old version-1 saves retain a completed shelter; start a new story to see the empty-island progression. Loose player-thrown stones are not separately persisted.

## Learn and submit

- [Assignment review and final handoff](ASSIGNMENT_REVIEW.md)
- [Prompt record](PROMPTS.md)
- [Run instructions and walkthrough](RUN_GAME.md)
- [Learning guide](LEARNING.md)
- [Submission checklist](SUBMISSION_CHECKLIST.md)
- [Credits](CREDITS.md)
- [Validation record](VALIDATION.md)

Repository: https://github.com/ashish3542/Assignment-1-Game

## Developer tools

Run `godot --headless --path . -- --test` (substitute your Godot executable path). Tests exercise the actual gameplay methods and NPC updates, use a separate test save, and return failure status on broken assertions. They do not replace human playtesting.

`--demo` runs an explicitly labeled automated walkthrough of actual collection, survival, dialogue, NPC cooperation and the ending. It is not active during normal play.

`--revision-demo` records the updated opening, automatic greetings and duties, player gathering/fire, autonomous food preparation and command overrides. Both demonstrations are automated, not student playtests.

`--polish-demo` stages a short review of solid tent walls, its open entrance, three simultaneous speech requests playing in order, and the direct-conversation camera. The integrated runner includes the regression scenarios in `scripts/polish_tests.gd`.

The [optional voice-generation tool](tools/voices/README.md) documents how the neural WAVs were produced. The game does not run a speech model or need Node; only developers rebuilding the audio need that tool. Voice settings and asset hashes are recorded in `audio/voices/generation.json`.

`--survival-demo` records the empty beach, larger plane, shipwreck and forest, then follows the actual autonomous resource trips and shelter construction without injecting materials. `scripts/survival_tests.gd` covers the new progression, resource costs, cooperation and saves.

`--comfort-demo` stages a short review of player/NPC collection, ground rest, food and tent recovery. Low health and a completed tent are explicitly labeled test fixtures. `scripts/comfort_tests.gd` checks contact timing, cancellation, recovery rates and saves.

Rest now uses a gradual crouch → sit → supported recline, with relaxed arms and subtle breathing. Getting up reverses these poses; canceling before the character falls asleep returns from the current position. Once asleep, all eight hours play out even at full health. `scripts/rest_pose.gd` contains the procedural poses. `--sleep-demo` records the ground/tent transitions and an interrupted lie-down with explicitly staged health and shelter.

`--day-cycle-demo` records staged morning, evening and late-night starts using real full-length sleep sequences. `scripts/day_cycle_tests.gd` checks time progression, day rollover, pause, save/resume, lighting and old-save migration.

`--wildlife-demo` records an automated northern habitat tour and a staged spear/harvest/cook/eat sequence. Starting supplies, positions and health are fixtures. `scripts/wildlife_tests.gd` checks species, safe spawns, northern navigation, attacks, pause, harvesting, saves, behavior and both cooking paths.

`--fishing-demo` records the player casting, reeling a visible fish, retrieving an empty line and Finn catching a fish before delivery. Camera and actor positions are staged; inventory and timing use the real fishing system.
