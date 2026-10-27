extends SceneTree

const EXPECTED_CLASSES: Array[String] = [
	"Cell",
	"Rng",
	"Chunk",
	"World",
]

const TESTS: Array[String] = [
	"res://tests/test_smoke.gd",
	"res://tests/test_cell.gd",
	"res://tests/test_rng.gd",
	"res://tests/test_chunk.gd",
	"res://tests/test_world.gd",
	"res://tests/test_world_loads_real_defaults.gd",
]


func _has_all_global_classes() -> bool:
	var registered: Array[Dictionary] = ProjectSettings.get_global_class_list()
	var names: Array[String] = []
	for item: Dictionary in registered:
		names.append(str(item.get("class", "")))
	for expected: String in EXPECTED_CLASSES:
		if not names.has(expected):
			return false
	return true


func _init() -> void:
	if not _has_all_global_classes():
		var import_exit: int = OS.execute(
			OS.get_executable_path(), ["--headless", "--path", ".", "--import"]
		)
		if import_exit != 0:
			push_error("Gagal menjalankan --import untuk registrasi class_name")
			quit(1)
			return
		var sub_out: Array = []
		var sub_exit: int = OS.execute(
			OS.get_executable_path(),
			["--headless", "--path", ".", "-s", "res://tests/run_tests.gd"],
			sub_out,
			true
		)
		for line: Variant in sub_out:
			print(str(line).strip_edges(false, true))
		quit(sub_exit)
		return

	var total: int = 0
	var failed: int = 0

	for test_path: String in TESTS:
		var script: GDScript = load(test_path) as GDScript
		if script == null or not script.can_instantiate():
			push_error("Gagal memuat skrip tes: " + test_path)
			total += 1
			failed += 1
			continue

		var suite: RefCounted = script.new() as RefCounted
		var result: Dictionary = suite.call("run") as Dictionary
		var suite_total: int = int(result.get("total", 0))
		var suite_failed: int = int(result.get("failed", 0))
		total += suite_total
		failed += suite_failed

	print("Total: %d, Failed: %d" % [total, failed])
	quit(1 if failed > 0 else 0)
