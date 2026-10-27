extends RefCounted

const REG_LOADER = preload("res://tests/test_material_registry.gd")

const ID_UDARA: int = 0
const ID_STONE: int = 1
const ID_SAND: int = 2
const ID_WATER: int = 3


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_physics_liquid: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func _make_water() -> Cell:
	return Cell.new(ID_WATER, 20.0, 1.0, Cell.Fase.CAIR)


func _make_sand() -> Cell:
	return Cell.new(ID_SAND, 20.0, 1.6, Cell.Fase.PADAT)


func _make_stone() -> Cell:
	return Cell.new(ID_STONE, 20.0, 2.6, Cell.Fase.PADAT)


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}
	var defaults: Dictionary = {"suhu_ambient_c": 20.0, "material_udara_id": ID_UDARA}
	var reg: MaterialRegistry = REG_LOADER.load_real_registry()

	# 1. Satu water di (5,5) di atas udara. Tick 1x -> water di (5,6).
	var w1: World = World.new(1, defaults, reg)
	var c1: Chunk = w1.chunk_at(Vector2i(0, 0))
	c1.set_cell(5, 5, _make_water())
	w1.tick(World.TICK_DT)
	_assert_true(
		c1.get_cell(5, 6).material_id == ID_WATER
		and c1.get_cell(5, 5).material_id == ID_UDARA,
		"Satu water di (5,5) harus turun ke (5,6) setelah 1 tick",
		stats
	)

	# 2. Cek: setelah 20 tick dari y=50, water berhenti di dasar (y=63).
	var w2: World = World.new(1, defaults, reg)
	var c2: Chunk = w2.chunk_at(Vector2i(0, 0))
	c2.set_cell(5, 50, _make_water())
	for t: int in range(20):
		w2.tick(World.TICK_DT)
	var bottom_water_count: int = 0
	for x: int in range(Chunk.CHUNK_SIZE):
		if c2.get_cell(x, 63).material_id == ID_WATER:
			bottom_water_count += 1
	_assert_true(
		bottom_water_count == 1,
		"Setelah 20 tick, water harus berada di dasar (y=63)",
		stats
	)

	# 3. Basin: water 5x di baris y=5, kolom x=5..9, lantai batu di y=8 (atau dasar dekat).
	#    Gunakan lantai batu di y=8 agar dalam 10 tick semua water jatuh ke y=7 dan menyebar horizontal.
	var w3: World = World.new(1, defaults, reg)
	var c3: Chunk = w3.chunk_at(Vector2i(0, 0))
	for x: int in range(Chunk.CHUNK_SIZE):
		c3.set_cell(x, 8, _make_stone())
	for x: int in range(5, 10):
		c3.set_cell(x, 5, _make_water())
	# Tambah 1 water di (7, 4) supaya tumpukan menyebar horizontal di atas lantai y=7
	c3.set_cell(7, 4, _make_water())
	for t: int in range(10):
		w3.tick(World.TICK_DT)
	var water_on_floor: int = 0
	for x: int in range(Chunk.CHUNK_SIZE):
		if c3.get_cell(x, 7).material_id == ID_WATER:
			water_on_floor += 1
	_assert_true(
		water_on_floor == 6,
		"Semua water harus jatuh ke lantai basin dan menyebar horizontal di y=7",
		stats
	)

	# 4. Sand di atas water: water column di y=5..9 (di atas batu y=10), sand di y=4 di kolom sama.
	#    Tick 5x -> sand tenggelam melalui water (turun > 0, mencapai y > 4).
	var w4: World = World.new(1, defaults, reg)
	var c4: Chunk = w4.chunk_at(Vector2i(0, 0))
	c4.set_cell(5, 10, _make_stone())
	for y: int in range(5, 10):
		c4.set_cell(5, y, _make_water())
	c4.set_cell(5, 4, _make_sand())
	for t: int in range(5):
		w4.tick(World.TICK_DT)
	var sand_y: int = -1
	for y: int in range(Chunk.CHUNK_SIZE):
		for x: int in range(Chunk.CHUNK_SIZE):
			if c4.get_cell(x, y).material_id == ID_SAND:
				sand_y = y
	_assert_true(
		sand_y > 4,
		"Sand di atas water harus tenggelam melalui water (y > 4)",
		stats
	)

	# 5. Determinisme: dua World seed=42 identik dengan campuran, 50 tick, state_hash sama.
	var wa: World = World.new(42, defaults, reg)
	var wb: World = World.new(42, defaults, reg)
	var ca: Chunk = wa.chunk_at(Vector2i(0, 0))
	var cb: Chunk = wb.chunk_at(Vector2i(0, 0))
	for x: int in range(10, 20):
		ca.set_cell(x, 30, _make_stone())
		cb.set_cell(x, 30, _make_stone())
	for x: int in range(12, 18):
		ca.set_cell(x, 25, _make_water())
		cb.set_cell(x, 25, _make_water())
		ca.set_cell(x, 20, _make_sand())
		cb.set_cell(x, 20, _make_sand())
	for t: int in range(50):
		wa.tick(World.TICK_DT)
		wb.tick(World.TICK_DT)
	_assert_true(
		wa.state_hash() == wb.state_hash(),
		"Determinisme liquid: dua World seed=42 identik setelah 50 tick harus memiliki state_hash sama",
		stats
	)

	return stats
