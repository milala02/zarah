extends RefCounted

const REG_LOADER = preload("res://tests/test_material_registry.gd")

const ID_UDARA: int = 0
const ID_STONE: int = 1
const ID_SAND: int = 2
const ID_WATER: int = 3


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_benchmark: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}
	var defaults: Dictionary = {"suhu_ambient_c": 20.0, "material_udara_id": ID_UDARA}
	var reg: MaterialRegistry = REG_LOADER.load_real_registry()

	var world: World = World.new(42, defaults, reg)
	var chunk: Chunk = world.chunk_at(Vector2i(0, 0))

	# Isi lantai batu di y=63
	for x: int in range(Chunk.CHUNK_SIZE):
		chunk.set_cell(x, 63, Cell.new(ID_STONE, 20.0, 2.6, Cell.Fase.PADAT))

	# Buat ~1000 sel aktif campuran sand (500) dan water (500)
	var active_count: int = 0
	for y: int in range(10, 30):
		for x: int in range(10, 60):
			if (x + y) % 2 == 0 and active_count < 500:
				chunk.set_cell(x, y, Cell.new(ID_SAND, 20.0, 1.6, Cell.Fase.PADAT))
				active_count += 1
			elif (x + y) % 2 == 1 and active_count < 1000:
				chunk.set_cell(x, y, Cell.new(ID_WATER, 20.0, 1.0, Cell.Fase.CAIR))
				active_count += 1

	var start_usec: int = Time.get_ticks_usec()
	var total_ticks: int = 100
	for t: int in range(total_ticks):
		world.tick(World.TICK_DT)
	var end_usec: int = Time.get_ticks_usec()

	var total_ms: float = float(end_usec - start_usec) / 1000.0
	var avg_ms: float = total_ms / float(total_ticks)

	print("Benchmark avg: %.3f ms/tick (total: %.2f ms / %d ticks)" % [avg_ms, total_ms, total_ticks])

	_assert_true(
		avg_ms < 50.0,
		"Rata-rata simulasi harus < 50.0 ms/tick (aktual: %.3f ms/tick)" % avg_ms,
		stats
	)

	return stats
