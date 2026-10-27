extends RefCounted


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_world: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}
	var defaults: Dictionary = {"suhu_ambient_c": 20.0, "material_udara_id": 0}

	# 1. chunk_at(Vector2i(0,0)) -> semua sel material_id==0, suhu_c==20.0, fase==Cell.Fase.GAS
	var w0: World = World.new(42, defaults)
	var c00: Chunk = w0.chunk_at(Vector2i(0, 0))
	var all_default: bool = true
	for y: int in range(Chunk.CHUNK_SIZE):
		for x: int in range(Chunk.CHUNK_SIZE):
			var cell: Cell = c00.get_cell(x, y)
			if (
				cell.material_id != 0
				or not is_equal_approx(cell.suhu_c, 20.0)
				or not is_equal_approx(cell.massa_kg, 0.0)
				or cell.fase != Cell.Fase.GAS
			):
				all_default = false
				break
		if not all_default:
			break
	_assert_true(
		all_default,
		"chunk_at(0,0) harus berisi sel default (material_id=0, suhu_c=20.0, fase=GAS)",
		stats
	)

	# 2. Determinisme A: seed sama + 100 tick -> state_hash() identik
	var w1: World = World.new(42, defaults)
	var w2: World = World.new(42, defaults)
	for i: int in range(100):
		w1.tick(World.TICK_DT)
		w2.tick(World.TICK_DT)
	_assert_true(
		w1.state_hash() == w2.state_hash(),
		"Determinisme A: dua World ber-seed 42 setelah 100 tick harus memiliki state_hash identik",
		stats
	)

	# 3. Determinisme B: seed berbeda + 100 tick -> state_hash() berbeda
	var w3: World = World.new(43, defaults)
	for i: int in range(100):
		w3.tick(World.TICK_DT)
	_assert_true(
		w3.state_hash() != w1.state_hash(),
		"Determinisme B: World ber-seed 43 harus memiliki state_hash berbeda dari seed 42",
		stats
	)

	# 4. Order-independence chunk: urutan pembuatan chunk (0,0)->(1,0) vs (1,0)->(0,0)
	var w_a: World = World.new(42, defaults)
	w_a.chunk_at(Vector2i(0, 0))
	w_a.chunk_at(Vector2i(1, 0))
	for i: int in range(10):
		w_a.tick(World.TICK_DT)

	var w_b: World = World.new(42, defaults)
	w_b.chunk_at(Vector2i(1, 0))
	w_b.chunk_at(Vector2i(0, 0))
	for i: int in range(10):
		w_b.tick(World.TICK_DT)

	_assert_true(
		w_a.state_hash() == w_b.state_hash(),
		"Order-independence: urutan pembuatan chunk tidak boleh memengaruhi state_hash",
		stats
	)

	return stats
