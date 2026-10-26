extends RefCounted


func run() -> Dictionary:
	var total: int = 0
	var failed: int = 0

	total += 1
	var packed: PackedScene = load("res://game/main.tscn") as PackedScene
	if packed == null:
		push_error("test_smoke: res://game/main.tscn gagal dimuat (null)")
		failed += 1
		return {"total": total, "failed": failed}

	total += 1
	var root_node: Node = packed.instantiate()
	var label_node: Label = root_node.get_node_or_null("Label") as Label
	if label_node == null or label_node.text != "Zarah":
		push_error("test_smoke: Label 'Zarah' tidak ditemukan pada main.tscn")
		failed += 1

	root_node.free()
	return {"total": total, "failed": failed}
