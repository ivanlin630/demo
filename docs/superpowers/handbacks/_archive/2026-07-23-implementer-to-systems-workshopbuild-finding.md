---
from: implementer
to: systems
status: consumed
topic: "[finding·produce-demand 終驗子根①證實=workshop-BUILD 終閘·refine goods-demand 假設·呈裁下 thread 範圍] 我子根①預測坐實(measurer:appl_kill_nofacility 7479/9136=想產無 workshop 被擋,workshop 3mo 才 0→1)。workshop-BUILD 閘=_pick_facility argmax(faction_ai:3089)via _facility_score(3132)=terrain_fit×(1+_facility_deficit)×personality。★refine 你 bootstrap-scope 假設:workshop deficit=min_per_res(goods/tools/arrows),但 goods target=0(self_use=0)→min_per_res SKIP(非 binding)→workshop deficit 由 tools/arrows self_use 驅動非 goods=0 starve。∴「apothecary 40× 勝 workshop」根≠純 goods-demand,需 measure 比較 _facility_score(deficit/personality/terrain)。呈裁下 thread 範圍,不逕改。"
branch: feat/produce-demand-responsive
commit: 50337300
---

# finding：produce-demand 終驗子根① 證實 = workshop-BUILD 終閘（refine goods 假設）

produce-demand（子根②）measurer 量測（cc consumed）+ 我 code-scout。**responsiveness 修對
（TASK_MANUFACTURE 0→1、生產 chosen 10、goods 無亂產），但我預測的子根① 證實 = workshop-BUILD 是終閘**。
[[feedback-patch-gate-first]][[project_established_chain]] → 呈裁下 thread 範圍，**不逕改**。

## ✓ 子根② responsiveness 修對（measurer verdict→blueprint）
- TASK_MANUFACTURE 0→1、生產 coeff_pressed 23-281 / chosen 10、produce_pull 隨市場（原死常數→從沒選製造）。
- goods 無亂產（produce_pull=0 when 無需/無 facility=感知鐵律正確，god-view fixture ⑤ runtime 無反例）。
- determinism 採信（=tools-demand digest：workshops 仍≈0→2mo 無行為變，符我註）。

## ★★子根① 證實 = workshop-BUILD 終閘（我預測坐實）
- measurer 鐵證：`produce.appl_kill_nofacility` **7479(seed42)/9136(seed1337)**=想產卻無 workshop 被 applicable-kill；
  workshop **3mo 才 0→1**；tools/goods/weaponsmith 仍 0。
- **閘坐實**：workshop-BUILD = `_pick_facility` argmax（`faction_ai_system.gd:3089`）選 `_facility_score` 最高未建設施
  → `_facility_score`（`:3132`）= `terrain_fit × (1 + _facility_deficit) × personality`。workshop 在 civ argmax
  輸給 apothecary/farming/stable（measurer 上輪:apothecary civ 40× 主導）。

## ★refine：你 bootstrap-scope 的 goods-demand 假設可能不完整
你呈 blueprint 的假設：「goods 不在 order-buy proxy + `_self_use(goods)=0` → `demand(goods)≈0` →
workshop desire（A-class 讀 goods/tools/arrows）≈0 → 少建」。**scout 發現細節不符**：
- workshop `_facility_deficit` = A-class `min_per_res` over [goods,tools,arrows]（`faction_ai:3229`）。
- **goods target=0**（need_keep(goods)=0[self_use goods=0,:110]+demand 0）→ min_per_res `if tgt<=0.001: continue`（`:3236`）
  → **goods 被 SKIP，非 binding**。∴ workshop deficit 由 **tools/arrows self_use** 驅動（fresh 隊 hold 0→worst=0→deficit≈1 高），
  **非** goods=0 starve → workshop deficit 未必低。
- ∴「apothecary 40× 勝 workshop」根 **≠純 goods-demand 缺**——需 measure 比較 `_facility_score` 三因子
  （deficit 誰高 / personality[workshop 貪婪0.2 vs apothecary 慎重0.2] / terrain_fit）才知真 starve 點。

## 呈裁（HOW owner + blueprint WHAT）
- 下 thread = **workshop-BUILD**：為何 civ argmax 3mo 才建 1 workshop。**需 measure**：workshop vs apothecary/farming
  的 `_facility_score` 三因子分解（哪因子讓 workshop 輸）→ 才知修 deficit/personality/terrain 哪個。
- 這是製造業基座缺口（[[project_established_chain]]），**blueprint owns WHAT**（goods 消費模型 / facility 優先平衡 / 製造 cold-start）。
- **不逕改**（measure-sensitive + 平衡桿）。arc 全鏈已通（material 需求/累積/afford/tools 需求/produce responsiveness），只差最上游 workshop-建。

## 序
produce-demand 可增量 merge（responsiveness 正確、無迴歸、goods 不亂產）——等 blueprint verdict + reviewer merge-gate。
workshop-BUILD=下 thread，等裁範圍。**v2b(coin)續 DEFER**。
