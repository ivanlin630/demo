class_name RelationGraph

# typed-edge 關係圖。邊：{ "type": String, "target": int, "intensity": float, "tick": int }
# 純 static 操作 Array；核心只按 type/target filter → 加型別=加 reader,零核心改(WHAT §4)。
# G2 用型別：feud / killed / protect / gratitude。未來 kin/spouse/master 等同型塞入。

static func add_edge(edges: Array, type: String, target: int, intensity: float, tick: int) -> void:
	if target == -1:
		return
	for e in edges:
		if e["type"] == type and e["target"] == target:
			e["intensity"] = maxf(float(e["intensity"]), intensity)
			e["tick"] = tick
			return
	edges.append({ "type": type, "target": target, "intensity": intensity, "tick": tick })

static func edges_of_type(edges: Array, type: String) -> Array:
	var out: Array = []
	for e in edges:
		if e["type"] == type:
			out.append(e)
	return out

static func edges_to(edges: Array, target: int) -> Array:
	var out: Array = []
	for e in edges:
		if e["target"] == target:
			out.append(e)
	return out

static func strongest(edges: Array, type: String) -> Dictionary:
	var best: Dictionary = {}
	var best_i: float = -1.0
	for e in edges:
		if e["type"] != type:
			continue
		if float(e["intensity"]) > best_i:
			best_i = float(e["intensity"])
			best = e
	return best
