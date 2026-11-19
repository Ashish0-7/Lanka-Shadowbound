# Integration Contracts: Lanka Shadowbound (UI Consumption Specifications)

*Proposed by Member 3 (UI, Art & Presentation) for Member 1, 2, and 4 Review & Alignment.*

This document specifies the exact signals and data structures consumed by the UI system.
**Rule:** The UI strictly **consumes** these signals and does **not** store authoritative gameplay state.

---

## 1. Player & Combat Contracts (Owned by Member 2)

### 1.1 Health Updates
* **Signal Name:** `player_health_changed(current: int, max_hp: int)`
* **Description:** Emitted whenever Hanuman takes damage or receives healing.
* **UI Behavior:** Updates `HUD.set_health(current, max_hp)`. If `current / max_hp <= 0.25`, triggers low-health warning indicator and pulse.

### 1.2 Player Defeat
* **Signal Name:** `player_died()`
* **Description:** Emitted when Hanuman's health drops to 0.
* **UI Behavior:** Updates HUD to display "DEFEATED" and preps game-over / respawn overlay.

### 1.3 Shrink Ability State
* **Signal Name:** `shrink_ability_updated(is_active: bool, cooldown_remaining: float, cooldown_max: float, duration_remaining: float, duration_max: float)`
* **Description:** Emitted continuously or upon state change of Hanuman's miniaturization ability.
* **UI Behavior:** Updates `HUD.set_shrink_ability(...)`:
  - When `is_active == true`: Shows "ACTIVE (SHRUNK)" in Surya Orange with active duration countdown.
  - When `cooldown_remaining > 0.0`: Shows "RECHARGING" in Granite Highlight with recharge progress bar.
  - When ready: Shows "SHRINK READY" in Divine Gold with `[SHIFT]` input badge.

---

## 2. Objective & Mission Contracts (Owned by Member 1 / Member 4)

### 2.1 Objective Update
* **Signal Name:** `objective_updated(text: String, is_complete: bool)`
* **Description:** Emitted when narrative or quest goals change (e.g. entering a new zone or solving an encounter).
* **UI Behavior:** Updates `HUD.set_objective(...)`:
  - Sets text in Parchment Cream with auto-wrapping.
  - Toggles icon between `[•]` (In progress) and `[✔]` (Complete) in Lush Jade.

---

## 3. Stealth & AI Contracts (Owned by Member 4 - Lanka at Night)

### 3.1 Stealth Alert Meter
* **Signal Name:** `stealth_alert_level_changed(alert_level: float, is_detected: bool)`
* **Description:** Emitted during Level 3 (*Lanka at Night*) based on guard vision cones and proximity.
* **UI Behavior:** Updates `HUD.set_stealth_alert(...)`:
  - `alert_level == 0.0`: Meter hidden.
  - `0.0 < alert_level <= 0.65`: "UNNOTICED" in Celestial Cyan.
  - `0.65 < alert_level < 1.0`: "SUSPICIOUS (HIGH)" in Golden Ember.
  - `is_detected == true` or `alert_level >= 1.0`: "DETECTED!" in Ruby Blood.

---

## 4. Dialogue System Contracts (Owned by Member 4)

### 4.1 Dialogue Line Structure
* **Data Schema (Dictionary or Resource):**
  ```gdscript
  {
      "speaker_name": String,      # e.g., "Hanuman", "Mandodari", "Sita", "Surasa"
      "portrait_id": String,       # e.g., "hanuman_neutral", "mandodari_pensive", "sita_sorrow"
      "text": String,              # Dialogue content
      "blip_sound": String,        # "hero", "female_melodic", "reverent", "monster"
      "auto_advance_time": float   # 0.0 = manual press to advance, > 0.0 = auto
  }
  ```
* **Signal Name:** `dialogue_started(dialogue_sequence: Array[Dictionary])`
* **Signal Name:** `dialogue_finished()`
