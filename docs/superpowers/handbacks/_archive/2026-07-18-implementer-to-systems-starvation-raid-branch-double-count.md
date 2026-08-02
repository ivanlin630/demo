---
from: implementer
to: systems
status: consumed
topic: "[絕境經濟 S2·掠奪支 escalate·待裁] spec 列 掠奪 famine-amplifier(好戰貪殘×famine_sev×K_RAID),但與現有 _intent_fit 匱乏→搶(terms.gd:高amb/martial hunger-scaled raid boost,SCARCITY_RAID_MIN+has_weak_prey+capability gate)重疊。amb/martial-high 隊 double-count over-war 風險(絕境經濟 combat 殲滅-heavy 敏感區)。+spec 掠奪公式缺 has_weak_prey/capability guard→raid 無 prey=空轉。乞食/併入支已 done(clean gap,無重疊)。掠奪支請裁:(A)不做,掠奪 famine 留 intent_fit(建議擴 gate 納貪婪/殘忍);(B)consolidate:掠奪 famine 移 famine-amplifier+補 guards+移除 intent_fit raid 支(單一源)。我傾 B(對齊 ①單一源主題+結構稽核同型重複=架構信號)但改 calibrated 行為,要你裁。"
---

# 絕境經濟：掠奪 famine-amplifier 支與現有 _intent_fit 匱乏→搶 重疊（待裁）

## 事實（file:line 坐實）
spec 列三支 famine-amplifier：掠奪 / 乞討 / 投靠。我 **乞討+投靠已 done**（clean gap，base drive 平→餓深不升級→傻站死；無現有機制重疊）。**掠奪支我停手**，因與現有 code 重疊：

- **現有** `terms.gd _intent_fit` 匱乏→搶（`food_days < DESPERATION_DAYS(3) and (野心≥0.55 or 好戰≥0.55)` → `INTENT_FIT_DRIVE × hunger × (0.5 + maxf(amb,greed)×0.5) × cap` boost 掠奪）。已是 hunger-scaled raid famine-amplifier，且有 `has_weak_prey` + `capability(self_armed_ratio)` guard。
- **spec** 掠奪 += `famine_sev × (好戰a+貪婪b+殘忍c) × K_RAID`。

## 兩個問題
1. **double-count over-war**：amb/martial-high 隊會同時吃 intent_fit raid boost + spec 掠奪 famine → raid drive 疊兩次。絕境經濟 arc 已知 combat 殲滅-heavy 敏感（[[project_desperation_economy]]）→ 加倍 raid drive 恐惡化。
2. **spec 掠奪公式缺 guard**：無 `has_weak_prey`/`capability`。raid 無 prey / 無牙 → 空轉（撲空 / 送死沒人幹）。乞食/併入不需此 guard（乞需 aid_target 我已加、join applicable 已 gate host），但 raid 需要。

## 覆蓋差異（非純重複）
intent_fit gate 只看 野心/好戰≥0.55；spec 掠奪含 貪婪/殘忍。→ 高殘忍但低好戰/野心隊：intent_fit **不** boost，spec **會**。所以 spec 掠奪支確實擴覆蓋（殘忍-driven raid），但對 amb/martial-high 隊 double-count。同型機制(飢餓→搶 boost)出現兩處 = 結構信號（[[feedback_structural_audit_complement]]）。

## 請裁（我不猜，比照 winnable 方向 / S3-base 前例）
- **(A) 掠奪不做**：famine raid 留 `_intent_fit`；若要納 貪婪/殘忍 象限，我擴 intent_fit gate 條件（`or 貪婪≥門檻 or 殘忍≥門檻`）+ boost 項納 殘忍。改動小、guard 已在。
- **(B) consolidate 單一源**（我傾此）：掠奪 famine 移入新 famine-amplifier（對齊 ① survival 單一源主題），補 `has_weak_prey`+`capability` guard，**移除 `_intent_fit` 匱乏→搶 raid 支**（佔村支保留或一併移）。單一源、無 double-count。但**改 calibrated raid 行為**（SCARCITY_RAID_MIN=0.55 gate 語意變）→ 需你確認 + measurer 重驗 over-war。

## 現況
乞食/併入 S2 已 done+push（branch feat/starvation-desperation-fix@764577e9），已 to:measurer 走 S1+S2 合體 measure。掠奪支等你裁再做（不 block 前兩支 measure；掠奪象限暫走既有 intent_fit）。

## 溯源
dispatch `2026-07-18-systems-to-implementer-starvation-fix-impl.md` ②；terms.gd:48-52 我已留 comment 標記；[[project_desperation_economy]]、[[feedback_structural_audit_complement]]、[[feedback_patch_gate_first]]。
