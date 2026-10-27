extends RefCounted

const REG_LOADER = preload("res://tests/test_material_registry.gd")

const ID_UDARA: int = 0
const ID_STONE: int = 1
const ID_SAND: int = 2
const ID_WATER: int = 3


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_physics_powder: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func _make_sand() -> Cell:
	return Cell.new(ID_SAND, 20.0, 1.6, Cell.Fase.PADAT)


func _make_stone() -> Cell:
	return Cell.new(ID_STONE, 20.0, 2.6, Cell.Fase.PADAT)


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}
	var defaults: Dictionary = {"suhu_ambient_c": 20.0, "material_udara_id": ID_UDARA}
	var reg: MaterialRegistry = REG_LOADER.load_real_registry()

	# 1. Satu sand di (5,5), sel lain udara. Tick 1x -> sand di (5,6), (5,5) udara.
	var w1: World = World.new(1, defaults, reg)
	var c1: Chunk = w1.chunk_at(Vector2i(0, 0))
	c1.set_cell(5, 5, _make_sand())
	w1.tick(World.TICK_DT)
	_assert_true(
		c1.get_cell(5, 6).material_id == ID_SAND
		and c1.get_cell(5, 5).material_id == ID_UDARA,
		"Satu sand di (5,5) harus jatuh ke (5,6) setelah 1 tick",
		stats
	)

	# 2. Kolom 5 sand di y=5..9. Tick 1x -> semua sand bergeser ke y=6..10 (turun 1, bukan cascade).
	var w2: World = World.new(1, defaults, reg)
	var c2: Chunk = w2.chunk_at(Vector2i(0, 0))
	for y: int in range(5, 10):
		c2.set_cell(5, y, _make_sand())
	w2.tick(World.TICK_DT)
	var col_ok: bool = c2.get_cell(5, 5).material_id == ID_UDARA and c2.get_cell(5, 11).material_id == ID_UDARA
	for y: int in range(6, 11):
		if c2.get_cell(5, y).material_id != ID_SAND:
			col_ok = false
			break
	_assert_true(
		col_ok,
		"Kolom 5 sand di y=5..9 harus bergeser ke y=6..10 setelah 1 tick",
		stats
	)

	# 3. Sand di tepi bawah chunk (y=63): tidak bisa jatuh, tetap di y=63.
	var w3: World = World.new(1, defaults, reg)
	var c3: Chunk = w3.chunk_at(Vector2i(0, 0))
	c3.set_cell(10, 63, _make_sand())
	w3.tick(World.TICK_DT)
	_assert_true(
		c3.get_cell(10, 63).material_id == ID_SAND,
		"Sand di dasar chunk (y=63) harus tetap di y=63",
		stats
	)

	# 4. Determinisme: dua World seed=42 identik, 50 tick, state_hash sama.
	var wa: World = World.new(42, defaults, reg)
	var wb: World = World.new(42, defaults, reg)
	var ca: Chunk = wa.chunk_at(Vector2i(0, 0))
	var cb: Chunk = wb.chunk_at(Vector2i(0, 0))
	for i: int in range(10):
		ca.set_cell(15, 5 + i, _make_sand())
		cb.set_cell(15, 5 + i, _make_sand())
	ca.set_cell(15, 20, _make_stone())
	cb.set_cell(15, 20, _make_stone())
	for t: int in range(50):
		wa.tick(World.TICK_DT)
		wb.tick(World.TICK_DT)
	_assert_true(
		wa.state_hash() == wb.state_hash(),
		"Determinisme powder: dua World seed=42 identik setelah 50 tick harus memiliki state_hash sama",
		stats
	)

	return stats
