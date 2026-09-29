# Assignment review and handoff

Reviewed on 2026-09-29 against the assignment overview and Canvas submission fields pasted by the student. The linked **Assignment 1 -- Getting Started.pdf** could not be retrieved from Canvas, and no matching local download was found. Additional PDF-only requirements remain unverified; this is not a claim of full PDF compliance.

## Requirements and evidence

| Supplied requirement | Project evidence | Status |
| --- | --- | --- |
| Create a 3-D game | Godot 3D terrain, camera, characters, movement, survival and rescue chapter | Implemented; automated gameplay and rendered checks passed |
| Use a frontier model | AI-assisted development through OpenAI Codex in the student's IDE workflow; the student identified their selection as GPT 6 Astra Light in the prompt record | Development workflow recorded; exact historical model settings are not independently certified by project files |
| Player can talk to NPCs | E opens Maya/Finn/Rowan dialogue, story responses and recorded speech | Covered by tests and the current walkthrough |
| Player can direct NPCs | Gather, build, fish, cook, repair, follow, wait and resume duties | Command priority and held duties tested; walkthrough assigns Maya's repair task |
| NPCs interact with other NPCs | Cooperative shelter building; Finn delivers fish to Rowan; Maya requests a module, Finn retrieves and hands it over, Maya repairs | Actual state transitions, routes and resource transfers tested; walkthrough shows construction and radio cooperation |
| Effort, refinement and learning | Git commits, PROMPTS.md, VALIDATION.md, LEARNING.md and repeated fixes driven by student feedback | Development evidence provided; the student's personal observations must be their own |
| GitHub repository link | https://github.com/ashish3542/Assignment-1-Game | Source and documentation versioned in Git; instructor access must be checked separately |
| Prompt record in Markdown or TXT | PROMPTS.md | Provided; older grouped/backfilled entries and omitted private tokens are explicitly labeled |
| Instructions in Markdown or TXT | RUN_GAME.md | Provided; game and integrated tests checked from a fresh source copy |
| Video demonstration | Lost-Signal-Assignment-Demo.mp4 in the submission folder alongside this repository | Automated walkthrough with audio, supplemented by the current wildlife tour; explicitly labeled, not a manual student playtest |

## What to submit

1. **Repository field:** paste `https://github.com/ashish3542/Assignment-1-Game`.
2. **Prompt upload:** attach `PROMPTS.md`.
3. **Run-instructions upload:** attach `RUN_GAME.md`.
4. **Video upload:** attach `Lost-Signal-Assignment-Demo.mp4`.

The prepared `Assignment-Submission` folder alongside this repository collects these files and a source ZIP. The ZIP is an extra backup, not a replacement for the requested GitHub link. Videos are kept outside Git. Canvas uploads have not been performed.

## Checks still requiring the student

- Give the instructor access to the private repository, or choose your preferred visibility. Merely pasting a private link does not grant access.
- Supply the getting-started PDF if it contains additional rules not present in the pasted assignment.
- Play the current build yourself and review the video before submission. The automated checks do not prove there are no remaining bugs.
- Explain a real refinement in your own words. For example: observe an animal's behavior, hunt and cook food, then save/load to check resource persistence. `LEARNING.md` identifies the relevant code and experiments. No invented first-person reflection is supplied.

## Practical limits

This is a playable prototype chapter with original procedural art and animation, synthetic offline voices, fixed shelter construction, a finite wildlife population and a forgiving health floor. It is not a commercial-scale Far Cry or GTA game. Windows/Godot 4.7.2 Compatibility is the verified environment; other platforms and standalone exported executables are untested. No API key, paid model call or voice model runs during gameplay.
