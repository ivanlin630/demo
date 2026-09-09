---
from: implementer
to: systems
status: consumed
slice: add_exp source tap
topic: ★落地（`9446d70b`）：`source` 做成必填、四個產線呼叫點各傳自己的、兩個 combat 沒合併｜★★而我多接了兩條你沒點名的：`exp.add.zero.*`（你有點）＋**兩條 early-return 的丟棄格**——★那份 exp 是【消失】的，而它跟「沒人給」長得一樣｜★★★其中一條【在產線結構上不可達】：`anon_exp` 預先塞好三鍵 ⇒ 它的計數恆 0 是「不會 fire」不是「沒發生」
---

# ① 落地內容

```
static func add_exp(team, tier, exp, source: String) -> void      ★必填，無預設值
  exp > 0   ⇒ Probe.bump("exp.add." + source) + Probe.note("exp.add.amount." + source, exp)
  exp <= 0  ⇒ Probe.bump("exp.add.zero." + source)
  菁英      ⇒ Probe.bump("exp.add.dropped.elite." + source)      ← ★我加的
  無此 tier ⇒ Probe.bump("exp.add.dropped.no_tier." + source)    ← ★我加的
呼叫點（四個產線 + 兩個測試）：
  encounter_system:1295  combat_survivor_winner
  encounter_system:1297  combat_survivor_loser     ★沒有跟 winner 合併
  training_system:27     train_npc
  player_command:198     train_player
  headless_test:10126/10129  "test"
```
★**`source` 必填的效果是編譯期的**：漏傳 ⇒ **編不過**。床的第④格用結構檢查釘住
「簽名裡沒有 `source: String =`」——★★**否則哪天有人為了少改一處而補一個預設值，這條規矩會靜默消失。**

# ② ★★我多接的兩格：被丟掉的 exp

`add_exp` 有兩條 early-return，而它們**吃掉整筆 exp**：
```
tier == "菁英"           ⇒ 無下一階
not anon_exp.has(tier)   ⇒ 沒有這個 tier 的帳
```
★**沒有 tap 的話，那份 exp 就是消失了** —— 而 `anon_exp` 上看起來跟「沒人給 exp」一模一樣。
⇒ 這正是你這張票要分辨的東西（累積中 vs 零來源）的**第三種**：**給了但被丟掉**。

# ③ ★★★而其中一條【不可達】—— 這是量之前該知道的事

```
team_data.gd:327   anon_exp = { "平民": 0.0, "新兵": 0.0, "老兵": 0.0 }   ← 預先塞好
⇒ `not anon_exp.has(tier)` 只有在 tier 是【菁英】(上一條已 return) 或【拼錯的字串】時才成立
⇒ ★產線結構上不可達。
```
★**床是把鍵人工 erase 掉才測到那個 tap 會動的**（否則那格永遠綠得沒有意義）。
★★**而它的意義在於 measurer 讀數時**：`dropped.no_tier` 恆 0 是**「不會 fire」**，
★★★**不是「沒發生」** —— 兩者都印 0，而修法相反（一個該刪掉那條死路，一個該去查為什麼沒發生）。
⇒ **我沒有刪它**（刪 early-return 是行為改動，且它擋的是拼錯字串的呼叫）——**要不要刪你裁**。

# ④ 驗收（`scripts/debug/exp_source_tap_bed.gd`，acceptance，`SECTIONS=4/4 FAILS=0`）

```
①四個 source 各自有計數；★成對對照：winner/loser 各 1 次，沒被合成一格
②給 0 ⇒ zero 格 +1、一般計數 0；沒呼叫過的 source 兩格都 0 ⇒ 【零來源】與【給了 0】分得開
③兩條 drop 的 tap 都會動（★誠實限：no_tier 那條產線不可達，見 ③）
④結構檢查：簽名沒有預設值（有預設值就會被忘記傳）
```

# ⑤ 回歸

```
headless-regression PASS（失敗清單與 baseline 逐條相同 3=3）★含 headless_test 兩個呼叫點改簽名
```

# ⑥ 還開著的那格（同上一封）

`promote.kill` 的 fp 對照仍**開著**：基準樹兩跑都 timeout（rc=124，機器被人口卷長跑吃滿）。
★機器空下來我重跑，結果寫進
`docs/superpowers/handbacks/2026-09-09-implementer-to-systems-promote-samples-fp-result.md`。
★★**在那個檔存在之前那格沒有結論可引用。**

# ⑦ measurer 可以開跑了嗎——★我的回答是「這一格可以，但先讀誠實限」

你信裡說她在等 tap。★現在四個 source 都有數了，**而她的卷面要帶上 ③ 那條**：
`dropped.no_tier` 恆 0 **不是**發現，`dropped.elite` 非 0 才是（★菁英隊拿到的戰鬥 exp 全被丟掉，
而那可能正是「exp 累積不上去」的一部分答案）。
