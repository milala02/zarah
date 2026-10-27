extends RefCounted

const MATERIAL_FILES: Array[String] = [
	"res://data/materials/udara.json",
	"res://data/materials/stone.json",
	"res://data/materials/sand.json",
	"res://data/materials/water.json",
]


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_material_registry: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


static func load_real_registry() -> MaterialRegistry:
	var materials: Dictionary = {}
	for path: String in MATERIAL_FILES:
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var raw: String = file.get_as_text()
		file.close()
		var parsed: Variant = JSON.parse_string(raw)
		if parsed is Dictionary:
			var entry: Dictionary = parsed as Dictionary
			var id_str: String = str(entry.get("id", ""))
			materials[id_str] = entry
	return MaterialRegistry.from_dict(materials)


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}
	var reg: MaterialRegistry = load_real_registry()

	# 1. has(0..3) true; has(999) false
	_assert_true(
		reg.has(0) and reg.has(1) and reg.has(2) and reg.has(3) and not reg.has(999),
		"has(0..3) harus true dan has(999) harus false",
		stats
	)

	# 2. get_physics_kind(0..3)
	_assert_true(
		reg.get_physics_kind(0) == MaterialRegistry.KIND_GAS
		and reg.get_physics_kind(1) == MaterialRegistry.KIND_STATIC
		and reg.get_physics_kind(2) == MaterialRegistry.KIND_POWDER
		and reg.get_physics_kind(3) == MaterialRegistry.KIND_LIQUID,
		"get_physics_kind(0..3) harus sesuai (GAS, STATIC, POWDER, LIQUID)",
		stats
	)

	# 3. get_density(0..3)
	_assert_true(
		is_equal_approx(reg.get_density(0), 1.2)
		and is_equal_approx(reg.get_density(1), 2600.0)
		and is_equal_approx(reg.get_density(2), 1600.0)
		and is_equal_approx(reg.get_density(3), 1000.0),
		"get_density(0..3) harus sesuai (1.2, 2600.0, 1600.0, 1000.0)",
		stats
	)

	# 4. Unknown ID -> push_error, return nilai aman (KIND_STATIC, density 0.0), tidak crash
	var unknown_kind: int = reg.get_physics_kind(999)
	var unknown_density: float = reg.get_density(999)
	_assert_true(
		unknown_kind == MaterialRegistry.KIND_STATIC
		and is_equal_approx(unknown_density, 0.0),
		"ID tidak dikenal harus mengembalikan KIND_STATIC dan density 0.0",
		stats
	)

	return stats
