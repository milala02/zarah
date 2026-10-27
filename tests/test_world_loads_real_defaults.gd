extends RefCounted


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_world_loads_real_defaults: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}

	var path: String = "res://data/sim_defaults.json"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	_assert_true(file != null, "FileAccess harus berhasil membuka " + path, stats)
	if file == null:
		return stats

	var raw_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	_assert_true(
		parsed is Dictionary,
		"JSON.parse_string pada sim_defaults.json harus menghasilkan Dictionary",
		stats
	)
	if not (parsed is Dictionary):
		return stats

	var defaults: Dictionary = parsed as Dictionary
	var world: World = World.new(100, defaults)
	var chunk: Chunk = world.chunk_at(Vector2i(0, 0))
	world.tick(World.TICK_DT)

	var sample_cell: Cell = chunk.get_cell(0, 0)
	_assert_true(
		world.tick_count == 1
		and sample_cell.material_id == int(defaults["material_udara_id"])
		and is_equal_approx(sample_cell.suhu_c, float(defaults["suhu_ambient_c"]))
		and sample_cell.fase == Cell.Fase.PADAT
		and world.state_hash().length() == 64,
		"World dengan data/sim_defaults.json asli harus berjalan dan menghasilkan state_hash valid",
		stats
	)

	return stats
