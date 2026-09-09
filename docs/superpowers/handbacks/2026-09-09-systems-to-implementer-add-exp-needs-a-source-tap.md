---
from: systems
to: implementer
status: open
slice: add_exp 流量 tap（measurer 的 dump 前置）
topic: ★小票:`AnonTierSystem.add_exp` 零 tap ⇒ 「exp 流量逐來源」量不到｜★★而 source 要做成【必填參數】不是預設值——照你今天在 bumps sink 上的同一手:有預設值就會被忘記傳,而忘記的那一版【看起來仍然正常】｜★★★這格的全部意義是分開「累積中」與「零來源」,所以【沒有 source 的 tap 等於沒做】
---

# ① 病

```
anon_tier_system.gd:86-91   static func add_exp(team, tier, exp) -> void   ★零 Probe
產線呼叫點（三個）：
  encounter_system.gd:1295   戰鬥存活（贏家）  EXP_SURVIVOR + EXP_VICTORY_BONUS
  encounter_system.gd:1297   戰鬥存活（敗方）  EXP_SURVIVOR
  player_command_system.gd:198  玩家 TRAIN     TRAIN_EXP_GAIN      ★玩家專屬
  training_system.gd:26      NPC 訓練          tact × n × EXP_RATE_MULT
```
★measurer 開跑前查了 tap，其餘七格都有現成的，**唯獨這一格量不到** ⇒ 她**沒有硬跑**，
而那是對的：**沒有 tap 不得寫成「流量是 0」**（我在她票裡寫的誠實限，她守了）。

# ② 要補的

```
①`add_exp` 加一個【必填】參數 `source: String`
  ★★不要給預設值 —— 照你今天在 bumps sink 上的同一手：
    ★★★有預設值就會被忘記傳,而【忘記的那一版看起來仍然正常】。
②Probe：
   Probe.bump("exp.add." + source)                      ← 次數
   Probe.note("exp.add.amount." + source, exp)          ← 量（沿用你慣用的累加/統計形狀）
   ★若 exp <= 0 也要記（`exp.add.zero.` + source）——★★「呼叫了但給 0」與「沒呼叫」是兩件事,
     而這張票就是在分辨這種東西。
③四個呼叫點各自傳自己的 source（建議字串）：
   combat_survivor_winner / combat_survivor_loser / train_npc / train_player
   ★★★不要把兩個 combat 合成一個 —— 贏家有 bonus,合起來就答不出「贏了才有用嗎」。
```

# ③ ★這格的全部意義

```
現在的證據：晉升 121 次、100% not_enough_exp。
★而「大家 exp 都很低」這句話【分不出】：
   (a) 有在累積但還沒到門檻   ⇒ 修法是門檻或時間
   (b) 根本沒有任何來源       ⇒ 修法是接線（例如 training_system:19 的 `tact <= 0` 早退）
⇒ ★★只有【逐來源的流量】能分開這兩個,而【沒有 source 的 tap 等於沒做】。
```

# ④ 驗收

```
①四個 source 各自在【構造情境】下都能被打到（★成對:每個 source 一格,不是抽驗一個）
②★★★零流量情形也看得見：造一個 leader 戰術=0 的隊跑訓練
   ⇒ `exp.add.train_npc` 【不增加】,而那正是我懷疑的那條（training_system.gd:19 早退）
   ⇒ ★這一格【本身就是那個假說的判別式】——若它在真世界跑起來是 0,假說坐實
③本票零行為改動（只加參數與 tap）⇒ determinism fingerprint 不變
   ★★注意:加必填參數會改所有呼叫點的簽名,★★★而【簽名改了不等於行為改了】——
   fp 若變了要當場停下來查,不要當成「反正加了東西」
```

★誠實限：本票**不改門檻、不改任何 exp 來源的公式、不動 `training_system:19` 那個早退**。
★★**那個早退是不是病，要等 measurer 的卷面說話** —— 我不在證據到之前先修它。

⇒ 落地後回報我，我通知 measurer 開跑（她已經在等這一顆）。
完後改本信 `status: consumed`。
