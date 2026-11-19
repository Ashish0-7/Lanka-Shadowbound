# Development Status — Lanka Shadowbound

## Current status
**Phase:** Initial project foundation.
**Repository:** https://github.com/Ashish0-7/Lanka-Shadowbound  
**Engine:** Godot 4.7.2 stable/GDScript; Compatibility renderer.
**Playable build:** Initial movement scene created; interactive movement still needs editor/runtime verification.

## Locked decisions
- Title: Lanka Shadowbound.
- 2D pixel-art action-adventure.
- Story follows Hanuman's journey to Lanka from the Ramayana.
- Five-level sequence: Crossing the Ocean; The Gates of Lanka; Lanka at Night; Ashoka Vatika; The Escape.
- Four roles are defined in README and `TEAM_RESPONSIBILITIES.md`.
- One shared GitHub repository is the source of truth.
- Initial foundation baseline: top-down 2D, 640 × 360 logical viewport, 16 × 16 tile-size target, 1280 × 720 window override, Compatibility renderer, WASD/arrow movement.

## Critical path
1. Member 1 confirms Godot version, perspective, viewport, controls and shared contracts.
2. Establish canonical player scene and a minimal level-transition path.
3. Greybox a playable route through all five levels.
4. Implement Surasa timing, Simhika shadow, Lankini boss, stealth/map reveal, ring handover and rooftop escape.
5. Integrate UI, art, effects and audio.
6. Run end-to-end QA, fix blockers and export a working build.

## Initial task board

| Task | Owner | Status |
|---|---|---|
| Confirm Godot version and create initial project | Member 1 | In review |
| Decide perspective, resolution, tile scale and input map | Member 1 | In review |
| Define player and transition contracts | Member 1 | In progress |
| Implement canonical player movement/controller | Member 1 with Member 2 | In review |
| Surasa timing challenge | Member 2 | Not started |
| Simhika shadow encounter | Member 2 | Not started |
| Lankini boss encounter | Member 2 | Not started |
| Visual identity and asset pipeline | Member 3 | Not started |
| Main menu, HUD and dialogue UI | Member 3 | Not started |
| Build five greybox levels and story progression | Member 4 | Not started |
| Lanka stealth layout and Mandodari reveal | Member 4 | Not started |
| Ashoka Vatika ring handover | Member 4 | Not started |
| Rooftop escape and ending | Member 4 | Not started |
| End-to-end test and export | Member 1 with all | Not started |

## Status rules
Use Not started, In progress, Blocked, In review and Done. Mark Done only after the owner reports files, tests and integration status. Never mark untested work as verified.

## Open decisions (Member 1 owns)
- Review and approve the provisional Godot version, perspective, resolution, tile scale, renderer and movement bindings recorded in `TECHNICAL_ARCHITECTURE.md`.
- Input actions beyond movement and the extended player contract (abilities, combat, health, interactions and animation states).
- Main scene and shared autoload/service decisions.
- Export target and final presentation requirements.
