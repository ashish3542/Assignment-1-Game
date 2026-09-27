# Learn how the game works

Run a feature first, then read the small function that produced what you saw.

| File | Responsibility | Start here |
| --- | --- | --- |
| `scripts/game.gd` | Inventory, interactions, objectives, saves | `use_fire()` |
| `scripts/crew.gd` | NPC routines, greetings, commands and deliveries | `choose_routine()`, `greet()` and `command()` |
| `scripts/cinematic.gd` | Shot timing, actor movement and crash visibility | `sample()`, `CUES` and `finish()` |
| `scripts/player.gd` | Input, movement, camera | `_physics_process()` |
| `scripts/island.gd` | World and walkable routes | `walkable()` and `path_to()` |
| `scripts/interface.gd` | Menus, dialogue, map, HUD | `show_dialogue()` |
| `scripts/sound.gd` | Sounds, music, voice playback | `play()` and `speak()` |
| `scripts/models.gd` | Original procedural objects | `human()` |
| `scripts/demo.gd` | Labeled automated walkthrough | `run()` |

## Example: a state-dependent interaction

`use_fire()` checks for four wood and three stone. If missing, it explains the requirement. Otherwise it subtracts supplies, sets `fire_lit`, shows fire/light and starts audio. Later uses of the same fire cook fish. One button can have different valid actions depending on world state.

## Example: NPC teamwork

Maya enters `waiting_parts` at the transmitter. If Finn is idle and available for duties, she requests a module. He follows a route, collects it, changes to delivery, and carries a visible item. Handoff sets `module_installed`. Maya observes it, acknowledges him and repairs the transmitter. Player commands take priority; cancellation releases reservations and carried resources. A held or following NPC is unavailable for automatic requests.

## Real development problems and fixes

1. The fishing pier fell below the shoreline walkability threshold. The fishing/cooking integration test failed. Adjusting the boundary made it accessible and the test passed.
2. Canceling Finn's module delivery could leave a flag set, preventing retrieval. Cancellation now releases that state; a test covers it.
3. Saving a removed-but-undelivered resource could lose it. Save snapshots now preserve carried resources in restored shared inventory.
4. Rendered screenshots showed washed-out lighting. Lighting was reduced and procedural ground detail added.
5. Live Windows speech initialization stalled a restricted launch. The game now plays pre-generated speech clips without initializing live TTS.
6. The original opening showed the already-placed wreck behind the flying aircraft. Wreckage now belongs to one group whose visibility is controlled by the cinematic timeline, including debris and salvage pickups.
7. The first revised camera timings were shorter than several speech clips. Measuring the WAV durations exposed the problem. The `CUES` table now gives each line enough time to finish.

## Observe the revised behavior

- Begin a new story and watch the plane, emergency exit, four-person meeting and camp transition. Press Enter during a second run: the same final playable state should result.
- Stand back at camp. Watch each crew member leave for a job without pressing E. These decisions come from programmed priorities, not a live language model.
- Approach Rowan, hear a greeting, then remain nearby. It should not repeat continuously. Leave, wait for the cooldown, and return.
- Tell Finn to wait while Maya needs a module. He should stay put. Resume his duties and watch the delivery. Explain why `available()` checks both his task and whether duties are enabled.
- Compare the old and new videos. Identify one real improvement and one remaining limitation in your own words. Art and voices are still simplified/synthetic.

## Bug-fix lesson: visuals and game rules must agree

The tent used to look solid but had no obstacle footprint in the custom movement system. `island.gd` now supplies the same solid boundaries to player movement and NPC routing. Movement is checked in small steps, so a long frame cannot jump from one side of a thin wall to the other. This prototype uses footprint collision, not Godot's full CharacterBody3D physics controller.

The sound system already had one voice player, but each NPC independently started its speech bubble and mouth animation immediately. That made conversations look simultaneous and disconnected from queued voices. `sound.gd` now exposes one `active_speaker` and `active_line`; the subtitle and character animation use that same state. A small gap separates turns, incidental comments do not queue behind conversations, and stale lines expire.

Try sprinting toward the tent side, then entering through the open front. Next, speak to Maya while crew are working: her conversation should take focus, other chatter should clear, and only her mouth should animate for her response. These are observations for you to verify, not a reflection written on your behalf.

## Try these small changes

- Change walking speed from 5 to 4; predict and test the difference.
- Edit one NPC story response. Its existing speech clip does not automatically change: text and audio need to stay consistent.
- Change fire resource requirements. Find both the logic and every UI message explaining the cost.
- Ask Finn to retrieve the module, cancel, then request it again. Explain why cleanup matters.
- Save while Rowan carries wood. Load and inspect inventory for loss or duplication.

## Your reflection

Write this yourself: What did you request? What happened? What did you change after testing? Which function can you explain? What remains imperfect? Use real observations, including where AI output needed correction.
