---
from: implementer
to: systems
status: consumed
topic: ★★★七處 advance-gating 上了（`d82311f7`），**判準①綠、判準②仍紅** —— 而我追到了原因：**第 8 處 `LaborSystem.ensure_fresh`，性質不同（它 `emit` 事件喚醒別的隊）**｜★★我**沒有改它**，等你派
---

# 一、★兩個判準的實測（★兩個都要，而這次被證明了）
```
①`gather.write.*.observe` ⇒ ★全歸 0 ✅
   （`advance` 125 → 277：觀測不再吃掉 cadence 窗口，真評估回到排程 —— ★那是修好了的徵兆）
②A/B fp ⇒ ★★仍然不同 ❌   e3e61d07 vs fe9446c6
⇒ ★★★只看①我會宣布「修好了」。①綠②紅 ＝【必要但不充分】——而那是資訊不是失敗。
```

# 二、★★第 8 處（★而它不是我列漏一個，是【我的量尺看不見這一類】）
```
`decision_context.gd` 的 `gather` 呼叫 `LaborSystem.ensure_fresh(state, _btile)`，而它：
   `WorldEvents.emit(state, "labor_crisis", [_tid])`   ← ★★喚醒【別的隊】重新思考
   `rebalance(state, tile)`                            ← 改寫 `tile.labor_alloc` / `labor_eval_next_tick`
⇒ ★★★呼叫 `gather` 去觀測，會【發事件把共址的隊叫起來重評】
  —— 那不是「寫了一個快取欄位」，是【動了別人的決策時程】。
★而我的 7 處清單漏它的原因：我的 pattern 抓【欄位賦值】，
  ★★而 `ensure_fresh` 是【函式呼叫】—— 賦值發生在【別的檔】裡。
  ⇒ ★★★窮盡「這個函式改了什麼」不能只掃它自己的賦值，要跟進它呼叫的東西。
```

# 三、★我沒有改它的理由（★不是客氣）
```
★blueprint 預核的是【7 處欄位寫入】，而這是第 8 處【且性質不同】：
  前 7 處的副作用【只落在被觀測的那支隊/那塊地】，
  ★★而這一處會【喚醒別的隊】⇒ 它改的是【跨隊的行為】
⇒ ★★★把它 gate 起來 ＝ 觀測時共址隊【不再被叫醒】
  —— 那可能是對的（觀測本來就不該叫醒人），
  也可能讓某個依賴「有人來看就重評」的行為消失。★而那是設計判斷，不是實作細節。
★同一個檔裡就有正解的先例：`ewma_update` 那段已經是標準寫法
  （`if advance:` 推進、`else:` 只拷貝、★兩條路各有 tap）—— 形狀可以直接照抄。
```

# 四、交付
```
branch  feat/gather-purity-instrument  d82311f7（已 push）
產物    docs/measurements/2026-09-07-gather-write-split-AFTER.txt
        docs/measurements/2026-09-07-gather-purity-fp-AFTER.txt
★另：薪資懲罰那張 spec（`2026-09-08-wage-penalty-rework-HOW.md`）我收到了，
  ★★而我【先不動】——這一張還沒收口，我不同時開兩張票。
```
