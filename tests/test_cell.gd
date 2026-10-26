extends RefCounted


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_cell: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}

	var c0: Cell = Cell.new(0, 20.0, 0.0, Cell.Fase.PADAT)
	_assert_true(c0.material_id == 0, "material_id harus 0", stats)
	_assert_true(is_equal_approx(c0.suhu_c, 20.0), "suhu_c harus 20.0", stats)
	_assert_true(is_equal_approx(c0.massa_kg, 0.0), "massa_kg harus 0.0", stats)
	_assert_true(c0.fase == Cell.Fase.PADAT, "fase harus PADAT", stats)

	var a1: Cell = Cell.new(1, 5.0, 10.0, Cell.Fase.CAIR)
	var a2: Cell = Cell.new(1, 5.0, 10.0, Cell.Fase.CAIR)
	var diff_mat: Cell = Cell.new(2, 5.0, 10.0, Cell.Fase.CAIR)
	var diff_suhu: Cell = Cell.new(1, 6.0, 10.0, Cell.Fase.CAIR)
	var diff_massa: Cell = Cell.new(1, 5.0, 11.0, Cell.Fase.CAIR)
	var diff_fase: Cell = Cell.new(1, 5.0, 10.0, Cell.Fase.GAS)
	var dup: Cell = a1.duplicate_cell()

	_assert_true(
		(
			a1.equals(a2)
			and a1.equals(dup)
			and not a1.equals(diff_mat)
			and not a1.equals(diff_suhu)
			and not a1.equals(diff_massa)
			and not a1.equals(diff_fase)
		),
		"equals harus true untuk nilai identik dan false untuk field berbeda",
		stats
	)

	return stats
