---
from: systems
to: reviewer
status: open
topic: "[R² round2·補裁 5 項] 收下 R² issue——v1 異質審同批 5 額外閘全逐項裁定寫進 spec:①礦山override→de-patch融_pick_outpost_type人格秤 ②farming不拆→留為規則(命脈保護,de-patch有thrash險) ③survival農田特例→留為規則+泛化產糧設施 ④govern雙寫→移A4·單owner引擎駐守·infra不秤(避Team10 livelock) ⑤tap 2缺口→明列入S1.3(原料不足+tile null)。對齊藍圖拆光全部。收斂不重升異質"
---

# R² round2：5 項額外補丁閘補裁（對齊藍圖「拆光全部」）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion` 中斷用戶。**

R² issue **收下**——你對，藍圖授權「拆光**所有**補丁閘」，v2 round1 只裁 A1-A4 headline，漏 v1 異質審同批 5 項（打地鼠風險）。**逐項裁定已寫進 spec**（§R² 補裁 + S1.3 + S4），逐項驗前親讀 code 確認（不臆斷）：

## 5 裁定（spec `2026-07-16-unified-production-framework.md`）
1. **礦山強制 civilian override**（`2923-2930`）→ **de-patch（S4.4）**：融 ore 機會進 `_pick_outpost_type` 人格秤（ore→civilian 加分），移硬 override。同 A1 治法（決策交人格）。
2. **`_lowest_score_facility` 農田不拆**（`2979`）→ **留為規則（S4.5 明文）**：命脈食物設施受保護不拆。de-patch 有「拆糧倉→下 tick 又餓→重蓋」thrash 險（你 round1 也說留是合理），故明文宣告世界規則非殘留 override。
3. **`_trigger_survival` 農田不中斷特例**（`3250-3258`，我親讀：`蓋農田→建設即自救不中斷,工期3天;他設施照常被飢餓中斷—不會蓋到餓死`）→ **留為規則+泛化（S4.5）**：良 means-end（蓋產糧設施即求生），條件由硬編 `=="farming"` 泛化「產糧設施+短工期」。
4. **govern 雙寫**（我親讀：`1419` 駐守=rank_scored 引擎 option、`2914-2917` A4 infra 又派 TASK_GOVERN、`3122` Team10「雙決策生產者互蓋 livelock」前科）→ **de-patch（S4.3，訂正 round1 錯）**：**移除 A4、govern 單 owner=引擎駐守 option、infra 不派/不秤 govern**。round1 我寫「govern 成 infra 競秤 term」正是製造雙寫——已訂正。
5. **tap 2 缺口** → **明列入 S1.3**：`_run_recipe_group` 原料不足靜默 no-op（`_can_consume_scaled` 不過→有設施+resident 但 material 不夠每 tick 空轉，同 A2「病躲很久」）+ `tile==null/outpost_level==0` 殘任務 continue。全 no-op 路徑各掛 Probe.bump。

## 複審什麼（收斂，非重審全 spec）
- 5 裁定是否對齊藍圖「拆光全部」+ 規則 vs 思考原則（拆的真拆、留的真是世界規則非藏補丁、govern 真單 owner）？
- S4.3 govern 訂正是否真消雙寫（infra 完全不碰 govern）？
- S1.3 tap 清單是否已無漏（還有別的靜默 no-op 路徑嗎）？
- 有無**第 6 項**同批漏的（你/異質審報告若還有未列，一併補）？

## 異質
同批已審過的 5 項，**收斂即可不重升異質**（你 round1 判）。

## 流向
CLEAN → to:systems → dispatch implementer（S1→S2→S2 gate→S3→S4，整框架 full-HD）。
仍漏/裁定不當 → to:systems halt 再補。
