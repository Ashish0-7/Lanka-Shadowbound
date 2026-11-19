# Visual Identity & Style Guide: Lanka Shadowbound

## 1. Overview & Vision
*Lanka Shadowbound* is a 2D pixel-art action-adventure inspired by Hanuman's epic journey to Lanka across five narrative chapters:
1. *Crossing the Ocean* (Ocean expanse, deep sea beasts Surasa & Simhika)
2. *The Gates of Lanka* (Grand fortress threshold, guardian Lankini)
3. *Lanka at Night* (Stealth infiltration, moonlit palaces, Mandodari's chambers)
4. *Ashoka Vatika* (Secluded grove of sorrow and solace, meeting Sita)
5. *The Escape* (Burning rooftops, blazes, daring flight)

This document establishes the visual identity, 24-color restricted palette, typography, UI conventions, and Godot 4.x asset rules.

---

## 2. 24-Color Master Palette ("Lanka 24")
Every asset (sprites, tiles, UI, VFX) must strictly draw from this 24-color palette to guarantee aesthetic cohesion and retro fidelity.

| Index | Name | Hex Code | Primary Usage / Category |
|:---:|:---|:---:|:---|
| **01** | **Void Black** | `#0a0814` | Deepest shadows, UI backdrop outlines, silhouettes |
| **02** | **Midnight Indigo** | `#16172e` | UI panel body base, night skies, dark ambient shading |
| **03** | **Royal Indigo** | `#26294a` | UI panel highlight borders, deep ocean depths, armor shadows |
| **04** | **Lapis Blue** | `#3b4876` | Ocean midtones, guard uniforms, secondary panel borders |
| **05** | **Celestial Cyan** | `#5b80a6` | Water highlights, moonlight rims, divine glow edges |
| **06** | **Seafoam Teal** | `#8bc1b8` | Ocean froth, Surasa mist, spiritual aura highlights |
| **07** | **Deep Moss** | `#1c3024` | Vatika night shadows, foliage dark tones, Simhika shadow core |
| **08** | **Ashoka Emerald** | `#2d5e3c` | Vatika tree leaves, garden vegetation, poison/stealth cues |
| **09** | **Lush Jade** | `#5ca361` | Plant highlights, life energy indicators, objective success |
| **10** | **Spring Sprout** | `#a4de78` | High foliage speculars, potion/heal accents |
| **11** | **Sacred Ochre** | `#522b16` | Wood bark, earth, deep leather, Hanuman fur shadow |
| **12** | **Maruti Saffron** | `#b54e18` | Hanuman fur/dhoti base, clay tiles, torch wood |
| **13** | **Surya Orange** | `#eb7e28` | Flame midtones, ability active indicator, sunrise horizon |
| **14** | **Golden Ember** | `#f7b945` | Burning city sparks, active ability rim, alert warning level |
| **15** | **Divine Gold** | `#fce27c` | UI primary borders, Sita's ring, gold jewelry, focus frames |
| **16** | **Parchment Tan** | `#917756` | Muted parchment UI headers, inactive button text |
| **17** | **Parchment Cream** | `#d4c19c` | Dialogue body text, secondary labels, scroll paper |
| **18** | **Ivory Light** | `#fbf4e2` | Primary dialogue text, high-contrast labels, specular pings |
| **19** | **Rakshasa Crimson** | `#6e1724` | Lanka fortress banners, heavy enemy shadows, health bar empty base |
| **20** | **Ruby Blood** | `#ba2535` | Health bar fill, enemy alert eye, damage hit-flash |
| **21** | **Lotus Pink** | `#e86a82` | Sita's lotus, Mandodari ornaments, compassion cues |
| **22** | **Granite Shadow** | `#2c2834` | Fortress brick shadows, gate metal, stone platforms |
| **23** | **Granite Midtone** | `#585266` | Fortress stonework, rooftop tiles, neutral UI dividers |
| **24** | **Granite Highlight**| `#8c869e` | Stone bevels, weapon blades, neutral disabled buttons |

---

## 3. UI Visual Identity & Components

### 3.1 Color & Surface Motif
* **Panel Backgrounds:** `#16172e` (Midnight Indigo) with 90-95% opacity.
* **Panel Borders:** Ornate 2px border in `#fce27c` (Divine Gold) with an inner 1px bevel in `#26294a` (Royal Indigo).
* **Text Hierarchy:**
  * **Headers / Titles:** `#fce27c` (Divine Gold)
  * **Body / Dialogue:** `#fbf4e2` (Ivory Light)
  * **Subtitles / Prompts:** `#d4c19c` (Parchment Cream)
  * **Disabled / Inactive:** `#8c869e` (Granite Highlight) or `#917756` (Parchment Tan)
  * **Alert / Warning:** `#eb7e28` (Surya Orange) / `#ba2535` (Ruby Blood)

### 3.2 Button Styling & States
* **Normal:** Indigo background (`#16172e`), 1px Gold border (`#fce27c`), Parchment Cream text (`#d4c19c`).
* **Hover:** Dark Lapis background (`#26294a`), 2px bright Gold border (`#fce27c`), Ivory text (`#fbf4e2`) with subtle gold corner gems.
* **Pressed:** Midnight Indigo (`#0a0814`), 1px Gold border, shifted 1px down.
* **Focus (Gamepad/Keyboard):** Flashing or distinct outer border in `#fce27c` with left/right cursor indicator glyphs (`▶` or custom diamond sprites).
* **Disabled:** Granite Shadow (`#2c2834`), Granite Highlight border (`#8c869e`), muted text (`#585266`).

### 3.3 HUD Requirements
* **Health Bar:** Ruby Blood (`#ba2535`) bar over Rakshasa Crimson (`#6e1724`) with a Divine Gold (`#fce27c`) casing. Must display numeric text (e.g. "100 / 100") or pip segments so players who are colorblind do not rely on red alone.
* **Shrink Ability Indicator:**
  * **Ready:** Golden Ember glow (`#f7b945`) with icon of Hanuman's miniaturized silhouette.
  * **Active:** Pulsing Surya Orange (`#eb7e28`) ring with countdown pie fill.
  * **Cooldown:** Desaturated granite with sweep fill overlay and remaining seconds counter.
* **Objective Tracker:** Top-right or top-left discreet scroll panel with parchment font and checkmark icons.

### 3.4 Dialogue System Presentation
* **Speaker Portrait:** 48×48 or 64×64 pixel portrait box framed in gold on the left.
* **Speaker Nameplate:** Attached gold-trimmed badge sitting above the dialogue box.
* **Typewriter Effect:** Animated reveal (~30-40 characters per second) with audio blip pitch varied by speaker:
  * Hanuman: Mid-warm blip
  * Mandodari: Melodic gentle chime
  * Sita: Reverent soft bell
  * Surasa/Lankini/Enemies: Deep guttural growl
* **Advance Prompt:** Animated pulsing gold arrow / diamond prompt (`▼`) in the bottom right corner when line is fully revealed.

---

## 4. Typography Specification
* **Primary Pixel Font:** *Pixelify Sans* (Google Fonts, SIL Open Font License 1.1).
* **Fallback Pixel Font:** Godot default monospace / Kenney Pixel if system lacks TTF.
* **Standard Font Sizes (virtual canvas scaling):**
  * `Title / Header`: 20-24 pt
  * `Menu Items / Buttons`: 14-16 pt
  * `Dialogue Body`: 12-14 pt
  * `HUD Labels & Counters`: 10-12 pt
  * `Tutorial / Small Prompts`: 8-10 pt

---

## 5. Pixel Art & Technical Specifications in Godot 4.x

### 5.1 Import Rules
All 2D textures (`.png`) must use:
* **Texture Filter:** `Nearest` (essential for crisp pixel borders).
* **Mipmaps:** `Disabled` (avoids blurring at distances).
* **Compression:** `Lossless` (preserves exact palette indices).
* **Repeat:** `Disabled` (except for scrolling ocean/cloud backgrounds).

### 5.2 Asset Naming Conventions
Files must strictly follow `snake_case` with `category_name_variant_frame.ext`:
* Characters: `char_hanuman_idle_01.png`, `char_sita_portrait_neutral.png`
* Environments: `env_ocean_tileset.png`, `env_ashoka_vatika_bg.png`
* UI: `ui_panel_indigo_frame.png`, `ui_icon_shrink_ready.png`, `ui_button_hover.tres`
* Audio: `sfx_ui_select.wav`, `mus_level1_ocean_loop.ogg`

### 5.3 Accessibility Rule
**Never rely on color alone for game meaning.**
* Danger zones must pair red tints with exclamation icons or hazard patterns.
* Stealth detection must pair color changes (green → yellow → red) with an eye icon opening state (closed → half-open → wide open with pulse).
* Interactive objects must display a floating action prompt (e.g. `[E]` or `[A]`) rather than merely glowing.

---

## 6. Open Decisions Pending Member 1
1. **Target Viewport Resolution:** Standard pixel resolutions under consideration: `320×180` (16:9), `480×270` (16:9), or `640×360` (16:9).
2. **Stretch Mode:** Recommended: `canvas_items` with aspect `keep` and integer scaling enabled in Godot project settings.
3. **Base Tile Dimensions:** 16×16 px or 24×24 px grid.
4. **Sprite Dimensions:** Hanuman base height (e.g. 24×32 px normal, 12×16 px shrunken).
