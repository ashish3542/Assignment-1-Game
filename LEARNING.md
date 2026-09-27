# Learn how the game works

Run a feature first, then read the small function that produced what you saw.

| File | Responsibility | Start here |
| --- | --- | --- |
| `scripts/game.gd` | Inventory, interactions, objectives, saves | `use_fire()` |
| `scripts/survivor.gd` | NPC states, requests and deliveries | `command()` and `arrive()` |
| `scripts/player.gd` | Input, movement, camera | `_physics_process()` |
| `scripts/island.gd` | World and walkable routes | `walkable()` and `path_to()` |
| `scripts/interface.gd` | Menus, dialogue, map, HUD | `show_dialogue()` |
| `scripts/sound.gd` | Sounds, music, voice playback | `play()` and `speak()` |
| `scripts/models.gd` | Original procedural objects | `human()` |
| `scripts/demo.gd` | Labeled automated walkthrough | `run()` |

## Example: a state-dependent interaction

`use_fire()` checks for four wood and three stone. If missing, it explains the requirement. Otherwise it subtracts supplies, sets `fire_lit`, shows fire/light and starts audio. Later uses of the same fire cook fish. One button can have different valid actions depending on world state.

## Example: NPC teamwork

Maya enters `waiting_parts` at the transmitter. If Finn is idle, she requests a module. He follows a route, collects it, changes to delivery, and carries a visible item. Handoff sets `module_installed`. Maya observes it, acknowledges him and repairs the transmitter. Player commands take priority; cancellation releases reservations and carried resources.

## Real development problems and fixes

1. The fishing pier fell below the shoreline walkability threshold. The fishing/cooking integration test failed. Adjusting the boundary made it accessible and the test passed.
2. Canceling Finn's module delivery could leave a flag set, preventing retrieval. Cancellation now releases that state; a test covers it.
3. Saving a removed-but-undelivered resource could lose it. Save snapshots now preserve carried resources in restored shared inventory.
4. Rendered screenshots showed washed-out lighting. Lighting was reduced and procedural ground detail added.
5. Live Windows speech initialization stalled a restricted launch. The game now plays pre-generated speech clips without initializing live TTS.

## Try these small changes

- Change walking speed from 5 to 4; predict and test the difference.
- Edit one NPC story response. Its existing speech clip does not automatically change: text and audio need to stay consistent.
- Change fire resource requirements. Find both the logic and every UI message explaining the cost.
- Ask Finn to retrieve the module, cancel, then request it again. Explain why cleanup matters.
- Save while Rowan carries wood. Load and inspect inventory for loss or duplication.

## Your reflection

Write this yourself: What did you request? What happened? What did you change after testing? Which function can you explain? What remains imperfect? Use real observations, including where AI output needed correction.
