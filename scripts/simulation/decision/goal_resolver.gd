class_name GoalResolver

# ★means-end 長程規劃（組件 C，HOW spec 2026-07-24 §4）：runtime frontier 合成中間層。
# 對 team.goal_state 每個 active goal，walk GoalRegistry[goal_type].prereqs 拆前置鏈，
# 合成當前可動 frontier candidate 餵 decision rank 池（與 static option 同池 argmax 競爭）。
# ★唯讀、每 tick 重算 transient frontier（不寫回 goal_state=無 plan-state，守 HOW §9）。
# ★路徑必 scripts/simulation/decision/（constitution_gate GV_FILE_RE 涵蓋）→ god-view/RNG detector 看得到。
#
# Candidate 結構（HOW §4）：{ util:float, to_task:Dictionary, source_goal:GoalInstance, label:String, delegate:bool }。
#
# ★S1 骨架：stub 直接 return []（空 candidate）→ rank hook no-op → byte-identical no-op proof。
# ★whole-system-first：S1 不塞 frontier 合成邏輯（walk/handler/util/折現 = S2+），保持 stub。
static func frontier_candidates(state: WorldState, team: TeamData, ctx: DecisionContext) -> Array:
	return []   # S1 stub：空 frontier（骨架就位、零行為變；S2 填 goal walk + candidate 合成）
