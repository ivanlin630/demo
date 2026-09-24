---
from: systems
to: reviewer
status: open
slice: 打聽 v1（情報必進 belief ＋ 代價＝對方同意）
topic: R② 審設計。spec = docs/superpowers/specs/2026-09-25-inquiry-v1-consent-and-belief-HOW.md。★最該打的三處我先指出來（見下），★★而最大的一個主張是「blueprint 要的那把秤已經在 code 裡」——那一條如果我讀錯，整張票的形狀就錯了
---

# 一、這張票在主張什麼

```
①打聽成功 ＝ 呼叫既有的 `MessageSystem._exchange_intel()`（單向、加一個有預設值的 topic 參數）
  ⇒ 零新 claim 組裝碼、零新表。判準：**出現第二個 `record_claim` 呼叫點 ＝ 這票寫錯了**。
②「對方同意」＝ 既有的 `_decide_exchange_mode()` 回不回 `"silent"`（message_system.gd:194-207）
  ⇒ 它吃的是 giver 側的 `known_reputations` ＋ 領袖「慎重」「計謀」⇒ ★方向就是 blueprint 要的方向。
③今天的真相是【兩半都沒有】：`resolve_inquiry` 全程零寫入，而 UI 只印 "情報獲取"
  （`text_ui_main.gd:2305-2308` 從來沒有渲染過 payload）。
```

# ★★二、我請你優先打的三處

```
(甲)★★★§1⑤ 那一條是整張票的地基：我宣稱 `_decide_exchange_mode` 的 `rep` 取的是
    **被問方對問話方**的評價。請你自己讀那個函式體（不是讀我的引用）——
    ★如果它其實是反過來的，(B) 整段作廢、(E) 的修法也會變成把兩邊都改錯。
(乙)★★§3(A)「加一個有預設值的尾參數」——我據 §1⑩ 說有 7 個 bed 直接呼叫它，
    所以不能改簽章。★請驗那 7 個呼叫點我有沒有數漏（漏一個 ⇒ 回歸床當場炸，而我會說「零行為」）。
(丙)★§3(E) 修 `_calc_relationship` 方向，會連帶改 `:42 honest = rel > 0.5`
    ⇒ ★★「誰說實話」的判準整個換人。我在 spec 裡說那是【修對不是副作用】——
    請你判這句話是不是我在替自己的改動編理由。
```

# 三、我自己知道的洞（先認，不要你替我找）

```
・沒跑 Godot，全靜態。
・沒量 `silent` 在真實世界的比例 ⇒ 「拒答會不會太常見」我答不出來（§6②給了量法）。
・`ask_food_source` 本票只把 god-view **收窄**（全圖 → 被問隊見過的格），沒有消滅它；
  剩下那一半登了延後（food-amount-has-no-timestamped-subrecord）。
・記憶頁是我加進 v1 的（blueprint 的驗收句要它，而查詢面今天沒有）——
  ★如果你認為那是 scope 膨脹，請直說，我拿掉它並把驗收句退回 blueprint。
```

# 四、下一站

```
你 CLEAN ⇒ 我寫 dispatch 給 implementer（含 §4 那九格與兩條負對照）。
你打回 ⇒ 我改 spec，不進 implementer。
```
