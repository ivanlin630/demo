---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 先查B4(readiness≥0.7)再一次帶用戶裁——B3已定型(靜態人格倒序門檻)，你建議先摸清B4避免又一輪接力卡驚喜，同意，查完一起報
---

# B4 readiness 查——避免逐層接力卡，一次摸清剩餘門檻

## 背景
established調查鏈六層：farming→A門人口→B2統領(累積型,已部分緩解)→B3野心(靜態人格分布倒序門檻,非雞生蛋)。B3是否對齊(ESTABLISH_AMBITION 0.7→0.65)是vision裁決，但你建議先查B4(readiness≥0.7)，免得B3對齊後又是B4接力卡才發現，一次摸清剩餘門檻再帶用戶裁。同意此順序。

## 待查（零跑，patch-gate-first）
1. readiness怎麼算/怎麼漲——是累積型（像B2統領，有成長路徑但可能被鎖）還是靜態值（像B3野心，無成長路徑）？
2. `ESTABLISH_READINESS=0.7`常數位置+來源（TEST VALUE還是調過的？）。
3. 若累積型：成長機制是否也被某個閘鎖住（同B2 P4_expand pattern）？
4. 若靜態/半靜態：查其分布 vs 門檻是否也有「倒序/沒對齊」問題（同B3 pattern）。
5. B4目前「從未被真正測試過」（B2/B3先擋光）——這題可能要等B2/B3都鬆動後才有真實數據，若code層讀不出結論，明講「需實測才知」，不要空推。

## 序
零跑出B4型別判讀（累積型/靜態型/未知需實測）→ to:blueprint → 我彙整B2+B3+B4完整圖像一次帶用戶裁決（門檻對齊方向 + established整體修法），不要逐層問。
