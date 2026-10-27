extends RefCounted

const REG_LOADER = preload("res://tests/test_material_registry.gd")

const ID_UDARA: int = 0
const ID_STONE: int = 1
const ID_SAND: int = 2
const ID_WATER: int = 3


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_physics_gas: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func _make_udara() -> Cell:
	return Cell.new(ID_UDARA, 20.0, 0.0012, Cell.Fase.GAS)


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

	# 1. Satu udara (gas) di bawah permukaan water: (5, 10) udara, (5, 9) water, di atas dasar batu (5, 11).
	#    Di y=8 batu/tertutup sehingga hanya ada 1 sel water di (5, 9) tepat di atas udara (5, 10).
	#    Tick 1x -> udara naik ke (5, 9), water ke (5, 10).
	var w1: World = World.new(1, defaults, reg)
	var c1: Chunk = w1.chunk_at(Vector2i(0, 0))
	for y: int in range(8, 12):
		c1.set_cell(4, y, _make_stone())
		c1.set_cell(6, y, _make_stone())
	c1.set_cell(5, 8, _make_stone())
	c1.set_cell(5, 9, _make_water())
	c1.set_cell(5, 10, _make_udara())
	c1.set_cell(5, 11, _make_stone())

	w1.tick(World.TICK_DT)
	_assert_true(
		c1.get_cell(5, 9).material_id == ID_UDARA
		and c1.get_cell(5, 10).material_id == ID_WATER,
		"Tick 1x -> udara di (5,10) naik ke (5,9), water turun ke (5,10)",
		stats
	)

	# Kolom water lebih panjang: udara di (5, 20), water di (5, 15..19), wadah batu di y=14..21.
	# Setelah 20 tick, gelembung udara mencapai puncak kolom water (y=15).
	var w_col: World = World.new(1, defaults, reg)
	var c_col: Chunk = w_col.chunk_at(Vector2i(0, 0))
	for y: int in range(14, 22):
		c_col.set_cell(4, y, _make_stone())
		c_col.set_cell(6, y, _make_stone())
	c_col.set_cell(5, 21, _make_stone())
	for y: int in range(15, 20):
		c_col.set_cell(5, y, _make_water())
	c_col.set_cell(5, 20, _make_udara())

	for t: int in range(20):
		w_col.tick(World.TICK_DT)
	_assert_true(
		c_col.get_cell(5, 15).material_id == ID_UDARA
		and c_col.get_cell(5, 20).material_id == ID_WATER,
		"Setelah 20 tick, gelembung udara mencapai atas kolom water (y=15)",
		stats
	)

	# 2. Kontainer tertutup / atap batu:
	#    Dokumentasi perilaku aktual:
	#    Gelembung udara di (5, 11) terhalang batu tepat di atasnya (5, 9), namun ada
	#    water di diagonal atas (4, 9) dan (6, 9). Udara bergerak diagonal-up keluar
	#    ke ujung kolom water.
	var w2: World = World.new(1, defaults, reg)
	var c2: Chunk = w2.chunk_at(Vector2i(0, 0))
	for x: int in range(3, 8):
		c2.set_cell(x, 12, _make_stone())
	for y: int in range(8, 13):
		c2.set_cell(3, y, _make_stone())
		c2.set_cell(7, y, _make_stone())
	for x: int in range(4, 7):
		for y: int in range(9, 12):
			c2.set_cell(x, y, _make_water())
	c2.set_cell(5, 9, _make_stone())
	c2.set_cell(5, 11, _make_udara())

	for t: int in range(15):
		w2.tick(World.TICK_DT)
	_assert_true(
		c2.get_cell(4, 9).material_id == ID_UDARA
		or c2.get_cell(6, 9).material_id == ID_UDARA,
		"Gelembung udara yang terhalang batu di (5,9) harus keluar lewat diagonal-up ke ujung kolom water (y=9)",
		stats
	)

	# 3. Determinisme: 50 tick dengan 3 material bergerak (sand, water, udara) + stone, hash sama.
	var wa: World = World.new(42, defaults, reg)
	var wb: World = World.new(42, defaults, reg)
	var ca: Chunk = wa.chunk_at(Vector2i(0, 0))
	var cb: Chunk = wb.chunk_at(Vector2i(0, 0))
	for x: int in range(10, 21):
		ca.set_cell(x, 30, _make_stone())
		cb.set_cell(x, 30, _make_stone())
	for y: int in range(20, 31):
		ca.set_cell(10, y, _make_stone())
		cb.set_cell(10, y, _make_stone())
		ca.set_cell(20, y, _make_stone())
		cb.set_cell(20, y, _make_stone())
	for x: int in range(11, 20):
		for y: int in range(24, 29):
			ca.set_cell(x, y, _make_water())
			cb.set_cell(x, y, _make_water())
		ca.set_cell(x, 29, _make_udara())
		cb.set_cell(x, 29, _make_udara())
		ca.set_cell(x, 22, _make_sand())
		cb.set_cell(x, 22, _make_sand())
	for t: int in range(50):
		wa.tick(World.TICK_DT)
		wb.tick(World.TICK_DT)
	_assert_true(
		wa.state_hash() == wb.state_hash(),
		"Determinisme gas: dua World seed=42 identik dengan 3 material setelah 50 tick harus memiliki state_hash sama",
		stats
	)

	return stats
