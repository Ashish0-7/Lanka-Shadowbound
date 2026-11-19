class_name VFXHitFlash
extends Node

## VFXHitFlash: Applies a flash-and-restore color modulation to any Sprite2D/AnimatedSprite2D.
## Called by Member 2's combat system after landing a hit or receiving damage.
## Usage: VFXHitFlash.flash(sprite_node)

static func flash(target: Node2D, flash_color: Color = UIConstants.COLOR_IVORY_LIGHT, duration: float = 0.1, flashes: int = 2) -> void:
	if not is_instance_valid(target):
		return
		
	var original: Color = target.modulate
	var tween: Tween = target.create_tween()
	
	for _i in range(flashes):
		tween.tween_property(target, "modulate", flash_color, duration * 0.3)
		tween.tween_property(target, "modulate", original, duration * 0.7)
	
	# Always restore to original
	tween.tween_property(target, "modulate", original, 0.0)

## Damage flash — ruby blood red to signal player or enemy took a hit
static func damage_flash(target: Node2D) -> void:
	flash(target, UIConstants.COLOR_RUBY_BLOOD, 0.12, 3)

## Heal flash — jade green pulse to signal health restored
static func heal_flash(target: Node2D) -> void:
	flash(target, UIConstants.COLOR_LUSH_JADE, 0.15, 2)

## Shrink activation flash — golden ember burst when Hanuman activates miniaturization
static func shrink_flash(target: Node2D) -> void:
	flash(target, UIConstants.COLOR_GOLDEN_EMBER, 0.08, 4)
