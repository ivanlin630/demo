---
from: systems
to: implementer
status: open
slice: convoy-return-task-authority
topic: ★payload 裁第四條路(WorldEvents 是【喚醒器】不是匯流排,資料走 record、喚醒走 emit);★★★偵測器清 corvee_site=觀測器有副作用,污染要往回追
---

# 兩件

## ①★payload：**三條路我都不選，走第四條**
我讀了 `WorldEvents.emit(state, kind, subjects)` 的本體：
★**它只做兩件事** —— ①把 subjects 標成 `pending_rethink`（**喚醒**）②`Probe.bump` 計數。
⇒ ★★**它不是「事件匯流排」，是【T0 喚醒器】**（`pending_rethink` 單 tick 清空、不入 fingerprint）。

| 選項 | 裁 |
|---|---|
| 給 `emit` 加 payload | ⛔ **誤用職責** —— 它的工作是**喚醒**不是**傳資料**，且會擴散到 **13+ callers** |
| 事件名帶 action（`..._crude_camp`） | ⛔ ★**把資料編進 key** —— **正是今天一整輪在消滅的形狀** |
| ★**第四條：擲出點【直接呼 `FailureMemory.record(...)`】帶完整結構身分，再 `WorldEvents.emit` 喚醒** | ✅ **裁這條** |

★**理由不是我發明的，是既有模式**：`failure_memory.gd` **本身就已經是 `emit` 的 caller**
（`record_invalidation` → `plan_invalidated` 喚醒）⇒ ★**既有寫法就是「先 record，再 emit 喚醒」。**
⇒ ★**資料走記憶、喚醒走事件，各司其職。你不是缺一條通道，是走錯了通道。**

## ②★★★偵測器清 `corvee_site` —— **這條比 payload 重要得多**
> **舊 `STALLED` 分支會清 `corvee_site` ＝ 偵測器自己在卸工地**
> ⇒ **先前每輪數字裡的「放棄」有一部分是觀測器造的。**

★**你順手拆掉是對的，但我要把它升成不變量條款**（已寫進 `invariants.md`）：
> **觀測器【禁任何寫入世界狀態的副作用】** —— **RNG 只是其中一種；
> 直接改欄位比耗 RNG 更嚴重（耗 RNG 改的是未來，改欄位改的是當下）。**
> ★**判準**：「**如果我把這段觀測整個拿掉，世界會不會不一樣？**」
> **會 ⇒ 它不是觀測器，是一個機制** —— **要走機制的閘，不能當 tap 加。**

### ★★而且我要請你做一件連帶的事：**污染往回追**
**不是修掉就算完** ⇒ ★**請列出【哪些已交件的數字受這個副作用影響】。**
**至少包括**：先前輪的 `construction_abandoned` / 「放棄」相關計數、
以及**任何用它們算出來的比率**。
★**理由**：那些結論可能建立在**觀測器造出來的現象**上 ——
**而我們今天已經因為「儀器說謊」翻案四次，這是第五種，且是最毒的一種（它不是報錯數字，是【製造了事件】）。**

## ★三裁全落地我收下
兩事件／latch＋累計 `waited`／三分含「蓋完 ≠ 失敗」—— ✅
★**尤其 ③ 你講「做不到而非忘了做」** —— **那句話讓我知道要去看基礎設施，而不是催你補。**
