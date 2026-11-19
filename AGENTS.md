# AGENTS.md — Lanka Shadowbound

This is the mandatory operating contract for every AI coding agent in this repository.

## Project identity
- Project: **Lanka Shadowbound**
- Genre: 2D pixel-art action-adventure with traversal, combat, stealth, narrative exploration and platforming.
- Story: Hanuman's journey to Lanka from the Ramayana, adapted as a five-level playable mission.
- Target engine: Godot 4.x with GDScript, unless Member 1 records an approved change in `docs/TECHNICAL_ARCHITECTURE.md`.
- Hackathon constraint: 30 hours. Prioritise a complete, stable, demonstrable vertical slice over excessive scope.

## Required reading
Before coding, read:
1. `README.md`
2. `docs/GAME_DESIGN.md`
3. `docs/TEAM_RESPONSIBILITIES.md`
4. `docs/TECHNICAL_ARCHITECTURE.md`
5. `docs/INTEGRATION_CONTRACTS.md`
6. `docs/CODING_STANDARDS.md`
7. `docs/DEVELOPMENT_STATUS.md`

If a required file is missing, notify Member 1. Do not silently invent conflicting conventions.

## Four roles
- **Member 1 — Project Lead, Architecture & Integration:** final authority on scope, story adaptations, architecture, shared interfaces, merge approval, QA and release.
- **Member 2 — Player Mechanics, Combat & Encounters:** player abilities/mechanics, Surasa and Simhika encounter mechanics, Lankini boss, combat/damage, and agreed hazard mechanics.
- **Member 3 — UI, Visual Identity, Art & Audio Presentation:** menus, HUD, dialogue/interaction presentation, map-reveal presentation, visual standards, sprites/tiles/effects/audio integration.
- **Member 4 — Level Design, World Building, Narrative & Progression:** five level layouts, NPCs, patrol routes/layout, story triggers/dialogue content, clues, objectives, transitions and ending sequence.

Detailed ownership is in README and `docs/TEAM_RESPONSIBILITIES.md`.

## Mandatory task handshake
Before substantial edits, report:
- assigned member and role;
- understanding and acceptance criteria;
- files to create/edit;
- dependencies and shared interfaces;
- overlap/integration risks;
- test plan.

Wait for approval before changes to shared architecture, player/controller contracts, global state, input map, scene transitions, shared UI framework or another member's owned files.

## Repository inspection
- Inspect the current tree and relevant files before coding.
- Reuse existing scenes, scripts, assets and conventions.
- Implement only the assigned scope.
- Do not create a separate project or parallel game.
- Do not change the title, story sequence, genre, engine, controls, architecture or art direction without Member 1's approval.
- Avoid unrelated refactors and broad rewrites.

## Shared-system coordination
Shared/high-conflict areas include: canonical player controller, global state/autoloads, input map, scene transitions, interaction/dialogue interfaces, save/checkpoint data, shared UI theme and common enemy base.

Do not edit these without checking the integration contract and coordinating with Member 1 and the affected owner. Never create a second player controller, inventory, dialogue framework, health system or transition manager when one already exists.

## Ownership boundaries
- Member 2 owns mechanic/encounter logic; Member 4 owns encounter placement, level layout and story sequence.
- Member 3 owns presentation and asset integration; gameplay logic remains with its gameplay owner.
- Member 4 requests and integrates assets using Member 3's naming, scale and import conventions.
- Member 1 resolves conflicts and approves shared-contract changes.

Cross-role work requires explicit coordination; state dependencies rather than editing another role's area unilaterally.

## Git hygiene
- Work on the assigned feature branch. Never commit directly to `main` unless Member 1 explicitly instructs it.
- Do not force-push shared branches or overwrite another contributor's changes.
- Do not commit `.godot/`, editor caches, temporary exports, secrets, credentials or unrelated generated files.
- Keep commits focused and descriptive; use PRs/review for integration.

## Completion report
Every task report must include:
1. Implemented behaviour.
2. Files created/modified.
3. Dependencies/setup.
4. Tests actually performed and results.
5. Known limitations/bugs.
6. Integration notes and required action from other members.
7. Branch and commit/PR reference.

Never claim tests passed unless they were actually run. If unable to run Godot, say so and provide exact manual steps.

## Hackathon priorities
Keep a playable end-to-end path. Use replaceable placeholders only when needed. Avoid speculative systems, unnecessary online services, large late refactors and untested features. Escalate blockers early with the smallest safe alternative.
