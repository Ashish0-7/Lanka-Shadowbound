# Game Design — Lanka Shadowbound

## High concept
Lanka Shadowbound is a 2D pixel-art action-adventure following Hanuman's journey to Lanka. The player overcomes mythic trials, enters a guarded city, searches for Sita, delivers Rama's ring and escapes as Lanka burns.

## Player fantasy
The player should feel resourceful, agile, courageous and compassionate. Gameplay expresses ingenuity and timing during the ocean crossing; courage during Lankini's encounter; patience and observation during the night search; empathy during the meeting with Sita; and speed and daring during the escape.

## Five-level structure

### 1. Crossing the Ocean
**Purpose:** teach traversal, observation and timing.
- Establish the ocean crossing and scale of the journey.
- Surasa presents a timing challenge: read her cue and shrink at the correct moment to pass through her mouth.
- Simhika targets Hanuman's shadow. Watch the shadow/reflection on the water, read the warning and react before being pulled down.
- Success leads to Lanka.
**Requirements:** readable telegraphs, fair timing, visible success/failure feedback and quick retry. Simhika's shadow mechanic must be clear and fair.

### 2. The Gates of Lanka
**Purpose:** focused boss encounter.
- Lankini guards the entrance.
- Teach attack telegraphs, evade timing, damage feedback and boss defeat.
- Defeating Lankini opens the city.
**Requirements:** compact arena, readable patterns, clear feedback and definite victory transition.

### 3. Lanka at Night
**Purpose:** main stealth and exploration level.
- The city begins dark/obscured; the explored map is progressively revealed.
- Search palace spaces and follow clues while avoiding patrols.
- Provide readable guard vision/detection cues and opportunities to evade or hide.
- Include the story-accurate moment where Hanuman initially mistakes Mandodari, Ravana's queen, for Sita, then realises the mistake.
**Requirements:** stealth must be understandable, not arbitrary. Provide detection feedback and recoverable alert state where feasible. The Mandodari twist must be understandable to players unfamiliar with the episode.

### 4. Ashoka Vatika
**Purpose:** emotional centre of the mission.
- Hanuman finds Sita.
- He presents Rama's ring as proof and conveys Rama's message.
- This sequence is quieter and more intimate than the surrounding action.
**Requirements:** clear dialogue and staging; avoid unnecessary combat or fail states during the core exchange.

### 5. The Escape
**Purpose:** memorable action finale.
- Hanuman is captured and his tail is set on fire.
- Escape across Lanka's rooftops, igniting the city along the route.
- Jump/hazard/platforming gameplay leads to the final leap back across the ocean.
- Finish with a clear ending and credits or closing story panel.
**Requirements:** escalating pace, readable hazards, responsive jumps, satisfying fire feedback and a definite completion state.

## Core gameplay loop
Explore/traverse → observe a threat or clue → use the relevant ability/interaction → overcome the challenge → advance the story → reach the next level.

## Cross-level systems
- Player movement and animation.
- Contextual interaction.
- Health/damage and encounter feedback where needed.
- Reusable level transition/checkpoint flow.
- Dialogue/story event presentation.
- HUD and pause/restart flow.
- Audio feedback and atmosphere.
- Optional collectibles only if they do not threaten the critical path.

## Scope

### Must have
- Controllable player and all five story beats in playable sequence.
- Surasa timing mechanic, Simhika shadow mechanic and Lankini boss.
- Basic stealth and map reveal in Lanka at Night.
- Mandodari misidentification beat.
- Sita and ring handover.
- Rooftop escape and clear ending.
- Start/restart/pause flow and playable build.

### Should have
- Checkpoints and fast retries.
- Dialogue portraits or expressive poses.
- Music and distinctive sound effects.
- Optional clues or one small side interaction.
- Polished hit, alert, fire and transition effects.

### Could have only if time remains
- Multiple difficulty modes, large optional areas, extensive inventory/equipment, branching outcomes, save slots or meta-progression.

## Narrative/adaptation principles
- Preserve the five-part event order and key narrative turns.
- Present mythological characters respectfully.
- Do not add twists that contradict the agreed story without Member 1 approval.
- Keep exposition concise and use environmental storytelling where possible.
- Treat the ring handover as an emotional payoff, not just an item pickup.

## Perspective decision
Top-down, side-view or a deliberate hybrid is not yet locked. Member 1 must record perspective, resolution, pixel/tile scale and camera conventions in `TECHNICAL_ARCHITECTURE.md` before multiple levels are built. Do not let agents independently choose incompatible perspectives.
