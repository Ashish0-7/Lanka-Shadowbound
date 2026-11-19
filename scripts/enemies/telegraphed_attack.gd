class_name TelegraphedAttack
extends RefCounted

## TelegraphedAttack: minimal attack phase cycle READY → WINDUP → STRIKE → RECOVER → READY.
## Damage belongs only to the `struck` moment, never the whole animation.
## Placeholder timing for the vertical slice; Member 2 can tune or replace it.

signal windup_started()
signal struck()
signal recovered()

enum Phase { READY, WINDUP, STRIKE, RECOVER }

var windup: float
var strike: float
var recover: float
var phase: Phase = Phase.READY
var _timer: float = 0.0

func _init(windup_seconds: float, strike_seconds: float, recover_seconds: float) -> void:
	windup = windup_seconds
	strike = strike_seconds
	recover = recover_seconds

func is_ready() -> bool:
	return phase == Phase.READY

func start() -> bool:
	if phase != Phase.READY:
		return false
	phase = Phase.WINDUP
	_timer = windup
	windup_started.emit()
	return true

## Interrupts the attack (counter-hit, chapter restart). Goes straight to recovery.
func interrupt(recovery_seconds: float = -1.0) -> void:
	if phase == Phase.READY:
		return
	phase = Phase.RECOVER
	_timer = recover if recovery_seconds < 0.0 else recovery_seconds

func reset() -> void:
	phase = Phase.READY
	_timer = 0.0

func update(delta: float) -> void:
	if phase == Phase.READY:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	match phase:
		Phase.WINDUP:
			phase = Phase.STRIKE
			_timer = strike
			struck.emit()
		Phase.STRIKE:
			phase = Phase.RECOVER
			_timer = recover
		Phase.RECOVER:
			phase = Phase.READY
			recovered.emit()
