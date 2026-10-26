extends SceneTree

const TESTS: Array[String] = [
	"res://tests/test_smoke.gd",
]


func _init() -> void:
	var total: int = 0
	var failed: int = 0

	for test_path: String in TESTS:
		var script: GDScript = load(test_path) as GDScript
		if script == null:
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
