class_name Physics
extends RefCounted

const DIR_DOWN: int = 0
const DIR_UP: int = 1


static func apply_chunk(chunk: Chunk, registry: MaterialRegistry, tick_count: int) -> void:
	apply_chunk_kind(chunk, registry, tick_count, MaterialRegistry.KIND_POWDER)
	apply_chunk_kind(chunk, registry, tick_count, MaterialRegistry.KIND_LIQUID)
	apply_chunk_kind(chunk, registry, tick_count, MaterialRegistry.KIND_GAS)


static func apply_chunk_kind(
	chunk: Chunk,
	registry: MaterialRegistry,
	tick_count: int,
	target_kind: int
) -> void:
	var preferred: int = -1 if (tick_count % 2 == 0) else 1
	var cells: Array = chunk._cells
	var kinds: Dictionary = registry._kinds
	for y: int in range(Chunk.CHUNK_SIZE - 1, -1, -1):
		var y_offset: int = y * Chunk.CHUNK_SIZE
		for x: int in range(Chunk.CHUNK_SIZE):
			var cell: Cell = cells[y_offset + x] as Cell
			if cell.last_moved_tick == tick_count:
				continue
			var kind: int = int(kinds.get(cell.material_id, MaterialRegistry.KIND_STATIC))
			if kind != target_kind:
				continue

			if kind == MaterialRegistry.KIND_POWDER:
				_step_powder(chunk, registry, x, y, preferred, tick_count)
			elif kind == MaterialRegistry.KIND_LIQUID:
				_step_liquid(chunk, registry, x, y, preferred, tick_count)
			elif kind == MaterialRegistry.KIND_GAS:
				_step_gas(chunk, registry, x, y, preferred, tick_count)


static func _step_powder(
	chunk: Chunk,
	registry: MaterialRegistry,
	x: int,
	y: int,
	preferred: int,
	tick_count: int
) -> void:
	if _try_move(chunk, registry, x, y, x, y + 1, DIR_DOWN, tick_count):
		return
	if _try_move(chunk, registry, x, y, x + preferred, y + 1, DIR_DOWN, tick_count):
		return
	_try_move(chunk, registry, x, y, x - preferred, y + 1, DIR_DOWN, tick_count)


static func _step_liquid(
	chunk: Chunk,
	registry: MaterialRegistry,
	x: int,
	y: int,
	preferred: int,
	tick_count: int
) -> void:
	if _try_move(chunk, registry, x, y, x, y + 1, DIR_DOWN, tick_count):
		return
	if _try_move(chunk, registry, x, y, x + preferred, y + 1, DIR_DOWN, tick_count):
		return
	if _try_move(chunk, registry, x, y, x - preferred, y + 1, DIR_DOWN, tick_count):
		return
	if not _can_spread_sideways(chunk, registry, x, y):
		return
	if _try_move(chunk, registry, x, y, x + preferred, y, DIR_DOWN, tick_count):
		return
	_try_move(chunk, registry, x, y, x - preferred, y, DIR_DOWN, tick_count)


static func _step_gas(
	chunk: Chunk,
	registry: MaterialRegistry,
	x: int,
	y: int,
	preferred: int,
	tick_count: int
) -> void:
	if _try_move(chunk, registry, x, y, x, y - 1, DIR_UP, tick_count):
		return
	if _try_move(chunk, registry, x, y, x + preferred, y - 1, DIR_UP, tick_count):
		return
	_try_move(chunk, registry, x, y, x - preferred, y - 1, DIR_UP, tick_count)


static func _can_spread_sideways(
	chunk: Chunk,
	registry: MaterialRegistry,
	x: int,
	y: int
) -> bool:
	if y - 1 < 0:
		return true
	var above: Cell = chunk._cells[(y - 1) * Chunk.CHUNK_SIZE + x] as Cell
	var above_kind: int = int(registry._kinds.get(above.material_id, MaterialRegistry.KIND_STATIC))
	return (
		above_kind == MaterialRegistry.KIND_LIQUID
		or above_kind == MaterialRegistry.KIND_GAS
	)


static func _try_move(
	chunk: Chunk,
	registry: MaterialRegistry,
	x1: int,
	y1: int,
	x2: int,
	y2: int,
	direction: int,
	tick_count: int
) -> bool:
	if not (x2 >= 0 and x2 < Chunk.CHUNK_SIZE and y2 >= 0 and y2 < Chunk.CHUNK_SIZE):
		return false
	var cells: Array = chunk._cells
	var idx1: int = y1 * Chunk.CHUNK_SIZE + x1
	var idx2: int = y2 * Chunk.CHUNK_SIZE + x2
	var src: Cell = cells[idx1] as Cell
	var dst: Cell = cells[idx2] as Cell

	if src.last_moved_tick == tick_count or dst.last_moved_tick == tick_count:
		return false

	var dst_kind: int = int(registry._kinds.get(dst.material_id, MaterialRegistry.KIND_STATIC))
	if dst_kind == MaterialRegistry.KIND_STATIC:
		return false

	var src_density: float = float(registry._densities.get(src.material_id, 0.0))
	var dst_density: float = float(registry._densities.get(dst.material_id, 0.0))
	if direction == DIR_DOWN:
		if dst_density >= src_density:
			return false
	elif direction == DIR_UP:
		if dst_density <= src_density:
			return false
	else:
		return false

	# In-place swap of cell fields to eliminate 2 full object instantiations per move
	var tmp_mid: int = src.material_id
	var tmp_suhu: float = src.suhu_c
	var tmp_massa: float = src.massa_kg
	var tmp_fase: int = src.fase

	src.material_id = dst.material_id
	src.suhu_c = dst.suhu_c
	src.massa_kg = dst.massa_kg
	src.fase = dst.fase
	# dst is not marked moved
	src.last_moved_tick = dst.last_moved_tick

	dst.material_id = tmp_mid
	dst.suhu_c = tmp_suhu
	dst.massa_kg = tmp_massa
	dst.fase = tmp_fase
	dst.last_moved_tick = tick_count

	chunk._dirty = true
	return true


static func swap_cells(
	chunk: Chunk,
	x1: int,
	y1: int,
	x2: int,
	y2: int,
	tick_count: int
) -> void:
	# Hanya src yang ditandai. dst (yang terdesak) tidak — sehingga
	# kolom material sejenis dapat jatuh bersama 1 sel per tick.
	var cells: Array = chunk._cells
	var idx1: int = y1 * Chunk.CHUNK_SIZE + x1
	var idx2: int = y2 * Chunk.CHUNK_SIZE + x2
	var c1: Cell = (cells[idx1] as Cell).duplicate_cell()
	var c2: Cell = (cells[idx2] as Cell).duplicate_cell()
	c1.last_moved_tick = tick_count
	cells[idx1] = c2
	cells[idx2] = c1
	chunk._dirty = true
