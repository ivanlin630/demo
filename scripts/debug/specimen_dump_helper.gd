# @observe-pure  ★observer-no-global-RNG 靜態閘納管(純觀測零 RNG;違=FAIL)
class_name SpecimenDumpHelper

# ★generalize §⑤ specimen dump（systems 2026-07-19 tooling ask）：
# 任何長跑（含 ad-hoc/unseeded 探索跑，非只 seeded_warring_bed）掛此助手 →
# 出 QA 可讀 event-dump（motive/action/outcome，經 SpecimenTracer），無 seed 也吐（QA 故事審不需可重現）。
# 純觀測 wiring：不改 production 邏輯，只讀 env + 設 SpecimenTracer.enabled/state.specimen_team_ids + 呼 write_jsonl。
#
# ★★RNG-neutral（observer_no_global_rng 家族，2026-07-28 揭露+鎖）：選取用**確定性 strided**（sorted id
#   等距取樣，零 pick_random/randf）→ 觀測不耗 global RNG、不改世界軌跡。measurer 2026-07-28 見的
#   specimen ON/OFF 世界岔開是**另一支已刪 ad-hoc temp wiring 用 pick_random 選取**所致、非此 helper；
#   本 helper 本來中性（bisect 坐實 fixed 選取 normal-LOD 2000tick byte-identical）。regression 鎖之
#   （specimen_confound_test._test_dumphelper_normallod_neutral）。
#
# 用法（任何 bed/腳本，setup 完 state 後、跑迴圈前呼一次）：
#   SpecimenDumpHelper.setup_from_env(state)
#   ...跑 sim 迴圈...
#   SpecimenTracer.flush()  # 可選：跑中定期印 timeline
#   SpecimenDumpHelper.dump(state, "docs/measurements/<topic>.specimen.jsonl")
#
# env 開關（未設任一 = no-op，零成本，SpecimenTracer.enabled 維持 false）：
#   SPECIMEN_TEAM_ID    逗號分隔明確 team_id 清單，如 "3,19,42"（含死隊死因才是故事關鍵——若已知目標隊先手動 dispatch 進 state.teams 後再呼此）。
#   SPECIMEN_SAMPLE_N   int，自動從當下 state.teams 均勻抽樣 N 隊（sorted team_id 等距取樣，涵蓋範圍非隨機聚一團）。
# 兩者可同時設（合併去重）。

static func setup_from_env(state: WorldState) -> void:
	var ids: Dictionary = {}   # 用 Dictionary 當 Set，去重
	var explicit_str: String = OS.get_environment("SPECIMEN_TEAM_ID") if OS.has_environment("SPECIMEN_TEAM_ID") else ""
	if explicit_str != "":
		for part in explicit_str.split(","):
			var s: String = part.strip_edges()
			if s.is_valid_int():
				ids[int(s)] = true
	var sample_n: int = int(OS.get_environment("SPECIMEN_SAMPLE_N")) if OS.has_environment("SPECIMEN_SAMPLE_N") else 0
	if sample_n > 0:
		var all_ids: Array = state.teams.keys()
		all_ids.sort()
		if all_ids.size() <= sample_n:
			for tid in all_ids:
				ids[tid] = true
		else:
			var step: float = float(all_ids.size()) / float(sample_n)   # ★確定性 strided（零 RNG）
			for i in range(sample_n):
				ids[all_ids[int(i * step)]] = true
	if ids.is_empty():
		return   # 兩開關皆未設 → no-op（SpecimenTracer.enabled 維持 false，零成本）
	var typed_ids: Array[int] = []
	for k in ids.keys():
		typed_ids.append(int(k))
	state.specimen_team_ids = typed_ids
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	print("[SpecimenDumpHelper] specimen_team_ids=%s（enabled=true，dump 前記呼 SpecimenDumpHelper.dump）" % str(state.specimen_team_ids))

# 收尾：flush 殘餘 + write_jsonl。path 未給 → 用時間戳預設檔名（存 docs/measurements/，同既有量測落地慣例）。
static func dump(state: WorldState, path: String = "") -> void:
	if not SpecimenTracer.enabled:
		return   # 未啟用（setup_from_env 沒收到任何 env）→ no-op
	SpecimenTracer.flush()
	var out_path: String = path
	if out_path == "":
		out_path = "docs/measurements/adhoc.specimen.jsonl"
	SpecimenTracer.write_jsonl(out_path)
