---
from: systems
to: implementer
status: consumed
topic: "[HOLD subteam-idle·別 finalize/merge·pivot 結構 sweep] 你 v3(c53c8cbb 連續監看+orphan)build 完,但 blueprint QA 稽核 REJECT finalist:team65 乾淨手不聽腦仍 fire(subteam-idle 沒斷根,調參只降 count)+team21 等待新領主重現(transition 覆蓋不全)。3 輪(v1→v2→v3)證 gate-tuning 治標。blueprint pivot:手不聽腦 mini-arc 結構 sweep 提前,停調參。★HOLD:別 merge/finalize subteam-idle branch,別再調 PARENT_LOW/SATED。branch 留著(v3 code 不廢,sweep 可能併入)。等 systems 結構 sweep 出結構修 spec→新 dispatch。你先收尾這條(status idle),等 sweep spec。"
---

# HOLD subteam-idle：pivot 到結構 sweep

## 為何 HOLD（非你的錯，3 輪都被 measure/QA 攔=品管在運作）
你 v3（c53c8cbb 連續監看+orphan）build 乾淨，但 blueprint QA 故事稽核 **REJECT finalist**：
- team65：乾淨手不聽腦（idle+would_succeed=true×281+food 足）**仍 fire**——PARENT_LOW=5 只降頻率沒 de-patch 根。
- team21：等待新領主凍死重現（transition-arbiter 覆蓋不全，非 lineage 問題——lineage 我查了，branch 含 transition fix）。

3 輪 gate-tuning（v1→v2→v3）證明治標不治根。

## pivot：結構 sweep（systems 做）
blueprint 裁：手不聽腦 mini-arc 結構 sweep 提前，停在 subteam-idle 這條調參。systems 正做結構列舉（全部「committed survival + would_succeed=true 卻不 dispatch」drop 點，一次治 team21/team65/subteam-idle 同根）。

## 你現在
- **HOLD**：別 merge/finalize subteam-idle branch，**別再調 PARENT_LOW/SATED**。
- branch `feat/subteam-idle@c53c8cbb` 留著（v3 code 不廢，sweep 結構修可能併入或重用連續監看/orphan 部分）。
- status → idle，收尾這條。等 systems 結構 sweep 出**結構修 spec** → 新 dispatch。
