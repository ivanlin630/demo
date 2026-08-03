---
from: systems
to: reviewer
status: consumed
topic: "[R²審L1 intra-faction distribute de-patch spec(2026-08-03-L1-intra-faction-distribute-depatch-HOW.md)·root三層CONFIRMED(measure坐實jia-distribute-zero-diagnostic.json)之L1:領主→自家居民distribute讀received_buy_orders(team_known co-location閘)即使goal_resolver:166註intra-faction合法→領主坐擁3940食居民餓死不救=過度套感知鐵律補丁閘·blueprint ratify intra-faction內部telemetry合法perceive非god-view(感知鐵律治cross-faction fog-of-war,SCOPE硬界僅自勢力)·修=de-patch換感知源:新helper _intra_faction_food_buy_orders直掃自家faction static居民active_orders(回傳同received_buy_orders shape)→_distribute_candidates:154換一行,下游for/order_id/pos/util byte-identical·★審點:①genuine不變(util relief+coin一字不改非crank)②★SCOPE cross-faction不破(_deliver_candidates:220+demand需still gated received_buy_orders不動,只改intra-faction distribute)③determinism零RNG Dictionary插入序④感知鐵律intra-faction carve-out(invariants.md已記)+constitution_gate新site標legit gate-ok⑤無框內平行求解器(換源非增殖solver)·尤②cross-faction隔離+①非crank最需戳·CLEAN→dispatch implementer build驗distribute.dispatch/food_delivered真>0"
---

# R² 審 L1 intra-faction distribute de-patch spec

**spec**：`docs/superpowers/specs/2026-08-03-L1-intra-faction-distribute-depatch-HOW.md`
**root**：§5 執行塌陷 root 三層之 **L1**（measure 坐實 `docs/measurements/2026-08-03-jia-distribute-zero-diagnostic.json` test_B/D + §5 probe dump；known_issues「§5 執行塌陷 root REFINE」段）。
**blueprint ratify**：intra-faction 內部 telemetry＝感知鐵律合法 perceive、SCOPE 硬界僅自勢力（invariants.md「intra-faction 內部 telemetry carve-out」2026-08-03）。

## 一句話修法
補丁閘 de-patch：`_distribute_candidates` 感知源從 `received_buy_orders`（team_known co-location 閘）→ 新 helper `_intra_faction_food_buy_orders`（直掃自家 faction static 居民 active_orders、同 shape）。**下游 byte-identical**。

## ★審點（R² refute checklist）
1. **genuine 非 crank**：util（relief_term + coin_term）**一字不改**，只感知源變。確認非藉機 crank 分數。
2. **★★SCOPE cross-faction 不破（最需戳）**：新 helper 只掃 `faction_id==team.faction_id && is_resident_static`。**`_deliver_candidates`（cross-faction 賣 :220）+ `demand()`（need_oracle :232）仍讀 `received_buy_orders`＝cross-faction 感知鐵律完整 gated、不動**。確認 de-patch 沒漏到 cross-faction（感知鐵律真只 intra-faction 開孔）。
3. **determinism**：純算術 + Dictionary 插入序（零 RNG、鏡射 :145 claimed 掃）。三跑 byte-identical。
4. **感知鐵律 + constitution_gate**：intra-faction carve-out 合法（invariants.md 已記）；新 helper 讀 `state.teams[tid]` resident 態＝constitution_gate god-view detector 該咬 → 需標 legit gate-ok（intra-faction 註，同 `consolidate_target_of` 範式）。確認 gate-ok 標記 legit。
5. **無框內平行求解器**（框內補丁 lens）：de-patch＝換單一感知源，非增殖 option/term/solver；買單 pipeline（resident post shortage_buy）不變。確認非「框架裡開分支繞過」。

## 邊界（spec 已列、reviewer 可加戳）
- 居民餓但未 post buy-order 的 timing gap → helper 該 tick 漏、下 cadence 補（不 synthesize 無 order_id 分配保 fulfillment plumbing）。認需補則另議、別塞本 slice。

**CLEAN → 回 systems → dispatch implementer build → measurer 獨立驗 execution-end（distribute.dispatch/food_delivered 真>0 + cross-faction 數字不變 + determinism + gate 綠）→ blueprint JUDGE merge。** 卡/BLOCKER → 報 `to:systems`。
