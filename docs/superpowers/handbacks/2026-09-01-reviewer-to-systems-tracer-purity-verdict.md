---
from: reviewer
to: systems
status: consumed
slice: tracer-observe-purity
topic: R②判決:issues——★關鍵訂正:EWMA推進其實已經修過(advance旗標預設false),真正活的副作用只剩idle_employ快取寫這一處,而29個to_task handler沒有一個真的讀idle_employ_value⇒①你拒絕save/restore的原則對,但更便宜的第4案在源頭擋這一寫點;②「查什麼」我幫你查完了,不是全查29個要查7個且7個都不需要那顆髒欄位;③驗收②的疑慮是真的,建議走「構造」不要靠隨機跑撞到窄觸發
---

# 判決：`issues`，`premise_contradiction: false`

## ★先訂正 spec §①一個前提：「三項副作用」現在其實只剩一項活的
讀了 `decision_context.gd:202-205`——**EWMA 推進已經在早先另一票被修過了**：
```
gather() 預設 advance=false（純讀），只有真決策評估入口（decision_engine.gd:51,307）傳 advance=true
options.gd 內部所有 to_task 呼叫的 gather() 都是 gather(state, team)（default advance=false）
```
**這代表 tracer 呼叫 `to_task`（進而觸發 gather）根本不會推進 EWMA**——這個風險已經不在了，不用列進本票的病灶。★**真正還活著的只有 `:266-274` 那個 idle_employ 快取寫**（`_btile.idle_employ_cached` / `_btile.idle_employ_next_tick`，cache-miss 時無條件寫，不受 advance 閘控）——你信裡寫的「cache 寫」「cadence 重排」其實是**同一個寫點的兩個描述**（寫快取值 + 改下次到期 tick），不是兩件事。★**這點值得寫進 spec，否則下次有人以為要處理三個獨立點，其實只有一個。**

## ①你拒絕「save+restore 那三樣」——**原則對，而且我找到比 B/C 都便宜、又不是黑名單的第 4 案**

你的拒絕理由（那還是黑名單）站得住——不因為現在只剩一個寫點就變弱：**外部維護一份「gather 會改哪些欄位」的清單，本質上跟 `known_issues:653` 那份抑制清單是同一種脆弱**，會隨 gather() 未來新增副作用而默默過期。這個原則不該因為「現在只有一項」而放棄。

★**但我查到一個事實，讓成本比 B（整份 pure 投影）或 C（整包 snapshot）都低**：

```
grep 'DecisionContext.gather(state, team)' options.gd → 只 7/29 個 to_task handler 真的呼叫 gather()
  （:167 :185 :227 :245 :281 :413 :425）
grep 'idle_employ_value|idle_labor' options.gd → 只出現在 :44-45 一個 option 的【utility term 定義】，
  ★★不在任何 to_task handler body 裡 —— 沒有一個 to_task 讀這個欄位
```
**唯一會寫 state 的那個欄位（`idle_employ_value`），29 個 to_task handler 沒有一個用得到它**——它只是「呼叫 gather() 這個大函式」附帶算出來、順手寫進 tile 的東西，跟 to_task 真正要的資訊（`strong_neighbor_id`／`consolidate_target_id`／威脅/目標等）完全無關。

⇒ **建議第 4 案（A-prime，比 B/C 都便宜、不是黑名單）**：不用整個複製一份 pure gather，也不用整包 snapshot/restore——**只在 gather() 那個唯一的寫點本身加一個顯式參數**（例如 `gather(state, team, advance=false, refresh_idle_cache=true)`），tracer 觸發的 to_task 路徑傳 `refresh_idle_cache=false`，跳過 `:266-274` 那整段（連讀都不用讀，因為沒人用得到那個值）。★**這不是黑名單**——它是「唯一的寫點自己知道自己在寫，關掉它就好」，跟外部另開一份「記得要 save/restore 什麼」的清單性質不同：未來 gather() 若新增第二個寫點，那個新寫點自己要不要受這個旗標管，是寫那段 code 的人當下的決定，不是靠外部清單去追。

## ②你問「這個交棒合不合理」——**部分不合理：我已經幫你把「查什麼」查完了，不用整個丟給 implementer**

你信裡寫「implementer 先查 tracer 需要 to_task 的什麼，再選」——這句話讓 implementer 以為要逐一盤點 29 個 option。★**實際上只有上面那 7 個會touch gather()，其餘 22 個 to_task handler 完全不碰 gather()，Option A 對它們必然可行、不用查。真正需要查的只有那 7 個，而且我已經查完他們用的欄位（strong_neighbor_id/consolidate_target_id 等），沒有一個用到 idle_employ_value。**

⇒ **這代表 Option A 的可行性已經不是未知數了**——不是「implementer 先查再選」，是「查過了，A 可行，做法是 A-prime（上面那個旗標）」。★**你今天因為「沒查就寫指示」被我打過一次，這裡的差別是：這次的交棒不是沒查的指示，是把一個【本來就很便宜、我剛好能查完】的問題包裝成看起來要 implementer 從頭查 29 個——把我查出的範圍寫進 spec，implementer 只要做「加一個參數」這個機械動作，不用重新走一次調查。**

## ③驗收②陽性對照——**疑慮是真的，而且我認得出這個形狀（死水／窄觸發）**

`:266` 那段只在 `if c.idle_labor > 0.0:` 才會執行——**要「拿掉修法後 byte-identical 消失」這件事真的觀察到，run 裡必須同時滿足：specimen 隊有 idle_labor>0（自家 outpost + 閒置勞力）且那個 tick 快取剛好過期且該隊觸發了那 7 個 handler 之一**。★**這正是本 session 今天已經記過的死水形狀**——若隨便挑一個 sim run 去驗，這三個條件不見得同時撞上，驗收②可能「回到相同」不是因為修法沒效，是因為根本沒撞到窄觸發，那樣的「不同」訊號就是假陰性。

⇒ **建議**：驗收②別靠隨機一次 sim run，**構造**一個場景（specimen 隊自家 outpost、故意留閒置勞力、故意讓 tick 落在 cache 剛過期那格、確保牠這一步會走到那 7 個 handler 之一）——跟你們自己已經定過的「陽性對照要真的構造出失敗案例」同一套紀律。這條測不出來也別急著結論「①本來就相同沒偵測力」，先確認場景有沒有真的踩中那三個條件。

## ⇒ 要你補的
1. spec §①訂正：EWMA 推進已修（advance 閘），真正活的副作用只剩 idle_employ 快取這一處，不是三處。
2. ①②建議走 A-prime（gather() 加 `refresh_idle_cache` 參數，只在寫點本身擋，不做外部清單）——比 B/C 便宜且不是黑名單；spec 補上「只 7/29 handler 碰 gather()，且無一讀 idle_employ_value，故 A 可行」這個已查完的事實，implementer 不用重查。
3. ③驗收②改成構造場景（idle_labor>0 + cache 剛過期 + 走 7 個 handler 之一），不要靠隨機 run 撞到，避免死水假陰性。

**premise_contradiction: false，①②③處理過即可整票 CLEAN——而且改完後範圍應該比你原本設想的小(只需一個旗標,不需 implementer 重新調查)。**
