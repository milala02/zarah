class_name Rng
extends RefCounted

# Konstanta 64-bit unsigned SplitMix64 dalam representasi two's complement int64 GDScript:
# MASK_64 = 0xFFFFFFFFFFFFFFFF = -1
# INC     = 0x9E3779B97F4A7C15 = -0x61C8864680B583EB
# MUL_1   = 0xBF58476D1CE4E5B9 = -0x40A7B892E31B1A47
# MUL_2   = 0x94D049BB133111EB = -0x6B2FB644ECCEEE15
const MASK_64: int = -1
const INC: int = -0x61C8864680B583EB
const MUL_1: int = -0x40A7B892E31B1A47
const MUL_2: int = -0x6B2FB644ECCEEE15
const SHIFT_30_MASK: int = 0x00000003FFFFFFFF
const SHIFT_27_MASK: int = 0x0000001FFFFFFFFF
const SHIFT_31_MASK: int = 0x00000001FFFFFFFF
const TOP_53_MASK: int = 0x001FFFFFFFFFFFFF
const INV_2_POW_53: float = 1.0 / 9007199254740992.0

var _state: int


func _init(seed_value: int) -> void:
	_state = seed_value & MASK_64


func next_u64() -> int:
	_state = (_state + INC) & MASK_64
	var z: int = _state
	z = ((z ^ ((z >> 30) & SHIFT_30_MASK)) * MUL_1) & MASK_64
	z = ((z ^ ((z >> 27) & SHIFT_27_MASK)) * MUL_2) & MASK_64
	return (z ^ ((z >> 31) & SHIFT_31_MASK)) & MASK_64


func next_float_01() -> float:
	var u: int = next_u64()
	var top53: int = (u >> 11) & TOP_53_MASK
	return float(top53) * INV_2_POW_53


func fork(salt: int) -> Rng:
	return Rng.new((_state ^ salt) & MASK_64)
