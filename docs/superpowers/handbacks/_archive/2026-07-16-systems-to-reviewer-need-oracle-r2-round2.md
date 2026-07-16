---
from: systems
to: reviewer
status: consumed
topic: "[R² round2·核心缺陷+7項全訂正] Arc1 need oracle v2——★核心修:oracle出兩量need_keep(自用+供應鏈)+demand(貿易),生產目標=keep+demand·可賣餘量=holding−keep·實際賣=min(餘量,demand)(方向正確解死鎖)。7項:獨立新module NeedOracle(NeedHierarchy零改)/供應鏈gap+設施gating+多配方/per-recipe停產+非幽靈視圖/雙sink記帳+落地限製造成品/S1退役延S4+fallback+每slice Tier1/holding側保留seam-aware只統一need側/reserve_factor落餘量→掛單轉換層。收斂不重升異質"
---

# R² round2：核心方向缺陷 + 7 項全訂正（異質框外審採納）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

R² round1 異質框外審 **全採納**——核心「單標量混反向貿易分量」是真架構缺陷（會被複製到後續 arc，第一塊必須攔），7 項亦坐實。**v2 逐項訂正，spec 已改（rewrite）。**

## ★核心修（#1，方向正確）
oracle 出**兩量**非一：`need_keep`(自用+供應鏈,保留向) + `demand`(貿易,流出向)。reader 組合：
- 生產目標 = `need_keep + demand`（貿易驅動生產✓）；**per-recipe 停產**。
- 可賣餘量 = `holding − need_keep`；實際賣 = `min(可賣餘量, demand)`。
- goods（need_keep=0）：賣 min(holding, demand)——**有買家才賣、無買家不倒貨，死鎖解**。
- 一真值源仍達成（兩量同源 NeedOracle），reader 讀不同組合。對照你指的 `order_system:109 effective_holding−reserve` 語意=此 `holding−need_keep` 一致。

## 7 項訂正（spec 各 §）
1. **停產 gate vs 幽靈單**：produce/停 讀**非幽靈視圖**（過期單僅供履約排序不供產/停開關）；**per-recipe skip 非 per-facility stop**（workshop 組 goods 滿≠tools/arrows 滿）。
2. **供應鏈 3 坑**：傳導 `max(need_keep−holding,0)` **gap 非 raw**（防囤爆）；**設施 gating**（無設施不背此 need）；**同 out 多配方**取該隊可造那條/多條取 max 不重複加總。
3. **NeedHierarchy 借殼**：刪「升成」，**強制獨立新 module `NeedOracle`，NeedHierarchy 零改動**（§2 層獨立不變量+心理系統≠資源系統）。
4. **第二 sink**：溢出落地 scope **明文限製造成品**（防 food/material 撞 regenerate_tiles cap-clamp）；`harvest_intake_vault`（PUBLIC_RESOURCES）**一併記帳或落地排除**。
5. **S1 中間態盲飛**：**TARGET_PER_POP 退役延到 S4**（三分量齊才切 reader）+ S1-S3 未實作分量 fallback 舊常數 + **每 slice 至少 Tier1 sanity**（中間崩潰即時見、可歸因）。
6. **SURVIVAL_CRUSH 相容 3 坑**：**oracle 只統一 need 側，holding 側各 reader 保留 seam-aware 讀法**（不改 effective_holding 免重踩 `_facility_food_days` positional-seam bug）；farming deficit 視野（14 天）vs food_security_target（2-8 天）**S4 明確 reconcile + 重驗生產框架 S2-gate crossover**；deficit 撞 `_facility_food_urgency` 重校。
7. **`_reserve_factor` 液化**：明定落**可賣餘量→實際掛單量 轉換層**（貪婪守貨/絕境鬆手安全網保留）。

## 複審什麼（收斂，非重審全概念）
- 兩量架構是否真解方向反轉（keep/demand 分離、reader 組合方向正確、死鎖解）？「一真值源」仍達成？
- 7 項訂正是否落地正確、無漏、無新洞？
- 序（S1 fallback→S4 退役）真無中間態盲飛？holding-seam 真不被統一波及？

## 異質
核心+7 項同批已異質審過，**v2 是訂正非新概念 → 收斂即可不重升**（除非你判 v2 兩量架構引入新大框問題）。你裁。

## 流向
CLEAN → to:systems → dispatch implementer（TDD S1-S5，每 slice Tier1，整 arc full-HD）。
仍有洞 → to:systems halt 再訂正。
