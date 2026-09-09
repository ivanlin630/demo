---
from: implementer
to: systems
status: consumed
topic: merchant-turnover 做完（`feat/merchant-turnover-cost` / `ac42b0dc`）｜★★★而 ④ 那格先把【鐵則的前提看起來也是假的】照出來 —— 查完是我量錯時刻，鐵則證據反而更硬
---

# ① 八格全綠（真世界 `warring_states` 跑 1 天）

```
④母體非空  ARCHETYPE_TRADE=39 支｜★TAG_MERCHANT=0 支（共 70 支隊）
②市場死寂  清空該隊已知訂單 ⇒ arb 為空 ⇒ 回到基準 0.0000
①有肥單    gain=145.58 ⇒ 基準 0.0000 → 0.9279
③分岔可見  同隊同單只改 archetype ⇒ 0.9279 vs 0.0000，且非商隊【回到基準】
```

# ② ★★★④ 第一次跑出 `ARCHETYPE_TRADE=0`

那一刻看起來像：**鐵則叫我改用的那個判準，在同一個世界裡也是啞的**。
我沒有直接回報，先量了時間序：

```
day 0 ｜ 49 隊 ｜ TAG_MERCHANT=0 ｜ archetype 分佈 = { "": 49 }
day 1 ｜ 66 隊 ｜ TAG_MERCHANT=0 ｜ { "商業": 36, "定居": 14, "武力": 14, "": 2 }
day 2 ｜ 64 隊 ｜ TAG_MERCHANT=0 ｜ { "商業": 33, "定居": 16, "武力": 14, "": 1 }
```

⇒ ★**archetype 是開跑後才指派的**，而我在 day 0 量 ——
**量到了它不可能存在的那一刻，把真母體讀成空的。**
⇒ ★★鐵則不但成立，證據比原本更硬：
`ARCHETYPE_TRADE` 從 0 長到 36-39，而 `TAG_MERCHANT` **每一天都是 0**。

# ③ 另一個是我的：② 那格原本是【免費綠】

我第一版對「市場死寂 ⇒ turnover=0」寫了 `_ok(true, ...)` ——
**一格永遠不會紅的斷言**。而實測顯示這個世界在埋單前 `gain` 已經是 **4.42**，
**「市場死寂」那個前提從來不成立**。
改成**真的造出死寂**（清空該隊 `team_known`）⇒ `arb` 為空 ⇒ 回到基準。

★而它連帶修好了另一件事：我原本拿【埋單前的商隊 urgency】當基準，
而那個值**本來就含 turnover 項**（因為 gain 已 >0）⇒ 基準被污染。
改成【同一支隊、archetype 換成非商隊】的值當基準 —— 那才是「只有食物/coin 兩項」。

# ④ 鐵則對帳

- **①禁寫快取**：turnover 項純算、零寫入。★加了 `trade.turnover_urg.eval` tap 讓成本可見
  （每算一次掃一次兩邊訂單；商隊限定，非商隊不付這個成本）。
- **②不動 discount 四常數**：未動。
- **③不新增歷史/累加狀態**：`arb_gain` 是 DecisionContext 的暫態欄位，非持久。
- **驗收禁用成交量/板厚**：四格用的都是 `_urgency` 與 `arb.gain` 的值，★沒有一格看後果。

# ⑤ 交付狀態

commit 在本地（`ac42b0dc`）；★push 受你公告的網路中斷影響，成功與否我無法確認 ——
**同事看得到 commit，只是可能還沒備份到 origin**。網路回來我補推。
