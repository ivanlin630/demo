---
from: reviewer
to: systems
status: consumed
topic: [R② verdict] 完整 consolidation utility（§HOW-8）= CLEAN
---

# 對抗② 審判 verdict — §HOW-8 完整 consolidation utility

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "resource_slack/absorb_yield/ambition_gap 雙用皆非冗餘（不同軸/不同公式/互斥分支），投靠 ungate 有 threat 門檻非氾濫開放。同意 systems 判斷。" }
```

## file:line 驗證
- `decision_context.gd:9,106 food_days` — 確認現況=單一「survival 餘命」軸（ef/(pop×消耗率)）。
- `decision_context.gd:22,113 ambition_gap` — 確認存在，現由 `ambition_drive`(`terms.gd:71`) 讀用於生產/建設 gate。
- `faction_ai_system.gd:211,253,261 _belief_richness` — 確認存在，現用於掠奪/征服候選評分（greed 視角）。
- `options.gd:99` 投靠現況 gate — 確認 `food_days<DESPERATION_DAYS and has_strong_neighbor`，符合 spec 現況錨點描述。

## 冗餘 lens 逐項
1. **resource_slack vs food_days**：語意真分開——food_days=會不會餓死（生存餘命單軸），resource_slack=養不養得起更多嘴（統領餘裕+資源buffer+產能盈餘複合）。非換皮，過。
2. **absorb_yield vs richness**：richness=貪婪視角「值不值得搶」（用於掠奪/征服候選評分）；absorb_yield=「target 產能−pop負擔」淨值，養得起視角。公式/目的不同，非同一 solver——**但兩者可能讀同一 target belief 資料源，僅投影不同**，非共用決策邏輯,不算冗餘,備註供 implementer 勿直接拿 richness 當 yield 抄捷徑。
3. **ambition_gap 雙用**（ambition_drive 生產/建設 gate + absorb_drive 擴展需求）：context 欄位本就設計給多 term 讀。兩處是互斥選項 argmax 競爭中的獨立分支（非同 tick 同時疊加同一決策），非重複計 ambition。過。

## 其他審項
1. 禁 flat 湊 volume：spec 明守「征服真划算而贏=合理 emergent 保留」，目標=決策到位非湊量。過。
2. 投靠 ungate：現況 gate 確認為 file:line 坐實；提案 OR 子句要求 threat 過門檻，非「有強鄰即投靠」氾濫。門檻值留 measurer 校準，非設計缺陷。過。
3. 仁慈=1-殘忍/信義：既有 person value 映射，非新造。屬設計詮釋選擇（proxy 非精確因果），接受但非鐵證，留意未來若失真需重估映射。
4. judge 盤點：複用 ambition_gap/併入分流/loyalty init 確認無新平行決策物。過。

dispatch implementer，可疊統一決策 win + 完整 utility 一起 merge。
