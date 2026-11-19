extends CharacterBody2D
## Canonical prototype controller; Member 2 can extend this after coordination.

@export var move_speed: float = 120.0


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * move_speed
	move_and_slide()
