---
from: measurer
to: qa
status: consumed
slice: 「玩家死後 7 天」specimen（給 QA 故事稽核）
topic: ★回應 systems 派工（`2026-10-06-systems-to-measurer-specimen-after-player-death.md`）：specimen 已落地，請讀 motive→action→outcome 判「世界死後有沒有繼續合理地動」。副本：systems（SendMessage 已敲）。
---

# 一、已落地 exact path（開檔驗過存在）

```
docs/measurements/player-death-7day.specimen.jsonl
  ·存在：是（1587 entries，1.49MB）
  ·注意：*.specimen.jsonl 在 .gitignore（既有慣例，大型 raw dump 不進 repo）
    ⇒ 本機 docs/measurements/ 下讀，別去 git 裡找
```

# 二、樹 ／ 種子 ／ 母體邊界

```
·樹：commit 57ab240ad（已 push origin/main，≥ 要求的 78e42f776）
  （產生此檔的床本身也在這顆：scripts/debug/player_death_7day_specimen.gd，零碰
   scripts/simulation|data/*.gd ⇒ specimen 內容＝未改過的 production 行為）
·種子：1337（固定，重跑可得同一批隊：player=15／鄰近=[11,3,16]，已驗兩輪 commit 一致）
·母體：
  ─ 4 支隊：Team15（原玩家隊）＋ Team11／Team3／Team16（暖身 3 天後 tile_pos
    歐氏距離最近鄰 3 支，確定性排序零 RNG，非隨機抽）
  ─ 時窗：殺玩家後 7 天（tick 4320 → 14400，TICKS_PER_DAY=1440）
  ─ 殺玩家前先推 3 天暖身（tick 0→4320），避免「母體太年輕看不出有沒有停」
  ─ 殺法：逐字照 scripts/debug/story_end_not_physics_bed.gd:67-73（真的寫入者：
    remove_member 清光 named_members ＋ persons.erase(player_id) ＋
    EventSystem.new().handle_player_succession）
```

# 三、這一份【能】答什麼／【不能】答什麼

```
能：  Team15/11/3/16 這 4 支隊，殺玩家後 7 天內逐事件 motive→action→outcome
      （reaction 的 loyalty/stress why、SoloAI 任務選擇、交易 order、位置…）。
不能：·其餘 16 支隊（teams=20，只抽 4）沒有 trace。
      ·7 天之外（第 8 天起）沒有資料。
      ·不同種子/不同暖身長度下是否同一結論——本份只是 1 份樣本，非掃描。
```

# 四、機械面（我看到的，故事結論是你的格）

```
·★母體地板過：game_over=true（原因「玩家絕後（Team15 無繼承人）」），殺完才往下推。
·current_tick 如期 4320→14400（+10080，要求值），advance_tick 回傳分佈全 ""（無 stall）。
·兩輪（commit 前/後）各跑一次，current_tick 推進量、選中隊、game_over 原因逐字相同 ⇒ 非 flake。
·逐隊 snapshot（population/tile_pos/current_task/food/coin/material）殺玩家後 vs 7 天後比對：
  4 支隊沒有一支「population>0 卻全欄位零變化」（床裡 _mech_anomalies 空）。
·無 SCRIPT ERROR / Parse Error（wrapper child exit=0）。
·★Team15（原玩家隊）7 天後仍在 ws.teams（沒消失/沒被併），faction_id=-1（暖身期已是 -1，非
  殺玩家後才掉勢力——我沒查這是不是另一個該被你讀到的故事點，留給你判）。
```

# 五、交件

```
·commit：57ab240ad（床：scripts/debug/player_death_7day_specimen.gd）
·床跑法：GODOT_TIMEOUT=600 .\tools\godot.ps1 --headless --script scripts/debug/player_death_7day_specimen.gd
·SendMessage 已敲：qa（本封）＋ systems（副本通知，同路徑同 sha）
```
