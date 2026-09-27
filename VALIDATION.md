# Validation — 2026-09-26

Environment: Windows, Godot 4.7.2 stable, Compatibility renderer. Graphics runs identified an NVIDIA GeForce RTX 4050 Laptop GPU.

## Collision and conversation polish — 2026-09-27

The integrated runner passed again from a fresh source directory without `.godot` or Git metadata. New regression scenarios in `scripts/polish_tests.gd` exercised player sprinting into a tent side with long simulation steps; walking through the entrance; stopping at the rear wall; an NPC following a complete route around the tent without entering solids; camera obstruction; and three same-frame speech requests taking ordered turns. Duplicate speech and incidental interruptions were rejected. Pausing froze the conversation. Direct dialogue cleared unrelated speech and identified the correct speaker. Subtitle timing was tested with voices disabled.

The original report of everyone talking at once had a visual synchronization cause: a single audio player already serialized clips, but bubbles and talking poses began independently when an NPC requested speech. The revised shared active-speaker state now controls the subtitle and talking animation as well as playback. This is a targeted fix; it is not evidence that every possible bug has been eliminated.

Recorded a 33.8-second staged automated polish preview with audio and inspected rendered frames. It shows the actual movement solver stopping at the tent wall, entry through the open front, serialized speech, and the closer conversation camera. The final review also corrected oversized foreground labels and added visible cloth to the blocked tent rear. No script errors appeared during the recording. The standard restricted-environment certificate warning remains.

`Lost-Signal-Polish-Preview.mp4` is alongside the project, not committed as a large Git asset. Earlier videos document earlier revisions. The current source still uses original procedural animation and Microsoft synthetic voice clips; no motion-capture pack, human actor performance or new neural voice service is claimed.

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
- Simplified procedural models and basic driving; no wildlife, spear combat, swimming or GTA-scale world.
