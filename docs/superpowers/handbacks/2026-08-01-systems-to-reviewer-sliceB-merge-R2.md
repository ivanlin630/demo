---
from: systems
to: reviewer
status: open
topic: "[R²融合驗(merge前)甲SLICE B領主分配·branch feat/logistics-sliceB-distribution de33885f·dev-verify 6/6綠(price光譜仁君0.33<公道1.0<貪3.0連續非gate+仁君/貪candidate fire+免費/付費coin守恆+convoy regression 6/6+constitution74+determinism byte-identical+不凍teams91)·審真code diff(goal_resolver+95 _distribute_candidates/interaction+34 override_ask/faction_ai+20/bed+150)·★四約束grep硬檢在真code非只spec:①候選非特判(grep goal_resolver無if kind==distribute繞argmax)②連續weigh非硬gate(grep util/price_factor無if greed>X階梯)③override_ask=local_value×price_factor modulation非新定價機制④復用_market_visitor_sell+TradeValuation零新market/order class·★flag(非merge-blocker):warring distribute.dispatch=0(scarce領主無餘糧)mechanism綠但organic firing未證→§5一次合量查分配真fire·merge-care:stale-base handback刪行=branch-point artifact 3-way保main·CLEAN→我merge+跑merge-result lord_distribution_bed驗(SLICE A convoy-fixture-fail教訓)"
---

# R² 融合驗（merge 前）甲 SLICE B 領主分配政策

**branch**：`feat/logistics-sliceB-distribution` @ de33885f。dev-verify **6/6 綠**（price 光譜 仁君 0.33<公道 1.0<貪 3.0 連續非 gate + 仁君/貪 candidate fire + 免費/付費 coin 守恆 + convoy regression 6/6 + constitution 74 + determinism byte-identical FBF182FA + 不凍 teams91）。

## 審真 code diff（非只 spec）
- `goal_resolver.gd +95`：`_distribute_candidates`（光譜候選 + persona util）。
- `interaction_system.gd +34`：`override_ask` 注入口 + free-end guard 放寬。
- `faction_ai_system.gd +20`：deficit 偵測 / unrest 耦合 / tap。
- `lord_distribution_bed.gd +150`：dev-verify bed。

## ★四約束 grep 硬檢（在真 code、blueprint 指定）
1. **候選非特判**：goal_resolver `_distribute_candidates` 產候選入同一 argmax；grep 無 `if kind=="distribute"` 在 dispatch/決策層繞 argmax。
2. **連續 weigh 非硬 gate**：util/`_price_factor` 無 `if greed>X`/`if honor>X` 階梯、只連續乘除。
3. **價格 modulation 非新機制**：`override_ask = local_value × price_factor`，乘現成 `TradeValuation.local_value`；無新 price 常數表/class。
4. **復用市場非新 class**：DELIVER 走現成 `_market_visitor_sell`+`TradeValuation`+coin 轉；grep 無新 market/order class。
- **感知鐵律**：deficit 讀本勢力自有居民（intra-faction 合法）。
- **全量 tap**：distribute util per-option / DELIVER 量 / deficit runway / unrest 源。

## ★flag（非 merge-blocker、但你知情）
- **warring `distribute.dispatch=0`**（此窗 scarce 領主無餘糧）→ **mechanism 綠但 organic firing 未證**（unrest 耦合活 add137/reduce5）。**§5 一次合量必查「分配真 fire?」**（execution-end、[[feedback_verify_execution_end]]）。非 merge-blocker（mechanism 對、gates 綠、bed 證光譜），是合量的 must-check。

## merge-care
- stale-base：diff 顯示 handback 刪行＝branch-point artifact（分支早於我 handback commits）、3-way merge 保 main 的、非真刪。驗無 SLICE A convoy code 衝突。
- **CLEAN → 我 merge + 跑 merge-result `lord_distribution_bed` 驗**（SLICE A convoy-fixture-fail 教訓：merge 後先驗 slice test）。有洞 → 回 `to:systems`。
