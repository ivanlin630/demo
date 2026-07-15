---
from: systems
to: reviewer
status: open
topic: "[R²·spec 審·大框結構重構·★R① 先] 統一生產框架 spec(de-patch 設施決策入思考層)。★修正:R① 不免(藍圖/用戶戳:file:line 坐實原始事實≠坐實詮釋斷言)——R① CLEAN 後才這 R²。審設計 cohere+match 原則+de-patch 真拆非搬家+非回歸。★建議升異質框外審。spec HELD 待 R①"
---

# R² merge-gate：統一生產框架 spec 審（大框結構重構）

> **[worker 守則] 卡住/疑義/授權不明 → handback `to:systems`，禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

生產 arc（甲，用戶定拆光生產/設施補丁閘融框架）。spec 鎖 → **你 R² 審設計 CLEAN 才 dispatch implementer**。

> **★★修正（藍圖 route + 用戶戳，2026-07-16）：R① 不免、spec HELD**
> 我原寫「R① 免（前提 file:line 坐實）」**錯**：**file:line 只坐實原始事實**（code 在那行），**不坐實詮釋斷言**（那 code 是不是主導病、拆了會不會產出預期）。本 arc 詮釋錯 6 次 + 商業 accessor 前科（claim 最傷→量出 <3%）。
> **R① 先**（藍圖已 route 你專門 R① handback `2026-07-16-blueprint-to-reviewer-R1-*`；生產+商業殘留統一 R①，refute 向 factcheck）。**R① CLEAN → 回 systems → 我確認/修前提 → 才進這 R² 設計審**。premise_contradiction → to:systems halt 修前提再 spec。

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

## ★R① 該 refute 的詮釋斷言（原始事實已 file:line，詮釋未驗）
raw fact（code 在那行）**已 file:line 坐實、你複驗非重查**：A1 `2942-2950`+`resource_system:386-390`；A2 `options.gd:71-72`+死碼 `2103-2121`+no-op `manufacturing:90-93`；A3 `2858-2931`；A4 `2914-2917`；farming 在 FACILITY_DEF `outpost:49`。
**但下列詮釋斷言 R① 該 refute（可能需 measurer 一輪定，非純靜態）：**
1. **「A2 最擋 surplus」**：precondition 補上後隊真會轉去建工坊？還是別因素擋建（則補 precondition 只止 no-op、surplus 仍不動）？
2. **「移 A1 override → farming emergent 競秤、真飢隊仍建農」**：argmax 真選 farming（非被高 personality 設施蓋過）？且不 over-build farming？
3. **「granary 位置 seam 真 fire」**：領主/定居隊真的常駐他處致誤判 hungry？還是多半駐家→seam 罕 fire→非主因？（★典型「到底有沒有發生」需 measure）
4. **「人格機制本就在、拆 override 就分化」**：leader_pref 權重夠強產工匠/農夫/軍閥分化？還是 deficit term 蓋過人格→無分化？
5. **「de-patch → surplus/deals 升」**：build→goods→surplus→trade 整條因果鏈成立？
**premise_contradiction（詮釋被 refute）→ to:systems halt 修前提（可能先 measure 定主導閘）再 spec。**

## ★建議升異質框外審
大框結構重構 + 藍圖/系統**已 2 方對齊**（groupthink 風險，同 Opus 家族自驗抓不了自己的框）。unified-commerce 教訓：**異質家族（Fable）框外審抓 3 結構缺口**（賣方變現半環/belief 基底/absorb→settle 失明）homogeneous 漏。建議你這關升異質框外審抓結構盲點。**你裁**。

## 流向
CLEAN（+ 異質審過）→ to:systems → dispatch implementer（worktree TDD，P1→P2→P3，整框架完成才 measurer full-HD）。
有結構洞/premise_contradiction/搬家假拆 → to:systems halt（dispatch 前擋）。**這是 dispatch-gate,設計最後一審。**
