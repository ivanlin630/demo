class_name GoalRegistry

# ★means-end 長程規劃（組件 B，HOW spec 2026-07-24 §3）：宣告式依賴 registry。
# goal_type → 前置宣告（prereqs / payoff / invest / action）。GoalResolver walk 此表拆前置鏈。
# ★S1 骨架：空表結構 + 5 種前置 kind 常數就位；registry data 空（S2+ 填 goal 定義）。
# ★whole-system-first：S1 純接線宣告，別提前塞 goal 資料。

# 前置 kind（HOW WHAT §5 五種固定，資料隨 goal 變）。goal 的 prereqs 每元素 kind ∈ 此集。
const PREREQ_RESOURCE: String = "resource"    # 資源量前置（res + qty）→ 生 res-need（NeedOracle 管數量）
const PREREQ_LOCATION: String = "location"    # 定位前置（去某類 tile；resolver 每 tick 重選最近可達）
const PREREQ_MANPOWER: String = "manpower"    # 人力前置（pop ≥ N）
const PREREQ_FACILITY: String = "facility"    # 設施前置（某 facility 存在）
const PREREQ_SUBGOAL: String  = "subgoal"     # 子目標前置（遞迴另一 goal_type）

# ★registry 資料表（goal_type → 前置宣告）。S1 空；S2+ 填如：
#   "build_weaponsmith": { prereqs:[{kind:PREREQ_RESOURCE,res:"material",qty:..},..], payoff:.., invest:true, action:{..} }
static var REGISTRY: Dictionary = {}
