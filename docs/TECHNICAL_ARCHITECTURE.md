# Technical Architecture — Lanka Shadowbound

## Status
Initial architecture brief. Member 1 must validate and complete decisions marked **TBD** before parallel implementation depends on them.

## Target technology
- Engine: Godot 4.x.
- Language: GDScript.
- Target: desktop playable hackathon build; confirm target OS/export template with the team.
- Rendering: 2D pixel-art.
- Backend/network: not required for the core single-player game unless explicitly approved.

Record the exact Godot minor version and use it consistently.

## Proposed scene organisation
- Bootstrap/main scene: startup and global services.
- Main menu: start, restart/continue if supported, options/exit.
- Player scene: one canonical controller and ability interface.
- Level scenes: one per story level, with environment, collision, spawn points and story/encounter triggers.
- UI scenes: reusable HUD, pause menu, dialogue and interaction presentation.
- Encounter scenes: Surasa, Simhika and Lankini.
- Ending scene/presentation: mission completion.

Record concrete scene paths after the initial Godot project is created.

## Proposed code boundaries
- `player/`: canonical player controller, movement and animation coordination.
- `combat/`: damage, attacks, health and encounter combat logic.
- `enemies/` or `encounters/`: enemy and boss state/behaviour.
- `world/`: interactables, triggers and level-specific world logic.
- `story/`: objective state, dialogue content and progression.
- `ui/`: menus and presentation components.
- `systems/`: scene transitions, checkpoints and approved global services.

Avoid global autoloads for features that can remain local. Member 1 approves autoloads/shared services.

## Shared contracts to define before parallel work
Member 1 must document:
1. Player movement/ability API and input action names.
2. How encounters request player actions and report success/failure.
3. Health/damage interface, if shared.
4. How interactables expose prompts and trigger interactions.
5. Dialogue request/close interface.
6. Objective and story-flag representation.
7. Level completion/next-scene mechanism.
8. Checkpoint/restart behaviour.
9. HUD data source and update signals.
10. Pixel resolution, viewport scaling, tile size and camera rules.

Agents must not independently invent incompatible contracts.

## Perspective and camera — TBD
Choose top-down, side-view or an intentional hybrid. If perspectives vary by level, make transitions deliberate and controls consistent. Document player dimensions, collision conventions, camera limits and movement rules before building level geometry.

## Input map — TBD
Define named actions for movement, interact, primary action/attack, ability, dodge and pause, plus any level-specific input. Avoid scattered hard-coded key checks.

## Asset/pixel pipeline
Member 3 proposes and Member 1 approves:
- logical viewport and scaling;
- tile/sprite scale;
- texture filtering and pixel snapping;
- palette and UI font;
- animation naming;
- asset directories and naming;
- source/licence tracking.

## Constraints
- Game must run without network access.
- Prefer simple, testable mechanics over complex fragile systems.
- Avoid plugins/dependencies unless approved.
- Do not commit `.godot/` cache or local editor state.
- Keep scenes/scripts cohesive and avoid circular dependencies.
- Provide a clear restart path after encounter failure.
- Test export on the intended machine.

## Validation checklist
- Project opens in agreed Godot version.
- Main scene starts.
- Player moves and collides.
- Level transition works.
- HUD receives required state.
- A test encounter starts and finishes.
- No missing resource references.
- Export target has been tested.
