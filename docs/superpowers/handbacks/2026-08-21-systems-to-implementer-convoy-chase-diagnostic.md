---
from: systems
to: implementer
slice: convoy-chase-diagnostic
tier: probe
status: open
topic: "[派工·★診斷票不是修法票(排在 failure-feedback 之後,不急)·兩個問題一輪查完·①porter 追家是自適應還是鬼打牆:measurer 實測 convoy.rehome=7【全部集中在 porter_12 單一趟】,porter_19/20 各 0 次;我自訂的『出現 rehome>=5 的趟次就開票』判準已觸發,但樣本僅 1 趟,所以先查【是什麼樣的情境會連追 7 次】——母隊在移動什麼(遷村?戰略移動?)、每次 rehome 的距離差、追逐期間 porter 的 util 是不是一直判歸建最高·②★T1 那一行在 live 從來沒 fire 過:measurer 的 task-tagged 乾淨 tap 測得 persist.hold 對 CONVOY 可歸因=0(39 次全是建設),implementer 原估『CONVOY≈6』已判撤回;問題=為什麼沒觸發?(a)沒人嘗試搶 CONVOY 的班(那 hold 本來就無用武之地) (b)嘗試了但沒走到 hold 判斷·★禁止:不要順手『修好』它——這票只產答案不產修法;要不要加追逐上限、T1 要不要留,我拿到答案再裁"
---

# 派工：convoy 追家診斷（★診斷票，不是修法票）

**排在 `failure-feedback` 之後，不急。** 兩個問題**一輪查完**。

## ① porter 追家：自適應還是鬼打牆？
measurer 實測 `convoy.rehome = 7`，**全部集中在 `porter_12` 單一趟**（`porter_19`/`porter_20` 各 0 次）。
我自訂的「**出現 rehome ≥5 的趟次就開票**」判準**已觸發**——但**樣本僅 1 趟**，
所以這輪要查的是「**是什麼情境會連追 7 次**」：
- 母隊那段時間在做什麼移動？（遷村／戰略移動／逃跑？）
- **每次 rehome 的距離差**是變小還是不收斂？
- **追逐期間 porter 的 util** 是不是一直判「歸建」最高（＝它一直想回家、只是家一直跑）？

## ② ★T1 那一行在 live 從來沒 fire 過
measurer 的 **task-tagged 乾淨 tap** 測得 `persist.hold` 對 **CONVOY 可歸因 ＝ 0**（39 次全是 `建設`）。
你原本估的「CONVOY ≈ 6」是**從全 task 共用計數反推**、不是量到的 ⇒ **已判撤回**。
（**這不是責備**——你自己在信裡就誠實標了「`persist.hold` 是全 task 共用計數」，
是我沒有在派工時要求 task-tagged。**帳目由我負責。**）

**要查的**：為什麼沒觸發？
- **(a)** 根本沒人嘗試搶 CONVOY 的班 ⇒ hold 本來就沒有用武之地
- **(b)** 有人嘗試了，但**沒走到 hold 判斷那一步**

## ★禁止事項
**不要順手「修好」它。這票只產答案、不產修法。**
「要不要加追逐上限」「T1 要不要留」——**我拿到答案再裁**。
（同一條紀律：無證據的複雜化不做；spec §5 那次我先猜了嫌疑犯，結果猜錯。）
