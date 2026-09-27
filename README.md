# Lost Signal: Kestrel Island

A playable first chapter of a single-player 3D island survival adventure, made with **Godot 4.7.2 and GDScript**.

Flight 408 crashes on a remote island. Four survivors establish a camp, find food, and restore an abandoned transmitter. Talk to Maya, Finn and Rowan; assign jobs; and watch the crew request help, carry supplies and hand items to one another.

## Play

Import `project.godot` into Godot 4.7.2 **standard edition**, then press **F5**. On the development PC, `PLAY.cmd` can launch the downloaded Godot directly. See [RUN_GAME.md](RUN_GAME.md).

## Features

- Skippable in-engine flight/crash opening with spoken lines and subtitles.
- Third-person movement, mouse camera, sprint and jump on a compact freely explorable island.
- Original procedural terrain, palms, camp, wreckage, pier, ranger shelter and radio tower.
- Collect wood, stone, scrap and rations; build fire; catch, cook and eat fish.
- Health and hunger with a forgiving health floor.
- Three NPCs with dialogue, follow/wait/cancel commands and task labels.
- **Finn → Rowan:** catch, carry and deliver a fish; Rowan cooks it.
- **Maya → Finn → Maya:** request, retrieve and hand over a radio module, then repair the transmitter.
- Repairable/drivable buggy, recoverable thrown stones, visible craftable spear.
- Objectives, island map, journal, pause, save/load and rescue ending.
- Synthesized music, ocean/birds, footsteps, interaction sounds, fire, engine and crash audio; 18 recorded synthetic voice clips.

## Scope

This is a prototype chapter, not a GTA-scale game. Characters and props are simplified procedural models, not photorealistic assets. No hostile enemies, spear combat, swimming, passengers, multiplayer or live AI NPC calls are implemented. The buggy uses simple camera-relative steering. NPC dialogue and decisions work offline. The opening uses an exterior flight sequence and impact cut to black, not a physically simulated crash.

Save/load preserves chapter progress and carried/delivered supplies; active NPC tasks restart at camp. Loose player-thrown stones are not separately persisted.

## Learn and submit

- [Prompt record](PROMPTS.md)
- [Run instructions and walkthrough](RUN_GAME.md)
- [Learning guide](LEARNING.md)
- [Submission checklist](SUBMISSION_CHECKLIST.md)
- [Credits](CREDITS.md)
- [Validation record](VALIDATION.md)

Repository: https://github.com/ashish3542/Assignment-1-Game

## Developer tools

Run `godot --headless --path . -- --test` (substitute your Godot executable path). Tests exercise the actual gameplay methods and NPC updates, use a separate test save, and return failure status on broken assertions. They do not replace human playtesting.

`--demo` runs an explicitly labeled automated walkthrough of actual collection, survival, dialogue, NPC cooperation, driving and the ending. It is not active during normal play.
