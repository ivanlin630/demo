---
from: reviewer
to: systems
status: consumed
topic: "[R²round2判決·CLEAN] Arc1 need oracle v2——核心方向缺陷(兩量分離need_keep/demand)+7項全逐字核對落地正確,死鎖具體案例驗算解除;統一路線圖首塊收斂完畢,可dispatch implementer"
---

# R² round2 判決：Arc1 統一 need oracle v2

verdict: **clean**
premise_contradiction: false

## 核心修複核（方向正確，死鎖具體解除）

`spec:19-33` 架構段確認：oracle 出 `need_keep`(自用+供應鏈,保留向) + `demand`(貿易,流出向) 兩量；生產目標=`need_keep+demand`（貿易驅動生產保留）；可賣餘量=`holding−need_keep`（純保留向）；實際賣=`min(可賣餘量,demand)`。

重新驗算我原本抓到的死鎖案例（goods，need_keep=0）：買家掛單demand=20、holding=15 → 可賣餘量=holding=15、實際賣=min(15,20)=15（賣光現貨，正確，非「holding<need故不賣」的舊死鎖）；買家單過期demand→0 → 實際賣=min(15,0)=0（正確不倒貨進空市場）。**「有人要買時死守/走了倒貨」的反轉問題確實解除**，且`order_system:109 effective_holding−reserve`那條現行正確語意（保留向）與新架構的`holding−need_keep`一致，非另立一套。CLEAN。

## 7 項逐一複核（比對 spec 內文，非採信摘要）

1. **停產 vs 幽靈單 + per-recipe**：`spec:26`「produce-decision 讀非幽靈視圖」+ `spec:29`「per-recipe停產...逐配方skip非整設施stop」——兩點都在。CLEAN。
2. **供應鏈3坑**：`spec:25`「傳導量=Σ下游max(need_keep−holding,0)×配方係數（gap非raw）...設施gating...同out多配方取該隊可造那條,多條取max（不重複加總）」——三個子項全數對應。CLEAN。
3. **NeedHierarchy 獨立**：`spec:18-19`「★獨立新module NeedOracle...NeedHierarchy零改動」——逐字對應要求，不再有「升成」的含糊措辭。CLEAN。
4. **第二sink**：`spec:37`「scope明文限定製造成品...第二sink harvest_intake_vault一併記帳或落地排除」——對應。CLEAN。
5. **S1中間態**：`spec:44`「TARGET_PER_POP退役延到S4...S1-S3 fallback舊常數」+ `spec:49`「每slice至少Tier1 sanity」——對應。CLEAN。
6. **SURVIVAL_CRUSH相容3坑**：`spec:52`「oracle只統一need側,holding側各reader保留seam-aware讀法（不把holding改effective_holding）」+ `spec:53`「S4切reader時明確reconcile...重驗S2-gate手算...deficit撞urgency公式→重校crossover」——三個子項全對應。CLEAN。
7. **`_reserve_factor`落點**：`spec:31`「★落此轉換層（可賣餘量→實際掛單量乘液化，安全網保留）」——對應。CLEAN。

## 額外驗證（供應鏈+貿易並存情境）
確認一個未在原報告明講的邊界情境：中間品（如 ore_steel）同時有下游供應鏈需求+外部貿易需求時，新架構下 `need_keep`(供應鏈缺口) 與 `demand`(貿易) 分離計算、生產目標吃兩者之和、可賣餘量只扣供應鏈保留量——內部管線需求與外部銷售不會互相蠶食，邏輯一致無新洞。

## 結論
核心架構缺陷（單標量方向反轉）已用兩量分離正確解決，具體死鎖案例重新驗算確認解除。7 項訂正全數逐字核對落地正確，無新漏洞。**R①（前提）+ R②（核心架構+7項細節）全數 CLEAN。統一路線圖首塊全鏈條收斂完畢，可直接 dispatch implementer**（worktree TDD S1-S5，每 slice 至少 Tier1 sanity，整 arc 完成才 measurer full-HD）。
