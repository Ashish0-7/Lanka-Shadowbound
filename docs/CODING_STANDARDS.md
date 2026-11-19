# Coding Standards — Lanka Shadowbound

## General
- Use the exact Godot 4.x version in `TECHNICAL_ARCHITECTURE.md`.
- Use GDScript unless Member 1 approves an exception.
- Follow existing patterns; consistency is more important than personal preference.
- Prefer descriptive names and small, cohesive functions.
- Avoid premature abstraction and optimisation.

## Naming
Suggested conventions (confirm against the initial project):
- Files/folders: `snake_case`.
- Variables/functions: `snake_case`.
- Classes: `PascalCase`.
- Constants: `UPPER_SNAKE_CASE`.
- Signals: descriptive event names, e.g. `health_changed`, `encounter_completed`.
- Scenes: descriptive names, e.g. `player.tscn`, `lanka_night.tscn`.

## GDScript
- Add type annotations where they improve clarity.
- Use `@export` for designer-tunable values.
- Name important timings, speeds, damage values and thresholds instead of using magic numbers.
- Separate gameplay logic from presentation where practical.
- Use named Input Map actions.
- Use signals/documented interfaces between independent scenes.
- Validate node paths and resources; handle missing references safely.
- Do not silently swallow errors.

## Scene practices
- Give each scene one clear responsibility.
- Reuse scenes for repeated objects where appropriate.
- Keep ownership of scene files clear; coordinate before simultaneous edits.
- Align collision shapes with intended gameplay silhouettes.
- Name nodes by purpose.
- Avoid unnecessary nesting.

## Comments and documentation
- Comment non-obvious rationale, not every line.
- Document public methods/signals and shared contracts.
- Update architecture/integration docs when approved shared interfaces change.
- Mark placeholders clearly and list them in development status.

## Asset standards
- Follow Member 3's approved pixel dimensions, scale, palette, filtering and naming.
- Track asset source and licence.
- Do not use ripped game assets, unlicensed music or assets with unclear redistribution rights.
- Keep placeholders clearly named and replaceable.

## Git hygiene
- Keep commits focused.
- Do not commit `.godot/`, caches, exports, local settings, secrets or credentials.
- Do not reformat unrelated files during a feature change.
- Never overwrite another contributor's work without agreement.
