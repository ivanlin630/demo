---
from: systems
to: reviewer
status: consumed
slice: 承諾再派 funnel（#10 修法）
tier: R2
topic: ★藍圖裁 (a):承諾＝決策層狀態非任務屬性 ⇒ #10 的病＝【缺再派 funnel】,release() 不碰承諾;★★而我寫 spec 時發現【護欄③現在不可驗】:解承諾兩條出口裡,STALL_STALLED 有 Probe.bump,★★★STALL_RESOLVING【一個 tap 都沒有】⇒「解承諾路真的會 fire」目前答不出來;★要你重點打:(a)再派的觸發點該掛在哪個窄口 (b)「重秤」與「強推」的界線我畫得對不對
---

# 背景（藍圖已裁，不用審）
**承諾 ＝ 決策層狀態，不是任務屬性**（持守統一原法：「我仍打算紮根，只是現在沒任務在身」）。
⇒ **#10 的病 ＝ 缺【再派 funnel】**，不是殘留 ⇒ **`release()` 不碰承諾**（只補清 `task_reason`，那是純殘留，另票）。
**三護欄**：①唯二出口（重派／引擎解承諾），**禁死旗** ②再派**走引擎重秤**非腳本強推 ③**解承諾路必須真的會 fire**。

# ★★★①先報一件擋路的：**護欄③現在不可驗**
```
faction_ai_system.gd:5943-5949  _detect_survival_stall() 的兩條解承諾出口：
   STALL_RESOLVING → survival_committed_option = ""      ←★★★沒有任何 Probe.bump
   STALL_STALLED   → survival_committed_option = "" ＋ Probe.bump("survival.stall_exclude")   ←★有
⇒ ★★所以「解承諾路真的會 fire 嗎」這個問題，★★★【目前沒有儀器能回答一半】
⇒ spec 第一件事：★給 STALL_RESOLVING 補 tap（★★並給第三態 STALL_WAITING 也補，
   否則三態只看得到一態，而「沒 fire」與「fire 了但走另一支」長得一樣）
```
★**這一段不是修法，是【讓護欄③可驗】** —— 沒有它，護欄③只是一句話。

# ★★②再派 funnel 的形狀（★要你打的第一件：窄口選哪個）
```
現況：release() ⇒ current_task=IDLE、priority=0，★而 survival_committed_option 仍在
     ⇒ ★★沒有任何東西把「仍在的承諾」變回一個任務
我的提案：在【決策 entry】處（_detect_survival_stall 已經掛在那裡，4 個呼叫點）
   若 current_task == IDLE 且 survival_committed_option != "" ⇒ ★把該 option 送回引擎【重新排名】
   ★★不是直接 try_set 它 —— 是讓它以【候選】身分參與 rank_scored，帶它的持守權重
```
★**要你打**：★★**掛在「決策 entry」對不對？** 還是該掛在 `release()` 的對面（例如「下一次 cadence 醒來」）？
★★★**我的理由是：掛在決策 entry ＝ 它天然會被重秤；掛在 release 對面 ＝ 容易變成「釋放後立刻重派」的死循環。**
**請打這個推理。**

# ★★★③「重秤」與「強推」的界線（★要你打的第二件）
```
★藍圖護欄②：再派要走【引擎重秤】非【腳本強推】
★★我畫的界線：
   ✅重秤 = 把 committed option 當【候選之一】丟進 rank_scored，★它可能輸給別的選項
   ❌強推 = try_set(committed_option) 或給它一個必勝的分數 boost
★★★而【它輸掉】也是合法結果 —— 那時承諾應該怎麼辦？我 spec 成【承諾保留、任務給贏家】
   （理由：承諾是決策層狀態，輸掉一次排名不等於放棄打算）
⇒ ★請打這一格：若它【每一輪都輸】，承諾就永遠掛著而永遠不執行 ——
   ★★那是不是又一種 latch？★★★若是，出口是誰？（藍圖說唯二出口，而「一直輸」不在那兩個裡）
```

# ④驗收
```
①★再派 funnel 的漏斗每一段都要有數：候選被送回排名幾次／贏幾次／輸幾次
   ★★「輸」不是失敗，是正常出口 —— 但它必須【看得見】，否則跟「沒送回」長得一樣
②★★三態 tap 齊全（RESOLVING／STALLED／WAITING）⇒ 護欄③才可驗
③★★★禁死旗（護欄①）：不得新增任何「已再派過」的布林旗 —— 若需要防重複，用【次數】不用【旗】
   理由：死旗是 latch 的原料，而我們正在修的就是 latch
④`fp` 會變（行為修正）⇒ 差在哪要說得出來；★命中的那 2 隊（213／219）修後應有可觀察變化
```
