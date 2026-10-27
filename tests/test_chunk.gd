extends RefCounted


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_chunk: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}

	var def_cell: Cell = Cell.new(0, 20.0, 0.0, Cell.Fase.PADAT)
	var chunk: Chunk = Chunk.new(Vector2i(0, 0), def_cell)

	# 1. Ukuran benar (CHUNK_SIZE * CHUNK_SIZE) dan nilai awal sesuai default_cell
	_assert_true(
		chunk._cells.size() == Chunk.CHUNK_SIZE * Chunk.CHUNK_SIZE
		and chunk.get_cell(0, 0).equals(def_cell)
		and chunk.get_cell(63, 63).equals(def_cell),
		"Chunk harus berukuran 64x64 dan terinisialisasi dengan default_cell",
		stats
	)

	# 2. set_cell(x, y, c) lalu get_cell(x, y).equals(c)
	var custom_cell: Cell = Cell.new(3, 85.5, 12.0, Cell.Fase.CAIR)
	chunk.set_cell(10, 20, custom_cell)
	_assert_true(
		chunk.get_cell(10, 20).equals(custom_cell),
		"get_cell(10, 20) harus mengembalikan sel yang di-set",
		stats
	)

	# 3. Setelah set_cell, is_dirty() == true. Setelah mark_clean(), false.
	_assert_true(chunk.is_dirty(), "is_dirty() harus true setelah set_cell", stats)
	chunk.mark_clean()
	_assert_true(not chunk.is_dirty(), "is_dirty() harus false setelah mark_clean()", stats)
	chunk.set_cell(1, 1, custom_cell)
	_assert_true(chunk.is_dirty(), "is_dirty() harus kembali true setelah set_cell berikutnya", stats)

	# 4. get_cell & set_cell di luar batas -> push_error dipanggil, tidak crash,
	#    dan get_cell mengembalikan salinan default_cell (didokumentasikan).
	chunk.mark_clean()
	var oob_neg: Cell = chunk.get_cell(-1, 0)
	var oob_pos: Cell = chunk.get_cell(0, Chunk.CHUNK_SIZE)
	chunk.set_cell(Chunk.CHUNK_SIZE, 0, custom_cell)
	_assert_true(
		oob_neg != null
		and oob_neg.equals(def_cell)
		and oob_pos != null
		and oob_pos.equals(def_cell)
		and not chunk.is_dirty(),
		"get_cell/set_cell di luar batas tidak boleh crash, mengembalikan default_cell, dan tidak mengubah state",
		stats
	)

	return stats
