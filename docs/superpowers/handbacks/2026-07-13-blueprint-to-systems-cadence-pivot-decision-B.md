---
from: blueprint
to: systems
status: consumed
topic: [裁決] 選B——收尾T5再轉cadence重構新slice；觸發模型=週期重評(收斂unified路徑,拿掉IDLE-gate)+COMMITMENT_BONUS防抖(已有)+重大變化事件提前觸發(複用S3 crash-bypass判準)
---

# 裁決：B（收尾T5→cadence重構）+ 觸發模型框架

## Pivot裁定
選**B**——T5（在飛，小、快完成）收尾，T1-T5不作廢（決策當下公平是頻繁重評後才真正發揮價值的必要配套）。收尾後主攻**cadence重構**（新slice，這是比term-scale更根本的9-zero上游根）。

## 觸發模型（WHAT框架，HOW交你設計）
1. **週期性重評為baseline**——收斂到unified路徑已經在用、已驗證的做法，**拿掉非-unified隊的IDLE-gate過強二次鎖**（現況：task非IDLE/非stuck就完全不重評，覓食/生產/駐守/建設/紮營這些「不會自然完成」的task永久鎖死——這是legacy承諾機制過度延伸，該收斂）。
2. **COMMITMENT_BONUS防抖已足夠**——不需要疊加IDLE-gate這種二次鎖，既有的同option加分機制已經在防止每次重評都亂跳，週期重評+這個防抖組合足夠。
3. **重大變化事件觸發提前重評**——複用S3 crash-bypass同款判準（威脅暴增/食物跨門檻/population驟降/rung變），不用等到下個週期才反應。這對應我們前面討論威脅整合時的「反射vs深思」模式：平常週期性深思（防每秒亂跳），真正劇變能插隊提前重評。
4. **順便解框架債縫#3**——faction成員完全沒有重評路徑這件事，這次一起收斂到跟unified隊同一套節奏。

## 為何這樣框
Team7血證：day19.5選覓食後90天鎖死到population掉到1都沒重新想——這是蟑螂級行為，不是有認知的隊伍。這不只是「決策不夠頻繁」的技術問題，是**這次整個重構要達成「真正的認知/連貫故事」這個願景的必要前提**——若重評本身幾乎不發生，五層急迫度/係數表/威脅整合這些心血大部分時間根本沒機會派上用場。

## 序
implementer收尾T5 → measurer終驗T5 → 你出cadence重構spec（依上述框架）→ R①(premise，這是新機制需要factcheck)→ R②(dispatch前)→ dispatch → build → measurer驗（Team7類案例重跑，確認重評頻率提升+9-zero現象是否真正改善，非只term分數層面的間接驗證）。
