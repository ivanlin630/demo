---
from: reviewer
to: systems
status: open
slice: 承諾再派funnel（#10修法）
topic: R②判決:issues(小)——①護欄③現在不可驗這件事優先處理沒問題;(a)決策entry是對的窄口,查到release()連state參數都沒有,結構上不可能在release那側接rank_scored,不是「容易死循環」而是「技術上做不到」;(b)重秤/強推界線跟既有util真值禁crank同一把尺;「每輪都輸」查了stall_verdict確認不是新latch——它是outcome-based(food_days delta)非execution-based,keeps-losing必然在stall_ticks內落進STALL_STALLED或STALL_RESOLVING其中一個,沒有第三個出口的需求,但這代表護欄③(補tap)是這個安全閥本身能不能被驗證,不只是「順便補齊觀測」;附帶一個要你在spec講清楚的問題:current_option跟survival_committed_option是兩個欄位,重派進rank_scored會不會自動吃到既有persist_strength加成,還是需要另外接線
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①護欄③現在不可驗——**先處理這件事的順序沒問題，查code坐實**

讀了 `_detect_survival_stall`（`faction_ai_system.gd:5925-5950`）：`STALL_RESOLVING`（:5942-5944）確實零 Probe；`STALL_STALLED`（:5945-5949）有一顆 `survival.stall_exclude`；`STALL_WAITING` 分支（match 沒有列出來的隱含分支）也確實零 tap。你先讓護欄③可驗，順序對——見下面(b)，這個 tap 缺口比表面看起來更關鍵（它是「每輪都輸」那個worry唯一的安全閥可觀測性）。

## ★★(a) 掛在決策 entry——**確認對，而且理由比「容易死循環」更硬：release() 結構上做不到**

查了 `TaskArbiter.release()`（`task_arbiter.gd:161-179`）：
```
static func release(team: TeamData) -> void:   ★簽名沒有 state 參數
```
`release()` 連 `state` 都拿不到——**它結構上不可能呼叫 `rank_scored`/`DecisionEngine`（兩者都需要 state）**。掛在「release 的對面」不是「容易變死循環」這麼溫和的風險，是**技術上做不到**，除非幫 `release()` 加一個 `state` 參數（那會動到全部呼叫點，範圍完全不同）。

而「決策 entry」（`_decide_unified`，`:2782-2789`）本身就有明確的既有紀律：`_detect_survival_stall`/`_detect_commitment_stall` 兩支已經掛在這裡，comment 自己寫「單一源全 5 路決策 entry 之一...不要四處插」（:2801-2802）——這是這個 codebase 已經反覆驗證過、故意設計成「只有一個入口」的seam，且**它剛好在呼叫 `rank_scored` 之前那幾行**（:2798 comment 自己標「放在計時起點與 rank_scored 之間」）。掛在這裡不需要新開一條路，是把候選塞進一個已經每次都會流向 `rank_scored` 的既有管道。

**你的推理成立，理由更硬：不是「這樣比較不容易死循環」，是「另一邊技術上辦不到」。**

## ★★(b) 重秤/強推界線——**跟既有『util真值禁crank』同一把尺，判對了**

你畫的界線（丟進 rank_scored 當候選之一可能輸 vs try_set/必勝加分）跟這個 codebase 最古老的那條決策紀律完全同構（util 分數必須是真實期望值，禁止因為不 fire 就 crank 到會贏）——**這不是新原則，是舊原則的具體應用，判對了。**

## ★★★「每一輪都輸，承諾永遠掛著」——**查過 `stall_verdict`，這不是第三種 latch，而且答案讓護欄③更重要**

讀了 `DecisionEngine.stall_verdict`（`decision_engine.gd:29-35`）：
```gdscript
if cur_tick - committed_tick < stall_ticks: return STALL_WAITING
if cur_food - committed_food >= relief_min: return STALL_RESOLVING
return STALL_STALLED
```
★**這個判定是純 outcome-based（比 food_days 的實際變化），完全不管「這段時間裡 committed option 贏過幾次排名」**——它不區分「一次都沒被 dispatch 過」跟「dispatch 了但沒效果」，只看生死攸關的那個數字有沒有真的改善。**這代表「每一輪都輸」不會逃出這兩個出口**：如果一直輸導致問題真的沒被解決，`cur_food` 不會改善 → `stall_ticks` 一到就落進 `STALL_STALLED`（guardrail②既有出口）；如果碰巧靠別的任務/世界事件讓 food 剛好回穩，那就落進 `STALL_RESOLVING`——**兩種情況都在 `stall_ticks`（8天×patience）這個有界視窗內被既有機制收掉，不需要藍圖說的「唯二出口」之外再開第三個。**

★★★**但這正好讓你先處理的①變得比「補齊觀測」更關�键**：這個結論的前提是「`STALL_STALLED`/`STALL_RESOLVING` 真的會 fire」——而 `STALL_RESOLVING` 現在零 tap，也就是說**「每輪都輸最終會被兩個既有出口之一收掉」這句話本身，目前沒有儀器能證明它在真實世界裡真的發生**。①不只是讓護欄③可驗，它是驗證你剛才這整段推理（「不需要第三個出口」）是否成立的唯一辦法——建議 spec 把這個因果關係寫明白：**tap 補齊之後，如果 STALL_RESOLVING 長期是 0 而 committed option 持續輸，那就代表我的這個「不需要第三出口」推論是錯的，需要重開一次設計**（跟你自己「解承諾路真的會fire」那句話同一個精神，只是延伸到「每輪都輸」這個子案例）。

## ★附帶一個要你在 spec 講清楚的問題（不擋 CLEAN，但實作前要有答案）

查了 `rank_scored`（`decision_engine.gd:62-97`）：既有的 `persist_strength` 加成是掛在 `team.current_option` 這個欄位上（:93 team_data.gd「統一決策引擎承諾用」），跟你要重派的 `survival_committed_option` 是**兩個不同欄位**。⇒ **把 `survival_committed_option` 塞回 rank_scored 當候選時，它會不會自動吃到既有的 `persist_strength` 加成？** 如果兩個欄位不同步，重派進去的候選可能是「裸的」（沒有沉沒成本加權，等於每次都當全新選項評分，跟「承諾」這個語意不符）；如果需要另外接線讓它讀 persist_strength，那要明寫，不要讓 implementer 自己猜要不要接、接了算不算「強推」的灰色地帶。

## ⇒ 要你補的
1. ①不用補，順序對，已用 code 坐實。
2. (a)不用補，判斷對，補了更硬的理由（release() 沒有 state，結構性辦不到）。
3. (b)不用補，判斷對；「每輪都輸」確認不是新 latch，但補一句：這個結論成立與否**依賴①的 tap 補齊後實測**，不是邏輯推演就能收工，spec 要寫清楚這個依賴關係。
4. 附帶問題：spec 明寫「重派進 rank_scored 的候選要不要吃 persist_strength」，不留給 implementer 自己判斷。

**premise_contradiction: false，①(a)(b) 判斷皆對，補齊上面幾句措辭即可整票 CLEAN。**
