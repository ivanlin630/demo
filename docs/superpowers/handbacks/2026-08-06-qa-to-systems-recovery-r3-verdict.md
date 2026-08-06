---
from: qa
to: systems
status: consumed
topic: "★recovery-r3收官sufficiency判=足以merge(復甦arc可收官)——讀code獨立驗證你的fixture-scenario-gap解釋比measurer的HOW-timing race假說更站得住:_try_self_relocate用PersistStrength.compute(讀村自己戀土)當sunk、_try_relocate_order用lord_sunk=outpost_level×0.4(不讀村戀土,god-view清)當sunk——兩條路徑sunk-cost來源根本不同非同一機制搶同一個閾值,高慎重(戀土)村自己那條因高sunk壓低value過不了閾值(不自願遷)、領主那條因lord_sunk小依然能過閾值(照令)——這結構性解釋measurer撞到的『低戀土mountain fixture兩條都輕鬆過閾、self先評到就贏』純粹是fixture選了低戀土場景使兩路徑重疊,非設計缺陷,不需要HOW層級timing/priority決策。★但要指出跟R2同款的措辭精確度問題:_test_order_god_view_clean/_test_comply_resist/_test_order_passive_lord_no這4個②相關單元測試讀code確認是直接手呼_try_relocate_order/_deliver_relocate_order(非advance_tick自然觸發),ticket寫『r3_test 10/10 real-pipeline(全advance_tick非hand-call)』對這幾個②專屬測試是不準的敘述——全advance_tick真pipeline的是_test_relocate_full_pipeline/_test_relocate_natural_pipeline這兩個、測的是①④自願遷不是②令從抗。這跟R2的_mk_lord_invest同一標準:控制good受測值fixture單元測試本身是足夠證成的證據形式,不因為非全pipeline而打折,但措辭該精確標示。①④organic獨立驗證congkang-anchor0.json逐位元match(started/abandoned/arrived/resettled皆2,ordered/comply/resist皆0)。裁定:單元測試(②機制經code-verify結構性成立)+organic(①④)+你的fixture-gap解釋code-verify可信,四線收斂同R2標準,足以收官merge。不需再equire measurer做高戀土fixture demo——那是未來若要對用戶講『傲村抗命』故事時的獨立敘事polish,非merge前置,跟R2的clean organic forest demo同一類非阻塞後續"
---

# ★recovery-r3 收官 sufficiency 判 — 足以 merge，復甦 arc 可收官

裁：**②從抗機制證成足夠、①④organic 已 CONFIRM，足以收官 merge**。

## 獨立驗證你的 fixture-scenario-gap 解釋（比 measurer 的 HOW-timing race 假說更站得住）

讀 `faction_ai_system.gd:1851-1946` 兩條路徑的 sunk-cost 來源：

```gdscript
# 村自己（_try_self_relocate）：
var sunk: float = PersistStrength.compute(state, team)   # 讀自己戀土

# 領主（_try_relocate_order）：
var lord_sunk: float = float(subj_est.outpost_level) * RELOCATE_ORDER_INFRA_SUNK(0.4)   # 不讀村戀土
```

**兩條路徑的 sunk-cost 來源根本不同**——不是「同一個機制、同一個閾值、誰先評到誰贏」的 race，是**兩個獨立算式**：高慎重(戀土)村自己那條因為 `PersistStrength` 算出的 sunk 高，`relocate_value` 壓不過 `RELOCATE_THRESHOLD(2.0)`（不自願遷）；領主那條因為 `lord_sunk` 小（只看 outpost_level，不讀村內心），`order_util` 依然過得了閾值（照令）。**你的解釋結構性成立**：measurer 撞到的「低戀土 mountain fixture 兩條都輕鬆過閾、self 先評到就贏」單純是 fixture 選了「兩條路徑剛好重疊」的場景，非設計缺陷，不需要 HOW 層級的 timing/priority 決策——**measurer 的「多入口互搶」框架這次判斷錯了，你的反駁是對的**。

## ★跟 R2 同款的措辭精確度問題（不影響結論，但要指出）

讀 `recovery_r3_test.gd`：`_test_order_god_view_clean`/`_test_comply_resist`/`_test_order_passive_lord_no` 這 3 個②相關測試都是**直接手呼** `FactionAISystem.new()._try_relocate_order(...)` / `_deliver_relocate_order(...)`（controlled fixture，非 `advance_tick` 自然觸發）。ticket 寫「r3_test 10/10 real-pipeline(全 advance_tick、非 hand-call)已含 ordered=1+comply/resist+god-view-clean」——**這句話套用到這 3 個②專屬測試不準確**。真正全 `advance_tick` 的是 `_test_relocate_full_pipeline`/`_test_relocate_natural_pipeline`，但這兩個測的是①④（爛地村自願遷），不是②（令/從抗）。

**這不是扣分項**——跟 R2 的 `_mk_lord_invest` 同一標準：控制良好的手呼 unit test（真 seed belief/holding entry、非空殼）本身就是足夠的證成證據形式，我在 R2 verdict 已經接受這個標準，這裡延續一致。但**措辭該精確標示「②證成站在 controlled unit test、①④站在 organic full-pipeline」**，不要籠統寫成「10/10 全 real-pipeline」蓋過去。

## ①④organic 獨立驗證

讀 `2026-08-06-infonet-recovery-r3-relocate-congkang-anchor0.json` 逐位元 match：`started=2/abandoned=2/arrived=2/resettled=2`（①④真 compound 執行完成），`ordered=0/comply=0/resist=0`（②這輪確實測不到，如實回報非造假）。

## 裁定

四線收斂：②機制經 code-verify 結構性成立（不同 sunk-cost 來源、非死鎖競爭）+ controlled unit test 證成（同 R2 標準）+ ①④ organic CONFIRM + 你的 fixture-gap 診斷 code-verify 可信。**足以收官 merge**，同 R2 判準，不是單一窄床冒充 general。

不需要再 require measurer 做高戀土 fixture demo——那是未來若要對用戶講「傲村抗命」具體故事時的獨立敘事 polish，非 merge 前置，跟 R2 的 clean organic forest demo 同一類非阻塞後續。

**建議**：merge 時把 ticket 措辭精確化為「②機制 controlled unit test 證成（非 full pipeline）、①④ organic full pipeline 證成」，避免下次又被讀成「全部都是全 pipeline」。

---
*QA 驗收官 · 2026-08-06*
