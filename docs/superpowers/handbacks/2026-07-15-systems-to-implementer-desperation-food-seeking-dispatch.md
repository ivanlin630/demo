---
from: systems
to: implementer
status: open
topic: "[DISPATCH] 絕境找糧真根修 A+B+C——新分支feat/desperation-food-seeking;R②v2 CLEAN;TDD;守感知鐵律+憲法閘"
---

# Dispatch：絕境找糧真根修（A+B+C）

spec（讀全文，R②v2 收斂細節在內）：`docs/superpowers/specs/2026-07-15-desperation-food-seeking.md`
R②v2 CLEAN：`docs/superpowers/handbacks/2026-07-15-reviewer-to-systems-desperation-food-seeking-r2v2-clean.md`
承：execlock thrash-fix 是換皮（真根=買糧海市蜃樓+隊困死），執行鎖廢。

## 新分支（execlock 廢棄，別基於它）
`feat/desperation-food-seeking`，worktree `.worktrees/desperation-food-seeking`，base = **最新 origin/main**（`bcb205fe`+，含 cherry-pick 的交易/威脅 tap + seeded bed + 死亡偵測修）。先 `git fetch && git log origin/main -1` 確認 base。

## 做什麼（spec 為準，摘要）
- **A 買糧 look-before-leap**：`decision_context` 加 `has_buyable_food`＝`received_sell_orders` 含 food 且 ≤`MERCHANT_MAX_RANGE`（**不濾 stale**，血訓）。gate `options.gd:137` 買糧 applicable。
- **B 遷移找糧**（新 survival option）：`food_seek_target`＝VisionSystem **視野內**（VISION_RADIUS×地形係數，**禁自由半徑常數**）wild_game（**繼承 FORAGE_VIABLE_POP** pop 守衛）/ received 食物賣單 pos，**皆過 PathSystem 可達過濾**。新 `遷移找糧` option（applicable+to_task+SURVIVAL_OPTION_SET）+ terms weight。**抵達→`TaskArbiter.release`→引擎重秤**（★零新 try_set 落點，憲法 baseline 不變）+ latch/timeout。
- **執行鎖不碰**（`_in_survival` 那套廢，不在此分支）。

## ★硬約束（R②抓的，別重犯）
1. **感知鐵律**：has_buyable_food 只讀 received（無遠端讀板）；wild_game 只掃 VisionSystem 視野（無 god-view/自由常數）。
2. **pop 守衛**：wild_game 支必繼承 `population<=FORAGE_VIABLE_POP`（否則 pop>15 追不到野味死）。
3. **可達性過濾**：food_seek_target 過 PathSystem（防選回不可達 target 死循環）。
4. **憲法閘**：抵達走 `TaskArbiter.release`→引擎重秤，**零新 try_set 落點**。若發現非得新 mutation site＝**紅旗停下報 systems**（別自更 baseline）。
5. **不濾 stale received**（血訓 G1d/r3）。

## TDD
1. 構「當地無糧 + 視野內可達 wild_game」→ 斷言隊選 遷移找糧移向它（非守買糧）+ 抵達 release 後覓食承接。
2. 構「pop>15 + 視野有野味」→ 斷言不選 wild_game 遷移（走賣單支或連貫死）。
3. 構「真四方無糧/target 不可達」→ 斷言連貫嘗試序 + **不 dispatch→timeout→dispatch 死循環**。
4. 標準：determinism 兩跑同（純確定性 finder）；憲法 sites=29 不變（零新 try_set）；headless 零新增。

## 完成後
→ measurer 全-HD 重跑（Team20+Team18+新死隊 specimen，reproducible）→ QA 故事複判連貫窮死 → blueprint 批 merge。
完成判定 = systems + reviewer/QA。scope 疑義/非得新 try_set → 走 `to:systems`（不自標 REDO、不自更 baseline）。
