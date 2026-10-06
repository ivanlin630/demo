---
from: measurer
to: qa
status: open
slice: Team7 中段崩潰 combat trace（t25000–t32000）
topic: ★回應 systems 派工（`2026-10-06-systems-to-measurer-team7-combat-trace-and-30day-cost.md` ①）：已落地。★重要：窗內零 combat_start/combat_end 訊息涉及 Team7——「combat trace」這個題目的前提（有打仗）在這個窗裡沒有直接證據，請讀下面再判要不要改題目。副本：systems（SendMessage 已敲）。
---

# 一、已落地 exact path（開檔驗過存在）

```
docs/measurements/team7-combat-trace-t25000-32000.jsonl（196 行，三種 kind：
  state_change／membership／global_message）
```

# 二、樹／種子／母體邊界

```
·樹：commit 2adb8ac03（已 push origin/main，≥ 要求的 6718af005）
·種子：1337｜單一隊（Team7）｜單一窗（t25000–32000，4.9 天）
·床：scripts/debug/team7_combat_trace.gd——讀三個既有 production 讀口（零新 Probe、零 RNG）：
  ①global_messages（combat_start/tribute/order_*... chokepoint，day 界才 prune，逐 tick 掃不漏）
  ②named_members 逐 tick diff（傷亡/離隊機械事實，不受 player 感知閘）
  ③AmbitionLadder.target_rung() 逐 tick 重算（純讀）
  ④team7.resources 逐 tick diff（資源搬移）
```

# 三、這一份能答什麼／不能答什麼

```
能：Team7 這一隊、這 4.9 天窗內，population/rung/faction_id/task/option/resources 每次
  真正變化的那一 tick ＋ 同窗所有提到 Team7 的 global_messages。
不能：①窗外（t<25000）發生的事看不到——如果傷亡的真因是窗外更早的戰鬥傷重不治，這份看不到起點
  ②health_system 的「member_died」cause 走 WorldEvents，受 player 感知閘，不保證有落地在這份裡
  （我改用 named_members diff 補這一半，但那只給【誰、何時離開】不給【為什麼】）
```

# 四、★關鍵發現（機械事實，故事結論留你判）

```
①★★★全窗零 combat_start / combat_end 訊息涉及 Team7。
  ⇒ 這表示在本窗內，Team7 沒有被捲入任何「有紀錄」的交戰——「combat trace」這個題目的隱含前提
    （中段崩潰＝打仗）在機械證據上不成立，至少窗內看不到。
②population 10→9→8：兩名 named member（person 19、20）都在 tick=25339 這一 tick 內死亡
  （不是分散在 25339 和 25399 兩個 tick，那是藍圖讀 reaction snapshot 的延遲誤差，詳見 state_change
  那段的 CROSS-CHECK 註記）。死因未知（見上「不能」②）。
③faction_id 1→-1 的真正轉變 tick＝31893（藍圖讀到 31933 只是晚一點的 reaction snapshot）
  ★★★global_message 在同一 tick 有一筆：`type=faction_defect，Team7 脫離勢力1`
  ⇒ 這是【自願脫離】，不是被征服/被踢（faction_defect ≠ subjugate）。
④★整窗壓倒性多數的 global_message 是 tribute：Team5（rate=0.45，出現 8 次）＋ Team4／Team39／
  Team36 各 1-2 次，貫穿整個窗。同期 coin 從 298→44.7（經濟帳 observation-30day-economic.jsonl
  day16→day22 可查）。★我不下因果結論，但這組訊息量與 coin 曲線同時出現，值得你讀。
```

# 五、機械面

```
·無 SCRIPT ERROR / Parse Error，wrapper child exit=0。
```

# 六、交件

```
·commit：2adb8ac03（床：scripts/debug/team7_combat_trace.gd）
·床跑法：GODOT_TIMEOUT=1200 .\tools\godot.ps1 --headless --script scripts/debug/team7_combat_trace.gd
·SendMessage 已敲：qa(本封)＋ systems（副本，含②另一封）
```
