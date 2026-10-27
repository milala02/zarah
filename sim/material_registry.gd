class_name MaterialRegistry
extends RefCounted

const KIND_STATIC: int = 0
const KIND_POWDER: int = 1
const KIND_LIQUID: int = 2
const KIND_GAS: int = 3

const _KIND_MAP: Dictionary = {
	"static": KIND_STATIC,
	"powder": KIND_POWDER,
	"liquid": KIND_LIQUID,
	"gas": KIND_GAS,
}

const _FASE_MAP: Dictionary = {
	"padat": Cell.Fase.PADAT,
	"cair": Cell.Fase.CAIR,
	"gas": Cell.Fase.GAS,
}

var _by_num: Dictionary


func _init() -> void:
	_by_num = {}


static func from_dict(materials: Dictionary) -> MaterialRegistry:
	var reg: MaterialRegistry = MaterialRegistry.new()
	for key: Variant in materials.keys():
		var entry_var: Variant = materials[key]
		if entry_var is Dictionary:
			var entry: Dictionary = entry_var as Dictionary
			if entry.has("id_numerik"):
				var id_num: int = int(entry["id_numerik"])
				reg._by_num[id_num] = entry.duplicate(true)
	return reg


func has(id_num: int) -> bool:
	return _by_num.has(id_num)


func get_physics_kind(id_num: int) -> int:
	if not _by_num.has(id_num):
		push_error("MaterialRegistry: id_numerik tidak dikenal (%d)" % id_num)
		return KIND_STATIC
	var entry: Dictionary = _by_num[id_num] as Dictionary
	var kind_str: String = str(entry.get("physics_kind", "static")).to_lower()
	if not _KIND_MAP.has(kind_str):
		push_error("MaterialRegistry: physics_kind tidak valid (%s)" % kind_str)
		return KIND_STATIC
	return int(_KIND_MAP[kind_str])


func get_density(id_num: int) -> float:
	if not _by_num.has(id_num):
		push_error("MaterialRegistry: id_numerik tidak dikenal (%d)" % id_num)
		return 0.0
	var entry: Dictionary = _by_num[id_num] as Dictionary
	var k_val: Variant = entry.get("kerapatan_kg_m3", 0.0)
	if k_val is float or k_val is int:
		return float(k_val)
	if k_val is Dictionary:
		var k_dict: Dictionary = k_val as Dictionary
		var fase_def: String = str(entry.get("fase_default", "padat")).to_lower()
		if k_dict.has(fase_def):
			return float(k_dict[fase_def])
		push_error(
			"MaterialRegistry: kerapatan_kg_m3 tidak memiliki kunci fase_default '%s' untuk id=%d"
			% [fase_def, id_num]
		)
		return 0.0
	push_error("MaterialRegistry: format kerapatan_kg_m3 tidak valid untuk id=%d" % id_num)
	return 0.0


func get_fase_default(id_num: int) -> int:
	if not _by_num.has(id_num):
		push_error("MaterialRegistry: id_numerik tidak dikenal (%d)" % id_num)
		return Cell.Fase.PADAT
	var entry: Dictionary = _by_num[id_num] as Dictionary
	var fase_str: String = str(entry.get("fase_default", "padat")).to_lower()
	if not _FASE_MAP.has(fase_str):
		push_error("MaterialRegistry: fase_default tidak valid (%s)" % fase_str)
		return Cell.Fase.PADAT
	return int(_FASE_MAP[fase_str])
