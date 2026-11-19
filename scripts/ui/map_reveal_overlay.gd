class_name MapRevealOverlay
extends Control

## Presentation-only fog-of-war overlay for Lanka at Night.
## World/progression code remains the source of truth and supplies revealed cells.

@export var grid_size: Vector2i = Vector2i(20, 12)
@export var fog_color: Color = UIConstants.COLOR_VOID_BLACK
@export_range(0.0, 1.0, 0.05) var fog_opacity: float = 0.78

var _revealed_cells: Dictionary = {}

func _ready() -> void:
	if has_node("/root/GameEvents"):
		var events: Node = get_node("/root/GameEvents")
		if events.has_signal("map_reveal_updated"):
			events.connect("map_reveal_updated", Callable(self, "set_revealed_cells"))
		if events.has_signal("map_cell_revealed"):
			events.connect("map_cell_revealed", Callable(self, "reveal_cell"))

## Replaces the displayed explored set using grid coordinates supplied by gameplay.
func set_revealed_cells(cells: Array[Vector2i]) -> void:
	_revealed_cells.clear()
	for cell: Vector2i in cells:
		_revealed_cells[cell] = true
	queue_redraw()

## Updates presentation after gameplay confirms that one cell is explored.
func reveal_cell(cell: Vector2i) -> void:
	if _revealed_cells.has(cell):
		return
	_revealed_cells[cell] = true
	queue_redraw()

func clear_reveal() -> void:
	_revealed_cells.clear()
	queue_redraw()

func _draw() -> void:
	if grid_size.x <= 0 or grid_size.y <= 0:
		return
	var cell_size := Vector2(size.x / grid_size.x, size.y / grid_size.y)
	var color := Color(fog_color, fog_opacity)
	for y in grid_size.y:
		for x in grid_size.x:
			var cell := Vector2i(x, y)
			if not _revealed_cells.has(cell):
				draw_rect(Rect2(Vector2(cell.x, cell.y) * cell_size, cell_size), color)
