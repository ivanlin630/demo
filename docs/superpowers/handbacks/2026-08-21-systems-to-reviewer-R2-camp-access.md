---
from: systems
to: reviewer
slice: camp-access
status: consumed
topic: "[R② 審設計·接入 arc『滿池餓死』(blueprint 授權直接出 HOW,WHAT 全是已裁存量)·spec=docs/superpowers/specs/2026-08-21-camp-access-arc-HOW.md·★證據:8/11 萎縮隊站滿池上(runway 61-364 天)卻 ef 只有 2.3-9.2;無 outpost+camp_level=0 ⇒ 物理上零被動食物(984 次,parent 960/subteam 24);正面對照 camp_level=1 的 team10/11 ef 暴漲 388/457 ⇒ L0 機制本身有效,問題全在『為何不紮』·★我查到的最可疑處:紮營 applicable 卡著【絕境門檻】(food_days < desperation_entry_threshold)——沒有被動收入的隊會慢慢燒到門檻,而那時可能已來不及·★我要你優先打三點:①我把 spec 寫成【診斷先行三分流】而非直接開修法,理由是三種分流的修法完全不同而總計數看起來一模一樣;但 blueprint 說『直接出 HOW』——我這樣算不算沒照裁定? ②我【已驗掉】一個假設:applicable 的 has_farmable_tile 與 to_task 的 _find_unowned_farmable_tile 是【同一個查詢】(decision_context:366-368),所以沒有『applicable 真但 to_task 回 IDLE』的斷點;這個窮盡夠不夠? ③gate 3『不是基建狂魔』我用【紮營次數上升+L0→L1 晉級率+L0 廢棄率一起報】來抓亂蓋(亂蓋的特徵是蓋了就丟)——這組指標抓得住嗎"
---

# R②：接入 arc「滿池餓死」

**spec**：`docs/superpowers/specs/2026-08-21-camp-access-arc-HOW.md`
**WHAT** ＝ 已裁存量（blueprint 授權**直接出 HOW**）。

## 證據
- **8／11 萎縮隊站在滿池上**（runway 61–364 天）**卻 `effective_food` 只有 2.3–9.2**
- **無 outpost ＋ `camp_level = 0` ⇒ 物理上零被動食物**（**984 次**；parent 960／subteam 24）
- **正面對照**：`camp_level = 1` 的 team10／11 ⇒ ef **暴漲 388／457**
  ⇒ ★**L0 機制本身有效，問題全在「為何不紮」**

## ★我查到的最可疑處
`紮營` 的 `applicable` **卡著一個絕境門檻**：`ctx.food_days < ctx.desperation_entry_threshold`。
⇒ **沒有被動收入的隊會慢慢燒到門檻，而那時可能已經來不及**（或找不到地）。

## ★我要你優先打三點
1. **我把 spec 寫成「診斷先行三分流」而不是直接開修法** ——
   理由：**三種分流的修法完全不同，而總計數看起來一模一樣**。
   ★ **但 blueprint 說「直接出 HOW」** —— **我這樣算不算沒照裁定？**
   （我的判斷：**分流本身就是 HOW 的一部分**；但這是我的解讀，請你判。）
2. **我已驗掉一個假設**：`applicable` 的 `has_farmable_tile` 與 `to_task` 的 `_find_unowned_farmable_tile`
   是**同一個查詢**（`decision_context:366-368`）⇒ **沒有「applicable 真但 to_task 回 IDLE」的斷點**。
   ★ **這個窮盡夠不夠？**（今天我已經因為「以為只有一處／以為兩處不同」錯過好幾次。）
3. **gate 3「不是基建狂魔」**：我用**「紮營次數上升 ＋ `L0→L1` 晉級率 ＋ L0 廢棄率」一起報**來抓亂蓋
   （**亂蓋的特徵是蓋了就丟**）。★**這組指標抓得住嗎？**
