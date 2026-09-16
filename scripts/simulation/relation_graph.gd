class_name RelationGraph

# typed-edge 關係圖。邊：{ "type": String, "target": int, "intensity": float, "tick": int }
# 純 static 操作 Array；核心只按 type/target filter → 加型別=加 reader,零核心改(WHAT §4)。
# G2 用型別：feud / killed / protect / gratitude。未來 kin/spouse/master 等同型塞入。

static func add_edge(edges: Array, type: String, target: int, intensity: float, tick: int) -> void:
	if target == -1:
		return
	for e in edges:
		if e["type"] == type and e["target"] == target:
			# ★★★【飽和疊加】1−(1−a)(1−b) 取代 `maxf`（用戶裁 2026-09-16 影子場，恩怨帳）：
			#   ★`maxf` 之下「十次小重徵」＝「一次小重徵」 ⇒ **累積的戲永遠長不出來**。
			#   ★★飽和式自帶四個性質，而它們**都不是靠常數換來的**（零新常數）：
			#     小怨會累積／單次大怨直接高／**永不破 1**／**順序無關**。
			#   ★★★而這裡是【唯一疊加點】⇒ `gratitude` 與 `protect` **同時改變** ——
			#     那不是副作用，是「同類疊＝飽和」本來就涵蓋全 type；★驗收必須看到 `protect` 那一格。
			var a: float = float(e["intensity"])
			e["intensity"] = clampf(1.0 - (1.0 - a) * (1.0 - intensity), 0.0, 1.0)
			e["tick"] = tick
			if Probe.enabled:
				Probe.bump("grudge.stack")
				Probe.bump("grudge.stack." + type)
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

# ★★★【per-target 查邊】—— ★本切片所有新讀者走它，**不得用 `strongest`**。
#   ★理由（systems §0 訂正④）：`strongest` 只看最強的那一條邊
#   ⇒ **我對 B 的怨若不是最強，B 在我眼裡就不是仇人** —— 那是個結構缺陷，不是這裡要沿用的東西。
#   ★★而 `_views_as_foe`（`interaction_system.gd:1790`）本身**不在本切片**（不順手改別人的讀者）。
static func intensity_to(edges: Array, type: String, target: int) -> float:
	for e in edges:
		if e["type"] == type and e["target"] == target:
			return float(e["intensity"])
	return 0.0

# ★★★【消耗邊】—— 回傳**實際消耗掉的量**（不是剩下的量）。
#   ★歸零 ⇒ **移除該邊**：留一條 0 強度的殭屍邊，會讓「有沒有這條邊」與「強度多少」給出兩個答案。
#   ★★唯一鐵則（WHAT）：**消耗邊的是【事件】，被動與無不消耗** ——
#     ⇒ 呼叫端只有【真的發生了那件事】的地方，不得掛在「每 tick 淡忘」那種地方。
static func consume_edge(edges: Array, type: String, target: int, amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	for i in range(edges.size()):
		var e: Dictionary = edges[i]
		if e["type"] != type or e["target"] != target:
			continue
		var cur: float = float(e["intensity"])
		var taken: float = minf(cur, amount)
		var left: float = cur - taken
		if left <= 0.0:
			edges.remove_at(i)
		else:
			e["intensity"] = left
		return taken
	return 0.0
