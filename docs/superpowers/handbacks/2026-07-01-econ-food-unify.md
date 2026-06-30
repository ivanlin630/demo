---
from: implementer
to: systems
status: open
topic: 統一食物存取(成長讀 effective_food)done + 乾淨 bed 證 pop 長;但 TASK_TRADE 未 fire(forest 覓食非交易)+無摩擦差異;貿易 delivery 路徑另有 silo
---

# Hand Back: 經濟底 — 統一食物存取（econ-food-unify）

branch: `worktree-agent-a5def1a564658357d`（基於 origin/main，已含 plan）

## 實作摘要（各 Task commit）
- **Task 1** `3b6d738` feat：`reaction_system.gd` `_score_expand`(:164) + `_evaluate_life_events`(:199) 的 food surplus gate 由 `t.resources["food"]`（私產 silo）改讀 `ResourceSystem.effective_food(state, team)`（coherent=私產+自家糧倉，既有 WS-2c accessor，對齊 ambition_ladder:49）。thread `state` 過 `_evaluate_person`/`_score_expand`/`_evaluate_life_events`（簽名加 state 參數），改 caller `evaluate_all`(:27,:33)。**無「交易糧 bump granary」特殊線**（統一非補丁鐵令守住）。`headless_test.gd` 加 `_test_econ_growth_reads_coherent_food`（私產0+糧倉500 隊 → 生育/擴張 gate fire；反向私產+糧倉皆空 → fail，不誤放寬餓隊）+ 更新既有 9 處 reaction 測 call site（簽名加 state，無糧倉測隊 → effective_food == 私產，行為不變）。
- **Task 2** `4b90811` test：`config/econ_bed.json`（forest 林業村 food窮/material富 + plains 糧鎮糧倉滿 + 中立商隊；低野心無好戰=隔離戰鬥噪音）+ `econ_bed_diagnose.gd`（跑 6 月，量 forest pop/effective_food/granary/task/food_buy）。

## 改檔
- `scripts/simulation/reaction_system.gd`：2 處 food-read 換 effective_food + state 接線（純讀取換源，守恆數學不動）。
- `scripts/debug/headless_test.gd`：新測 + 既有 reaction 測簽名對齊。
- `config/econ_bed.json` / `scripts/debug/econ_bed_diagnose.gd`：乾淨 bed fixture。

## 整環驗收（乾淨 bed）
**forest pop 6→12（長=Y）**，plains 6→12。effective_food 累積 30→2287（生育 fire→minor 每月成熟成人，`[PopMgmt] 長大` 連發）。**結構 bug 修好**：成長 gate 不再卡私產 silo，非 plains 隊累積食物即能興旺（修前注定餬口）。

### ★ 誠實報失敗/不確定（plan 要求，不粉飾）
1. **TASK_TRADE 從未 fire**：forest 靠 `覓食`(forage) 累積食物，**不是 plan 願景的「賣 material→買糧」交易環**。forest 雖發 food buy 單，live sim 決策中 `覓食` 勝過 `買糧`/TASK_TRADE（buyfood weight vs forage weight 之爭，非生產隊 archetype）。→ **貿易 delivery 路徑另有未統一 silo（決策權重 / 商隊配對），不在本 fix scope**。
2. **forest 漲幅 = plains（無摩擦差異）**：因 forest 走免費 foraging 非摩擦交易，「forest 興旺較 plains 費力」believability 未被本 bed 證實。要證差異，須先讓交易 delivery 真的 fire。
3. **bed harness 教訓（非產品 bug）**：`SimRunner.advance_tick(state, player_pos)` 用**傳入的 player_pos 參數**算 near/far，**非自算 player 隊位**。傳 `(-1,-1)`（如 food_ledger_diagnose）→ 全隊 far → **LOD 跳遠區人物反應 → 生育永不評估**。bed 改傳 `anchor_pos=(5,5)` 才驗到生育。曾試「player 隊當錨」→ 該隊被 raid 滅 → game_over 凍世界；改回 player_id=-1 + 純座標錨。

## 守恆 / regen / 摩擦
- coin_eq=0.00（4 scenario 全 0），InvariantViolation=0。
- **REGEN_RATE 未動**：forest food=3 / material=12 / plains food=8（bed 印證）。**未 nerf 地形**。
- **交易摩擦未碰**：市集可達/價差/運輸/granary 填法/order_system 全未改。
- framework S1-S6 全 PASS，DORMANT=0。
- 既有飢荒/絕境/生育測全綠（effective_food 是私產+糧倉 superset，舊私產足者仍足；真餓隊兩者皆空仍 fail）。headless `=== DONE ===` 無 SCRIPT ERROR。

## 連動風險（主 session 評估）
- `reaction_system` 簽名變更（`_evaluate_person`/`_score_expand`/`_evaluate_life_events` 加 state）：所有 caller 已接（production `evaluate_all` + 9 處 test）。grep 確認無殘留舊簽名。
- effective_food 換源**放寬**生育/擴張閾值（私產→私產+糧倉）：對定居隊正確（糧本就在糧倉），對餓隊不誤放寬（superset，皆空仍 fail，既有絕境測綠佐證）。

## 待主 session 確認 / 建議後續
1. **🟡 經濟底是否站穩？** 本 fix 證「成長讀 coherent 食物 → 累積 → 長 pop」整環（**accumulation gate 已通**）。但 plan 願景的「**賣特產→買糧**」交易 delivery **在 live sim 未 fire**（forest 覓食非交易）。若藍圖的「站穩」門檻 = 交易 delivery 真跑通+摩擦差異可見 → **尚有一條 silo（決策權重 buyfood vs forage / 商隊配對）未統一**，建議下一 arc。若門檻 = 累積 gate 不再卡地形（本 fix）→ 可宣告本層 done。
2. **量級**：surplus 7天 buffer / 擴張 food>100 閾沿用未調；bed 顯示足夠（生育穩 fire）。

## finishing
finishing skill → Option 3（Keep branch as-is），主 session merge。
