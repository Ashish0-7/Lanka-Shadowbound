# LANKA SHADOWBOUND

**A 2D pixel-art action-adventure inspired by Hanuman's journey to Lanka from the Ramayana.**

> Five levels. One extraordinary journey.

Lanka Shadowbound is a single-player action-adventure planned for a 30-hour hackathon. The player experiences five connected story chapters: crossing the ocean, entering Lanka, searching the city at night, meeting Sita in Ashoka Vatika, and escaping across the rooftops as Lanka burns.

This repository is the **single source of truth** for all four human team members and their AI development agents. Everyone contributes to this one game and follows the same design and technical decisions.

---

## 1. Game overview

### The five levels

| # | Level | Main gameplay | Key story/gameplay moments |
|---|---|---|---|
| 1 | **Crossing the Ocean** | Traversal and timing | Surasa tests the player; shrink at the right moment to escape. Simhika grabs the player's shadow, so watch the shadow/reflection on the water and react. |
| 2 | **The Gates of Lanka** | Boss combat | Lankini, guardian of the city, blocks the entrance. Defeat her to enter Lanka. |
| 3 | **Lanka at Night** | Stealth and exploration | Explore a dark city whose map is revealed as you move. Search palaces, avoid patrols and follow clues. A figure mistaken for Sita is actually Mandodari, Ravana's queen. |
| 4 | **Ashoka Vatika** | Narrative and emotional interaction | Find Sita and give her Rama's ring as proof of identity. This is a quiet, story-led moment. |
| 5 | **The Escape** | Action and platforming | Captured, Hanuman's tail is set on fire. Escape across Lanka's rooftops, setting the city ablaze, then leap back across the ocean. |

### Core experience

The game should combine responsive movement, readable encounters, exploration, stealth, environmental storytelling and a memorable finale. Keep the five story beats in the agreed order. The Mandodari misunderstanding and the ring handover are important narrative moments, not optional filler.

### Scope rule

For the hackathon, prioritise a stable, complete playable path through all five levels over a large amount of unfinished content. Optional inventory, side quests, extra enemies, complex save systems and additional modes are lower priority unless the core game is already working.

---

## 2. Four-member team — ownership and responsibilities

Each human member is paired with a dedicated AI agent. The human member remains accountable for checking the agent's output, running tests and communicating dependencies. These assignments are the official ownership boundaries.

### Member 1 — Project Lead, Architecture & Integration

**Primary responsibility: make the whole game work as one coherent project.**

- Own the game vision and make final decisions on scope, story adaptations, gameplay direction, visual direction and technical architecture.
- Maintain this repository as the shared source of truth.
- Confirm the Godot version, project structure, naming conventions, input map, viewport/pixel scale and camera/perspective decisions.
- Establish shared contracts for the player controller, abilities, health/damage, interactions, dialogue, objectives, story flags, checkpoints and level transitions.
- Assign work, coordinate all three other members and their agents, and resolve conflicting changes.
- Review and integrate work from feature branches; protect the stability of the main branch.
- Check that all five levels connect in the intended story order.
- Run end-to-end QA, prioritise blockers and prepare the final playable build and presentation.
- Require every contributor to report files changed, dependencies, tests performed and remaining issues.

**Member 1 is the final decision-maker.** No agent may independently change the title, story sequence, core scope, engine, architecture or visual identity.

### Member 2 — Player Mechanics, Combat & Encounters

**Primary responsibility: implement how the player and gameplay encounters behave.**

- Implement agreed player abilities and gameplay mechanics using the canonical player/controller contract defined with Member 1.
- Implement Surasa's shrink-and-timing challenge, including clear cues, timing windows, success/failure feedback and a fair retry.
- Implement Simhika's shadow-targeting encounter, including readable shadow/reflection cues, warning states and player counterplay.
- Implement Lankini's boss behaviour, attack patterns, telegraphs, damage/health logic, hit feedback and defeat state.
- Implement agreed player combat behaviour such as attacks, dodge/evade, damage and health, if included in the approved design.
- Coordinate with Member 4 on guard detection/alert behaviour for Lanka at Night.
- Coordinate with Member 4 on fire, damage and hazard gameplay for The Escape.
- Provide isolated test scenes or exact reproducible steps for encounters and mechanics.
- Document any player/controller or shared API requirements before changing shared code.

**Member 2 does not own:** level layouts, narrative dialogue/progression, overall UI framework or a separate player controller.

### Member 3 — UI, Visual Identity, Art & Audio Presentation

**Primary responsibility: make the game readable, consistent and visually polished.**

- Establish the visual identity: palette, pixel scale, character/environment proportions, typography, UI styling, icon language and animation principles.
- Create the main menu, pause menu, HUD, health/ability indicators, interaction prompts and objective notifications.
- Implement the presentation layer for dialogue, story interactions, level transitions and tutorial hints.
- Create the map-reveal and stealth/alert presentation for Lanka at Night in coordination with Member 4.
- Create or integrate character sprites, environment tiles, props, effects, UI assets and audio assets.
- Maintain consistent art scale, palette, readability and asset naming/import settings across all five levels.
- Coordinate with Members 2 and 4 so combat, patrol alerts, hazards and story events have clear visual/audio feedback.
- Track the source and licence of imported assets. Use original, licensed or otherwise permitted assets only.

**Member 3 does not own:** authoritative gameplay rules, combat logic, patrol AI or story progression. UI must consume agreed gameplay state rather than becoming the source of truth for it.

### Member 4 — Level Design, World Building, Narrative & Progression

**Primary responsibility: build the places, story events and route the player experiences.**

- Design and assemble the five levels in the agreed order: Crossing the Ocean, The Gates of Lanka, Lanka at Night, Ashoka Vatika and The Escape.
- Build each level's layout, collision, navigation routes, platform geometry, props, spawn points, checkpoints and boundaries.
- Implement NPC placement, dialogue content, clues, story triggers, objectives and level-completion conditions.
- Build the Surasa and Simhika spaces and connect their triggers to Member 2's encounter mechanics.
- Build Lankini's arena and connect it to Member 2's boss implementation.
- Design Lanka at Night: palace search spaces, dark/explored map areas, patrol routes, hiding/avoidance options and clue placement.
- Implement the story beat where Hanuman mistakes Mandodari for Sita and then realises the mistake.
- Build Ashoka Vatika and stage the meeting with Sita and delivery of Rama's ring.
- Build the rooftop escape route and coordinate its fire/hazard triggers with Members 2 and 3.
- Verify that all level transitions preserve the story order and lead to a clear ending.

**Member 4 does not own:** a duplicate player/combat framework or a separate UI framework.

### Feature ownership at a glance

| Feature or system | Accountable owner | Collaborators |
|---|---|---|
| Game vision, scope and final decisions | Member 1 | All |
| Architecture and shared code contracts | Member 1 | All |
| Canonical player/controller integration | Member 1 | Member 2 |
| Surasa timing/shrinking mechanic | Member 2 | Member 4 |
| Simhika shadow mechanic | Member 2 | Member 4 |
| Lankini boss mechanics | Member 2 | Member 4 |
| Combat, damage and health behaviour | Member 2 | Member 1 |
| Main menu, pause menu and HUD | Member 3 | Member 1 |
| Dialogue and interaction presentation | Member 3 | Member 4 |
| Art direction, sprites, tiles, effects and audio | Member 3 | All |
| Five level layouts and world assembly | Member 4 | Member 3 |
| Patrol routes and stealth level layout | Member 4 | Members 2 and 3 |
| Mandodari and Sita story sequences | Member 4 | Member 3 |
| Ashoka Vatika ring handover | Member 4 | Member 3 |
| Rooftop escape layout and story triggers | Member 4 | Members 2 and 3 |
| Integration, end-to-end testing and release | Member 1 | All |

For expanded responsibilities, see [docs/TEAM_RESPONSIBILITIES.md](docs/TEAM_RESPONSIBILITIES.md).

---

## 3. How the AI agents must work

All agents must read [AGENTS.md](AGENTS.md) and the relevant documents in [docs/](docs/) before making changes.

1. **One repository, one game.** Do not create a separate game or independent project copy.
2. **Respect ownership.** Work only on the assigned member's tasks. Ask before editing another member's owned area.
3. **Inspect first.** Read the repository tree and relevant existing files before creating or replacing anything.
4. **Do not duplicate systems.** Reuse the canonical player, dialogue, health, inventory, UI, transition or other shared system if one exists.
5. **Coordinate shared changes.** Player/controller contracts, global state, input actions, transitions, checkpoints and shared UI require Member 1's approval.
6. **No unilateral redesign.** Do not change the story, title, engine, perspective, core scope or art direction without Member 1's approval.
7. **Use feature branches.** Do not commit directly to `main` unless Member 1 explicitly authorises it.
8. **Keep changes reviewable.** Make focused commits and do not overwrite another contributor's work.
9. **Test honestly.** State what you actually ran. If you could not run Godot, provide precise manual test steps and say it remains unverified.
10. **Report handoffs.** List behaviour implemented, files changed, interfaces/dependencies, tests/results, known issues and branch/PR link.

Read [AGENTS.md](AGENTS.md) for the full mandatory agent operating rules.

---

## 4. Repository structure

The documentation structure is being established first. The Godot project and runtime folders will be added after Member 1 confirms the engine version and project settings.

```text
Lanka-Shadowbound/
├── README.md
├── AGENTS.md
└── docs/
    ├── GAME_DESIGN.md
    ├── TEAM_RESPONSIBILITIES.md
    ├── TECHNICAL_ARCHITECTURE.md
    ├── INTEGRATION_CONTRACTS.md
    ├── CODING_STANDARDS.md
    └── DEVELOPMENT_STATUS.md
```

Planned runtime folders (final paths to be confirmed by Member 1):

```text
scenes/
  player/
  encounters/
  levels/
  ui/
scripts/
  player/
  combat/
  enemies/
  world/
  story/
  systems/
assets/
  characters/
  environments/
  animations/
  ui/
  audio/
data/
```

Do not create a second project structure or introduce new top-level conventions without coordinating with Member 1.

---

## 5. Technical direction

- Proposed engine: **Godot 4.x**.
- Proposed language: **GDScript**.
- Target: a playable desktop build for the hackathon.
- Core game should be single-player and work offline; no backend is required for the planned experience.
- Exact Godot version, perspective (top-down/side-view/intentional hybrid), logical resolution, tile scale, camera rules and input actions are **not yet locked**. Member 1 must decide and record them in [docs/TECHNICAL_ARCHITECTURE.md](docs/TECHNICAL_ARCHITECTURE.md) before parallel scene work depends on them.

---

## 6. Current status and next steps

This repository is currently in the **planning/documentation setup phase**. The documentation does not yet mean that a playable Godot project or game systems have been implemented.

Immediate sequence:
1. Member 1 confirms the Godot version and creates/validates the initial Godot project.
2. Member 1 records perspective, viewport, tile/pixel scale, input map and shared interfaces.
3. Establish one canonical player scene and a minimal level transition flow.
4. Greybox a playable route through all five levels.
5. Implement the distinctive mechanics and story beats.
6. Integrate UI, visuals, effects and audio.
7. Test the complete sequence and export a working build.

See [docs/DEVELOPMENT_STATUS.md](docs/DEVELOPMENT_STATUS.md) for task ownership and status. Update it as work progresses; do not mark untested tasks as done.

---

## 7. Documentation index

- [AGENTS.md](AGENTS.md) — mandatory instructions for all AI agents.
- [Game Design](docs/GAME_DESIGN.md) — story, levels, gameplay and scope.
- [Team Responsibilities](docs/TEAM_RESPONSIBILITIES.md) — detailed ownership for all four members.
- [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md) — engine, scene/code boundaries and decisions to lock.
- [Integration Contracts](docs/INTEGRATION_CONTRACTS.md) — shared system interfaces and coordination rules.
- [Coding Standards](docs/CODING_STANDARDS.md) — GDScript, scenes, assets and Git practices.
- [Development Status](docs/DEVELOPMENT_STATUS.md) — critical path, task board and open decisions.

