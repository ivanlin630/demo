class_name SpecimenDumpHelper

# specimen 量測 wiring helper（measurer 長跑用）：選取 N 隊 trace + dump summary。
#
# ★★RNG-neutral 鐵律（observer_no_global_rng 家族，2026-07-28 揭露）：
#   選取 specimen 隊**禁耗 global RNG**（禁 pick_random/randf/randi/shuffle）——選取一次耗 RNG
#   即 shift 整條 global RNG 流 → 世界從此走不同軌跡 = 觀測擾動被觀測世界（違「觀測禁擾動」）。
#   measurer 2026-07-28 A/B 坐實 bug 根：舊 temp wiring 用 RNG 抽樣 10 隊 → specimen ON 世界動、
#   OFF 世界凍（同 seed 唯一變因 specimen）。SpecimenTracer 本身的 capture/observe 路徑已驗中性
#   （fixed 選取 normal-LOD 2000 tick byte-identical）→ leak 純在選取 RNG。
#   ∴ 此 helper 選取用**確定性 strided 取樣**（sorted id 均勻步進，零 RNG）→ 觀測中性。

# SPECIMEN_SAMPLE_N env → 選取 N 隊 + 開 tracer。N<=0 或未設 → no-op（specimen off）。
static func setup_from_env(state: WorldState) -> void:
	var n: int = int(OS.get_environment("SPECIMEN_SAMPLE_N")) if OS.has_environment("SPECIMEN_SAMPLE_N") else 0
	if n <= 0:
		return
	select(state, n)

# ★確定性 strided 選取（零 global RNG）：sorted id 均勻步進取 N 個 → 代表性抽樣 + 觀測中性。
static func select(state: WorldState, n: int) -> void:
	if n <= 0:
		return
	var ids: Array = state.teams.keys()
	ids.sort()   # 確定性順序（Dictionary keys 序不保證 → 必 sort）
	var picked: Array = []
	if ids.size() <= n:
		picked = ids.duplicate()
	else:
		# 均勻步進（strided），非 pick_random：確定性 + 覆蓋 id 分布 + 零 RNG。
		var step: float = float(ids.size()) / float(n)
		var seen: Dictionary = {}
		for i in range(n):
			var idx: int = int(i * step)
			if idx >= ids.size():
				idx = ids.size() - 1
			var tid = ids[idx]
			if not seen.has(tid):   # 防步進碰撞重複
				seen[tid] = true
				picked.append(tid)
	state.specimen_team_ids.assign(picked)
	SpecimenTracer.enabled = true

static func dump() -> void:
	if not SpecimenTracer.enabled:
		return
	SpecimenTracer.summary()

static func teardown() -> void:
	SpecimenTracer.enabled = false
	SpecimenTracer.reset()
