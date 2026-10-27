class_name World
extends RefCounted

const TICK_HZ: int = 20
const TICK_DT: float = 1.0 / 20.0

var seed: int
var chunks: Dictionary
var tick_count: int
var _defaults: Dictionary
var _rng: Rng
var _registry: MaterialRegistry


func _init(
	p_seed: int,
	defaults: Dictionary,
	registry: MaterialRegistry = null
) -> void:
	seed = p_seed
	_defaults = defaults.duplicate()
	_rng = Rng.new(p_seed)
	_registry = registry
	chunks = {}
	tick_count = 0


func _make_default_cell() -> Cell:
	var mat_id: int = int(_defaults["material_udara_id"])
	var suhu: float = float(_defaults["suhu_ambient_c"])
	# TODO(T2.2): ganti ke registry.get_fase_default(material_udara_id)
	return Cell.new(mat_id, suhu, 0.0, Cell.Fase.GAS)


func chunk_at(coord: Vector2i) -> Chunk:
	if not chunks.has(coord):
		chunks[coord] = Chunk.new(coord, _make_default_cell())
	return chunks[coord] as Chunk


func _sorted_coords() -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	for key: Variant in chunks.keys():
		coords.append(key as Vector2i)
	coords.sort_custom(
		func(a: Vector2i, b: Vector2i) -> bool:
			if a.x != b.x:
				return a.x < b.x
			return a.y < b.y
	)
	return coords


func tick(_dt: float) -> void:
	tick_count += 1
	_rng.next_u64()
	if _registry != null:
		var coords: Array[Vector2i] = _sorted_coords()
		# Pass 1: POWDER
		for coord: Vector2i in coords:
			var chunk: Chunk = chunks[coord] as Chunk
			Physics.apply_chunk_kind(chunk, _registry, tick_count, MaterialRegistry.KIND_POWDER)
		# Pass 2: LIQUID
		for coord: Vector2i in coords:
			var chunk: Chunk = chunks[coord] as Chunk
			Physics.apply_chunk_kind(chunk, _registry, tick_count, MaterialRegistry.KIND_LIQUID)
		# Pass 3: GAS
		for coord: Vector2i in coords:
			var chunk: Chunk = chunks[coord] as Chunk
			Physics.apply_chunk_kind(chunk, _registry, tick_count, MaterialRegistry.KIND_GAS)


func state_hash() -> String:
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)

	var header: String = "%d|%d|%d|" % [seed, tick_count, _rng._state]
	ctx.update(header.to_utf8_buffer())

	var coords: Array[Vector2i] = _sorted_coords()

	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	for coord: Vector2i in coords:
		var chunk: Chunk = chunks[coord] as Chunk
		buf.clear()
		buf.put_32(coord.x)
		buf.put_32(coord.y)
		for y: int in range(Chunk.CHUNK_SIZE):
			for x: int in range(Chunk.CHUNK_SIZE):
				var c: Cell = chunk.get_cell(x, y)
				buf.put_64(c.material_id)
				buf.put_double(c.suhu_c)
				buf.put_double(c.massa_kg)
				buf.put_64(c.fase)
				buf.put_64(c.last_moved_tick)
		ctx.update(buf.data_array)

	return ctx.finish().hex_encode()
