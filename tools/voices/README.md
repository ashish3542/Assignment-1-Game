# Rebuild the voice recordings (optional developer tool)

Normal play requires only Godot and the committed WAV files. Do not install these
tools just to run the game.

The clips use original game dialogue and stock Kokoro voices, not cloned actors.
Maya uses Bella, Rowan Heart, Finn Puck, the pilot Michael, and the coast guard George.
Speech generation runs on the development computer's CPU. The full-precision model
download is approximately 326 MB; allow additional space for development packages.

Tested generation environment: Windows, Node 24.19.0, pnpm 11.19.0. From this folder:

```powershell
pnpm install --frozen-lockfile --ignore-scripts
node generate.mjs ../.. ../../../../work/voice-staging ../../../../work/neural-voices/model-cache
```

Paths are explicit: game project, output staging directory, then model cache.
The initial generation needs internet to download public model files; there is no
API subscription. On Windows the dependency packages include CPU runtime binaries.
Other operating systems may require additional package setup and are untested.

Review staged recordings before copying them into `audio/voices`. Preserve
`index.json`, which maps exact dialogue strings to filenames. `generation.json`
records the cast, spoken text, speeds, durations, WAV hashes and model hash.
The generator leaves word/sentence pauses intact and writes lightly leveled PCM16
audio with short edge fades. It does not add a robotic pitch effect or vocoder.

After replacement, run the game's `--test` checks. They verify actual cinematic
clip lengths against shot windows and check conversation turn-taking. If a clip
is longer than its shot, extend the corresponding `CUES` time in
`scripts/cinematic.gd`; don't speed up speech just to force it into a short shot.

Set `KESTREL_VOICES_OFFLINE=1` to rebuild using an existing model cache only.
The model's upstream `main` revision may change; compare the model hash with the
committed manifest when trying to reproduce this exact asset set. The model and
dependency caches are development files and must not be committed.

Sources: [Kokoro](https://github.com/hexgrad/kokoro),
[Kokoro JS](https://github.com/hexgrad/kokoro/tree/main/kokoro.js),
[ONNX model](https://huggingface.co/onnx-community/Kokoro-82M-v1.0-ONNX).
The model and Kokoro library are Apache-2.0 licensed. These recordings remain
synthetic speech; convincing emotional acting is still a separate quality goal.
