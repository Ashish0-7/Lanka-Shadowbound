## mock_vfx_harness.gd
## Member 3 — Task 10 dev harness. NOT shipped in production.
## Keys: 1=water spray, 2=shadow tentacle warning, 3=small torch, 4=large blaze,
##       5=ember trail, 6=burning city start, 7=burning city stop,
##       H=hit flash, D=damage flash, S=shrink flash, A=heal flash
extends Node

@onready var _spray: CPUParticles2D   = $VFXWaterSpray
@onready var _tentacle                = $VFXShadowTentacle
@onready var _fire                    = $VFXFire
@onready var _city                    = $VFXBurningCity
@onready var _dummy_sprite: Sprite2D  = $DummySprite

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_1:
			_spray.play()
		KEY_2:
			_tentacle.extend_toward(Vector2(100, -60))
		KEY_3:
			_fire.set_mode(VFXFire.FireMode.SMALL_TORCH)
			_fire.emitting = true
		KEY_4:
			_fire.set_mode(VFXFire.FireMode.LARGE_BLAZE)
			_fire.emitting = true
		KEY_5:
			_fire.set_mode(VFXFire.FireMode.EMBER_TRAIL)
			_fire.emitting = true
		KEY_6:
			_city.start_inferno(1.0)
		KEY_7:
			_city.stop_inferno()
		KEY_H:
			VFXHitFlash.flash(_dummy_sprite)
		KEY_D:
			VFXHitFlash.damage_flash(_dummy_sprite)
		KEY_S:
			VFXHitFlash.shrink_flash(_dummy_sprite)
		KEY_A:
			VFXHitFlash.heal_flash(_dummy_sprite)
