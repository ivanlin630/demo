class_name GoalRegistry

# ★means-end 長程規劃（組件 B，HOW spec 2026-07-24 §3）：宣告式依賴 registry。
# goal_type → 前置宣告（prereqs / payoff）。GoalResolver walk 此表拆前置鏈。
# ★S2：填 5 個資源維持 goal（resource 前置）；定位/人力/設施/子目標 goal = S3-S6。

# 前置 kind（HOW WHAT §5 五種固定，資料隨 goal 變）。goal 的 prereqs 每元素 kind ∈ 此集。
const PREREQ_RESOURCE: String = "resource"    # 資源量前置（res + qty[走 need_keep 通用]）
const PREREQ_LOCATION: String = "location"    # 定位前置（S3；resolver 每 tick 重選最近可達）
const PREREQ_MANPOWER: String = "manpower"    # 人力前置（S5，pop ≥ N）
const PREREQ_FACILITY: String = "facility"    # 設施前置（S4，某 facility 存在）
const PREREQ_SUBGOAL: String  = "subgoal"     # 子目標前置（S4/S6，遞迴另一 goal_type）

# ★S2 資源維持 goal → 對應 res（組件 A 生成 + resolver walk 用）。holding<need_keep(res)→active。
# food/material/tools/weapon/coin「維持夠用」（WHAT §8 基礎 goal-set 資源維持部分）。
const MAINTAIN_GOAL_RES: Dictionary = {
	"maintain_food":     "food",
	"maintain_material": "material",
	"maintain_tools":    "tools",
	"maintain_weapons":  "weapon_melee_low",   # 代表性武器（S2 單 res；多武器型 goal-set 泛化=後續）
	"maintain_coin":     "coin",
}

# ★registry 資料表（goal_type → {prereqs, payoff}）。S2 填 5 資源維持 goal。
# payoff=解掉此 goal 的上層 util 估（TEST VALUE，S6 折現+校準）。qty 走 need_keep 通用（resolver 動態算非硬寫）。
static var REGISTRY: Dictionary = {
	"maintain_food":     {"prereqs": [{"kind": PREREQ_RESOURCE, "res": "food"}],             "payoff": 1.0},
	"maintain_material": {"prereqs": [{"kind": PREREQ_RESOURCE, "res": "material"}],         "payoff": 1.0},
	"maintain_tools":    {"prereqs": [{"kind": PREREQ_RESOURCE, "res": "tools"}],            "payoff": 1.0},
	"maintain_weapons":  {"prereqs": [{"kind": PREREQ_RESOURCE, "res": "weapon_melee_low"}], "payoff": 1.0},
	"maintain_coin":     {"prereqs": [{"kind": PREREQ_RESOURCE, "res": "coin"}],             "payoff": 1.0},
}
