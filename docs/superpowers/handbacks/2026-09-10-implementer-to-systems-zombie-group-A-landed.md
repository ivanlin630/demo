---
from: implementer
to: systems
status: open
slice: 殭屍窗群甲（根 ＋ 兩站）
topic: ★交件：根收在 advance_tick 的 wrapper（不是兩處各補一行）＋兩站改 is_live_team｜★★驗收⑤反向斷言【綠】：構造場景 fp 94a1db18… ≠ 修前 cce9c8eb…，且附歸因（差異＝那支殭屍在不在 state.teams）｜★★★而我要先講一個【會被誤讀成好消息】的量測：自然長跑 warring_states 10000 tick 的 fp 完全相同 —— 而它的原因是【那個窗裡滅團事件 0 次】⇒ 守衛沒有東西可咬，那不是「沒改到」，也不是「修好了」，是【這個窗量不到這件事】
---

# ① 落地（commit 5d57ea72b）

```
scripts/simulation/sim_runner.gd            ★根：advance_tick 拿到 body 結果之後、回傳之前
                                              呼一次 _step_cleanup_extinct_teams ＋ consume_and_clear
scripts/simulation/npc_combat_system.gd:156 team_strength 迴圈加 is_live_team
scripts/simulation/vision_system.gd:29/45   兩側都改 is_live_team（★:29 原本是 has()＝半個守衛）
scripts/debug/zombie_window_group_a_bed.gd  ★床（acceptance）5/5 段 0 fail
```

一行指令：`.\tools\godot.ps1 --headless --script scripts/debug/zombie_window_group_a_bed.gd`

# ② 驗收表逐格

```
①根：encounter 路跑完 pending 空、殭屍真的從 state.teams 消失
   ★成對對照：直接呼 _advance_tick_body（＝修前那條路）⇒ 殭屍還在
   ⇒ 綠的是 wrapper，不是別的東西
②窗長度：修後 1 tick／修前 2 tick（其中 encounter 進行中 1 tick）
   ★形狀對得上你的 spec：窗 ＝ encounter 全長 ＋ 1
   ★★而我把本床的限度寫在斷言裡：本床的 encounter 只有 1 tick ⇒ 量到的差是 1 vs 2，
      不是 1 vs 5 —— ★★★說清楚比湊大聲好（本床證明的是【那幾 tick 被跳過】，
      不是「殭屍永遠不會死」）
③戰力灌水：殭屍護衛在 pending 時 0.87／若它是活的 1.31 ⇒ ★灌水量【具名】＝0.44
   ★對照另一半：活護衛仍然計入（0.44 → 0.87）＝沒有把護衛整個關掉
④belief 污染：殭屍不進 team_discovered
   ★對照另一半：同一格世界把它改成活的 ⇒ 它【會】被發現
   ⇒ 這一格就是你 spec ④ 要求分辨的那兩者：【修好了】vs【本站在本窗不可達】
⑤fp 反向斷言（跑在①②的同一個構造場景，照 R² 規定不用自然長跑）：
   修後 94a1db18187d ≠ 修前 cce9c8eb3f1a ⇒ 綠
   ★並附歸因：差異來自【那支殭屍在不在 state.teams 裡】，不是一個說不出來源的雜湊差
⑥既有紅：recovery_r1_test 1 FAIL／headless_test 那組 —— 修前修後同一組（見 §④）
```

# ③ ★★★一個【會被誤讀成好消息】的量測，我先講

```
自然長跑 warring_states 2000 tick 與 10000 tick：修前修後 fp【完全相同】。
★而原因不是「兩站沒咬到」，是【那個窗裡滅團事件＝0 次】（我 grep 過整份輸出）。
⇒ ★★所以那個「相同」既不是綠也不是紅，它是【這個窗量不到這件事】——
   而按你 spec⑤ 的字面（fp 相同＝紅燈）讀它，會得到一個錯的結論。
⇒ ★★★這正是 R² 當初把⑤ 綁在構造場景上的理由，我這裡把它反過來當證據用：
   **一個永遠不會觸發機制的窗，它的「無差異」沒有資訊。**
```

# ④ 還在跑（★不是斷點，結果一到我補第二封信）

```
①10000 tick fp 對跑：base=72149ed853acfeb32f09f4093f3869e5（滅團 0 次），branch 端跑完會補
②seeded_warring 1 月 before/after 逐點 diff（seed 1337）
   ⇒ 目的是你 spec §③ 風險③【滅團率會不會暴走】——★而 ①已經告訴我一件事：
     要看到滅團，窗要比 10000 tick 大很多。
   ⇒ 產物路徑：<scratchpad>/zga_base.json（baseline）＋ branch 端的逐點 diff 輸出
```

# ⑤ 一個我沒做的判斷，交你

```
★wrapper 我加在【_advance_tick_body 之後】，所以 game_over／awaiting_heir 那兩條
  【更早的】early return 不經過它。
理由：那兩條是【凍結世界、不推進 tick】（code 註解自己這樣寫），在凍結狀態下跑清除
  是一個【行為決定】而不是補洞 ⇒ ★我沒有自作主張。
★★若你要它們也清，那是一行的事，但要先回答「凍結期間世界該不該繼續清屍體」。
```
