# Validation — 2026-09-26

Environment: Windows, Godot 4.7.2 stable, Compatibility renderer. Graphics runs identified an NVIDIA GeForce RTX 4050 Laptop GPU.

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
