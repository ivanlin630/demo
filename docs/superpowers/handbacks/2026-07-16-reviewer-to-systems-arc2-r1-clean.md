---
from: reviewer
to: systems
status: consumed
topic: "[R①判決] Arc2三重dispatch收斂前提——①確認4個rank_*函式(非3個,計數需訂正)②重大反框架:全部是同一DecisionOptions.applicable()池+同DecisionTerms權重機制的filtered subset,非繞過引擎(收斂scope比roadmap暗示的小很多)③survival/threat語意可併=開放設計問題非可靜態判定,標R②裁；無premise_contradiction"
---

# R① factcheck 判決：Arc2 三重 dispatch 收斂前提

verdict: **clean（一項計數訂正、一項重大反框架、一項需R②裁）**
premise_contradiction: false

## 逐條 refute-向 factcheck（自己 grep+read，非臆斷）

### 1. 「真有幾條平行 rank/dispatch 路」— **CONFIRMED，但精確計數是 4 非 3**
`decision_engine.gd` 逐一核對，確認 4 個獨立 `rank_*` 函式：
- `rank_scored`（`:15`）/`rank_scored_ctx`（`:23`）——呼叫者 3 處：`faction_ai_system.gd:1492`(`_decide_unified`)、`:1748`(`_decide_subteam`)、`:1879`(`_evaluate_solo`)。
- `rank_survival`（`:105`）——呼叫者 1 處：`:3334`(`_trigger_survival`)。
- `rank_threat`（`:134`）——呼叫者 1 處：`:402`(`_evaluate_threat`)。
- `rank_ambient`（`:159`）——呼叫者 1 處：`:835`（loop3 idle-filler，函式內註解自稱「序3 follow-up：rank_scored_ctx→rank_ambient」）。

**訂正**：函式數量精確為 4，非 roadmap 講的「三重」。但若照**派發用途/優先權層級**（非函式數）算，可以合理歸成 3 大類：①主路（rank_scored，涵蓋 unified/subteam/solo 三種呼叫脈絡但同一函式）②威脅中斷路（rank_threat，獨立優先權層 `PRIO_THREAT`）③遺留求生路（rank_survival，narrow scoped，見下）。`rank_ambient` 本質是主路的最低優先權篩選視圖（自身註解承認），可併入①算。**這樣算「三重」講得通**——是計數口徑問題非事實錯，但精確 file:line 核對後 spec 該寫函式數=4、dispatch 層級=3，避免 implementer 照字面找「3 個函式」找不到對應而誤刪 `rank_ambient`。

### 2. 「真繞過引擎、還是同引擎的 filtered subset」— **CONFIRMED 為 filtered subset，這是重大反框架發現**
`rank_ambient`（`:159-170`）逐行讀完：`for opt in DecisionOptions.applicable(ctx): if opt not in AMBIENT_OPTION_SET: continue`，後面 `DecisionTerms.weight`/`DecisionTerms.eval` 完全同一套。核對 `rank_survival`/`rank_threat`（本 session 稍早已查證）也是**同一模式**——三者全部從同一個 `DecisionOptions.applicable(ctx)` 池 + 同一套 `DecisionTerms` 權重機制篩子集，只是各過濾到不同 OPTION_SET（`SURVIVAL_OPTION_SET`/`THREAT_OPTION_SET`/`AMBIENT_OPTION_SET`）。**這些 rank_* 函式不是獨立繞過引擎的平行決策系統——它們就是同一個引擎的不同視角**（filtered view），共用同一份 term 定義、同一套人格權重公式。

**這是比 roadmap 前提更樂觀的發現**：Arc2 的真實工作量比「消滅繞過引擎的違規系統」小得多——底層評分機制已經是統一的，要收斂的其實是**「誰在什麼時候呼叫哪個過濾視角、以及要不要把這些視角本身也合併成一個」**這種調度/呼叫圖層面的整併，不是重寫評分邏輯。這個定性差異會大幅影響 Arc2 spec 的風險評級——**建議 spec 明確採用「合併 filtered subset」的定性，而非「收繞過路」**，後者會讓 implementer 誤以為要動評分核心（風險被高估）。

### 3. 「收斂成一 encounter eval 的前提成立？survival/threat 語意可併」— **無法純靜態判定，是開放設計問題，標交 R②**
確認遺留 `_evaluate_survival`（`:3174-3196`）的明確 gate：`:3195 if uses_unified(team) or team.parent_team_id == -1: return`——遺留 `rank_survival` 路徑**只服務非-unified 子隊**（parent_team_id!=-1 且非 uses_unified），範圍比可能想像的窄（不是「一半世界走新路一半走舊路」，是「主流全走新路，僅一種子隊類型的邊角案例走舊路」）。這條 gate 本身有明確理由（`:3191-3194` 註解記載 Team10 livelock 教訓，故意保留非全退）。

`survival`(soft, rank_survival/主 rank 內建候選) vs `threat`(hard, rank_threat 有獨立 `ctx.threat_react>=ctx.threat_threshold` 門檻閘) 語意是否可併——這**不是能靜態 grep 出答案的前提**，是真正的架構設計判斷（權重量級如何互相不淹沒、hard gate 併入 soft 競秤後閾值語意變不變）。`project_unification_matrix` 記過的「survival 雙語意 watch」屬實存在（我確認 `rank_survival`/一般 rank 裡都有「survival」相關 option 但語意/觸發條件不同）。**這條標記「需 R② 設計裁定」，非本輪 R① 可判定 CLEAN/contradiction**——這正是 factcheck（前提事實）與設計審（怎麼做對）的分界，我不越權。

## 結論
無 premise_contradiction。前提整體站得住，但：
- **#1 計數需訂正**：4 個函式非 3 個（可用「3 層級」措辭圓過去，但要明確寫函式對應避免 implementer 找不到/誤刪 `rank_ambient`）。
- **#2 是重大利多發現**：這些 rank_* 是同引擎 filtered subset 非獨立繞過系統——spec 定性建議改寫成「合併呼叫圖/過濾視角」而非「消滅違規系統」，風險評級應相應調低。
- **#3 語意合併問題留給 R②**：這是真設計判斷非前提事實，R① 職權不裁。

## 下一站
CLEAN → 你據上述訂正後的精確前提（4函式/filtered-subset定性/survival-threat併語意留R②）架 Arc2 spec → R②（審設計，屆時我會重點審 survival/threat 語意合併方案）。
