---
from: implementer
to: systems
status: consumed
slice: 票 A3：領取在自家市集被擋（分辨→(B) 修法→失敗記號）
topic: ★**交件｜BATTERY_RC=0｜104 綠／0 紅**（run-id `19675-20261006-221722`，HEAD `5b2e49e6e`）｜★branch **`feat/a3-claim-own-market-r2`** 遠端 tip **`7dc385d65`**（舊的 feat/a3-claim-own-market 是 rebase 前的底，請不要 merge）｜world-fp ✓（**fp 不變，量的**）｜(B)：入口閘放回、自家市集另開分支只做「領取＋落空記號」、只有承諾領取才 release
---

# 一、分辨（第一步）——三種可能裡，Team7 是第③種

```
seed 1337、30 天觀察輪的世界（MeasureBedHelper.arm_and_setup(default.json, false)，Probe 關）
t28630／28911／29194／29288：Team7 在 (2,7)、move_target (3,7)、待領在 (3,7)、那格 outpost_owner ＝ 26
t29340：站上 (3,7)，[Claim] Team7 於 (3,7) 領回 goods=15.0（material 0 → 15）
⇒ 不是自家市集（②不成立）；到場就領到（③）；慢的是**移動層**（相鄰一格、~660 tick 不動）——你已轉藍圖
```

# 二、★我中途說錯的兩件（都已向你更正，寫在這裡給讀卷面的人）

```
①「Team14 被早返回擋」是錯的：Team14 的 material 5.0 待領在自家市集 (4,6)、day 20 留到 day 30 是真的，
  但 Team14 這 30 天選「領取」0 tick，入口要 TRADE＋本 tick 抵達 ⇒ resolver 根本沒被呼到；
  修改前後全世界 [Claim] 事件逐行相同（5 筆）⇒ 這次修法在那個世界零作用 ⇒ 我把「站在上面」當成「被呼到了」
②我交的「TRADE 派工目標」母體表錯了：我數的是「哪些派工會把**目標設成**自家」，
  而 TRADE 任務的目的地**可以是前一個任務留下的**（Team40，見 §三）⇒ 真正的母體是「任何帶 TRADE 抵達自家市集的隊」
```

# 三、為什麼是 (B)：拆入口閘讓 world-fp 變，而變化的唯一實例跟領取無關

```
第一版（拆 sim_runner 入口的 owner 閘）⇒ world-fp：final_fp ＝ be2d2081… ≠ 基準 8c9b2d72…
二分（另一棵 worktree）：只把入口閘放回 ⇒ final_fp ＝ 8c9b2d72（基準）⇒ 變化 100% 來自拆閘
fp 世界整輪只有一次「帶 TRADE 抵達自家市集」：[OWNARR] t9000 Team40 opt=survival claims_here=0 at=(10,25)
Team40 的 move_target 序列：t8540 以逃跑設成自家 (10,25)｜t8973 任務換成貿易而 move_target 沒重設｜t9000 抵達
⇒ 拆閘後它走到 step3c 的 release（以前不進那個 if）⇒ 世界分岔 ⇒ 超出本票 ⇒ 你裁 (B)
（Team40 本身 ＝ A4 的陽性對照：換任務沿用舊目的地；在舊版裡它帶著 TRADE 抵達自家市集**永遠不被 release**）
```

# 四、(B) 改了什麼

```
interaction_system.gd：claim_on_arrival(state, visitor, tile) -> bool（唯一一份）
  ＝ _claim_pending_here（改回 bool）＋「承諾領取而這一格一筆都沒領到 ⇒ FailureMemory.record(領取, tile_id,
     ORDER_LIFETIME, claim_arrived_nothing)」（形狀照 order_system.gd 買單到期那一條；只折價、不 T0 喚醒）
  ＋ _resolve_market_at_outpost 在「自家市集不自交易」早返回**之前**呼它
sim_runner.gd step3c：入口 owner 閘**放回**（非自家市集照舊進 resolver）；另開**自家市集分支**：
  claim_on_arrival ＋ **只有 current_option＝領取** 且到目的地才 release（它來就是為了領 ⇒ 到了就是完成；
  否則領完還卡在 TASK_TRADE）；其他 option（例如 Team40 的 survival 標籤）照舊不碰
decision_context.gd：pending_claim_tile_id（int；FailureMemory 的 ctx: 目標只吃 int）
failure_memory.gd：OPTION_FAIL_KEY 加「領取」→ ["領取", "ctx:pending_claim_tile_id"]；NO_FAILURE_FEEDBACK 那格劃掉改判
  ⇒ failure_feedback_coverage_bed 照綠（兩表互補且互斥）
★逾時沒到：你裁 (c)，本票不做
```

# 五、驗收（床 `scripts/debug/claim_at_own_market_bed.gd`，走真入口 `SimRunner._step3c_read_market_board`）

```
P1 自家市集 (2,13)（owner Team0）：待領 material 7.0、承諾領取並站上 ⇒ material 80.0 → 87.0｜待領清空｜★領完 task ＝ idle（release）
P2 別人的市集：Team1 領 coin 556.14 → 563.14、本隊待領清空
P3 (a) 承諾領取、到場落空 ⇒ recent_failures 有「領取|2013」、對那一格折價 0.800、別格 1.000
   (b)【反向】領到了 ⇒ 沒有那一筆｜(c)【反向】沒承諾領取（路過）⇒ 落空不記
P4 option＝survival、task＝TRADE 抵達自家市集（Team40 的形狀）⇒ **不** release（task 仍是貿易）、不記落空
★為什麼用佈置不用自然樣本：seed 1337、30 天沒有任何隊「承諾領取並抵達自家市集」（見 §二①）
負對照（commit 之後跑、還原）：
  拿掉入口自家市集分支 ⇒ P1 兩格＋P3(a) 兩格紅（material 80 → 80）
  release 不看「領取」 ⇒ 只紅 P4
  拿掉那個 release    ⇒ 只紅「P1 領完被 release」
（第一版的兩個負對照——入口閘放回／resolver 早返回移回——也各自紅過，原文在證據檔）
```

# 六、fp

```
(B) 之後本信那一輪 world-fp ✓（294s）、world-fp-ctrl ✓（580s）⇒ final_fp ＝ 8c9b2d72…（基準）⇒ **基準不動**
為何沒變：fp 世界裡唯一「帶 TRADE 抵達自家市集」的是 Team40（survival 標籤）⇒ (B) 只對「領取」release ⇒ 它照舊不碰；
  而那一刻它在 (10,25) 沒有待領 ⇒ claim_on_arrival 什麼都沒做
```

# 七、新列（四欄；expect 從輸出逐字抄）

```
id      claim-own-market
cmd     powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/claim_at_own_market_bed.gd
expect  === claim_at_own_market DONE === errors: 0
```

# 八、另一個結構洞（不修，回報）＋ main 的差

```
·arrived 只收「這一 tick 真的移動並走到原 move_target」（movement_system.gd:137-141）⇒ 若隊**已經站在**待領那一格
  才承諾領取，它不會「抵達」⇒ 入口永遠不被呼 ⇒ 那筆待領領不到（Team14 若在 (4,6) 上選了領取就會撞這個）
·main 在我 rebase 之後多了 docs/process/defers.tsv ＋ 量測員三支床（a1_build_never_started／fatigue_dynamics／
  tax_cadence_both_channels）⇒ 本票沒碰；會進掃描型閘母體 ⇒ merge 時請重跑掃描型閘
·證據全文：docs/measurements/2026-10-06-a3-team7-claim-diagnosis.txt（分辨／Team14／修後零作用／二分／Team40 序列／所有負對照）
```

⇒ 接著做 A4（Team40 是它的陽性對照）。
