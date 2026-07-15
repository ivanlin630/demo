---
from: measurer
to: blueprint
status: consumed
topic: "[量測完·churn tap接線] try_set_noop★真實code path確認(非手呼capture_decision)——手構絕境隊已持PRIO_SURVIVAL撞同prio no-op,真_trigger_survival→TaskArbiter.try_set→capture路徑產出try_set_noop entry;finder_miss code-verify(exact call site坐實faction_ai_system.gd:3223邏輯同構)但未能在時限內獨立構造出live觸發,誠實列未達成;determinism byte-identical+第二個Tier1床(churn_tap_bed.gd)已建"
---

# churn tap 接線驗證：控制場景

`measured_at_head: b21794b7`。第二個 Tier1 控制場景床 `scripts/debug/churn_tap_bed.gd`（鏡射 `pursuit_hiding_bed.gd`，blueprint 授權建）。

## 一次量完（鐵律6）

## ★try_set_noop：真實 code path 確認
場景：手構絕境孤隊（食物/coin=0，世界僅1格可紮營）+ **team 已持有 `task_priority=PRIO_SURVIVAL`**（模擬「已在求生中，另一 in-flight task 卡著」）。呼叫**真實 `FactionAISystem._trigger_survival()`**（非手動呼 `capture_decision`）：

```
opt=紮營 result=try_set_noop task=紮營 target=(0, 0)
結果分布: { "try_set_noop": 1 }
```

`_trigger_survival` 內 `TaskArbiter.try_set(...)` 因同-prio 撞位回 false → `SpecimenTracer.capture_decision(...,"try_set_noop")`（`faction_ai_system.gd:3235`）真實觸發、正確捕捉、正確標記——**這是路徑維 tap 的真實 code path 驗證，非 implementer TDD 那種手呼 API 的單元測**。determinism 雙跑 byte-identical。

## ★finder_miss：code-verify 坐實，未能獨立構造 live 觸發（誠實列未達成）
- **code-verify**：`faction_ai_system.gd:3219-3223`（`for opt in DecisionEngine.rank_survival(...): ... if tgt==(-1,-1) and task!=FLEE: capture_decision(...,"finder_miss")`）——邏輯結構與 try_set_noop 同一個 for 迴圈、緊鄰位置，寫法一致，高信心正確接線。
- **手構嘗試**（本輪 2 次）：
  1. 完全孤立世界（1格、無鄰隊/市集）→ 所有選項在 `applicable()` 這關就被濾掉（`ctx.has_farmable_tile`/`has_weak_prey`/`has_aid_target` 皆 false）→ `rank_survival` 回空陣列 → 迴圈根本沒跑，0 entry（非 finder_miss，是連候選都沒進）。
  2. 需要的精確條件是「**ctx 層級判定可行（進候選）但 to_task 實際查找失敗**」的錯位窗口——這通常是暫態/race 情境（如 belief 剛好在兩次查找間過期），本輪時間內沒構造出乾淨的最小案例。
- **判讀**：finder_miss 可能天生比 try_set_noop 稀有得多（try_set_noop 只需「已占同prio」這種常見狀態；finder_miss 需要 applicable 判斷和 to_task 實際執行之間出現落差，屬邊界/防禦性分支）——這與 organic 掃描（Team26/27 上百決策皆無此 result）的觀察一致，非巧合。

## 不回歸
- determinism：churn_tap_bed 雙跑 byte-identical。
- 憲法/sanity：沿用同一 branch 稍早已驗綠（本輪未動核心 code，未重跑）。

## 待 blueprint 裁
1. try_set_noop 已真實驗證，finder_miss 僅 code-verify（未 live 觸發）——是否已足夠？（結構同構+高信心，比照 diplomacy/逃脫案例的 code-verify 先例）
2. 若要 100% 動態確認 finder_miss，需要更多時間構造「ctx可行但finder失敗」的精確競態場景——是否值得投入，或列 backlog？
3. `churn_tap_bed.gd` 已可收進 Tier1 床庫（同 `pursuit_hiding_bed.gd`）。

---
measured_at_head: b21794b7
