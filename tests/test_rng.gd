extends RefCounted


func _assert_true(cond: bool, msg: String, stats: Dictionary) -> void:
	stats["total"] = int(stats["total"]) + 1
	if not cond:
		push_error("test_rng: " + msg)
		stats["failed"] = int(stats["failed"]) + 1


func run() -> Dictionary:
	var stats: Dictionary = {"total": 0, "failed": 0}

	# 1. Cross-check 5 nilai pertama SplitMix64 seed=42 terhadap referensi Python
	var ref_rng: Rng = Rng.new(42)
	var expected_s64: Array[int] = [
		-4767286540954276203,
		2949826092126892291,
		5139283748462763858,
		6349198060258255764,
		701532786141963250,
	]
	var ref_match: bool = true
	for exp_val: int in expected_s64:
		if ref_rng.next_u64() != exp_val:
			ref_match = false
	_assert_true(ref_match, "SplitMix64 seed=42 harus cocok dengan vektor referensi", stats)

	# 2. Determinisme: 1000 panggilan next_u64() dari Rng.new(42) identik
	var r1: Rng = Rng.new(42)
	var r2: Rng = Rng.new(42)
	var seq_equal: bool = true
	for i: int in range(1000):
		if r1.next_u64() != r2.next_u64():
			seq_equal = false
			break
	_assert_true(seq_equal, "1000 nilai pertama Rng(42) harus identik", stats)

	# 3. Seed berbeda: Rng(42) dan Rng(43) 100 angka pertama tidak identik
	var r_a: Rng = Rng.new(42)
	var r_b: Rng = Rng.new(43)
	var diff_count: int = 0
	for i: int in range(100):
		if r_a.next_u64() != r_b.next_u64():
			diff_count += 1
	_assert_true(diff_count == 100, "Rng(42) dan Rng(43) harus menghasilkan urutan berbeda", stats)

	# 4. next_float_01() selalu dalam [0.0, 1.0)
	var r_f: Rng = Rng.new(12345)
	var bounds_ok: bool = true
	for i: int in range(1000):
		var val: float = r_f.next_float_01()
		if val < 0.0 or val >= 1.0:
			bounds_ok = false
			break
	_assert_true(bounds_ok, "next_float_01() harus selalu berada di [0.0, 1.0)", stats)

	# 5. fork(7): tidak mengubah state induk, berbeda dari induk, deterministik dari induk ber-seed sama
	var parent1: Rng = Rng.new(42)
	var parent2: Rng = Rng.new(42)
	var state_before: int = parent1._state
	var child1: Rng = parent1.fork(7)
	var child2: Rng = parent2.fork(7)
	_assert_true(parent1._state == state_before, "fork() tidak boleh mengubah _state induk", stats)

	var child_matches_other_child: bool = true
	var child_differs_from_parent: bool = false
	for i: int in range(50):
		var c1_val: int = child1.next_u64()
		var c2_val: int = child2.next_u64()
		var p_val: int = parent1.next_u64()
		if c1_val != c2_val:
			child_matches_other_child = false
		if c1_val != p_val:
			child_differs_from_parent = true
	_assert_true(
		child_matches_other_child and child_differs_from_parent,
		"fork(7) harus deterministik dan berbeda dari induk",
		stats
	)

	return stats
