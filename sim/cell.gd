class_name Cell
extends RefCounted

enum Fase { PADAT = 0, CAIR = 1, GAS = 2 }

var material_id: int
var suhu_c: float
var massa_kg: float
var fase: int
var last_moved_tick: int = -1


func _init(p_material_id: int, p_suhu_c: float, p_massa_kg: float, p_fase: int) -> void:
	material_id = p_material_id
	suhu_c = p_suhu_c
	massa_kg = p_massa_kg
	fase = p_fase
	last_moved_tick = -1


func equals(other: Cell) -> bool:
	return (
		material_id == other.material_id
		and is_equal_approx(suhu_c, other.suhu_c)
		and is_equal_approx(massa_kg, other.massa_kg)
		and fase == other.fase
	)


func duplicate_cell() -> Cell:
	var copy: Cell = Cell.new(material_id, suhu_c, massa_kg, fase)
	copy.last_moved_tick = last_moved_tick
	return copy
