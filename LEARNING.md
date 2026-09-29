# Learn how the game works

Run a feature first, then read the small function that produced what you saw.

| File | Responsibility | Start here |
| --- | --- | --- |
| `scripts/game.gd` | Inventory, interactions, objectives, saves | `use_fire()` |
| `scripts/crew.gd` | NPC routines, greetings, commands and deliveries | `choose_routine()`, `greet()` and `command()` |
| `scripts/cinematic.gd` | Shot timing, actor movement and crash visibility | `sample()`, `CUES` and `finish()` |
| `scripts/player_actions.gd` | Collection, cancellation and health recovery | `start_pickup()`, `toggle_rest()`, `update()` |
| `scripts/player.gd` | Input, movement, camera | `_physics_process()` |
| `scripts/island.gd` | World and walkable routes | `walkable()` and `path_to()` |
| `scripts/interface.gd` | Menus, dialogue, map, HUD | `show_dialogue()` |
| `scripts/sound.gd` | Sounds, music, voice playback | `play()` and `speak()` |
| `scripts/models.gd` | Original procedural objects | `human()` |
| `scripts/demo.gd` | Labeled automated walkthrough | `run()` |
| `scripts/animal.gd` | Animal behavior, health and carcasses | `update()`, `damage()` |
| `scripts/wildlife.gd` | Hunting timing and animal saves | `attack()`, `restore()` |
| `scripts/day_cycle.gd` | Island clock, light and sleep scene | `update()` |

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
8. An animal spawn overlapped the new marsh obstacle. The wildlife check found it; spawning now searches for nearby clear ground.
9. An already-thrown stone could continue moving after loading another journey. Loading now clears projectiles from the abandoned state. An unfinished spear thrust also cancels when collection or rest starts, keeping damage aligned with the visible action.

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

## Voice-quality lesson: the recording and the game are separate

The earlier voices came from Windows desktop speech. Adjusting pauses and speed did
not satisfy the requested naturalness. We replaced their source with Kokoro neural
speech, generated once on this computer and saved as ordinary WAVs. The game still
uses the same audio player and dialogue queue in `scripts/sound.gd`; it does not
need to run a neural model while you play. `tools/voices/generate.mjs` is the separate
development tool, and `audio/voices/generation.json` records each voice and line.

Listen to the previous/new greeting previews in order: Maya, Finn, Rowan. Describe
which sounds more conversational and whether any pronunciation or emotion still
needs work. Then talk to Maya in the game and press N: the subtitle should retain
its timing even with speech disabled. This tests the distinction between an audio
asset's quality and the game's timing/interaction logic. These are prompts for your
own observations, not a claim that synthetic speech matches a human actor.

## Survival construction: appearances must come from game state

The old camp was drawn immediately when the scene loaded. The new `shelter.gd`
keeps separate states for unpaid materials, paid construction and completion.
The shared cost (6 wood, 2 cloth, 2 rope) is deducted once. Progress advances only
when at least two workers are physically at their build positions; the player can
count as a worker by helping nearby. `island.gd` draws the frame, tarp and finished
camp from that progress, enabling walls and updating navigation when needed.

The crew's `choose_routine()` now prioritizes shelter over radio and food. The same
pickup reservations prevent two people from collecting one item. The expanded
aircraft supplies fabric; `wilderness.gd` creates the old shipwreck and uses shared
mesh instances for many inland trees. Instancing reduces the number of separate
drawing operations required for the forest.

A real integration failure occurred when the new save version was checked with
array membership: JSON returned a numeric value that needed explicit conversion
to an integer. The save was rejected, which caused several later progression and
collision tests to fail. Fixing the version check restored loading and those tests.

Try a new story. Tell two crew members to wait once building starts: the remaining
builder should stop making progress. Stand near the open front and press B to be
the second worker, or resume another survivor's duties. Save halfway through and
load: the frame and progress should return without charging the materials again.
Record what you actually observe in your own words.

## Try these small changes

- Change walking speed from 5 to 4; predict and test the difference.
- Edit one NPC story response. Its existing speech clip does not automatically change: text and audio need to stay consistent.
- Change fire resource requirements. Find both the logic and every UI message explaining the cost.
- Ask Finn to retrieve the module, cancel, then request it again. Explain why cleanup matters.
- Save while Rowan carries wood. Load and inspect inventory for loss or duplication.

## Your reflection

Write this yourself: What did you request? What happened? What did you change after testing? Which function can you explain? What remains imperfect? Use real observations, including where AI output needed correction.

## Pickup and rest: time is part of a game rule

The earlier pickup pose rotated the entire model around its feet. The revised
`models.gd` bends the hip and knee joints and lowers the hips while keeping the
torso upright. `player_actions.gd` reserves an item first, then transfers it at
0.85 seconds into the reach, and ends the action at 1.65 seconds. The NPC routine
uses the same contact and stand-up timing. Animation and inventory must agree:
canceling before contact releases the item; canceling afterward must not duplicate it.

Rest is a separate state, not a menu that instantly refills health. On clear ground
it creates a temporary leaf mat. A finished tent permits faster recovery. Both
need food to heal and freeze while paused. Sleep now finishes all eight island
hours even at full health. Save/load restores the clock and remaining committed
sleep scene; unfinished collection or settling is cleared.

Try interrupting a pickup before and after the hand reaches it, then inspect the
shared count. After hunger has lowered health, compare one eight-hour sleep on the ground
with one inside the tent. Explain why different recovery rates make
building shelter useful. Record your own results; these are experiments to try.

The next sleep refinement moves the body's pivot from the feet to the hips while
posing the legs and arms separately. `scripts/rest_pose.gd` describes crouching,
sitting, supporting the torso and settling; `player_actions.gd` runs that timeline
forward or backward. Try H, wait until seated, then press H again. The character
should return from that position, not jump to the fully lying pose first. Watch
the health bar: recovery starts only after settling. These observations connect
animation timing, interruption handling and the actual health rule.

## One clock drives both the scene and the game

`day_cycle.gd` stores total island hours, including the day count. Ordinary play
adds a little time each frame. Committed sleep smoothly advances that same value
by eight hours over fourteen real seconds. Sun angle, sky, fog, moonlight, ambience
and the HUD all read that value. The scene never changes only the clock label while
leaving the island at noon.

`player_actions.gd` separates settling, committed sleep and getting up. Reaching
100 health no longer cancels the middle phase. Saving records elapsed sleep and
its starting clock, so loading continues the remainder without applying the same
healing or food cost again. Try pausing halfway through, then saving/loading there:
the scene and displayed time should resume from that point. Describe what you see
in your own words; the supplied recording is an automated test, not your playtest.

## Wildlife: behavior, resources and a larger world

`animal.gd` gives each animal a small state machine: graze, roam, flee, defend,
then become a collectible carcass if its health reaches zero. Species change
health, speed, meat yield and whether they defend themselves. These decisions
are programmed rules, not an AI model answering live during play.

`wildlife.gd` separates pressing attack from the moment the spear makes contact.
That keeps damage aligned with the animation. The existing collection action
transfers meat only when the hand reaches the carcass. Saves preserve both the
animal's death and whether that meat was already taken, preventing duplicate loot.
`crew.gd` lets Rowan use the same shared food supply.

`northern_wilderness.gd` builds the added terrain's scenery and navigation grid.
It marks small areas around obstacles instead of checking every tree against
every grid cell. Nearby animals update about twelve times per second; distant
animals stop moving. These choices reduce work as the island grows.

Try approaching a deer, then a boar. Describe how their decisions differ. Hunt
one animal, save before collecting it, collect its meat, save again and reload.
Check that each save restores the correct state and cannot duplicate meat.
Finally, bring raw meat home and ask Rowan to cook it. Record your actual results
and any rough animation or movement you find; this is an experiment, not a supplied reflection.
