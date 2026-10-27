class_name Chunk
extends RefCounted

const CHUNK_SIZE: int = 64

var coord: Vector2i
var _cells: Array
var _dirty: bool
var _default_cell: Cell


func _init(p_coord: Vector2i, default_cell: Cell) -> void:
	coord = p_coord
	_default_cell = default_cell.duplicate_cell()
	_cells = []
	_cells.resize(CHUNK_SIZE * CHUNK_SIZE)
	for i: int in range(_cells.size()):
		_cells[i] = default_cell.duplicate_cell()
	_dirty = true


func get_cell(x: int, y: int) -> Cell:
	_check_bounds(x, y)
	if not _in_bounds(x, y):
		return _default_cell.duplicate_cell()
	return _cells[y * CHUNK_SIZE + x] as Cell


func set_cell(x: int, y: int, cell: Cell) -> void:
	_check_bounds(x, y)
	if not _in_bounds(x, y):
		return
	_cells[y * CHUNK_SIZE + x] = cell.duplicate_cell()
	_dirty = true


func is_dirty() -> bool:
	return _dirty


func mark_clean() -> void:
	_dirty = false


func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE


func _check_bounds(x: int, y: int) -> void:
	if not _in_bounds(x, y):
		push_error("Chunk: koordinat di luar batas (%d, %d)" % [x, y])
		return
