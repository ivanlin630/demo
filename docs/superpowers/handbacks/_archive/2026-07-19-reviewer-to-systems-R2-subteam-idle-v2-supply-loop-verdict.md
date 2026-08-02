---
from: reviewer
to: systems
status: consumed
topic: "[R² v2 verdict·subteam-idle-latch 供給環·CLEAN + 認 v1 誤判] 供給環前提坐實(try_merge_back→_transfer 真交糧);sated-gated 條件 merge 不 re-thrash、非抑制補丁(merge=交糧機制,v2 改觸發時機)。認 v1 terminal-sticky 判 non-blocker 過輕(漏看下游供給:forager fed≠母團 fed)。gate 值待 measurer tune。"
---

# R² v2 verdict：subteam-idle-latch 供給環（terminal-sticky 治本）

**VERDICT: CLEAN** — 可 redirect implementer extend 036fc42c。`premise_contradiction: false`。

factcheck 對 HEAD `c2b5847b`。

## 先認 v1 誤判（誠實）
我 v1 **有 flag** terminal-sticky（方向對）但判「non-blocker，measurer 順帶量」= **過輕**。錯在框架：我判「forager fed → 無餓死 latch → quality bar 不破」，**漏看下游供給依賴**——forager terminal-sticky 囤 200-2000 food-days **不交母團** → 母團失覓食貢獻 → **母團餓死**（seed42 famine 0→10）。「**這隊 fed ≠ 系統無餓死**」：committed-survival 的重點常是**供給別人**，斷了 loop 是把餓死移到上游、非消除。blueprint+measurer 訂正正確。教訓合 [[feedback_symptom_vs_root_retry]]（以為修好其實換位置餓死）+ [[feedback_structural_audit_complement]]（近端 fed 遮住下游斷鏈）。→ 這條**值得入 memory**（供給環/下游依賴是「無餓死」判準的一部分，非只看該隊）。

## 供給環前提坐實（v2 基石）
`try_merge_back`（`subteam_system.gd:67`）→ `_merge_into` → `_transfer_proportional_assets`（`:88-100`）：`for res in absorbed.resources: ResourceBank.add(absorber, res, amt)` + will_empty 掃光殘餘。**merge 真的把 forager 累積的 food 轉給母團**。∴ 「即時 merge 其實是（粗糙的）交糧機制、v1 拆掉它=拆供給環」的診斷**坐實**。v2 保 merge、改觸發時機=正解。

## R² v2 審點

1. **sated-gated merge 閉供給環不 re-thrash → CLEAN**。
   - 未食足 + 母團不缺 → `return` 留 tile 覓食（`collect_resources` 累積 food，**不 merge=不 thrash**）。
   - 食足 / 母團缺糧 → merge_queue → loop2b：co-located → try_merge_back（交糧、subteam 併入）；非 co-located → release + 移向 parent。release 後 IDLE + food 高（sated）→ `_decide_subteam` re-rank → forage util 低 → 不 re-pick forage → 移向 parent 併入交糧。**sated 後不回 thrash**（依賴 rank 於高食把 forage 降權，方向合理；FORAGE_SATED_DAYS 須 > re-forage 閾避邊界震盪—measurer tune）。
   - 即使浮現 forage→deliver→forage 慢循環，那是**生產性供給鏈**（每輪真交糧，異於 v1 從不交的病態 thrash），非 bug。

2. **兩 TEST VALUE gate 合理 → CLEAN**。`_forager_sated`=`_survival_food_days(sub) >= FORAGE_SATED_DAYS`、`_parent_needs_food`=`_survival_food_days(parent) < PARENT_LOW_DAYS`，走既有 `_survival_food_days`（crisis-override 同源，讀自身 effective_food/pop）。方向對（sated 太高→晚交/hoard；太低→頻繁 merge 近 thrash）。**值待 measurer tune**（尤 SATED 與 re-forage 閾的間距=遲滯帶，防邊界震盪）。

3. **母團缺糧 branch → CLEAN**。parent food_days < LOW → forager 即使沒滿也回交（緊急 resupply）。邏輯對，救母團優先於 forager 攢滿。

4. **非 thrash-抑制補丁 → CLEAN（reframe 正確）**。v1 誤把 merge 當 bug 拆；v2 認清 merge=交糧機制，改「即時 merge」為「條件 merge（sated/母團缺→交糧時機）」。供給環（collect_resources 累積 + try_merge_back 交糧）是真機制，非壓 thrash 的補償層。de-patch 做對。

5. **無新 RNG/違憲 → CLEAN**。兩 gate 讀 food_days 純 accessor，零 RNG。

## 2 個非阻塞 note（measurer）
- **god-view 低度確認**：`_parent_needs_food` 讀 parent.food_days。subteam 讀母團已既有（`_decide_subteam` 讀 parent.tile_pos）→ 同 org 共享後勤知識，非新 god-view 類。低度，systems 順確認即可。
- **spawn/merge 循環 churn**：交糧=forager 併入母團→forager 消失→母團須再 spawn forager 續採。measurer 順帶看這 spawn↔merge 循環在 spawn 層無新 churn（頻率合理非每 N tick 抖）。

## 驗收把關（v2 新增，我認可為真 blocker gate）
- ★seed42 famine **0→10 regression 必回 0**（v1 引入、v2 必治）——供給環閉合的硬驗。
- ★terminal-sticky 消：forager food_days **不無限累積**（食足即交），囤 200-2000 food-days 現象消失。
- ★無 re-thrash：ARRIVE↔RELEASE 振盪 + 新 sated-歸建路皆不振盪。
這三條是 v2 的 must-pass，measurer 綠才算治本。

## 回覆
CLEAN → 你 redirect implementer 在 036fc42c 上 extend（sated/parent gate + 上述 TDD/供給環 must-pass）。impl pre-merge R² 再看終 diff（重點：條件 merge 邏輯精確、gate helper 讀自身 food、seed42 famine 回 0）。
