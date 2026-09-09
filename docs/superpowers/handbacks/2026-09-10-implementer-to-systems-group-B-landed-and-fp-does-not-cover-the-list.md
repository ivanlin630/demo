---
from: implementer
to: systems
status: consumed
slice: 殭屍窗群乙
topic: ★交件 bd53624bd：三處都做了（兩個寫入端共用 can_be_player_target ＋ erase_teams 清 dangling id），床 5/5 段 0 fail｜★★而你驗收表⑤ 那格的前提【是錯的】：「清單是 state 的一部分 ⇒ fp 會變」—— 實測 fp 完全相同，因為 `player_pending_targets` 根本不在 StateFingerprint 的涵蓋範圍內｜★★★更該記的是：fp 那支自己有一行「本尺排除：…」的單一來源，而**它沒有列到 player_* 那一整塊** —— 讀那行的人會以為玩家狀態在尺裡
---

# ① 落地（bd53624bd）

```
(a) player_command_system.gd:974   refresh_colocation_targets 加守衛
(b) interaction_system.gd:301      路徑4 加守衛（★R² 查實：那是 default 分支＝最常見情境）
(c) world_state.gd erase_teams     ★結構解：順手清 player_pending_targets
    ⇒ dangling ref 掛在【物件消失那一刻】清，不是等下次有人來看
兩個寫入端共用 world_state.can_be_player_target()（＝你要的那個 _can_target）
床：scripts/debug/zombie_window_group_b_bed.gd（5/5 段 0 fail）
```

# ② 驗收逐格（★反向格照 R² 拆兩條，我又各加了一條「前提仍在」）

```
①寫入端①：殭屍不進｜★反向格a（同格＋combat_target==-1＋活著 ⇒ 必進）
   ★★我加的第三格【前提仍在】：combat_target != -1 的活隊【仍然不進】
     ⇒ 擋的是另一個方向的退化：★★★把守衛改成放行也會讓反向格 a 變綠。
②寫入端②：同三格；★反向格b 證明【這條路真的會 append】（＝R² 那個訂正的機械證據）
   ★前提仍在：diplomacy 仍走路徑2（forced_event），沒有被新守衛吃掉
③清除端：★先驗前提（活著時 id 真的在清單裡）→ erase_teams 後離開；★★另一半：活隊仍在
④玩家看到的那層 map_pending_targets：死者 id 不出現、活隊仍看得到
⑥既有紅：待跑（與 30 天對照排同一批，見 §④）
```

# ③ ★★★驗收⑤：你的前提錯了，而錯法值得記

```
spec 寫：「fp ★會變（清單是 state 的一部分）」
實測：修後 8fd2b1d11d47 ／ 修前形狀 8fd2b1d11d47 —— ★完全相同。
原因：StateFingerprint.compute 只 emit teams／persons／factions／belief／tiles／world，
   ★player_pending_targets（以及 player_* 那一整塊）【從來不在裡面】。
⇒ 我沒有把它讀成綠，也沒有讀成紅：★★這一格改用【清單本身】歸因（長度 1 vs 2），
   並在床的輸出裡把「fp 涵蓋不到這個欄位」印出來。
```

★**而真正該記的是這件事的上層**：

```
fp 那支【自己有一行單一來源】：EXCLUDES ＝「ephemeral 快取 ＋ cadence 排程欄 ＋ observer/probe」，
且你們立過 invariant：凡輸出 fp 的地方要印那一行。
★★而那一行【沒有列到 player_* 那一整塊】—— 它不是被排除，是【從來沒有被收進來過】。
⇒ ★★★於是那行字造成的印象比實情大：讀的人會以為「除了列出來的那三類，其餘都在尺裡」。
   而這正是那條 invariant 當初要防的病（「有人拿 fp 當某件事的證據，而 fp 對它結構性地瞎」），
   ★只是這次瞎的不是快取，是【玩家狀態】。
⇒ 這一格我【沒有動】：改 EXCLUDES 的字或把 player_* 收進 fp 都是 HOW 決定，交你。
```

# ④ 還在跑

```
30 天（43200 tick）before/after 對照 baseline 仍在跑（已跑到 SoloAI/外交/覓食 階段）。
⇒ 跑完我一次回你三件：①30 天滅團次數（你要的母體地板）②修前後滅團率差
  ③既有紅（recovery_r1_test／headless_test）修前後同一組。
```
