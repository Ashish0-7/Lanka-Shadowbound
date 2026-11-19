# Asset Attribution & Verification Log: Lanka Shadowbound

This log tracks every third-party and custom audio, art, font, and UI asset integrated into *Lanka Shadowbound*.
All assets must be verified for commercial/hackathon use under permitted licences (CC0, CC-BY, SIL OFL 1.1, or MIT).

## Asset Registry

| Path | Category | Source / Creator | Link / Provenance | Licence | Attribution Required / Text | Date Added | Status |
|:---|:---:|:---|:---|:---:|:---|:---:|:---:|
| `assets/ui/fonts/pixelify_sans.ttf` | UI Font | Stefie Justprince (Google Fonts) | https://fonts.google.com/specimen/Pixelify+Sans | SIL OFL 1.1 | Copyright 2023 The Pixelify Sans Project Authors | 2026-11-19 | Verified / Integrated |
| `assets/ui/main_theme.tres` | UI Theme | Member 3 (Original) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Created / Active |
| `assets/ui/style_panel_indigo.tres` | UI StyleBox | Member 3 (Original) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Created / Active |
| `assets/ui/style_button_*.tres` | UI StyleBox | Member 3 (Original) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Created / Active |
| `assets/ui/style_progress_*.tres` | UI StyleBox | Member 3 (Original) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Created / Active |
| `assets/ui/portraits/portrait_hanuman.png` | UI Portrait Art | User-provided Hanuman atlas (2× bust crop via tools/gen_characters.gd, 2026-11-20) | Internal repository | User-approved / Project License | Cropped from the supplied four-direction Hanuman atlas | 2026-11-19 | Verified / Integrated |
| `assets/ui/portraits/portrait_mandodari.png` | UI Portrait Art | Original pixel art, 2× bust of char_mandodari_idle (tools/gen_characters.gd, 2026-11-20) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/ui/portraits/portrait_sita.png` | UI Portrait Art | Original pixel art, 2× bust of char_sita_seated_sad (tools/gen_characters.gd, 2026-11-20) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/ui/icons/` | UI Icons | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Planned |
| `assets/characters/hanuman/char_hanuman_idle_{direction}.png` | Character Sprite (24x32) | User-provided source atlas / original restyling | Internal repository | User-approved / Project License | Sliced from the supplied four-direction Hanuman atlas | 2026-11-19 | Verified / Integrated |
| `assets/characters/hanuman/char_hanuman_walk_{direction}_{01-08}.png` | Character Walk Sprite (24x32) | User-provided source atlas / original restyling | Internal repository | User-approved / Project License | Sliced from the supplied four-direction Hanuman atlas | 2026-11-19 | Verified / Integrated |
| `assets/characters/enemies/boss_surasa/boss_surasa_idle_01.png` | Boss Sprite (64x64) | User-provided Surasa atlas | Internal repository | User-approved / Project License | 48 frames re-sliced by content (tools/reslice_boss_atlas.gd) with black background keyed out, 2026-11-20; source atlas retained alongside frames | 2026-11-19 | Verified / Integrated |
| `assets/characters/enemies/boss_simhika/boss_simhika_idle_01.png` | Boss Sprite (64x64) | User-provided Simhika atlas | Internal repository | User-approved / Project License | 48 frames re-sliced by content (tools/reslice_boss_atlas.gd) with black background keyed out, 2026-11-20; source atlas retained alongside frames | 2026-11-19 | Verified / Integrated |
| `assets/characters/enemies/boss_lankini/boss_lankini_idle_01.png` | Boss Sprite (64x64) | User-provided Lankini atlas | Internal repository | User-approved / Project License | 48 frames re-sliced by content at 64x64 (tools/reslice_boss_atlas.gd), 2026-11-20; source atlas retained alongside frames | 2026-11-19 | Verified / Integrated |
| `assets/characters/enemies/char_guard_patrol_24x32.png` | Enemy Sprite (24x32) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/characters/npcs/char_mandodari_32x24.png` | Story NPC (32x24) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/characters/npcs/char_sita_24x32.png` | Story NPC (24x32) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/environments/tilesets/env_ocean_tileset.png` | Level 1 Tileset (64x64) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/environments/tilesets/env_gates_tileset.png` | Level 2 Tileset (64x64) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/environments/tilesets/env_night_palace_tileset.png` | Level 3 Tileset (64x64) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/environments/tilesets/env_ashoka_vatika_tileset.png` | Level 4 Tileset (64x64) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/environments/tilesets/env_burning_rooftops_tileset.png` | Level 5 Tileset (64x64) | Member 3 (Original Pixel Art) | Internal repository | MIT / Project License | Created for Lanka Shadowbound | 2026-11-19 | Verified / Integrated |
| `assets/characters/npcs/char_sita_seated_{sad,blink,joy}.png` | NPC Sprite (24x32) | Original pixel art (tools/gen_characters.gd) | Internal repository | MIT / Project License | Sita seated beneath the Ashoka tree: sorrowful, blink, joyful-with-ring frames | 2026-11-20 | Verified / Integrated |
| `assets/characters/npcs/char_guard_rakshasa_{01,02}.png` | NPC Sprite (24x32) | Original pixel art (tools/gen_characters.gd) | Internal repository | MIT / Project License | Rakshasa palace guard, 2-frame lantern flicker; replaces char_guard_patrol_24x32 in game | 2026-11-20 | Verified / Integrated |
| `assets/characters/npcs/char_mandodari_idle.png` | NPC Sprite (24x32) | Original pixel art (tools/gen_characters.gd) | Internal repository | MIT / Project License | Queen Mandodari in the Chapter 3 palace | 2026-11-20 | Verified / Integrated |
| `assets/characters/enemies/minions/minion_{sea,gate,shadow,thorn}_{walk1,walk2,windup}.png` | Minion Sprite (16x16) | Original pixel art (tools/gen_characters.gd) | Internal repository | MIT / Project License | Chapter imps: 2 walk frames + red-eyed wind-up per variant | 2026-11-20 | Verified / Integrated |
| `assets/audio/music/mus_main_theme_loop.wav` | Original Procedural Theme | Member 3 (Original) | Internal repository | MIT / Project License | Procedurally synthesized loop; no third-party content | 2026-11-20 | Verified / Integrated |
| `assets/audio/sfx/*.wav` | Original Procedural SFX | Member 3 (Original) | Internal repository | MIT / Project License | 27 synthesized (8 boss-telegraph sounds — hiss, bite, whoosh, roar, slam, shadow, grab, impact — regenerable via tools/gen_boss_sfx.gd) UI, combat, movement, environment, encounter, dialogue, victory and defeat effects | 2026-11-20 | Verified / Integrated |

---

## License Validation Criteria
1. **CC0 1.0 Universal:** Public domain dedication. Safe for all game jams and commercial releases.
2. **CC-BY 4.0 / 3.0:** Attribution required in credits screen and this log.
3. **SIL Open Font License 1.1 (OFL):** Allows bundling and embedding with software.
4. **MIT License:** Standard open source software license with attribution notice.
5. **Prohibited:** Any Non-Commercial (CC-NC), Share-Alike (CC-SA unless approved), or ambiguous web rips.

## Task 10 � VFX Scripts and Scenes
| File | Type | Author | Source | License | Notes | Date | Status |
|:-----|:-----|:-------|:-------|:--------|:------|:-----|:-------|
| `scripts/vfx/vfx_hit_flash.gd` | VFX Script | Member 3 (Original) | Internal | MIT / Project License | Static class: flash/damage/heal/shrink tween modulation | 2026-11-19 | Verified |
| `scripts/vfx/vfx_water_spray.gd` | VFX Script | Member 3 (Original) | Internal | MIT / Project License | CPUParticles2D subclass, one-shot ocean splash | 2026-11-19 | Verified |
| `scripts/vfx/vfx_shadow_tentacle.gd` | VFX Script | Member 3 (Original) | Internal | MIT / Project License | Line2D tentacles, extend_toward, warning pulse | 2026-11-19 | Verified |
| `scripts/vfx/vfx_fire.gd` | VFX Script | Member 3 (Original) | Internal | MIT / Project License | CPUParticles2D subclass, FireMode enum (SMALL_TORCH/LARGE_BLAZE/EMBER_TRAIL) | 2026-11-19 | Verified |
| `scripts/vfx/vfx_burning_city.gd` | VFX Script | Member 3 (Original) | Internal | MIT / Project License | Composite Node2D: ember rain + sky tint + fire columns | 2026-11-19 | Verified |
| `scenes/vfx/vfx_hit_flash.tscn` | VFX Scene | Member 3 (Original) | Internal | MIT / Project License | Node with vfx_hit_flash.gd script | 2026-11-19 | Verified |
| `scenes/vfx/vfx_water_spray.tscn` | VFX Scene | Member 3 (Original) | Internal | MIT / Project License | CPUParticles2D scene with splash preset | 2026-11-19 | Verified |
| `scenes/vfx/vfx_shadow_tentacle.tscn` | VFX Scene | Member 3 (Original) | Internal | MIT / Project License | Node2D + 3x Line2D tentacle children | 2026-11-19 | Verified |
| `scenes/vfx/vfx_fire.tscn` | VFX Scene | Member 3 (Original) | Internal | MIT / Project License | CPUParticles2D scene with fire preset | 2026-11-19 | Verified |
| `scenes/vfx/vfx_burning_city.tscn` | VFX Scene | Member 3 (Original) | Internal | MIT / Project License | Composite scene: SkyTint + EmberRain + FireColumns (3x VFXFire) | 2026-11-19 | Verified |
| `scripts/vfx/mock_vfx_harness.gd` | Dev Harness | Member 3 (Original) | Internal | MIT / Project License | Test harness for all VFX (not shipped) | 2026-11-19 | Dev Only |
| `scenes/vfx/mock_vfx_harness.tscn` | Dev Harness | Member 3 (Original) | Internal | MIT / Project License | Test scene with key bindings (not shipped) | 2026-11-19 | Dev Only |
