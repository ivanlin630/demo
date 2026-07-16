---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] de-patch軌2值閘——閘1/5/6/7逐一驗證屬實(7確認calc_attack_score production零caller應刪非人格化);但閘4事實有誤(_maybe_request_join_player無任何決策骰,randi()只產event ID)+閘2/3RNG已部分人格加權(慎重/loyalty影響機率非純random)需spec講清楚de-patch指什麼"
---

# R② 判決：de-patch 軌2 值閘人格化 spec

verdict: **issues**
premise_contradiction: false

## 逐閘驗證（file:line 全查證，非採信轉述）

### 閘1 `_threat_recent` — **CONFIRMED，承我 R①批次的發現**
`faction_ai_system.gd:3131-3139`（結構與 spec 引用一致）——硬布林 gate（無最近威脅→武器坊/護甲坊 deficit 直接歸零，personality 項發不了力）。這正是我上輪 R①批次抓出併入真缺清單的那條。de-patch 方向（intent/好戰/感知威脅共同秤）合理。CLEAN。

### 閘5 `tribute_accept` FLEE override — **CONFIRMED**
`diplomatic_ai_system.gd:34-44`：`:40 if defender.current_task==TASK_FLEE: return true`——硬 return 在 `:41-44` 的人格讀取（慎重/義氣/求生欲）**之前**，逃跑時這些人格項完全被繞過。精確坐實 spec 描述——硬 override pre-empt 既有人格公式（同 `_threat_recent` 同一種病）。CLEAN。

### 閘6 `_calc_diplomacy_score` — **CONFIRMED，框架描述精準**
`diplomatic_ai_system.gd:80-100+` 讀過：`_calc_diplomacy_score` 本身已是連續、多項人格/情境加權的公式（food_ratio/power_gap/reputation/relation/peace-values 相加），**硬門檻在消費端**（`handle_diplomacy_message` 用 `ALLIANCE_ACCEPT_THRESHOLD` 等 flat 常數判斷 accept/reject），非計分本身寫死。spec「軟化」的定位精準對到真正該動的地方（閾值/切點，非重寫已存在的連續公式）。CLEAN。

### 閘7 `calc_attack_score` — **CONFIRMED 孤兒，應直接刪**
`faction_ai_system.gd:185` 宣告確認存在，但全 codebase 呼叫端**只有** `headless_test.gd:9178/9180`（測試）+ `longwindow_bed.gd:248`（量測床）——**production 決策路徑零呼叫**（`options.gd`/`decision_engine.gd`/`faction_ai_system.gd` 本身皆無引用）。spec 自己的條件句「先查是否孤兒→孤兒則刪」——**查證結果=孤兒，該刪，非人格化**。你這條的 conditional 已經有答案了，spec 該直接寫「刪」，implementer 不必再花時間查。

## issue：閘4 `_maybe_request_join_player` 事實描述有誤

spec 說「隊要不要求加入玩家的決策骰→de-patch→utility（求生欲/謙卑/絕境秤）」，暗示函式內有一個「要不要求」的機率決定。**逐行讀完 `faction_ai_system.gd:3541-3551`**：函式**無條件**執行（只檢查同格+無待處理事件兩個布林前提，皆非機率），`:3549 randi()` 唯一用途是產生 `player_forced_event_id` 的**識別字串**（`str(randi())`），跟「要不要請求加入」這個決策**完全無關**——這是純粹的 ID 生成隨機性，不是決策骰。

再查全部 3 個呼叫端（`:1535`/`:1793`/`:3344`）：全部是「`if opt=="併入" and target==玩家隊: if _maybe_request_join_player(...): return`」——**呼叫前也沒有任何機率門檻**，是不是要投靠玩家已經由更上游的「併入」option 的人格化 argmax（DecisionEngine rank）決定了，這個函式只是「決定要投靠玩家後，把請求真的送出去」的執行面，不含任何「決策骰」。

**要求**：這一條 spec 描述跟實際 code 不符，會讓 implementer 帶著錯誤預期去找一個不存在的「決策骰」。要嘛刪除閘4（沒有東西可 de-patch，這個 gate 本來就沒有硬骰），要嘛 systems 重新指認真正想講的目標（可能是別的函式、或者根本是我這輪查證前就已經被更早的某輪 de-patch 拆掉了，值得對照 triage 清單的原始出處核對）。

## 待訂正（非阻擋，但需 spec 講清楚）：閘2/閘3 的 RNG 現況已部分人格加權

- **閘2** `try_proactive_diplomacy`（`diplomatic_ai_system.gd:121-124`）：`if randf() > 慎重×0.5+0.2: return`——**這個 randf 門檻已經吃慎重人格**（慎重高→更容易通過門檻→更常主動外交），不是無人格的純隨機。`consider_betrayal`（`:303-308`）也類似，註解自陳「driver 為主驅；接近門檻保留小 stochastic tie-break（非主驅，去純RNG）」——**背叛判斷本身已經是 driver（人格化）為主，RNG 只是邊界 tie-break**，不是「決策全靠骰子」。
- **閘3** `_check_discipline`（`faction_ai_system.gd:1711-1730`）：`fail_chance=(1−avg_loyalty)×avg_stress×常數`，這個機率本身**已經完全由忠誠度/壓力（皆動態人格/狀態值）決定**，只是最終「這個 tick 到底有沒有真的失控」保留一個機率骰（忠誠度低+壓力高≠每次都當場失控，這本身可能是合理的「累積到某個機率才真的爆」敘事，屬於 spec 自己也承認的 outcome-RNG 候選）。

**這兩條不是「未穿人格的死骰子」，是「已穿人格的機率型決策」**——spec 若真要「拆決策骰→改純 utility argmax」，那是把「機率型行為」改成「確定型行為」，是比 spec 現在的措辭（暗示「加人格」）更大的行為改動（拿掉隨機性本身，非只是加權重）。**要求**：spec 明確講清楚意圖是（a）保留機率但確保權重已經夠人格化（現況已大致如此，這兩條可能不太需要大改）、還是（b）真的要去掉隨機性、改成閾值型的確定判斷（更大的行為變，需要在驗收裡明確講「慎重高的領袖現在絕對不會背叛」這種確定性斷言，而非「比較不會」的機率性斷言）——兩者對 measurer 要驗證的東西完全不同。

## 結論
閘1/5/6/7 逐一驗證 CLEAN（閘7 可直接確定「刪」不必再查）。**issue＝閘4 事實描述跟 code 不符（無決策骰可拆）+ 閘2/3 需要 spec 講清楚「拆RNG」具體指什麼行為改動**（現況已部分人格加權，非未穿人格的死骰子）。**issues → halt，退回訂正閘4 + 釐清閘2/3 意圖後可 CLEAN**（非重新設計，是修正前提描述精度）。
