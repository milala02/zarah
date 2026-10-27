extends RefCounted


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_serialize: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}

	var def_cell: Cell = Cell.new(0, 20.0, 0.0, Cell.Fase.PADAT)
	var chunk: Chunk = Chunk.new(Vector2i(-1, 3), def_cell)
	chunk.set_cell(5, 5, Cell.new(7, 99.5, 12.25, Cell.Fase.CAIR))

	var saved: Dictionary = SimSerialize.save_chunk(chunk)
	var loaded: Chunk = SimSerialize.load_chunk(saved)

	_assert_true(loaded != null, "load_chunk untuk versi 1 harus mengembalikan Chunk valid", stats)
	if loaded != null:
		_assert_true(loaded.coord == chunk.coord, "coord hasil load_chunk harus sama dengan chunk asli", stats)
		var all_equal: bool = true
		for y: int in range(Chunk.CHUNK_SIZE):
			for x: int in range(Chunk.CHUNK_SIZE):
				if not loaded.get_cell(x, y).equals(chunk.get_cell(x, y)):
					all_equal = false
					break
			if not all_equal:
				break
		_assert_true(all_equal, "semua sel (x, y) hasil load_chunk harus equals dengan chunk asli", stats)

	# Version mismatch: saved["version"] = 999 -> push_error, return null
	var bad_saved: Dictionary = saved.duplicate(true)
	bad_saved["version"] = 999
	var bad_loaded: Chunk = SimSerialize.load_chunk(bad_saved)
	_assert_true(bad_loaded == null, "load_chunk dengan version=999 harus mengembalikan null", stats)

	return stats
