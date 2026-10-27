extends RefCounted

const REG_LOADER = preload("res://tests/test_material_registry.gd")

const ID_UDARA: int = 0
const ID_STONE: int = 1
const ID_SAND: int = 2
const ID_WATER: int = 3


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_physics_integration: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func _make_cell(id_num: int, phase: int, mass: float) -> Cell:
	return Cell.new(id_num, 20.0, mass, phase)


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}
	var defaults: Dictionary = {"suhu_ambient_c": 20.0, "material_udara_id": ID_UDARA}
	var reg: MaterialRegistry = REG_LOADER.load_real_registry()

	# 1. Skenario: wadah batu, kolom air di tengah, sand di atas, udara terperangkap di bawah.
	#    100 tick dengan seed 42 -> hash dicatat. Ulangi -> hash identik.
	var build_scenario: Callable = func(w: World) -> void:
		var c: Chunk = w.chunk_at(Vector2i(0, 0))
		for x: int in range(15, 30):
			c.set_cell(x, 40, _make_cell(ID_STONE, Cell.Fase.PADAT, 2.6))
		for y: int in range(20, 41):
			c.set_cell(15, y, _make_cell(ID_STONE, Cell.Fase.PADAT, 2.6))
			c.set_cell(29, y, _make_cell(ID_STONE, Cell.Fase.PADAT, 2.6))
		for x: int in range(16, 29):
			for y: int in range(30, 39):
				c.set_cell(x, y, _make_cell(ID_WATER, Cell.Fase.CAIR, 1.0))
			c.set_cell(x, 39, _make_cell(ID_UDARA, Cell.Fase.GAS, 0.0012))
			for y: int in range(22, 28):
				c.set_cell(x, y, _make_cell(ID_SAND, Cell.Fase.PADAT, 1.6))

	var w1: World = World.new(42, defaults, reg)
	build_scenario.call(w1)
	for t: int in range(100):
		w1.tick(World.TICK_DT)
	var hash1: String = w1.state_hash()

	var w2: World = World.new(42, defaults, reg)
	build_scenario.call(w2)
	for t: int in range(100):
		w2.tick(World.TICK_DT)
	var hash2: String = w2.state_hash()

	_assert_true(
		hash1 == hash2,
		"Integrasi determinisme 100 tick: dua World identik harus menghasilkan state_hash identik",
		stats
	)

	# 2. Order independence chunk: buat chunk (0,0) dulu vs (1,0) dulu ->
	#    setelah 50 tick, gabungan state_hash kedua chunk sama.
	var wa: World = World.new(42, defaults, reg)
	var ca0: Chunk = wa.chunk_at(Vector2i(0, 0))
	var ca1: Chunk = wa.chunk_at(Vector2i(1, 0))
	ca0.set_cell(10, 10, _make_cell(ID_SAND, Cell.Fase.PADAT, 1.6))
	ca1.set_cell(20, 20, _make_cell(ID_WATER, Cell.Fase.CAIR, 1.0))
	for t: int in range(50):
		wa.tick(World.TICK_DT)

	var wb: World = World.new(42, defaults, reg)
	var cb1: Chunk = wb.chunk_at(Vector2i(1, 0))
	var cb0: Chunk = wb.chunk_at(Vector2i(0, 0))
	cb0.set_cell(10, 10, _make_cell(ID_SAND, Cell.Fase.PADAT, 1.6))
	cb1.set_cell(20, 20, _make_cell(ID_WATER, Cell.Fase.CAIR, 1.0))
	for t: int in range(50):
		wb.tick(World.TICK_DT)

	_assert_true(
		wa.state_hash() == wb.state_hash(),
		"Order independence chunk: urutan instansiasi (0,0) vs (1,0) tidak memengaruhi state_hash setelah 50 tick",
		stats
	)

	return stats
