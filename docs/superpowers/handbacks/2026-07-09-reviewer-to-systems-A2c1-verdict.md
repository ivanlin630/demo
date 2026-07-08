---
from: reviewer
to: systems
status: consumed
topic: A2c-1 spec 審畢——1 阻塞項（premise 錯）+ 2 次要，餘 CLEAN
---

# A2c-1 spec 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-A2c1-consolidate-into-engine.md`

## ★阻塞：查項 #2「dispatch-key 缺口」premise 錯（file:line 反證）

spec 主張「`_decide_unified`(1515-1518) 只認 `combat_target`/`social_target`,不認 `order_target`→需加 additive 消費」。

**反證**：`faction_ai_system.gd:401-403` `_wire_threat_task` 早已泛用消費 `order_target`：
```
func _wire_threat_task(team, td):
    if td.has("prosperity_target"): team.prosperity_target_id = int(td["prosperity_target"])
    if td.has("order_target"): team.order_target_id = int(td["order_target"])
    if td.has("order_task"): team.order_task = td["order_task"]
```
且此函式**已在同一 `_decide_unified` 呼叫路徑**、`combat_target`/`social_target` 消費之後、`return` 之前無條件呼叫（`faction_ai_system.gd:1535`）。同一 `td` dict、同一 tick、同一 return 前。

**結論**：「整併」option 的 `to_task` 回 `order_target: ctid` → `_decide_unified:1535` 的既有 `_wire_threat_task(team, td)` 呼叫**已足夠消費**，`team.order_target_id` 會被正確設。D1 提議在 1515-1518 旁再加一段 `if td.has("order_target"): team.order_target_id = ...` 是**重複**（非新增能力，寫兩次同值，idempotent 但誤導）。

同時「他 option 不回 order_target」的 additive 前提也不成立——`options.gd:228`（威脅/求和 option）**已經**回 `order_target`（走同一 `_wire_threat_task` 消費），非本 spec 首次引入。

**要求**：刪 spec D1 該段 additive dispatch-key 提案（`faction_ai_system.gd` 觸及檔表該行也刪），直接依賴既有 `_wire_threat_task:1535` 消費即可。省一段 diff、也修正對現有 seam 的錯誤描述。

## 次要（不阻塞，實作時注意）

1. **D3 helper 命名虛指**：`consolidate_target_of` 偽代碼呼 `_find_absorber_s`/`_hex_dist_s`（不存在的 static 變體）。既有慣例是 `FactionAISystem.new()._find_absorber(...)`（`decision_context.gd:121/153`、`options.gd:150` 等既有多處這樣呼）。建議直接沿用 instance-call 慣例，不必新造 static 雙生函式，diff 更小、風格一致。
2. **survival-sticky 機制描述不準（結論仍對）**：spec 稱「PRIO_SURVIVAL 80 > 整併 PRIO_DISPATCH 50」隱含在 rank_scored 內競秤——實際上 `_decide_unified` 本身統一以 `PRIO_DISPATCH` try_set（不論 winner 是何 option，含假設性 survival option），真正保護來自 `TaskArbiter.try_set`（`task_arbiter.gd:30`：`priority > team.task_priority` 才覆寫）——若團隊已由**另一條路徑**`_trigger_survival`（獨立 `rank_survival` 評分,`faction_ai_system.gd:3067-3099`）設下 `PRIO_SURVIVAL(80)` 任務，`_decide_unified` 的 `PRIO_DISPATCH(50)` try_set 結構上就寫不進去——與整併是否入 option 無關。**結論不變**（餓/危成員仍選 survival、整併確實壓不過），但「rank_scored 內競秤」的描述應改成「TaskArbiter priority-gate 擋」，避免下游校準/量測誤解機制。

## 其餘查項（3/5/6/憲法閘）：CLEAN

- 保真（#1）：`consolidate_target_of` 兩支條件對 `_try_consolidate_merge`(1419-1443) 逐條件等價（absorber 非空+small_b+small_c；攻擊 goal+dist範圍+leader餘容量）。
- leader/子隊排除（#5）：`team.parent_team_id == -1` 排子隊、`team.team_id != _f.leader_team_id` 排 leader，齊。
- 憲法閘（#6）：`_try_consolidate_merge` 兩 try_set 移除、改走引擎 dispatch try_set(1509)，baseline 更新方向對。
- re-slice（FA5/FA6 拆）：同意系統切法，FA6 movement-overlay 非 option-fold 確與本 slice 技術路徑不同。

## 裁決

CLEAN except 上述阻塞項。**修 D1（刪重複 additive 段）後可鎖 spec**，不需再審一輪（改動是刪碼、不是加邏輯）。次要 2 項為敘述/命名修正，systems 自行判斷是否採納。
