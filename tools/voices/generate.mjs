// Development-only tool. The game plays the generated WAVs; it never loads this model.
import { KokoroTTS } from 'kokoro-js';
import { env } from '@huggingface/transformers';
import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';

const [projectArg, outputArg, cacheArg] = process.argv.slice(2);
if (!projectArg || !outputArg || !cacheArg) {
  throw new Error('Usage: node generate.mjs <project-folder> <staging-folder> <model-cache>');
}
const project = path.resolve(projectArg);
const output = path.resolve(outputArg);
env.cacheDir = path.resolve(cacheArg);
// First run downloads public model weights. Set KESTREL_VOICES_OFFLINE=1 to require cache.
const offline = process.env.KESTREL_VOICES_OFFLINE === '1';
env.allowLocalModels = offline;
env.localModelPath = env.cacheDir + path.sep;
env.allowRemoteModels = !offline;
const model = 'onnx-community/Kokoro-82M-v1.0-ONNX';
const cast = {
  Maya: { voice: 'af_bella', speed: 1.0 },
  Rowan: { voice: 'af_heart', speed: 0.98 },
  Finn: { voice: 'am_puck', speed: 1.02 },
  Pilot: { voice: 'am_michael', speed: 1.02 },
  'Coast guard': { voice: 'bm_george', speed: 1.0 },
};
const storySpeakers = { maya_story: 'Maya', rowan_story: 'Rowan', finn_story: 'Finn' };
const index = JSON.parse((await fs.readFile(path.join(project, 'audio/voices/index.json'), 'utf8')).replace(/^\uFEFF/, ''));
await fs.mkdir(output, { recursive: true });
const tts = await KokoroTTS.from_pretrained(model, {
  dtype: 'fp32', device: 'cpu',
  progress_callback: p => { if (p.status === 'done') console.log('Loaded', p.file); },
});

// Preserve natural pitch and pauses. Only trim very quiet outer padding, leave safety
// margins, and level the clips. PCM16 works with Godot's runtime WAV loader.
function pcmWav(samples, rate) {
  if (!samples.length || samples.some(x => !Number.isFinite(x))) throw new Error('Invalid waveform');
  let first = 0, last = samples.length - 1;
  while (first < last && Math.abs(samples[first]) < 0.0008) first++;
  while (last > first && Math.abs(samples[last]) < 0.0008) last--;
  first = Math.max(0, first - Math.round(rate * 0.08));
  last = Math.min(samples.length, last + Math.round(rate * 0.18) + 1);
  const audio = samples.slice(first, last);
  let power = 0, peak = 0;
  for (const x of audio) { power += x*x; peak = Math.max(peak, Math.abs(x)); }
  const rms = Math.sqrt(power/audio.length);
  if (rms < 0.001) throw new Error('Generated clip is effectively silent');
  const gain = Math.min(2, 0.1/rms, Math.pow(10, -2/20)/peak);
  const wav = Buffer.alloc(44 + audio.length*2);
  wav.write('RIFF', 0); wav.writeUInt32LE(wav.length-8, 4); wav.write('WAVEfmt ', 8);
  wav.writeUInt32LE(16, 16); wav.writeUInt16LE(1, 20); wav.writeUInt16LE(1, 22);
  wav.writeUInt32LE(rate, 24); wav.writeUInt32LE(rate*2, 28);
  wav.writeUInt16LE(2, 32); wav.writeUInt16LE(16, 34);
  wav.write('data', 36); wav.writeUInt32LE(audio.length*2, 40);
  const fade = Math.round(rate*0.005);
  for (let i=0; i<audio.length; i++) {
    const edge = Math.min(1, i/fade, (audio.length-1-i)/fade);
    wav.writeInt16LE(Math.round(Math.max(-1, Math.min(1, audio[i]*gain*edge))*32767), 44+i*2);
  }
  return { wav, duration: audio.length/rate, gain };
}

const clips = [];
try {
  for (const [subtitle, resource] of Object.entries(index)) {
    const file = path.basename(resource);
    const stem = path.basename(file, '.wav');
    const prefix = subtitle.split(':', 1)[0].toLowerCase();
    const speaker = storySpeakers[stem] ?? Object.keys(cast).find(x => x.toLowerCase() === prefix);
    if (!speaker) throw new Error(`Missing cast assignment: ${subtitle}`);
    const text = storySpeakers[stem] ? subtitle : subtitle.slice(subtitle.indexOf(':')+1).trim();
    const audio = await tts.generate(text, cast[speaker]);
    const { wav, duration, gain } = pcmWav(audio.audio, audio.sampling_rate);
    if (duration < 0.5 || duration > 25) throw new Error(`Unexpected duration: ${file}: ${duration}`);
    await fs.writeFile(path.join(output, file), wav);
    clips.push({ file, speaker, text, ...cast[speaker], duration, gain,
      sha256: createHash('sha256').update(wav).digest('hex') });
    console.log(`${clips.length}/${Object.keys(index).length} ${file}: ${duration.toFixed(2)}s (${speaker})`);
  }
  const modelFile = path.join(env.cacheDir, model, 'onnx/model.onnx');
  const modelSha256 = createHash('sha256').update(await fs.readFile(modelFile)).digest('hex');
  await fs.writeFile(path.join(output, 'generation.json'), JSON.stringify({
    model, modelSha256, dtype: 'fp32', generator: 'kokoro-js@1.2.1',
    transformers: '3.8.1', format: 'mono 24000 Hz PCM16 WAV', cast, clips,
  }, null, 2)+'\n');
} finally {
  await tts.model.dispose();
}
