---
from: systems
to: reviewer
status: open
topic: "[R²·spec 審·大框結構重構] 統一生產框架 spec(de-patch 設施決策入思考層)——4 閘+死碼+seam 全 file:line 坐實(R① 免)。審設計 cohere+match 原則(框架管規則·思考歸引擎人格)+de-patch 真拆非搬家+非回歸。★建議升異質框外審(大框+藍圖系統2方對齊,商業異質審抓 3 缺口教訓)。CLEAN 才 dispatch implementer"
---

# R² merge-gate：統一生產框架 spec 審（大框結構重構）

> **[worker 守則] 卡住/疑義/授權不明 → handback `to:systems`，禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

生產 arc（甲，用戶定拆光生產/設施補丁閘融框架）。spec 鎖 → **你 R² 審設計 CLEAN 才 dispatch implementer**。

## spec
`docs/superpowers/specs/2026-07-16-unified-production-framework.md`

## 審什麼（設計 cohere + match 原則 + de-patch 真拆 + 非回歸）
1. **match 原則**（藍圖憲法精準版：框架管規則、思考歸引擎+人格）：
   - P1 製造 precondition（沒工坊不能製造）真的是**補缺規則**、非藏補丁？
   - P2/P3 是把決策**抽出**機制交人格 argmax、非把硬邏輯**搬進** facility code（換地方藏）？
2. **de-patch 真拆**：A1 override 移除後 farming 靠 deficit×personality 競秤——真 emergent、真飢隊仍會建農（非塌）？demolish 泛化不製造新硬 gate？
3. **granary seam 修**（P2-2）：facility-eval 食安改讀「本 tile 糧倉 + owner/resident 私產」非 wandering positional——**只改 facility-eval reader、不動消耗/survival positional effective_food**，這切法對？會不會誤傷定居隊消耗判定？
4. **常數分層**（C 表）：哪些人格化（決策門檻）vs 留 flat（世界物理）——分對？有沒有把世界物理常數誤人格化（工匠蓋工坊變便宜=怪）？
5. **★非回歸**：seam 限 `_evaluate_infrastructure`/`_pick_facility`/`options.gd:71`/`manufacturing tap`——不傷既有交易/飢荒/戰鬥？A2 precondition 不誤殺有設施隊製造？tap 禁耗 RNG/禁污染（觀測不變量）?
6. **觀測**：P1 tap（no-op 可見）落點對、byte-identical 可保？

## 前提坐實（R① 免——你複驗 file:line 非重查）
4 閘+死碼+seam 全 file:line（spec §根）：A1 `2942-2950`+`resource_system:386-390`；A2 `options.gd:71-72`+死碼 `2103-2121`+no-op `manufacturing:90-93`；A3 `2858-2931`；A4 `2914-2917`；farming 在 FACILITY_DEF `outpost:49`（移 override 不塌）。systems code 複驗過。**premise_contradiction 才 halt**。

## ★建議升異質框外審
大框結構重構 + 藍圖/系統**已 2 方對齊**（groupthink 風險，同 Opus 家族自驗抓不了自己的框）。unified-commerce 教訓：**異質家族（Fable）框外審抓 3 結構缺口**（賣方變現半環/belief 基底/absorb→settle 失明）homogeneous 漏。建議你這關升異質框外審抓結構盲點。**你裁**。

## 流向
CLEAN（+ 異質審過）→ to:systems → dispatch implementer（worktree TDD，P1→P2→P3，整框架完成才 measurer full-HD）。
有結構洞/premise_contradiction/搬家假拆 → to:systems halt（dispatch 前擋）。**這是 dispatch-gate,設計最後一審。**
