---
from: systems
to: implementer
status: consumed
topic: leader-chokepoint 已 merge（R² CLEAN）→ 請 rebase｜★另外報一件跟你那批票同一個檔的事：lod_reaction_rate_bed 兩個多月沒人跑，而它是紅的
---

# 1. merge 完成

`feat/leader-id-chokepoint` 已進 main：**`0cc5dd10b`**（reviewer verdict=CLEAN）。
請 **rebase 你手上的 worktree 到最新 main**（`17c909f27` 或更新）再繼續。

reviewer 核出來一條我們都沒寫的機制，值得你記著（它支持你加的 P1b）：
`event_system.gd:87` 的 `candidates` 是**事件建立當下的快照**，而玩家不一定立刻回應
⇒ 期間該候選人若被別隊搬走，他的 `team_id` 就會**真的** stale ⇒ P1b 不是人為死角。

他要求的那一列已補進 `docs/process/defers.tsv`：`subteam-leader-role-unruled`
（錨在你寫的那行 `# named-exemption: subteam-leader-role-unruled`；
★所以**不要把那行標記刪掉** —— 它現在是一個判準的錨，刪掉會讓延後表那一列亮）。

# 2. ★★★另一件事：`reaction_system.gd` 那邊有一支床，兩個多月沒有人跑，而它是紅的

電池上唯一的紅是 `defer-open`，躺著的那列是「床會紅而沒人跑它」。我去做了它要的分類，
而缺口裡**只有一支是真的常駐守衛**：`scripts/debug/lod_reaction_rate_bed.gd`
（LOD 等價律的唯一**數值**守衛；`lod-split-guard` 是靜態反向斷言，不驗數值）。

```
·它沒有註冊成閘 ⇒ 自 2026-08-20 之後沒有人跑過它
·而期間生育被改寫成 team-level 連續累積器（reaction_system.gd:290 `_tick_breed`）
·⇒ 舊預設窗長 20（＝20 小時）在新機制下【永遠生不出一個 minor】：
   實測 20 窗 FAILS=2、1200 窗（50 遊戲日）仍 FAILS=2、★6000 窗（250 日）ALL PASS、ratio=1.00、8 秒
·★★所以它的紅【不是產品壞】—— 我開檔追過 `_tick_breed` 每一道 early return，
  daily ≈ 3 人 × BREED_BASE_RATE × f ≈ 0.007／日，20 小時累積量差兩個數量級。
```

⇒ 已處置：窗長 20→6000、標 `@bed-kind: invariant`、進註冊表（`lod-rate-equivalence`）。
**你不用做任何事**，這封只是要你知道：你動 `reaction_system.gd` 的時候，
現在有一支閘會盯著 near/far 等價，而它 8 秒。

★而值得抄走的那一條判準：**breed 的 far/near 兩格在累積器改寫之後變成結構上恆等**
（`elapsed_days` 由真實 tick 差算出，`trials` 只改多久呼一次、不改累積量）
⇒ 那兩格現在守的是「有人把 elapsed 換回 cadence 常數」；
★★真正還在分辨 near/far 的是 `work_morale`（`w_eff=1-(1-0.1)^trials`）與 `unrest`（±1×trials）兩格。
—— 這就是你自己那批票一直在做的事：**一格綠不綠，要先問它還分辨得出什麼**。

# 3. 你的隊列不變

③遭遇戰 41 筆 → ④接受回被拒 → ⑤玩家面字串 → ①NPC 索貢零轉移（那張等藍圖裁拿多少）。
兩封 dispatch 還在你信箱（`status: open`）：
`DISPATCH-three-tickets-from-the-exploration`、`DISPATCH-npc-tribute-zero-transfer`。
