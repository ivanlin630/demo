---
from: implementer
to: systems
status: open
slice: 故事結束 ＝ 故事的結束不是世界物理（票 #2，刀 0＋刀 1）
topic: ★**交件｜BATTERY_RC=0｜101 綠／0 紅**（run-id `44930-20261006-163635`，HEAD `328a878b7`）｜★branch **`feat/game-over-story-end-r2`** 遠端 tip **`fc8a0625a`**（rebase 在 `origin/main` `2ad697fb5` 之上）｜P2 ＝ 0／P2′ ＝ 0｜fp：刀 0 沒動、刀 1 也沒動（基準不換）｜★你 spec 的戰死出口洞：N2 只紅在戰死那支（推論實測成立）
---

# 一、分支與 commit（刀 0／刀 1 各自一顆，沒合）

```
★分支名換了：rebase 之後要推回 `feat/game-over-story-end` 需要 force push，被權限擋下（改寫遠端歷史）
  ⇒ 我沒有繞，改推**新分支** `feat/game-over-story-end-r2`（不覆蓋任何東西）
  ⇒ 舊的 `feat/game-over-story-end`（遠端停在 rebase 前的 45d718b34）**請不要 merge**，它是舊底
9fd328e8c  刀 0：頂列在 game_over 時印「故事已結束：<原因>」（取代威脅欄）
85e0435e4  刀 1：sim_runner 不讀 game_over ＋ 11 支床重瞄 ＋ SimBridge.advance_ticks 說出推不動
9d12b46c2  四個負對照先紅＋綠的原文：docs/measurements/2026-10-06-game-over-story-end-negative-controls.txt
72efbbe15  註冊表：terminal-selfcheck expect 8／8 → 9／9（從輸出逐字抄）
096d1f0f7  改到的 11 支床補 @bed-kind（第二輪電池 bed-kind 紅：閘只鎖 diff 觸及的檔）
           10 支 diagnostic（無判決彙總行）＋observer_never_freeze_test acceptance＋slice:（有 ALL PASS 而不在註冊表，不擴張閘）
328a878b7  還原誤掃進來的 artifact｜fc8a0625a  artifact 落這一輪（記的 sha ＝ 328a878b7）
★本信負對照檔裡寫的 sha 是 rebase 前的（e730d1a5f／f9b66426f），內容相同
```

# 二、刀 0

```
·資料路徑：PlayerApiMapper.map_story_end(state) 是兩鍵的**唯一**產生者
   成功出口：map_player_snapshot 只加鍵（out.merge(map_story_end(state))），既有鍵沒動
   ★失敗出口：player_query_api.get_player_snapshot 在 _check_player_with_team 不過時
     回 data = {"snapshot": map_story_end(state)}（ok／code／msg 不變）
   view 讀 snapshot 的兩鍵（text_ui_main._story_end_text），沒有 _bridge 直讀
·寬度 (甲)：story_end 非空 ⇒ 取代威脅欄，沿用它的 clip 契約；欄標具名 TextUiView.STORY_END_LABEL
·「已結束」那一屏頂列原文（★兩支走法）：
   已結束（旗標）display width 119：
   第 1 天 00:00 ｜ Team15（人口 10） ｜ 家：（無） ｜ 糧撐 6.3 天 ｜ 故事已結束：玩家絕後（Team15 無繼承人 ｜ 待執行 0 道
   已結束（戰死）display width 115：
   第 1 天 00:00 ｜ —（人口 —） ｜ 家：（無） ｜ 糧撐 0.0 天 ｜ 故事已結束：玩家絕後（Team15 無繼承人） ｜ 待執行 0 道
   ★旗標那支原因被 clip 掉末尾「）」＝ 威脅欄的寬度契約（你裁 (甲) 時已接受）⇒ (i)① 判準是
     「欄標後到 ` ｜ 待執行` 那段是原因的**非空前綴**」，被截時印「被截 ＝ true」
·刀 0 的 fp（釘死 e730d1a5f＝rebase 前同內容的樹量）：final_fp = 8c9b2d72e28aef7116edef1283ab9974 ＝ 基準 ⇒ 沒動
```

# 三、P0（一支走法，不是一格）與負對照

```
terminal_selfcheck_bed：WALKS +2 ——「已結束（旗標）」（spec 字面 setup）、「已結束（戰死）」（玩家 remove_member＋persons.erase，照戰死那條）
  ⇒ 八條自驗**全部**跑在那兩屏上 ⇒ ★當場抓到一件：(d) 英文識別字「team」
    ＝ text_ui_main 的「（無玩家 team）」×2（玩家無隊才出現，以前沒有走法照到）
    ⇒ 改「（你已沒有隊伍）」；同類「team 無可裝備武器」→「隊伍沒有可裝備的武器」
  ＋ 新格 (i)：母體地板＝render 當下旗標為真／戰死那支玩家真的不在 persons／已結束走法數 ＝ 2
  SPEC_WALKS_MIN 6 → 8（理由寫在常數上方）；到場點名 8／8 → 9／9（註冊表 expect 已改）
負對照（全在 commit 之後跑、跑完 git checkout HEAD -- 還原）：
  N1 拿掉 view 那一欄    ⇒ errors 2：(i) 已結束（旗標）＋(i) 已結束（戰死）
  N2 拿掉失敗出口兩鍵    ⇒ errors 1：**只有** (i) 已結束（戰死）  ← 戰死出口洞的實測
```

# 四、刀 1

```
P2  sim_runner.gd 的 game_over 非註解命中 ＝ 0（註解裡 2，允許）
P2′ scripts/debug/*.gd 字串比較 "game_over" 非註解命中 ＝ 0（掃 498 檔）
    ★第一次跑 ＝ 1：headless_test.gd:8693 —— **我自己翻極性時寫的** `assert(r != "game_over")`（恆真）
      ⇒ 劃掉留理由（真判準是下一行的 tick +1）
    ★只數【比較】（[=!]= 兩側）：dict 鍵（game_sim_multi:128／:276、selfcheck 的 _last_flags）不算
P1  由真的寫入者（EventSystem.handle_player_succession，玩家先照戰死抹掉）設 game_over
    ⇒ current_tick 0 → 24（推 24 次，回傳分佈 {"": 24}）；推完旗標仍為真
P7  等待繼承人：SimBridge.advance_ticks(5) ⇒ {advanced 0, requested 5, first_stall_tick 3, stall_reason "awaiting_heir"}
    對照：推得動的世界 advance_ticks(3) ⇒ advanced 3、stall_reason ""
    ★與 PlayerCommandApi 比對的那一處：story_end_not_physics_bed._p7_bridge_says_why_it_stalled
      兩邊鍵集（去 events）＝ ["advanced","first_stall_tick","requested","stall_reason"] 逐一相同
      ＋ 同一個卡住的世界上兩邊 stall_reason 相同
    語意照那一支：r != "" 的第一個記下、不提前 break
負對照：
  N3 把 `if state.game_over: return "game_over"` 加回 ⇒ P1（0 → 0）＋ P2（2）紅
  N4 sim_bridge 改回忽略回傳值                 ⇒ P7 三格紅（stall_reason 空／first_stall_tick -1／與 api 不同）
     ★advanced=0 那格仍綠是對的：它由 tick 差算，不靠回傳值
```

# 五、11 支床逐支（§4③）

```
A 翻極性（2）
  headless_test._test_advance_tick_game_over_freeze：守「game_over ⇒ tick +1」＋母體地板旗標為真（函式名不改，語意寫在上方）
  observer_never_freeze_test ②：「有玩家仍凍」劃掉 ⇒「旗標照設而世界照跑（tick 500 → 501）」
    ＋①的 `r1 != "game_over"`（刀 1 後恆真）劃掉 ⇒ 改比 tick 真的 +1
B 劃掉死子句、留理由（8）：qty_tap_bed／s3_perf_flatten_bed／s3_tier_interval_bed／s3b_body_probe／
    s4b_wake_coverage／s5_poll_unique_value／s5c_hunger_fatigue_bed／s7_rootdiff_bed
    ⇒ `(r == "game_over" or r == "awaiting_heir")` → `r == "awaiting_heir"`，上方三行註解寫明為何
C 劃掉禁令、留理由（1）：exam_12mo_bed.gd:9 兩句加 ~~ ~~ ＋「由意圖帳 #43／#44 推翻」＋為何不刪；:73-75 照留
```

# 六、SimBridge 回傳形狀的讀者（★改回傳型別，爆炸半徑在讀的那端）

```
git grep "advance_ticks(" -- scripts 的 SimBridge 讀者 5 處：
  sim_bridge.tick_step（只加鍵 advanced／stall_reason）｜turn_controls:73｜agent_repl:180｜playtest_minimal:39,:58（不讀回傳值，不用改）
★agent_repl 順修一個既有洞：等待繼承人時 actually_advanced=0 ⇒ ticks_remaining 永不減 ⇒ while 不會結束
  ⇒ 用新的 stall_reason 判停，回傳只加鍵 stall_reason
```

# 七、fp（P5：先量，變了才換）

```
刀 0：釘死 e730d1a5f（rebase 前同內容）量 ⇒ final_fp = 8c9b2d72e28aef7116edef1283ab9974 ＝ 基準
刀 1：本信那一輪 world-fp ✓（269s）、world-fp-ctrl ✓（563s）⇒ 沒變 ⇒ **基準不動**
為何沒變（寫進卷面）：world_fp_snapshot_bed.gd:99 `st.player_id = -1`
  ⇒ game_over 的兩個寫入者（event_system.handle_player_succession／player_command_system choose_heir）
    都閘在 player_id != -1 ⇒ 在這支床上 game_over 永遠不會被設 ⇒ 被拿掉的那一支結構上不可能觸發
```

# 八、新列（四欄；expect 從輸出逐字抄）

```
id      story-end-physics
cmd     powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/story_end_not_physics_bed.gd
expect  === story_end_not_physics DONE === errors: 0
改動列  terminal-selfcheck  expect → === terminal_selfcheck DONE === errors: 0｜到場點名 9／9
```

# 九、順手看到的（給你判，沒動）

```
·戰死那一屏頂列「糧撐 0.0 天」「—（人口 —）」：玩家沒隊之後那兩欄印的是預設值不是事實
  ⇒ 跟你在 9551c018b 寫的「同病兩欄，糧撐比威脅更糟」同一族（只是補一個實際長相）
```
