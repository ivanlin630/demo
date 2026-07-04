# Hand Back: 引擎 dispatch-fallback（argmax 退次佳可派 — 修 unified 經濟隊覓食無格凍死，藍圖標記 2）

## 實作摘要

- `scripts/simulation/decision/decision_engine.gd`
  - 新增 `static func rank(state, team) -> Array`：options 依 util 降序，index tiebreak（util 相等→applicable 順序在前者勝，等同原 argmax strict `>` 首勝）。
  - `decide` 改 = `rank()[0]`（簽名/行為不變；設 current_option=best）。
- `scripts/simulation/faction_ai_system.gd`
  - `_decide_unified` 改成迭代 `DecisionEngine.rank(...)`，取**首個可派** option（target 有效，或 task=FLEE 允許 -1,-1）；不可派 → `continue` 試次佳。實際派出時才設 `team.current_option = opt`（承諾追蹤實際派出，非紙上 argmax）+ bump 探針（`g1.restock_chosen` / `g1.engine_survival`）+ `TaskArbiter.try_set(PRIO_DISPATCH)`。全部 option 不可派 → no-op 保持現行。
- `scripts/debug/headless_test.gd`
  - 加 `_test_engine_rank`（rank 非空、降序首=貿易、decide==rank[0]）並註冊於 `_test_unified_seam` 後。
  - 加 `_test_dispatch_fallback`（深危有家商隊、世界空無覓食格 → argmax 覓食無格 → 退 RETURN_HOME「返家補給」不凍；current_option 追蹤實際派出）並註冊於 `_test_unified_survival_boundary` 後。

與 spec 無差異。spec §1 rank / §2 decide 改用 rank / §3 _decide_unified 退次佳 全覆蓋。

## 驗收證據

### 回歸（全綠）
最終 `headless_test.gd`：`=== DONE ===`、SCRIPT ERROR/Parse/Assertion = **0**。
- 新測：`engine rank OK`、`dispatch fallback OK`
- TC1/4/6/7 全綠（decide=rank[0] 行為不變：TC1 changes=0/opt=貿易、TC4 建設/駐守、TC6 貿易、TC7 [建設,貿易,駐守]）
- survival 切片測：`unified seam OK`、`unified survival boundary OK`、`merchant restock OK`、`survival magnitude OK`
- 守恆/不變量：`投靠守恆整合 OK`（coin_eq）、`InvariantAudit population/faction/subteam 雙向 OK`

### world_sim 無凍死 trace（before/after，2 年純 NPC，unseeded）
追 **T1 = unified 經濟隊**（task reason `[unified]`，homeless：vault=-）：

| | BASE（改前 = HEAD~2 程式）| MINE（改後）|
|---|---|---|
| d30 | 建設[unified] food=0 famine=5 **mt=(-1,-1)（無目標、原地不動）** str1.0 | 建設[unified] food1.7d **mt=(2,4) dist=1 移動中** spd0.77 |
| d60 | **<gone>（約 30 日內餓死）** | 建設[unified] **food=12.5d（已抵達 fallback 目標補給回升）** |
| d90 | — | 建設[unified] food=0 famine=12（深危但仍在 active task，非凍結）|
| d120 | — | **<gone>（存活 ~90+ 日才死）** |

- **改前**：unified 隊覓食無格 → `_decide_unified` 早 return 不設 task → 原地 mt=(-1,-1) 凍住 → 30 日內餓死。
- **改後**：退次佳可派（移動/返家補給）→ T1 持續有動作、中途補給回 12.5 日存糧、存活拉長 3 倍才以無家深危隊身分餓死（believable 退化，符合「homeless deep-crisis 餓死 OK 只要不凍」）。
- 月取樣中 unified 隊 idle-freeze 計數：改前 0 / 改後 0（凍結並非停在 IDLE，而是停在舊 task + mt=-1；上表直接證 mt 改前懸空、改後有效）。

### 履約 / 探針 count（3 次 world_sim）
| run | engine_survival | restock_chosen | order_placed | shortage_buy | order_fulfilled |
|---|---|---|---|---|---|
| BASE（改前）| 7119 | 76 | 3858 | 2737 | **0** |
| MINE run1 | 2011 | 1326 | 4129 | 3138 | **0** |
| MINE run2 | 1821 | 98 | 3725 | 2704 | **0** |

- `restock_chosen` 維持（76 → 98/1326，同量級或更高）。
- `engine_survival` 大降（7119 → ~2000）：印證 fix 讓隊脫離每 tick 重 latch survival、改取 fallback 動作。
- order 機制（order_placed/shortage_buy）跨 base/mine 同量級 → 經濟 plumbing 未受影響。

## 連動風險

- `DecisionEngine.decide` 行為：現 = `rank()[0]`，tiebreak 用 applicable 順序的 index（等價原 strict `>` 首勝）。所有 decide consumer（TC1/4/6/7、commitment 測）已驗行為不變。**無已知連動風險**。
- `_decide_unified` 的 `current_option` 語意微調：改前由 `DecisionEngine.decide` 設為紙上 argmax（即使無格）；改後設為**實際派出**的 option。承諾慣性（COMMITMENT_BONUS）下一 cadence 會 bonus 實際派出項而非紙上 argmax — 這是預期且更正確（承諾追蹤真行為）。已由 `_test_dispatch_fallback` 鎖定。

## 待主 session 確認

1. **order_fulfilled=0 = unseeded 變異，非本塊回歸**：BASE（改前程式）同跑也 0.0%。`c4a739f` commit 訊息記的「履約 0→5」是切片 merge 當次幸運跑值；world_sim 無 seed（memory: multi sanity 無 seed），履約成交為隨機尾事件。本塊驗收的「履約不退」以 plumbing 量級（order_placed/shortage_buy/restock_chosen 維持）佐證；plan 的 `order_fulfilled≥5` 硬數字建議改判為「相對 base 不退」而非絕對門檻，或改用 seeded harness 量履約（屬 G1d/量測台債，非本塊）。
2. **切片缺口（藍圖標記 1）仍在**：loot/join/camp/beg 尚未還給經濟隊；無家深危 unified 隊最終仍餓死（fix 後不凍、過程有動作、存活拉長 → 達成標記 2 believable 退化目標，但根治需標記 1）。屬既知傘下債，非本塊範疇。

## 分支

`feat/dispatch-fallback`（worktree `.worktrees/dispatch-fallback`）。3 commits（Task1 rank、Task2 _decide_unified、Task3 verify=無 code 改故 handback 取代）。未 merge，待主 session review。
