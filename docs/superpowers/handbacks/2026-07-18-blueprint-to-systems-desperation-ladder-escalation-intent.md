---
from: blueprint
to: systems
status: consumed
topic: "[②intent裁定·絕望階梯怎麼爬 + 補丁閘偵測器盲點] ②裁=threat-severity同結構:①famine深度=amplifier(缺的那塊,food_days→0整個絕境category urgency升,util隨絕境重排非static)②方向=人格閘(勇/貪/殘→掠奪、慎/榮→乞討、低野心/高求生→投靠、baseline→覓食)③失敗升級=自然湧現不需計數器(買糧失敗→續餓→famine深→amplifier強→更絕境option蓋過)④無固定普適序(駁c,序由人格排:軍閥搶先於乞、農夫乞先於搶)⑤框架約束:amplifier讀famine_days×人格,禁全域ramp死常數⑥產自限attrition(每rung是行動非被動餓死)。★①camp補丁閘=constitution_gate偵測器盲點(behavior bug才抓到非機器scan)→強化偵測『豁免/skip條件擋survival/引擎re-trigger』類,否則機器證零殘留有洞。"
---

# ② intent 裁定：絕望階梯怎麼爬 + 一個框架盲點

## ② 絕望階梯爬升 = threat-severity 同一結構
選 (a)+(b)，駁 (c) 固定序。核心：**情境嚴重度放大、人格定方向**（跟我 threat 裁定同構）。
1. **famine 深度＝amplifier（缺的那塊）**：food_days→0 時整個絕境 category urgency 隨飢餓上升，util 隨絕境**重排**（非 static）。這是讓階梯「爬」的引擎。
2. **方向＝人格閘**：勇/貪/殘→掠奪、慎/榮→乞討、低野心/高求生→投靠、baseline→覓食獨撐。
3. **失敗升級＝自然湧現，不需失敗計數器**：買糧失敗→還是餓→famine 更深→amplifier 更強→更絕境 option 蓋過。**「失敗→升級」從『失敗使你續餓』自動長出**（合 [[feedback_symptom_vs_root_retry]]：X 若結構性永不成功，深化 amplifier 自動轉走它，非死鑽重試——這點很重要，別做成「retry X N 次才換」的補丁）。
4. **無固定普適序**（駁 c）：序由**人格排**——軍閥「搶」先於「乞」（寧搶不跪）、農夫「乞/投靠」先於「搶」。只有物理 baseline（覓食-自立恆在 < 買糧-需市場 < 社會/暴力隨飢餓升）。
5. **★框架約束**：amplifier 讀 `famine_days`（第三家）× 人格（第一家），**禁全域 ramp 死常數**（框架清潔 arc）。
6. **★產自限 attrition**（我 acceptable 判準）：每 rung 是**行動**（搶/乞/投靠/覓食）→ 解除或轉化飢餓，非被動站著餓死。這就是「傻站死→自限」的機制。

durable：`game-design.md §絕望階梯怎麼爬 intent 裁定`。HOW（util 形狀/famine 曲線）你出。

## ★① camp 補丁閘揭一個框架盲點（重要）
① proactive_camp 豁免是**補丁閘**，但**是被 starvation behavior bug 抓到的，不是 constitution_gate 機器 scan 抓到的**。∴ **constitution_gate 偵測器有盲點**：漏了「豁免/skip 條件擋掉 survival/引擎 re-trigger」這類 gate（`not proactive_camp` 跳過 re-trigger）。
- **這動搖「機器證零殘留」**：如果機器 scan 抓不到這類 gate，baseline 64「乾淨」是假乾淨——還有這類藏著。
- **請強化偵測器**抓此類（條件式豁免 engine/survival re-eval 的 skip），再重跑 baseline。**用戶剛問「怎麼還有補丁閘」——答案部分是：機器沒抓到它。** 這是框架硬條件①（機器證零殘留）的真缺口，不是小事。

## 流程（不跳 QA）
你 spec ①de-patch+②escalation → R² → impl → sim measure(含seed1337) → **QA 故事稽核**(thrash❌/窮死✅) → 我 release-pass → merge。verification-gate 結構強制此鏈（你 build 中）。

## 溯源
你的 cause2-roots-confirmed；[[project_desperation_economy]] 絕境階梯；threat-severity 裁定（同構）；[[feedback_symptom_vs_root_retry]]；constitution_gate 零殘留硬條件（大戰略校準）。
