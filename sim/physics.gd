class_name Physics
extends RefCounted

const DIR_DOWN: int = 0
const DIR_UP: int = 1


static func apply_chunk(chunk: Chunk, registry: MaterialRegistry, tick_count: int) -> void:
	var preferred: int = -1 if (tick_count % 2 == 0) else 1
	for y: int in range(Chunk.CHUNK_SIZE - 1, -1, -1):
		for x: int in range(Chunk.CHUNK_SIZE):
			var cell: Cell = chunk.get_cell(x, y)
			if cell.last_moved_tick == tick_count:
				continue
			var kind: int = registry.get_physics_kind(cell.material_id)
			if kind == MaterialRegistry.KIND_POWDER:
				_step_powder(chunk, registry, x, y, preferred, tick_count)


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
	if not _in_chunk(x2, y2):
		return false
	var src: Cell = chunk.get_cell(x1, y1)
	var dst: Cell = chunk.get_cell(x2, y2)
	if not _can_swap(src, dst, direction, registry, tick_count):
		return false
	swap_cells(chunk, x1, y1, x2, y2, tick_count)
	return true


static func _in_chunk(x: int, y: int) -> bool:
	return x >= 0 and x < Chunk.CHUNK_SIZE and y >= 0 and y < Chunk.CHUNK_SIZE


static func _can_swap(
	src: Cell,
	dst: Cell,
	direction: int,
	registry: MaterialRegistry,
	tick_count: int
) -> bool:
	var dst_kind: int = registry.get_physics_kind(dst.material_id)
	if dst_kind == MaterialRegistry.KIND_STATIC:
		return false
	if src.last_moved_tick == tick_count:
		return false
	if dst.last_moved_tick == tick_count:
		return false
	var src_density: float = registry.get_density(src.material_id)
	var dst_density: float = registry.get_density(dst.material_id)
	if direction == DIR_DOWN:
		return dst_density < src_density
	if direction == DIR_UP:
		return dst_density > src_density
	return false


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
	# Alasan: iterasi bottom-up menjamin src yang bergerak ke bawah
	# sudah melewati posisi tujuan, dan src yang bergerak ke atas
	# (gas) sudah ditandai sehingga tidak akan diproses lagi.
	var c1: Cell = chunk.get_cell(x1, y1).duplicate_cell()
	var c2: Cell = chunk.get_cell(x2, y2).duplicate_cell()
	c1.last_moved_tick = tick_count
	chunk.set_cell(x1, y1, c2)
	chunk.set_cell(x2, y2, c1)
