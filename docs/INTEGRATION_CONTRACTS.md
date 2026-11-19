# Integration Contracts — Lanka Shadowbound

## Status
This is the shared integration checklist. Member 1 owns approval and must fill in concrete node paths, method names, signal signatures and resource paths after inspecting the initial Godot project.

Agents must not assume proposed names are implemented APIs until Member 1 confirms them.

## Principles
- One canonical implementation of each shared system.
- Feature owners implement behaviour; collaborating owners provide scene placement or presentation.
- Prefer signals and narrow interfaces over reaching into another scene's internal nodes.
- Check the repository before assuming a node path, autoload or method exists.
- Shared-contract changes require agreement from affected members and an update to this file.

## Player contract — TBD
Record canonical player scene, movement ownership, abilities and invocation, health/damage interface, animation states, interaction entry point and player-state signals. Member 2 owns ability/combat behaviour; Member 1 owns shared architecture/integration.

## Encounter contract — TBD
Each encounter needs a clear lifecycle: initialise/reset, become active, report success/defeat, report failure/retry if applicable, and communicate completion to level/story progression. Member 2 owns mechanics; Member 4 owns placement/layout/story sequence; Member 1 approves interface.

## Interactables and dialogue — TBD
Define player detection, interaction prompt, trigger method, dialogue data interface and completion callback/signal. Member 4 owns narrative content/triggers; Member 3 owns presentation; Member 1 approves interface.

## Objectives and story flags — TBD
Define canonical current level, current objective, completed story events, key progression flags (including ring delivery and level completion), and checkpoint/restart state. Avoid duplicate conflicting progression state.

## Level transitions — TBD
Define a single mechanism for next level, restart/load, passing story/checkpoint state, transition presentation and invalid destination handling. Member 1 owns mechanism; Member 4 owns order/completion triggers; Member 3 owns presentation.

## HUD and feedback — TBD
Define source/signals for health, abilities, interaction prompts, objectives, stealth/alert state, map reveal and boss state. Member 3 owns UI presentation, not authoritative gameplay state.

## Stealth and map reveal — TBD
Member 4 owns patrol placement, layout and stealth progression. Member 2 owns agreed detection/alert logic. Member 3 owns map/alert presentation. Define one source of truth for explored areas and alert state.

## Fire and escape — TBD
Member 4 owns rooftop layout/story sequence; Member 2 owns approved gameplay hazards; Member 3 owns visual/audio fire effects. Cosmetic particles must not be the sole source of gameplay collision/damage.

## Shared-change proposal
Before changing a shared contract, report reason, current and proposed contract, affected files/members, migration steps and test plan. Member 1 approves and updates this document before dependent implementations proceed.
