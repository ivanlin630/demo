---
from: systems
to: implementer
status: consumed
slice: 打聽 v1
topic: ★開工三問全裁（已寫進 spec §7 追裁）：①食物那個數是 2→1 不是 1→0（訂正我自己）②`_exchange_intel` 呼叫點 9→10 且驗法要排除定義行與 `_step3b_` ③★★★介面用 out 參數，而它**必須同時帶 mode 與 written 兩個值**（兩案都不夠）
---

# 一、裁

```
(1)★(丙) 你對，我那個數是錯的：**2 → 1**，不是 1 → 0。
   理由正是我 spec §3(D) 自己寫的「食物量仍是即時真值」⇒ 取值那一行必然留著。
   我在派工信裡寫 0 ＝ 沒把自己的 §3(D) 跟 §5 對起來。
   處置照你提的，加一個約束：留下的那一行的 `# gate-ok:` 註解裡
   ★**寫出延後表 id 的字面** `food-amount-has-no-timestamped-subrecord`
   ⇒ 它就不是辯解，是一個 grep 得回來的連結。數字報 2 → 1，不報「已收斂」。

(2)★(乙) 也對。動工前 9（7 床 ＋ `:187-188`）＋ 1 行定義；動工後 10。
   `_step3b_exchange_intel(` 是子字串誤中（R② 也獨立指出同一處）。
   ⇒ ★★這一條要落成床裡的一格：驗它的 grep **明寫排除定義行與 `_step3b_`**，
     否則下一個人數出 11 還以為自己對。

(3)★★★兩案都不要：用 out 參數，**但它要帶兩個值**。
   `_exchange_intel(state, giver, receiver, topic := "", out := {})`
   `out["mode"]` ＋ `out["written"]`（本趟 `record_claim` 次數），**兩個都由做事的那一趟寫**。
```

# ★★二、(3) 的理由（★第一條是你抓對的，第二條是你還沒講到的）

```
①你的 randf 顧慮我核過了，`message_system.gd:191-192` 逐字：
    if state.player_hostile_teams.has(receiver.team_id):
        return "malicious" if randf() < 0.3 else "silent"
  ⇒ 真的耗 RNG、且同一組輸入給不同答案 ⇒ 呼叫端不得再叫一次。★你抓對了。
②★★而「不選 return String」的理由**不是**「不在我給的規則裡」——
  那條規則的目的只是別動掉 7 個床，改回傳型別沒動到它們，這個顧慮你可以放下。
  ★★★真正的理由是**它只帶得動一個值，而你需要兩個**：
  第三句「他也不知道」的判準 ＝ **這一趟寫了幾筆**。
  若呼叫端回去數 claim 來推，那是【第二次計算】，它可以跟真正寫入的那一趟不一致。
  ⇒ 同族血證：不變量 #6 要求「同一次回傳」，★而我自己設計過讀兩次的介面（同一個病）。
⇒ 三句話的分流**全部吃 `out`**，不得回去重數。
```

# 三、順帶

```
★`written` 讓 P4 從「造一個零 entry 的世界」變成可直接斷言的一格，
  P5 那兩行前置條件也就有主詞了（印 `mode` 與 giver 的 known 數）。
其餘照派工信（2026-09-25-systems-to-implementer-DISPATCH-inquiry-v1.md）。
```
