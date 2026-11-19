# Technical Architecture — Lanka Shadowbound

## Status
Foundation established on `feature/project-foundation`. The settings below are the initial project baseline and remain reviewable by Member 1.

## Target technology
- Engine: Godot 4.7.2 stable (official build `ed1daf0bf`).
- Language: GDScript.
- Target: desktop playable hackathon build; confirm target OS/export template with the team.
- Rendering: 2D pixel-art.
- Renderer: Compatibility (`gl_compatibility`).
- Perspective: top-down 2D for the initial foundation.
- Logical viewport: 640 × 360; window override: 1280 × 720; viewport stretch mode.
- Tile size baseline: 16 × 16 pixels.
- Texture filtering: nearest/no smoothing for pixel-art textures.
- Backend/network: not required for the core single-player game unless explicitly approved.

Record the exact Godot minor version and use it consistently.

## Scene organisation
- Bootstrap/main scene: startup and global services.
- Main menu: start, restart/continue if supported, options/exit.
- Player scene: one canonical controller and ability interface.
- Level scenes: one per story level, with environment, collision, spawn points and story/encounter triggers.
- UI scenes: reusable HUD, pause menu, dialogue and interaction presentation.
- Encounter scenes: Surasa, Simhika and Lankini.
- Ending scene/presentation: mission completion.

Initial concrete paths:
- Project configuration: `project.godot`.
- Main scene: `scenes/main.tscn`.
- Placeholder Hanuman/canonical prototype player: `scenes/player/hanuman.tscn`.
- Player controller: `scripts/player/player_controller.gd`.
- Initial bounded movement test area: `scenes/levels/test_environment.tscn`.

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

Initial repository folders:
- `scenes/`: `encounters/`, `levels/`, `player/`, and `ui/`.
- `scripts/`: `combat/`, `enemies/`, `player/`, `story/`, `systems/`, `ui/`, and `world/`.
- `assets/`: `animations/`, `audio/`, `characters/`, `environments/`, and `ui/`.

## Shared contracts to define before parallel work
Member 1 must document:
1. Player movement/ability API and input action names. Initial movement contract is recorded in `docs/INTEGRATION_CONTRACTS.md`.
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

## Perspective and camera
Initial perspective is top-down 2D. `Camera2D` is a child of the player and follows with position smoothing; its limits match the initial 1280 × 720 test environment. Camera behavior may be refined with level geometry, but must remain consistent with the approved perspective.

## Input map
Movement actions are defined in `project.godot`: `move_up`, `move_down`, `move_left`, and `move_right`, each bound to both WASD and arrow keys. The prototype reads these actions through `Input.get_vector`; do not add hard-coded movement key checks. `interact` is bound to E/Space, `pause` to Escape, `attack` to J, and `ability` to Shift. Dodge remains to be defined before it is implemented.

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
