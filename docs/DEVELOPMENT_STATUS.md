# Development Status — Lanka Shadowbound

## Current status
**Phase:** Repository setup and planning.  
**Repository:** https://github.com/Ashish0-7/Lanka-Shadowbound  
**Engine:** Godot 4.x/GDScript proposed; exact version and initial project setup not yet confirmed.  
**Playable build:** Not yet verified.

## Locked decisions
- Title: Lanka Shadowbound.
- 2D pixel-art action-adventure.
- Story follows Hanuman's journey to Lanka from the Ramayana.
- Five-level sequence: Crossing the Ocean; The Gates of Lanka; Lanka at Night; Ashoka Vatika; The Escape.
- Four roles are defined in README and `TEAM_RESPONSIBILITIES.md`.
- One shared GitHub repository is the source of truth.

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
| Confirm Godot version and create initial project | Member 1 | Not started |
| Decide perspective, resolution, tile scale and input map | Member 1 | Not started |
| Define player and transition contracts | Member 1 | Not started |
| Implement canonical player movement/controller | Member 1 with Member 2 | Not started |
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
- Exact Godot version.
- Top-down, side-view or intentional hybrid.
- Logical viewport/window resolution and pixel scale.
- Input actions and player movement contract.
- Main scene and shared autoload/service decisions.
- Export target and final presentation requirements.
