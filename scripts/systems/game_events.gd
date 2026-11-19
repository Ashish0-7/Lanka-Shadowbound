extends Node

## Narrow, display-facing event surface. Gameplay retains ownership of all state.
## Members 2 and 4 emit these only after their authoritative state changes.

signal player_health_changed(current: int, max_hp: int)
signal player_died()
signal shrink_ability_updated(is_active: bool, cooldown_remaining: float, cooldown_max: float, duration_remaining: float, duration_max: float)
signal objective_updated(text: String, is_complete: bool)
signal stealth_alert_level_changed(alert_level: float, is_detected: bool)
signal dialogue_requested(sequence: Array[Dictionary])
signal map_reveal_updated(cells: Array[Vector2i])
signal map_cell_revealed(cell: Vector2i)
signal encounter_feedback(text: String)
signal devotion_changed(value: float, max_value: float)

func request_dialogue(sequence: Array[Dictionary]) -> void:
	dialogue_requested.emit(sequence)

func update_map_reveal(cells: Array[Vector2i]) -> void:
	map_reveal_updated.emit(cells)

func reveal_map_cell(cell: Vector2i) -> void:
	map_cell_revealed.emit(cell)
