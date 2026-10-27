class_name SimSerialize
extends RefCounted

const VERSION: int = 1


static func save_chunk(chunk: Chunk) -> Dictionary:
	var cells_data: Array[Dictionary] = []
	cells_data.resize(Chunk.CHUNK_SIZE * Chunk.CHUNK_SIZE)
	var idx: int = 0
	for y: int in range(Chunk.CHUNK_SIZE):
		for x: int in range(Chunk.CHUNK_SIZE):
			var c: Cell = chunk.get_cell(x, y)
			cells_data[idx] = {
				"mid": c.material_id,
				"s": c.suhu_c,
				"m": c.massa_kg,
				"f": c.fase,
			}
			idx += 1
	return {
		"version": VERSION,
		"coord": [chunk.coord.x, chunk.coord.y],
		"cells": cells_data,
	}


static func _migrate(version: int, _data: Dictionary) -> Dictionary:
	push_error("SimSerialize: versi skema tidak didukung (%d)" % version)
	return {}


static func load_chunk(data: Dictionary) -> Chunk:
	if not data.has("version"):
		push_error("SimSerialize: field 'version' hilang")
		return null

	var ver: int = int(data["version"])
	if ver != VERSION:
		var _migrated: Dictionary = _migrate(ver, data)
		return null

	if not data.has("coord") or not data.has("cells"):
		push_error("SimSerialize: field 'coord' atau 'cells' hilang")
		return null

	var coord_arr: Array = data["coord"] as Array
	if coord_arr.size() != 2:
		push_error("SimSerialize: format 'coord' tidak valid")
		return null

	var cells_arr: Array = data["cells"] as Array
	var expected_size: int = Chunk.CHUNK_SIZE * Chunk.CHUNK_SIZE
	if cells_arr.size() != expected_size:
		push_error("SimSerialize: jumlah sel (%d) tidak sesuai (%d)" % [cells_arr.size(), expected_size])
		return null

	var coord: Vector2i = Vector2i(int(coord_arr[0]), int(coord_arr[1]))
	var first_entry: Dictionary = cells_arr[0] as Dictionary
	var initial_cell: Cell = Cell.new(
		int(first_entry["mid"]),
		float(first_entry["s"]),
		float(first_entry["m"]),
		int(first_entry["f"])
	)
	initial_cell.last_moved_tick = -1
	var chunk: Chunk = Chunk.new(coord, initial_cell)

	var idx: int = 0
	for y: int in range(Chunk.CHUNK_SIZE):
		for x: int in range(Chunk.CHUNK_SIZE):
			var entry: Dictionary = cells_arr[idx] as Dictionary
			var cell: Cell = Cell.new(
				int(entry["mid"]),
				float(entry["s"]),
				float(entry["m"]),
				int(entry["f"])
			)
			cell.last_moved_tick = -1
			chunk.set_cell(x, y, cell)
			idx += 1

	return chunk
