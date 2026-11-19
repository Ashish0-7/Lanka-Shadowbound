# Sprite Redesign Brief — Handheld Monster-RPG Era

## Purpose

Replace the current placeholder character art with original, readable pixel-art sprites that evoke the clarity and charm of late-1990s handheld monster-RPG games. Do **not** copy Pokémon characters, sprite sheets, poses, or game assets.

## Reference image

The user supplied a Hanuman pixel-art image in the prior Codex conversation. It is a style reference only and is **not stored in this repository**. After starting a new Codex session, ask the user to attach it again before image generation.

Visible style cues from the reference:

- Strong dark outline and compact, readable silhouette.
- Warm fur tones with a light peach tail and a flaming tail tip.
- Gold crown, gold mace, and restrained gold jewellery accents.
- Blue dhoti with red cloth accent.
- Expressive heroic pose with chunky pixel clusters.

## Production direction

- Engine display: 640 x 360, top-down 2D, 16 x 16 tile baseline.
- Hanuman gameplay sprite: 24 x 32 pixels; shrunken form: 12 x 16 pixels.
- Use the Lanka 24 palette in `docs/VISUAL_IDENTITY.md`; retain clear silhouette contrast at native scale.
- Use nearest filtering, disabled mipmaps, lossless PNG import, and transparent backgrounds.
- Build original four-direction idle/walk sprites first. Add attack, shrink, hurt, and leap poses only after the base readability is approved.
- Keep every asset in `snake_case` and log its source/licence/status in `docs/ASSET_LOG.md`.

## Cast order

1. Hanuman: idle and walk-facing set; then strike, leap, shrink, and hurt.
2. Lankini: guardian boss, 48 x 48, idle/telegraph/hit/defeat.
3. Surasa: ocean trial boss, 64 x 64, open-mouth timing silhouette.
4. Simhika: shadow creature, 64 x 64, readable dark grasp silhouette.
5. Guard: 24 x 32, patrol/alert directions.
6. Sita: 24 x 32, calm/concerned interaction poses.
7. Mandodari: 32 x 24, sleeping/reveal presentation pose.

## Image-generation prompt baseline

Use case: stylized-concept

Asset type: original pixel-art game character source asset

Primary request: original heroic Hanuman-inspired vanara messenger for a top-down 2D action-adventure game

Style/medium: authentic late-1990s handheld-era pixel art, chunky clusters, limited palette, crisp one-pixel dark outline, readable silhouette

Subject: warm brown fur, gold crown and mace, blue dhoti with a small red sash, long pale tail with a small flame at the tip

Composition/framing: full body, front three-quarter heroic idle pose, centered, generous empty margins

Constraints: genuinely transparent background; original design; no text, logos, watermark, Pokémon characters, copied sprite poses, or franchise assets

## Current technical blocker

The prior coding session could not access `OPENAI_API_KEY`. After the user restarts VS Code/Codex and reattaches the reference image, verify the key without printing it, then use the approved transparent-background generation workflow. Save generated source assets under the project asset folders and keep existing assets until replacements have been reviewed.
