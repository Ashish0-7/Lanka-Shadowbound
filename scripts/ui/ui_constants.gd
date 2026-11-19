class_name UIConstants
extends RefCounted

## UIConstants: Centralized visual identity tokens, layout dimensions, and timing.
## Follows docs/VISUAL_IDENTITY.md specifications.

# ==============================================================================
# VIEWPORT & GRID SPECIFICATIONS (Defaults pending Member 1 confirmation)
# ==============================================================================
const VIEWPORT_WIDTH: int = 480
const VIEWPORT_HEIGHT: int = 270
const TILE_SIZE: int = 16
const SPRITE_HANUMAN_NORMAL_WIDTH: int = 24
const SPRITE_HANUMAN_NORMAL_HEIGHT: int = 32
const SPRITE_HANUMAN_SHRUNK_WIDTH: int = 12
const SPRITE_HANUMAN_SHRUNK_HEIGHT: int = 16

# ==============================================================================
# 24-COLOR MASTER PALETTE ("Lanka 24")
# ==============================================================================
const COLOR_VOID_BLACK: Color = Color(0.0392, 0.0314, 0.0784, 1.0)        # #0a0814
const COLOR_MIDNIGHT_INDIGO: Color = Color(0.0863, 0.0902, 0.1804, 1.0)   # #16172e
const COLOR_ROYAL_INDIGO: Color = Color(0.1490, 0.1608, 0.2902, 1.0)      # #26294a
const COLOR_LAPIS_BLUE: Color = Color(0.2314, 0.2824, 0.4627, 1.0)        # #3b4876
const COLOR_CELESTIAL_CYAN: Color = Color(0.3569, 0.5020, 0.6510, 1.0)    # #5b80a6
const COLOR_SEAFOAM_TEAL: Color = Color(0.5451, 0.7569, 0.7216, 1.0)      # #8bc1b8

const COLOR_DEEP_MOSS: Color = Color(0.1098, 0.1882, 0.1412, 1.0)         # #1c3024
const COLOR_ASHOKA_EMERALD: Color = Color(0.1765, 0.3686, 0.2353, 1.0)    # #2d5e3c
const COLOR_LUSH_JADE: Color = Color(0.3608, 0.6392, 0.3804, 1.0)         # #5ca361
const COLOR_SPRING_SPROUT: Color = Color(0.6431, 0.8706, 0.4706, 1.0)     # #a4de78

const COLOR_SACRED_OCHRE: Color = Color(0.3216, 0.1686, 0.0863, 1.0)      # #522b16
const COLOR_MARUTI_SAFFRON: Color = Color(0.7098, 0.3059, 0.0941, 1.0)    # #b54e18
const COLOR_SURYA_ORANGE: Color = Color(0.9216, 0.4941, 0.1569, 1.0)      # #eb7e28
const COLOR_GOLDEN_EMBER: Color = Color(0.9686, 0.7255, 0.2706, 1.0)      # #f7b945
const COLOR_DIVINE_GOLD: Color = Color(0.9882, 0.8863, 0.4863, 1.0)       # #fce27c

const COLOR_PARCHMENT_TAN: Color = Color(0.5686, 0.4667, 0.3373, 1.0)     # #917756
const COLOR_PARCHMENT_CREAM: Color = Color(0.8314, 0.7569, 0.6118, 1.0)   # #d4c19c
const COLOR_IVORY_LIGHT: Color = Color(0.9843, 0.9569, 0.8863, 1.0)       # #fbf4e2

const COLOR_RAKSHASA_CRIMSON: Color = Color(0.4314, 0.0902, 0.1412, 1.0)  # #6e1724
const COLOR_RUBY_BLOOD: Color = Color(0.7294, 0.1451, 0.2078, 1.0)        # #ba2535
const COLOR_LOTUS_PINK: Color = Color(0.9098, 0.4157, 0.5098, 1.0)        # #e86a82

const COLOR_GRANITE_SHADOW: Color = Color(0.1725, 0.1569, 0.2039, 1.0)    # #2c2834
const COLOR_GRANITE_MIDTONE: Color = Color(0.3451, 0.3216, 0.4000, 1.0)   # #585266
const COLOR_GRANITE_HIGHLIGHT: Color = Color(0.5490, 0.5255, 0.6196, 1.0) # #8c869e

# ==============================================================================
# FONT SIZES
# ==============================================================================
const FONT_SIZE_TITLE: int = 22
const FONT_SIZE_HEADER: int = 16
const FONT_SIZE_BUTTON: int = 14
const FONT_SIZE_BODY: int = 12
const FONT_SIZE_HUD: int = 10
const FONT_SIZE_SMALL: int = 8

# ==============================================================================
# TIMINGS & ANIMATION DURATIONS (Seconds)
# ==============================================================================
const FADE_TRANSITION_DURATION: float = 0.4
const DIALOGUE_CHAR_INTERVAL: float = 0.025 # ~40 chars/sec
const ALERT_PULSE_DURATION: float = 0.6
const NOTIFICATION_DISPLAY_DURATION: float = 3.0
