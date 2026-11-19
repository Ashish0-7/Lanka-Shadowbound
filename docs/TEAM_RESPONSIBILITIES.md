# Team Responsibilities — Lanka Shadowbound

There are four human team members, each with a corresponding AI agent as a development partner. The human member remains accountable for reviewing their agent's work.

## Member 1 — Project Lead, Architecture & Integration
**Owns:** project direction, architecture, shared contracts, integration and release.
- Own the game vision and final decisions on scope, story adaptations, mechanics, art direction and technical architecture.
- Maintain this repository as the single source of truth.
- Establish Godot version, project structure, naming conventions, input map, scene communication patterns and shared interfaces.
- Define contracts for the player, level transitions, signals/events, interactions, checkpoint state and global game state.
- Assign tasks, coordinate agents and resolve ownership conflicts.
- Review and merge feature work; keep the stable build playable.
- Run end-to-end tests, prioritise bugs and prepare the final build/presentation.
- Require every member to report changed files, dependencies, tests and remaining issues.
**Boundary:** do not silently rewrite another member's feature. Coordinate shared-system changes first.

## Member 2 — Player Mechanics, Combat & Encounters
**Owns:** player abilities/mechanics and encounter/combat logic.
- Implement the agreed player ability/mechanics in coordination with Member 1's controller contract.
- Build Surasa's shrink/timing challenge with visual telegraph, timing window, success/failure and recovery.
- Build Simhika's shadow-targeting encounter with readable shadow/reflection cues and player counterplay.
- Build Lankini's boss behaviour, attacks, health/damage, telegraphs, hit feedback and defeat transition.
- Implement agreed player health/damage/dodge/attack behaviour.
- Support guard detection/alert mechanics with Member 4.
- Support fire/hazard gameplay mechanics with Member 4.
- Provide test scenes or reproducible test steps.
**Boundary:** does not own city maps, narrative progression or the global UI framework; does not create a second player controller.

## Member 3 — UI, Visual Identity, Art & Audio Presentation
**Owns:** player-facing interface and presentation.
- Define a cohesive visual identity: palette, pixel scale, fonts, UI frame language, icon style and animation principles.
- Build main menu, pause menu, HUD, health/ability indicators, interaction prompts, dialogue UI, objective notifications and level-transition presentation.
- Build map-reveal presentation for Lanka at Night with Member 4.
- Create/integrate permitted character sprites, tiles, effects, UI icons and audio assets; track sources/licences.
- Maintain consistent scale, palette and readability.
- Document asset import settings and naming conventions.
- Coordinate with Members 2 and 4 so presentation communicates combat, stealth, story and hazards.
**Boundary:** does not change gameplay rules or own level progression. UI consumes agreed interfaces/signals.

## Member 4 — Level Design, World Building, Narrative & Progression
**Owns:** five playable spaces, story events, NPCs, exploration and level sequence.
- Design/build all five levels in order: Crossing the Ocean; Gates of Lanka; Lanka at Night; Ashoka Vatika; The Escape.
- Build map layouts, collision, navigation routes, platform geometry, props, spawn points, checkpoints and boundaries.
- Implement NPC placement, dialogue/story triggers, clues, objectives and level completion conditions.
- Design Surasa/Simhika spaces and connect triggers to Member 2's mechanics.
- Build Lankini's arena and connect boss states to Member 2's implementation.
- Create Lanka stealth layout, palace search spaces, patrol routes and hiding/avoidance options; coordinate guard detection with Member 2.
- Implement Mandodari misidentification/reveal.
- Build Ashoka Vatika and the Sita/Rama's ring handover.
- Build rooftop escape route and connect fire/hazard mechanics with Members 2 and 3.
- Verify all transitions preserve story order and reach a clear ending.
**Boundary:** does not duplicate player/combat systems or create a separate UI framework.

## Feature coordination

| Feature | Accountable owner | Collaborators |
|---|---|---|
| Architecture/shared contracts/integration | Member 1 | All |
| Player controller integration | Member 1 | Member 2 |
| Surasa and Simhika mechanics | Member 2 | Member 4 |
| Lankini boss logic | Member 2 | Member 4 |
| UI framework and visual identity | Member 3 | All |
| Art assets/effects/audio integration | Member 3 | All |
| Five level layouts | Member 4 | Member 3 |
| Stealth layout/story flow | Member 4 | Members 2 and 3 |
| Sita, Mandodari and ring scene | Member 4 | Member 3 |
| Escape layout and fire presentation | Member 4 | Members 2 and 3 |
| End-to-end QA and release | Member 1 | All |

## Handoff format
Every handoff must include: completed feature/acceptance criteria; files created/modified; interfaces used/changed; assets and licence/source; tests/results; known bugs; dependencies/next actions; branch and commit/PR link.
