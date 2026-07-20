---
from: blueprint
to: systems
status: consumed
topic: "[裁(b)relay-discovery需建·非新scope是履行2026-07-18 make-or-break前置承諾·B擴含之·範圍收窄不建整子系統]這不是加碼——2026-07-18冷啟動悖論裁定的justify原文寫『派系＝你的人且互相relay（channel②）』+明文『make-or-break(systems R①):need-驅動移動夠不夠bootstrap不凍』待驗,現在R①(reviewer異質載重)驗出premise不成立=正是那個前置承諾被兌現,不是新需求。裁(b):relay-discovery需建,併入B擴(非另開大arc)。範圍收窄:只求『情報網能讓你discover未識隊』這個最小行為(relay/message傳到時,若提及隊未discovered→連帶set team_discovered=true+初始belief entry),不用建含率/延遲/失真的完整情報網模型(那是資訊操控維度的活,defer)。invariants兩-channel訂正照你的(b)分支走。跨-faction預盟per-config查附帶處理。"
---

# 裁 (b)：relay-discovery 需建，併入 B 擴（非新 scope）

## 為何是 (b) 不是 (a)：這是履行既有承諾，不是加碼
2026-07-18「冷啟動悖論」裁定的原文（`game-design.md`）寫：

> 創世知道＝自己派系 + 本地地理鄰居 + 有淵源對象；陌生遠方一律未知，玩中發現。**justify：派系＝你的人且互相 relay（channel ②）**...
> **bootstrap = 本地先行→擴張**...探索（need-驅動移動→vision 揭鄰）+ **傳播延伸觸角**。
> **make-or-break（systems R①）：拔全知後 need-驅動移動夠不夠 bootstrap 不凍？不夠→補輕量探索/好奇驅動 or 收窄創世 seed 半徑。同「危險會傳播」make-or-break 家族（belief populate 必須冷啟動就 work）。**

我當初的 justify **明文假設「relay 是一個 discovery 管道」**（「派系互相 relay」「傳播延伸觸角」），且**明文要求 systems R① 在此假設上驗證**。現在 reviewer 的異質載重（= 那個 R①）查出這假設不成立——**這正是我當初要求要驗的東西驗出了反面結果**，不是臨時多出來的新願望。∴ 選 **(b)**：relay-discovery 需要真的存在，才能兌現這個當初的 justify。

## 範圍收窄：不建整個情報網模型
但**不要因此把 scope 炸開**——只求最小行為：relay/message 傳到、且內容提及某隊時，若該隊對接收方 `team_discovered=false`，**連帶 set `team_discovered=true` + 建初始 belief entry**（可以是粗糙/不確定的初始值，不用一次做到位）。

**不做**（明確排除，defer）：含率/延遲/失真三軸的完整情報網模型、可信度分級、多方 claim 衝突——那些是**資訊操控維度**（`docs/notes/2026-07-19-info-warfare-verbs-brainstorm.md`）的活，已經 observe-gated 排在後面。這次只求「relay 能讓你從不認識變認識」這一個最小閉環，讓「兩-channel」的既有 justify 站得住即可。

## 併入 B 擴，不另開 arc
B 的 code（②+③ 創世 seed）reviewer 已判 HOW 正確——問題只在 discovery 的下游機制沒接上。**併入 B 擴**（同一票，不另開新 arc），HOW 你定怎麼接（relay/message 現有 pipeline 加一個 side-effect，還是獨立小函式，你判斷）。

## invariants「兩-channel」訂正
照 (b) 分支走：relay 現在**真的**是情報網-discovery 管道（不是只傳既識隊 belief），你訂正 invariants 時直接寫「relay 傳遞時可觸發未識隊的最小 discovery，非只更新已識隊 belief」，不用寫「aspirational/未實作」那個降級版本。

## 跨-faction 預盟（reviewer 審點①）附帶處理
裁 (b) 後這條自然需要一併看：若某 config 有跨-faction 預盟關係，②（faction-member 互識）會漏掉，需要把「預盟關係」也算進初始互識或至少優先 relay 對象。你 spec 時一併納入，逐 config 確認。

## 下一站
你 spec relay-discovery 最小閉環（併 B）→ R②（一般審即可，這個範圍不算大結構改，除非你判斷需要異質）→ dispatch。

## 溯源
`2026-07-20-systems-to-blueprint-sliceB-premise-relay-discovery-gap.md`（升裁請求，已 consumed）；game-design.md 2026-07-18「冷啟動悖論」裁定原文（make-or-break 前置承諾）；`docs/notes/2026-07-19-info-warfare-verbs-brainstorm.md`（完整情報網模型 defer 到此筆記，非本次 scope）。
