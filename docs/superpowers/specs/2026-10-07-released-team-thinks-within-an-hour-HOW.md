# 思考節律：被解除任務的隊一小時內必想一次＋release() 自己的 tap（HOW）

```
票源 ＝ 用戶裁「混合」（例行每小時＋事件解除，解除後不得空等超過一小時）
     ＋藍圖裁 `e34b461f5`（紅基線 4/190、最大 117；release() 補 tap，含 changed 旗）
量測 ＝ 量測員 `83dfd6505`（`scripts/debug/release_to_next_decision_gap.gd`，default seed 1337，30 天）
基準樹 ＝ `786c3e7a2`｜序 ＝ … → R → **本票** → 觀測輪重跑
```

## §0 現況（file:line）

```
①`task_arbiter.gd:334 release(team)`：清 task／move_target／priority／reason；★**不碰 pass_next_tick**、★**拿不到 state／tick**（呼叫點約 67 個非註解行；R² 實數）
②`sim_runner.gd:391-406 _collect_due_teams`：每顆 tick 跑（:650，在 _run_systems 之前；current_tick 在 :795 才 +1）
   到期後 `pass_next_tick = CadenceStagger.next_tick(cur, cur, tid, NEAR_CADENCE)` ＝ (cycle+1)×60＋offset ⇒ 間隔最長 ~119
③既有計數 `commit.release_clean`＋`commit.release_with_commitment`（:336-350）**每次呼叫都加** ⇒ 406；
   量測員代理偵測（task 真的變 IDLE）＝ 203（有效 190）⇒ 差 2 倍沒分出來
④`sim_runner.gd:340-341 pass.dup_in_cycle`：同一週期第二次 pass 就加 —— `pass_stagger_bed.gd:238` 讀它
```

## §1 做什麼

```
①【tap】release() 開頭：changed ＝ (current_task != TASK_IDLE)
   ⇒ Probe.bump("release.changed" 或 "release.noop")；changed ⇒ bump_sample("release.event", {team, prev_task})
   ⇒ ★release 拿不到 tick ⇒ 樣本的 tick 由②補（排程端第一次看到它的那一顆，記成 tick＝cur−1，鍵名 "tick_seen_minus_1" 照實寫，不假裝是精確 tick）
   ★只觀測：counts／samples 不寫 state、不呼 rand
②【標記】changed ⇒ `team.release_pending_task = prev_task`（新欄位，"" ＝ 無）
   ★noop 不設（防禦性呼叫不觸發任何事）
③【夾】`_collect_due_teams` 每顆 tick：release_pending_task != "" ⇒
     若 team.current_task == TASK_IDLE（還沒被重派）⇒ `pass_next_tick = mini(pass_next_tick, cur − 1 + NEAR_CADENCE)`，Probe.bump("pass.release_clamped")
     否則（同 tick 已被重派）⇒ 不夾，Probe.bump("release.reassigned_before_seen")
     兩種都清回 ""
   ★順序理由：release 多半發生在 tick T 的 _run_systems 內 ⇒ T+1 的 collect 第一次看到 ⇒ cur−1＋60 ＝ T＋60
     玩家指令在兩 tick 之間 release（current_tick 已是 T+1）⇒ 夾到 T+60 ＝ 比要求更嚴、不違反
   ★不動例行錯開：夾之後那一次到期照常跑、照常用 CadenceStagger 排下一次
④【不變量 #8 的豁免】夾出來的那一次可能與上一次例行落在同一週期 ⇒ `pass.dup_in_cycle` 會被它推高
   ⇒ 到期那一刻若是夾出來的（記在 team 上一個 bool 或由③的 bump 對應，你定）⇒ 記 `pass.dup_in_cycle.release` 而**不**記 `pass.dup_in_cycle`
   ⇒ ★`pass.dup_in_cycle` 的語意維持「例行每週期恰好一次」，事件觸發的另計（用戶裁的「混合」就是這兩類）
   ★夾不會造成 gap < MIN_GAP：夾值 ≥ release tick＋59 ≥ 上次評估＋59 > 30
⑤新欄位進不進指紋：`release_pending_task` 不帶 `_next_tick` 字尾 ⇒ 會被 FpCoverage 機器全集收進去
   ⇒ 照實量（P6），不要為了避開指紋改名
```

## §2 驗收

```
P1 [鑑別格] 量測員那支床改成判決床（同 seed 1337、30 天）：changed 的 release ⇒ release tick（tick_seen_minus_1）到下一次 pass 的距離
   ⇒ **> 60 的筆數 ＝ 0**（紅基線 4/190，修前必紅）；★母體地板：changed 筆數 ≥ 150（印出實數）
   ⇒ 按 prev_task 分桶**常駐印**（n／中位／p90／最大）；小母體（n<20）不單獨判
P2 [406 怎麼讀] 印 release.changed＋release.noop ＝ 舊兩個計數之和（同一輪、同一時刻）⇒ 必須相等（新 tap 沒漏呼叫）
   ⇒ 印 noop 佔比（這就是 203 vs 406 的答案；不斷言比例）
P3 [反向] 沒有 release 的隊不得多想：`pass.dup_in_cycle`（例行）＝ 0、gap 全部 ≤ 2×60−1（既有兩條，照守）
   ⇒ `pass.release_clamped` ≤ `release.changed`（夾只會由真的解除觸發）
P4 [同 tick 重派] `release.reassigned_before_seen` 印出來（＝量測員候選 (a) 的實數）
P5 [負對照] 拿掉③的 mini ⇒ P1 紅（實測筆數印進卷面）；拿掉④的分流 ⇒ pass_stagger 那一格紅
P6 fp 會變（行為改了＋新欄位）⇒ 先量、變了才換基準、與本票原子落地
P7 pass_stagger_bed 重跑：它讀 dup_in_cycle，語意改了 ⇒ 它的 expect 若要動，從輸出逐字抄
```

## §3 不做

```
·不給 release() 加 state／tick 參數（約 67 個呼叫點；這票只需要「下一顆 tick 看到」）
·不做「解除當下立刻想」（藍圖裁：夾進一小時，不改成事件即時）
·勢力粒度不動：`_collect_due_factions` 不讀這個標記（不變量 #8 推論：錯開單位＝系統粒度）
```
