# Validation — 2026-09-26

Environment: Windows, Godot 4.7.2 stable, Compatibility renderer. Graphics runs identified an NVIDIA GeForce RTX 4050 Laptop GPU.

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
- Simplified procedural models and animation; no wildlife, spear combat, swimming or GTA-scale world.
