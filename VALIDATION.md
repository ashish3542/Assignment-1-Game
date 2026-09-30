# Validation — 2026-09-26

Environment: Windows, Godot 4.7.2 stable, Compatibility renderer. Graphics runs identified an NVIDIA GeForce RTX 4050 Laptop GPU.

## Visible fishing and delayed catch rewards — 2026-09-29

Replaced the player's instant fishing reward with casting, waiting/bite and three-second reeling phases. A shared procedural rig shows the rod, line, floating bobber, ripples and a fish traveling from the water to the character's hand. Fish enters inventory only after landing. Early input or timeout retrieves an empty line. Finn now spends the last three seconds of his fishing job landing a visible catch before carrying it to Rowan. Direct conversation hides Finn's paused rig and restores it on resuming. Fishing remains an original procedural animation, not a motion-capture asset or physical fishing simulation.

The integrated runner passed in the project and a fresh source copy. New checks verify visible cast/catch props, water placement, delayed single inventory credit, repeated input, pause, early/missed bites, save/load canceling unfinished catches, and Finn landing before delivery. Existing NPC cooking/cooperation, hunting, sleep, collision, audio and chapter checks passed too. No script errors appeared; the known environment certificate-store warning remains. The full walkthrough script now waits for the landing rather than assuming an instant reward.

Recorded the 26.42-second `Lost-Signal-Fishing-Preview.mp4` and inspected rendered cast/float, player landing and Finn landing frames. Camera and actor positions are explicitly staged; rewards and timings use real gameplay. Appended this feature review to the submission video, now approximately 8:33 and 135 MB. The preceding chapter recording predates this fishing refinement; the final segment demonstrates the revised behavior. Other earlier recordings remain historical. The source ZIP, prompt record, run instructions and submission copies were refreshed with this revision.

## Final assignment review — 2026-09-29

Reviewed the project against the student's pasted assignment and four submission fields. `ASSIGNMENT_REVIEW.md` maps each requirement to implementation and verification. The Canvas getting-started PDF could not be retrieved, and no matching download was found; additional PDF-only requirements remain unverified. Canvas uploads and instructor access have not been performed or assumed.

Fixed two final interaction/save edge cases: beginning collection or rest cancels an unfinished spear thrust, and loading a journey clears in-flight stones from the abandoned state. A moving player's thrust now faces the same direction used by the hit check. Added regression assertions for action cancellation and projectile cleanup. The entire integrated runner passed again from a fresh source directory without `.godot` or Git metadata. Corrected a stale fishing failure prompt from “pier” to “cove” and clarified launching from VS Code. These text-only changes did not require another repeated gameplay test.

The current full-chapter automated walkthrough completed successfully: 10,876 frames at 24 fps, 7:33.17. It used actual gathering, cooperative shelter construction, fire building, player fishing/cooking/eating, Maya dialogue and repair direction, Finn's module retrieval and NPC handoff, repairs and the rescue ending. No supplies or completed camp were injected into this walkthrough. New failure checks stop the recording if movement times out or required food, radio or ending milestones fail. The separate wildlife tour uses explicitly labeled staged encounter fixtures. The final attack/save edge fixes were covered by the clean-copy regressions; they do not change the chapter actions shown in the recording.

The known restricted-environment certificate warning remained; the successful test and movie logs contained no game script errors. Automated checks and recordings do not replace the student's manual playtest or certify the absence of all bugs.

Encoded the full chapter plus the 33-second wildlife tour into `Lost-Signal-Assignment-Demo.mp4`: 8:06.50, 1280×720 at 24 fps, H.264 video and stereo AAC audio, approximately 133 MB. Inspected rendered frames of gathering, the finished shelter/fire, direct dialogue and command choices, module delivery/repair and the successful ending; the wildlife frames were reviewed separately. The combined MP4 decoded fully without errors. Audio-level checks measured mean -22.4 dB and peak -1.3 dB after normalization; this confirms populated audio below clipping, not a subjective listening assessment. Submission copies of the prompt record, run guide, review, learning guide, video and source ZIP are grouped in `Assignment-Submission` alongside the repository.

## Expanded island and wildlife — 2026-09-29

Expanded the terrain and navigation north while preserving the original camp and rescue locations. Added meadow, woodland, highland ridge and marsh scenery, with matching shoreline shading and a larger map. Seven procedural species have six animals each: deer, boar, goat, rabbit, junglefowl, monitor and crocodile. Animals roam/graze, flee or defend themselves. Crafted spear thrusts apply damage at contact; thrown stones can hit animals. Downed animals supply raw meat through the existing timed collection action. The campfire and Rowan turn meat into roast, which restores food and health. Saves persist animal health, positions and harvested state.

The integrated runner passed in the development project and a fresh source copy without Git metadata, `.godot` or voice-tool dependencies. Wildlife assertions cover population/species counts, obstacle-free spawn positions, a route from camp to the northern land, crafting requirements, delayed spear impact, paused attacks, carcass yields, duplicate collection rejection, both harvested and uncollected carcasses across repeated save/load, boar defense, deer fleeing, safety during sleep, player cooking/eating, Rowan cooking raw meat and stone collision damage. Existing construction, NPC cooperation, dialogue, rest/day-night, save and chapter regressions also passed. An initial invalid animal spawn beside the marsh was fixed by searching nearby clear ground. No script errors appeared in the successful runs; the known restricted-environment certificate-store warning remains.

Recorded and encoded `Lost-Signal-Wildlife-Preview.mp4`, 33.33 seconds at 1280×720 and 24 fps, about 4.1 MB, alongside the project. Inspected rendered frames of the new terrain and seven species, plus hunting, collection and the resulting cooked-food health gain. The final recording includes a size-adjusted resting height for carcasses. It is an automated habitat tour and staged encounter; starting supplies, health and positions are fixtures, not a manual student playthrough. Existing procedural ambience/music is included; no new animal voice recordings or human listening review is claimed.

Limits: simplified models, procedural gait and local obstacle avoidance; finite wildlife with no respawn, breeding, swimming or predator food chain. Nearby AI is stepped at roughly twelve updates per second, stops beyond 95 meters and hides beyond 140 meters. Camp and active collection/sleep are protected from animal damage. The health floor remains 10. This adds a survival hunting loop, not Far Cry-scale graphics or simulation. Fish remains the food requirement for the original rescue chapter; roast is an additional survival food.

## Eight-hour sleep and day/night scenes — 2026-09-28

Added a saved absolute island clock starting at Day 1, 08:00. Ordinary play advances one island hour per ninety real seconds. Sun angle/energy, sky colors, fog, moonlight, a moon mesh, daytime ocean/birds and nighttime ocean/insects follow the clock. Sleep commits to eight island hours after the existing 3.8-second settling animation, advances them over a fourteen-second cinematic, then wakes over 3.2 seconds. The scene cuts from the sleeper to an island view and back with short fades, letterboxing, a progressing clock and start/end times. Full health no longer ends sleep early; movement/H/E can cancel only before falling asleep, and Escape pauses the scene.

Sleep grants up to 24 ground / 48 tent health, using 12 food plus ordinary hunger. Healing is limited to the portion with food above 5. The sleep timeline, start clock and remaining duration are saved along with already-applied health/food, then resumed on load. Old saves without time begin at 08:00. NPC work continues at ordinary simulation speed; this does not simulate eight hours of off-screen work or implement NPC bedtime schedules.

The integrated runner passed in the development project and in a fresh source copy without `.godot`, Git metadata or voice-generation dependencies. New checks cover 08:00→16:00, 16:00→next-day 00:00 and 22:00→next-day 06:00; gradual midpoint progression; full-health and input not ending committed sleep; paused clock/camera; saved remaining sleep and food cost; waking/control return; distinct night lighting; ordinary clock rate; legacy-save fallback; and consistent food-limited healing across one long update versus smaller updates. Existing gameplay, cooperative construction, collision, animation, dialogue, voices and save regressions also passed. Adjusted a fractional-health save assertion to use a numeric tolerance for JSON round trips. No game script errors appeared in the successful runs; the known restricted-environment certificate warning remains.

Recorded a 72.7-second automated review with audio and inspected rendered daytime, night and dawn frames: `Lost-Signal-Day-Night-Preview.mp4`, 1280×720 at 24 fps, about 13.5 MB, alongside the project. Starting clocks and full health are explicitly staged; all three sleeps use the real timed sequence. Later small refinements keep the staged-review label inside the letterbox, suppress repeated proximity greeting requests during sleep and make low-food healing independent of frame size. Those are covered by final source review/clean-copy tests. The older Comfort/Sleep runners now wait for committed sleep to finish; their old recordings remain historical. No manual student playtest or subjective audio listening review is claimed.

## Gradual sleeping and waking — 2026-09-28

Replaced rigid backward rotation around the feet with hip-centered key poses in `rest_pose.gd`: crouch, move the legs forward, sit, brace with the arms, recline and settle. Transition duration is 3.8 seconds down and 3.2 seconds up, with eased interpolation, relaxed hands and subtle chest breathing. Sole clearance constrains hip height as the legs unfold. Partial interruption reverses from the current progress, and healing counts only time after settling, including a frame that crosses the transition boundary.

The integrated gameplay runner passed with added checks for the upright seated stage, no healing before settling, continuity when interrupted, pause freezing the wake sequence, and returning control with the body back at its original offset. Existing collection, health, construction, collision, cooperation, save/load and voice regressions passed. The known restricted-environment certificate-store warning remains; no script errors occurred in these runs.

Recorded the 27.7-second `Lost-Signal-Sleep-Preview.mp4` with audio and inspected sampled frames of crouching, sitting, reclining, settled rest, sitting up and tent bedding. The recording explicitly stages starting health and a completed tent, and includes a partial interruption. It is an automated visual review, not a student playtest or human motion capture. Subsequent cleanup resets residual player head/leg offsets on returning to ordinary animation and preserves NPC head tracking; it is covered by the final integrated run. Updated the older Comfort demo's waits to accommodate the longer wake duration.

## Collection animation and health recovery — 2026-09-28

Replaced the whole-root pickup bow with a shared hip/knee crouch and arm reach. Player collection now approaches, reserves, reaches, transfers one item at 0.85 seconds, and stands by 1.65 seconds. NPCs use the same timing before carrying supplies home. Movement can cancel player collection; cancellation before contact releases the reservation and after contact retains the collected supply. NPCs stop more precisely at their final collection position. Removed the buggy model, repair/drive interactions, movement overrides, engine loop and vehicle save fields. Older save files with vehicle fields still load, ignoring those fields.

Added H to rest on a temporary leaf mat on clear ground, or to sleep on bedding inside the completed tent. Ground recovery is 0.8 health/second and tent recovery is 2 health/second, after settling down. Rest requires food above 5, stops at full health, and can be interrupted. Meals heal 15, rations heal 8; passive standing regeneration was removed. Loading retains health/food but resets temporary actions and poses.

The integrated runner passed in the development project before final refinements, then passed with the final code in a fresh source copy without `.godot`, Git metadata or voice-generation dependencies. `comfort_tests.gd` covers player/NPC contact timing, reservations, cancellation before/after contact, pause, save/load, ignored legacy vehicle fields, unfinished-tent rejection, leaf-mat creation, both recovery rates, hunger gating, health cap, waking, food healing and joint/root poses. Existing shelter, collision, dialogue, fishing, cooking, cooperation, rescue and voice checks also passed. The final autonomous shelter simulation completed in 188.7 seconds. The restricted environment printed its known certificate-store warning; the final clean-copy run had no script errors or ObjectDB shutdown warnings.

Recorded and inspected frames from a 34.2-second automated review with audio. Visual review exposed excessive clearance between the resting body and mat; lowered the pose and hid the backpack while lying down, then re-recorded and inspected the corrected ground/tent poses. `Lost-Signal-Comfort-Preview.mp4` (alongside the project, about 3.3 MB) shows the revised player/NPC collection, ground rest, ration healing and tent recovery. Low starting health and the completed tent are explicitly labeled staged fixtures. This is not a manual student playtest. The later early-wake adjustment and equipped-spear visibility are covered by source checks/clean-copy execution but are not separately demonstrated in that recording.

Limits: original procedural joint animation with a small generic held pickup prop, not motion capture or full hand inverse kinematics. Rest restores the player's health; NPC resting schedules and time-of-day skipping are not implemented. Earlier videos and validation entries below describe historical versions, including the now-removed vehicle.

## Wilderness, salvage and cooperative shelter — 2026-09-28

The starting camp is an empty beach. Tent, furniture and fire geometry stay hidden until built; their hidden footprints do not block movement. Removed the ready-made pier and ranger shelter; signal equipment appears after Maya assembles it. Added instanced inland broadleaf forest, increased palms, enlarged the flight and crashed plane by 1.65, and added the original procedural Tidebreak shipwreck with accessible landward salvage and a damaged cargo buggy. New Cloth and Rope pickups have persistent IDs and join the shared inventory.

The integrated runner passed from the development project and from a separate fresh source copy without Git metadata, `.godot`, or generation dependencies. `scripts/survival_tests.gd` checks:

- Empty-start visuals and absence of invisible tent walls; forest density and wreck presence.
- Routes from camp to every supply pickup; plane salvage hidden before impact while old ship supplies remain visible.
- The 6 wood / 2 cloth / 2 rope gate and exactly-once deduction.
- One worker making no progress; two nearby workers, or an NPC plus the assisting player, making progress; pause freezing construction.
- Partial progress and paid materials surviving save/load, completed-camp persistence, and migration of version-1 saves to an established shelter.
- Actual autonomous gathering, delivery and construction without injected supplies. The final simulation completed in 190.8 seconds and used cloth from the plane and rope from the ship.
- Completed walls and furniture, plus the existing collision, dialogue, fishing, cooking, radio handoff, rescue, command override and save regressions.

The first run exposed rejection of the new save format because a JSON numeric version needed explicit integer conversion before array membership testing. That caused cascading construction/progression failures; correcting the version check restored the checks. Visual inspection also prompted wider clearings around the larger aircraft and ship and less regular placement of loose resources.

Updated seven scene/story recordings and added twelve neural construction/material lines, giving 53 indexed clips. All cinematic dialogue still fits its playback windows. The generator used the existing local Kokoro cache with remote access disabled. The WAV manifest records each line and hash; file checks verify mono 24 kHz PCM16, durations, non-silence and non-clipped peaks.

Recorded `Lost-Signal-Survival-Preview.mp4`, a 3:32 automated in-game review, in 1280×720 at 24 fps with audio. It shows the empty beach, both wrecks, forest, actual supply trips and staged construction; no inventory was injected. Inspected sampled frames showing the larger plane, ship, rising frame and finished shelter. This is an automated demonstration, not a manual student playtest. Earlier videos document earlier layouts. The known restricted-environment certificate warning remains. Some intermediate headless runs printed shutdown reference warnings; the final verbose and clean-copy runs passed without those warnings.

Limits: one fixed shelter site, finite loose salvage and fallen wood, simplified procedural characters/props and staged building animation. No tree chopping, unrestricted building placement, explorable wreck interiors, weather simulation or human motion capture is claimed. Existing full-chapter demo scripts were adapted to wait for shelter; their extended videos were not re-recorded in this revision. Old saves intentionally retain their completed camp; begin a new story to see construction.

## Neural voice replacement — 2026-09-27

Replaced all 41 Windows desktop-speech WAVs with full-precision Kokoro neural synthesis, using five distinct stock voices. Generation ran on the local CPU; the final 41-clip batch ran with remote-model access disabled after the initial model download. Model, cast, speed, text, duration and output hashes are preserved in `audio/voices/generation.json`. The development script and dependency lockfile are in `tools/voices`; model weights and package caches are not part of the game.

All 41 assets passed format, non-silence, hash and replacement checks: mono 24 kHz PCM16, 128.83 seconds total, individual durations 1.71–7.08 seconds. RMS ranged from -24.64 to -20.00 dBFS and maximum peak was -2.00 dBFS. These are file and level checks, not a claim that human listening or emotional-performance quality has been verified.

The Godot integrated runner passed with the new files, including every cinematic clip fitting its shot, single-speaker ordering, pause/resume, direct dialogue, collisions and the existing chapter progression tests. Cinematic talking gestures now consult the active speaker so they stop when a shorter recording finishes. Generated before/after greeting previews (Maya, Finn, Rowan) are saved alongside the project for the student's listening comparison.

Recorded a 29.46-second automated in-game preview with the replacement voices and inspected a rendered direct-dialogue frame. The MP4 audio measured mean -27.0 dB and peak -7.5 dB. No script errors appeared in the recording. Moving temporary WAV checks into a separate function removed the initial test-run shutdown reference warning; the final integrated run passed without ObjectDB leak warnings. The known restricted-environment certificate-store warning remains unrelated to offline playback. Verified the developer tool's frozen dependency installation and JavaScript syntax; its optional package-manager dependency checks required network access even when packages were already cached.

## Collision and conversation polish — 2026-09-27

The integrated runner passed again from a fresh source directory without `.godot` or Git metadata. New regression scenarios in `scripts/polish_tests.gd` exercised player sprinting into a tent side with long simulation steps; walking through the entrance; stopping at the rear wall; an NPC following a complete route around the tent without entering solids; camera obstruction; and three same-frame speech requests taking ordered turns. Duplicate speech and incidental interruptions were rejected. Pausing froze the conversation. Direct dialogue cleared unrelated speech and identified the correct speaker. Subtitle timing was tested with voices disabled.

The original report of everyone talking at once had a visual synchronization cause: a single audio player already serialized clips, but bubbles and talking poses began independently when an NPC requested speech. The revised shared active-speaker state now controls the subtitle and talking animation as well as playback. This is a targeted fix; it is not evidence that every possible bug has been eliminated.

Recorded a 33.8-second staged automated polish preview with audio and inspected rendered frames. It shows the actual movement solver stopping at the tent wall, entry through the open front, serialized speech, and the closer conversation camera. The final review also corrected oversized foreground labels and added visible cloth to the blocked tent rear. No script errors appeared during the recording. The standard restricted-environment certificate warning remains.

`Lost-Signal-Polish-Preview.mp4` is alongside the project, not committed as a large Git asset. Earlier videos document earlier revisions. At this checkpoint the source still used original procedural animation and Microsoft synthetic voice clips; the neural replacement is documented above. No motion-capture pack or human actor performance is claimed.

## Revision verification — 2026-09-27

Resumed from the student's c2b8673 checkpoint. The revised integrated runner passed the previous gameplay checks plus:

- Wreckage and survivors hidden during flight; only the wreck visible after impact.
- Staggered emergency-exit appearances, four-survivor regrouping and correct playable state after skipping.
- Every cinematic caption has a WAV clip, and its playback window is long enough for that actual clip to finish.
- Independent wood gathering, radio request/delivery/repair and food collection, followed by cooking once the player builds the fire.
- An explicit Wait command remains held despite another NPC requesting help; Resume duties restores cooperation.
- Approach greeting, no continuous repeat while nearby, and greeting on re-entry after cooldown.
- Pausing freezes crew progress and resource changes.

Inspected rendered escape/regroup/close-up images and sampled frames from the new 3 minute 34 second automated revision preview. Replaced hard-edged smoke spheres with soft particle textures, cleared the escape route of scenery, adjusted Maya's camera angle and expanded the cinematic to 75.3 seconds to avoid cutting off speech. The preview shows actual automatic jobs, greetings, gathering, fire, cooking and command overrides; it is not a manual student playtest.

`Lost-Signal-Revision-Preview.mp4` is 1280×720 at 24 fps, with stereo AAC audio, about 58 MB. Audio analysis measured mean -28.2 dB and peak -5.1 dB; this confirms a populated, non-clipped recording, not subjective voice quality. Voices remain synthetic. No script errors were reported during the recording or the final integrated test run. The restricted environment still prints its certificate-store warning.

The older 2:51 walkthrough described below documents the earlier chapter and its ending; the new preview documents this revision.

Copied the final revised source and assets into a new verification directory without Git metadata or a `.godot` cache. The integrated runner passed there as well, including cinematic voice timing and independent crew behavior.

## Passed gameplay tests

The integrated `--test` runner passed resource gates/costs; player fishing timing; Finn's fishing route and handoff to Rowan; cooking/eating; Maya's request and Finn's radio-module retrieval/delivery; repairs and ending; duplicate-pickup rejection; NPC reservations/cancellation; cancellation of a carried module; buggy repair/entry/exit; save/load progress and carried-resource preservation; land/ocean boundaries; generated audio data and 18 voice clips.

## Visual checks

Inspected actual rendered screenshots. Fixed overbright lighting and poor ground detail; added procedural ground shading, broader palm fronds, revised character shapes and contrasting HUD panels.

Recorded and inspected a 2 minute 51 second automated walkthrough using Godot Movie Maker. It completed actual gathering, player fishing/cooking, dialogue, Maya/Finn handoff and repairs, buggy driving, and the rescue ending. The MP4 contains stereo audio and is about 47 MB. It was recorded before a final cosmetic change hiding overhead NPC labels behind menus.

Copied the source, scripts, shaders and audio to a fresh directory without `.godot` or Git metadata; the test runner passed there too. Following explicit audio shutdown cleanup, the final integrated test run no longer reported ObjectDB leaks.

## Limits

- Automated tests drive gameplay methods and NPC updates, not a comprehensive human keyboard/mouse playthrough.
- Audio data is present; subjective loudness and quality need player feedback.
- Other GPUs, operating systems and a standalone exported executable are not tested.
- Restricted runs printed a certificate-store warning; some headless exits reported ObjectDB shutdown warnings. Gameplay assertions passed. No game network connection is required.
- Simplified procedural models and animation; no swimming or GTA-scale world. Wildlife and spear hunting were added in the later wildlife revision; older recordings show earlier scope.
