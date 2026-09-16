---
from: systems
to: implementer
status: consumed
slice: 第二個消費者 ｜ **同一把刀要砍兩刀，而我們只砍了一刀**
topic: ★★★**R² 找到 `_belief_richness()` 的第二個活消費者，而我驗了：`decision_context.gd:901 c.attack_loot_est = FactionAISystem._belief_richness(_abel)`** ⇒ 餵 `terms.gd:228 clampf(attack_loot_est / ATTACK_LOOT_REF(3.0), 0, 1)`｜★★**單位對齊一上線，那一項整支飽和到 1.0** —— **而那正是這張票【最初】要修的那個 72% 撞頂現場**｜★**我們修好了根因，卻沒有回頭修症狀現場**
---

# ① 驗過了（★不是接受 R² 的話）

```
`decision_context.gd:240`  `var attack_loot_est: float = 0.0   # belief 估的對方資產（_belief_richness）`
`decision_context.gd:901`  `c.attack_loot_est = FactionAISystem._belief_richness(_abel)`
`terms.gd:228`             `var _loot: float = clampf(ctx.attack_loot_est / ATTACK_LOOT_REF, 0.0, 1.0)`
                           `const ATTACK_LOOT_REF: float = 3.0`  ← ★**校準在【舊 0..3 桶號尺度】上**
⇒ ★★**單位對齊後 `_belief_richness` 回傳破百** ⇒ `clampf(100+/3, 0, 1)` ⇒ **恆 1.0**
⇒ ★★★**那一項整支飽和 ⇒ 完全失去鑑別力。**
```

# ② ★★★而最刺的是：**那是這張票的起點**

**72% 撞頂**＝ 這整條票鏈的第一個發現，**而它的現場就是 `terms.gd:228` 那個 clamp。**
⇒ ★**我們一路往下挖到根因（單位混用），修好了根因** ——
★★**然後把【當初發現問題的那個地方】留在原地。**
⇒ ★★★**而 spec §⑦ 我寫過「單位對齊後很可能不需要壓縮」** ——
  **那句話是對 `faction_ai_system.gd` 的 score 說的，而我沒有注意到它有兩個現場。**

# ③ 裁：**兩刀一起砍**

```
**刀一**（已做）：`faction_ai_system.gd` 的 score ⇒ 單調壓縮 ＋ 相對於我的 ref
**刀二**（要補）：`terms.gd:228` ⇒ ★**同樣用單調壓縮，而不是 `/3.0` 然後 clamp**
   ⇒ `_loot = CAP × (est/ref) / (1 + est/ref)`，**ref ＝ 觀察者自己的 `reference_wealth`**
   ⇒ ★★**而 `ATTACK_LOOT_REF = 3.0` 這個常數【刪掉】** —— **它是舊尺上的校準，新尺上沒有意義。**
   ⇒ ★★★**刪掉而不是改值** —— **改值會讓下一個人以為它還有校準的餘地。**
```
★**為什麼兩邊要同一個形狀**：`terms.gd` 那條式子把 `_loot` 與 `_need`／`_odds`／人格相乘，
**而那些都是 [0,1]** ⇒ **`_loot` 也必須是 [0,1]，而且要保住鑑別力** ⇒ **與 score 那刀同一個理由。**

# ④ ★★R² 的第二點我也收：**(b) 沒跟 (c) 走同一條路**

我在 spec 裡說 **(b)「有 belief 無資產欄」與 (c)「桶號 0」epistemic 對等** ——
★**而實作上 (c) 過人格門檻、(b) 只是「沒被排除」** ⇒ **對等沒有落實到 admission 層。**
⇒ **裁：(b) 也要走同一道 admission 判斷**（結果可以是通過，但**不能繞過它**）。
⇒ ★★**若這導致行為改變，驗收會看到** —— **那正是我們要的：一致性若有代價，代價要現形。**

# ⑤ 順序

**先補刀二 ＋ (b) 的 admission ⇒ 再跑 55 支。**
★**headless 那 6 條紅照我上一封的裁定**（零情報收窄成「連 claim 都沒有」）—— **一起改，一起跑。**
