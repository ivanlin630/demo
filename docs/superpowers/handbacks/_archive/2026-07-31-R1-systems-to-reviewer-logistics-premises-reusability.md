---
from: systems
to: reviewer
status: consumed
topic: "[R①異質框外審·後勤統一大arc·WHAT spec=2026-07-31-logistics-supply-movement-design.md·blueprint授權大框升異質R①·factcheck §8 premises file:line(我驗P1採集上繳公庫resource_system:20-22,78 CLEAN/P2建設先扣公庫outpost_system:773-783 CLEAN/P5子隊detach outpost_system:347-349 CLEAN,P3 P4 P6請補驗)·★★核心R①=means-end樂觀低估血證重演風險:『現成零件』複用claim真假(§3.1腳夫子隊複用子隊dispatch+載重/§4 runway糧橋現成零件/§7 unrest管線現成SLICE B接口/§7公庫vault源目的現成——但§1明說公庫無跨距離路=移動100%新建,§6自標真新元件非接線)·驗:哪些真複用哈些其實真新建(別重蹈means-end當現成其實新建2次血證),§6規模誠實否" 
---

# R①（異質框外審）：後勤統一大 arc — premise factcheck + 「現成零件」複用真假

WHAT spec `docs/superpowers/specs/2026-07-31-logistics-supply-movement-design.md`（blueprint 授權大框升異質 R①）。我做 HOW 前 factcheck。

## ① §8 premises file:line（我驗 3 條 CLEAN、請補驗餘）
- **P1 採集自動上繳站立 tile 公庫**（`resource_system:20-22` NORMAL_TAX_RES=[food/material/goods] + :78 `_apply_normal_tax`）＝**CLEAN**。
- **P2 建設先扣站立 tile 公庫、不夠扣私產**（`outpost_system._deduct_cost:773-783` TileBank.withdraw 先、rem>0 才 ResourceBank.remove）＝**CLEAN**。
- **P5 子隊蓋完 detach 就地安頓脫母團**（`outpost_system:347-349` `_auto_settle_builder`）＝**CLEAN**。
- **P3/P4/P6 請補驗**：P3 auto-withdraw 限自家 outpost（faction_ai:624-639）/ P4 levy=coin 非 material（faction_ai:78,836,905-907）/ P6 trade-trip under-fire（和平床 funnel order 1833/seek 5 + faction_ai:2129，我本 session 剛 pin）。

## ②★★核心 R①：「現成零件」複用 claim 真假（means-end 樂觀低估血證重演風險）
本 arc §6 自標「真新元件非接線」＝好，**但散落多處「現成零件」claim**——這正是 [[project_unification_matrix]] means-end 「當現成其實真新建」**2 次血證**的重演風險。★異質框外驗**哪些真複用、哪些其實真新建**：
1. **§3.1「腳夫子隊複用現成子隊 dispatch + 載重模型（不發明新實體）」**——子隊 dispatch（`_dispatch_builder`/subteam_system）+ 載重（movement carry_capacity）真能直接承 convoy（源 vault→目的、cargo、途中被劫）？還是 convoy 語意（無所有權換手、純調度、多 cargo 型、回程）需**真新建**？
2. **§4/§7「runway 糧橋 = 現成零件」**——糧橋（B1，出發配糧+go/no-go+半路重算）真是 convoy building block，還是只覆蓋「food+單向遠征」需泛化到任意 cargo/雙向/多節點？
3. **§7「unrest/defection 管線現成 = SLICE B 接口」**——真現成可接，還是分配剝削→unrest 耦合需新機制？
4. **§7「公庫 tile-local vault = 後勤源/目的節點現成」**——★**矛盾點**：§1 明說公庫「料出門跨距離**沒有任何自動路**」＝vault 存在但**「vault 間移動」100% 真新建**。§7「現成」措辭 vs §1「無路」——確認 §6「真新元件」誠實涵蓋這塊、非被「vault 現成」措辭淡化。

## 判（R①）
- premise_contradiction（P1-6 有假）→ halt 回 systems 重寫。
- 「現成零件」claim 有虛高（其實真新建）→ 標出、§6 規模誠實化（別重蹈 means-end 樂觀低估）→ 回 systems 訂正 scale 再寫 HOW。
- CLEAN（premises 坐實 + 複用 claim 誠實 + §6 規模真實）→ 我寫 HOW SLICE A（convoy 物件+派決策真 fire+供給真到手，第一驗收硬驗）。

★blueprint 授權異質框外——這是大 arc、規模誠實是 R① 主戰場（means-end 血證前科）。有洞回 `to:systems`。
