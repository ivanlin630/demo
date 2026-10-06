---
from: implementer
to: systems
status: open
slice: 終端 E2E（停工點，照你 2026-10-07 轉達的用戶裁：重開終端）
topic: ★停工交接｜branch `feat/terminal-e2e` 遠端 tip **`6493fd484`**（WIP，床還沒綠）｜電池：本票**沒跑過**｜重開後第一步＝修 `_to_main` 認主畫面的判法（鍵列換行）再跑床
---

# 一、在哪

```
worktree  A:\GDS\demo\.worktrees\e2e
branch    feat/terminal-e2e（已 rebase 在 823551f14 之上，含 A4）
tip       6493fd484（origin 同）
commits   15cf84caa press_on 抽出＋10 個 listed effect
          56f7447f6 解析器＋P0 自驗
          6493fd484 WIP：P10 修＋9 個目標動作 effect＋床主體草稿
```

# 二、做到哪

```
①共用送鍵 PlayerRepl.press_on（scripts/ui/player_repl.gd）——★完成、量過
   推進中 await process_frame 直到 is_advancing()==false；_feed／stdin／tcp 迴圈都 await
   實測：x ⇒ 回來那一屏「第 1 天 01:00」tick 60＝世界 60（等 1 幀）｜Esc ⇒ 0 幀（反向成立）
   ★play.py 落後一步隨之修好（同一支函式）—— 但 play_selfcheck／電池還沒跑過
②effect 欄（player_command_system.gd ACTION_SHAPE）——★完成
   自家隊 10 個＋目標動作 9 個（你的 (甲) 裁定），表上方逐支 handler file:line 已重算
   新值 "menu"（trade／recruit：只開子選單）⇒ 紅二不適用、紅三適用
③解析器（scripts/debug/terminal_e2e_bed.gd parse_screen）——★完成
   三個鍵位空間＋可互動目標清單＋「（未綁鍵）」清單；P0 自驗全綠
④床主體——★草稿，第一次跑在 step 0 ABORT（下面）
   雙世界：每步 A、B 各自「建（seed）→佈置→重放前綴按鍵」，一次只活一份
     （理由：GameSetup 會叫 CrossRunReset，兩份交錯推進會互相改 static）
   佈置：同格 NPC 7320 ＋ 強制事件 propose_alliance（同 forced_event_panel_bed 手法）
   A＝[t,(tab),(目標鍵),動作鍵,(打聽選第 1 題),esc…]｜B＝同樣打開、不按動作鍵、esc 回主畫面、g N enter 補齊；tick 不同 ⇒ ABORT
   判：P1／P2／P3／P4／P6／P10 常駐（每一鍵）／P5（同 seed 逐行同、換 seed 必不同）／P7（不觀測重放 fp 同）
   已知清單 KNOWN（第一次跑抓到的、§6 回報不修）—— 每條必須再現否則紅；目前空
```

# 三、第一次跑的結果（`6493fd484` 之前的工作樹）

```
P0 ✓｜P10（開場 x／反向 Esc）✓
WALK：step 0 ABORT「回不到主畫面」⇒ 其餘格全是空母體紅（地板有接住，不是空綠）
真因（我讀輸出看到的，還沒改）：_to_main 只看「 鍵：」那一行有沒有 [T]互動，
  而主畫面的鍵列折成兩行，[T]互動 在第二行 ⇒ 永遠判「不在主畫面」
```

# 四、探路已見、要進回報清單的（未經床判，先記下來免得重開後丟掉）

```
a. 互動面板寫「[T/Esc]關閉」，而按 T 印「現在沒有要回應的事件」、面板不關（同時畫面上正掛著 [A]接受 [B]拒絕）
b. 兩支都沒勢力（faction_id −1）的隊：「提議同盟（不可：對方已經和你同一個勢力）」⇒ −1 == −1 被當成同勢力
c. 成功的令在畫面上只有「已排入：行動：X」回音；成功句（行動：X：<msg>）進了 _events 但事件區只印 _feed_rows
   ⇒ 不只建立勢力（P11），是所有成功的令都沒有完成句 —— 待床確認
d. extort／invite_settle／beg 被拒時回 ok:true（「對方拒絕勒索」「拒絕邀請」「不予施捨」）⇒ 紅二候選
```

# 五、重開後第一步

```
1. git -C A:\GDS\demo\.worktrees\e2e log -1 ⇒ 6493fd484
2. _to_main 改判「畫面上任一 鍵： 開頭的段落（含續行）含 [T]互動」——跑床
3. 走通後依結果填 KNOWN（只填真的是既有缺陷、照 §6 回報的）、補三種紅的陽性對照、
   註冊列、整輪電池、交件
```

★本封之後我不開新工作，等用戶重開終端。
