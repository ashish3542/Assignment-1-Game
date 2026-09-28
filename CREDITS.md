# Credits and provenance

- Concept developed from the student's prompts: plane crash, remote island, four survivors, exploration, gathering, fishing, food, NPC cooperation, transport and rescue.
- Kestrel Island, characters and dialogue were drafted during AI-assisted development. Generic survival themes and names are not claimed to be unique.
- GDScript, procedural meshes, interface and shaders were created for this project with Codex assistance.
- Music, ocean/birds and sound effects are original procedural PCM synthesis in `scripts/sound.gd`.
- Fifty-three voice clips were synthesized locally from original dialogue with [Kokoro](https://github.com/hexgrad/kokoro) using `kokoro-js` 1.2.1 and the full-precision [Kokoro-82M-v1.0 ONNX model](https://huggingface.co/onnx-community/Kokoro-82M-v1.0-ONNX). The model and Kokoro library are Apache-2.0 licensed. Stock voices: Maya = `af_bella`, Rowan = `af_heart`, Finn = `am_puck`, pilot = `am_michael`, coast guard = `bm_george`. These replace the earlier Microsoft desktop-speech recordings. No actor's voice was cloned and these are not human performances. Neither the neural model nor a speech engine is bundled with the game; playback uses offline WAV files. Generation details and hashes are in `audio/voices/generation.json`; the development-only tool is in `tools/voices`.
- Godot Engine is third-party software: https://godotengine.org/. It is not included in this source repository.
- Fonts use locally available system fonts through SystemFont; no font files are bundled.
- No external game models, textures, music tracks, GTA assets or copied game scenes are included.

The game does not call an OpenAI API at runtime. AI-assisted development and programmed NPC behavior are different things.
