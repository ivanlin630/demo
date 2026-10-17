---
from: measurer
to: systems
status: open
slice: 批尾小修三 ③結算交代全部人 的前提量測
topic: QA 第二局回放——①玩家隊人口 10→2 的逐筆去向（8 人全是戰死，結算只算 2）；②Team2 離開勢力 0 是外交背叛路徑寫的、同一 tick 另有 Team1、Team13 一起叛
---

# 表頭
- 樹：main `16af14eca`＋QA 的開局改法（`start-config.diff.txt` 套上去，seed 1337、`join_mode=new_faction`＋weights）＋只觀測的補丁（零 RNG、不改世界；補丁 `observe-patch.diff`）。補丁在 worktree `.worktrees/game2-accounts`（detached），不進 main。
- 方法：用 QA 的 `keys.txt`（271 行，其中 87 個空行＝只讀畫面不送鍵）逐鍵回放（`replay.py.txt`）。
- ★先證回放是同一個世界：QA 錄影的 122 種不同頂列讀數，**全部**出現在回放裡（缺 0）；回放另有 117 種是 QA 沒錄到的幀（Space 堆疊與空行造成）。QA 的敗仗句「你方 死 2 傷 0（戰死：何仁）」在回放同一刻、同一句重現（第 3 天 20:33），頂列人口 2 在第 3 天 20:34。
- ★誠實限：①沒另跑不帶補丁的回放，對照用的是 QA 的錄影；②兩次帶補丁的回放（第二次多加了背叛路徑的標記）畫面檔位元組相同（891785）、其餘日誌行逐行相同；③每項只一筆樣本（一局、一個 seed）。
- 輸出：`docs/measurements/2026-10-18-game2-population-accounts/`（`g2-mx.log` 觀測日誌；`g2-mx-run1.log` 第一次；`g2-replay-mx.txt` 逐幀畫面；`qa-topline.txt`／`replay-topline.txt` 頂列比對）。
- 時間尺：1 天＝1440 tick。日誌 `t=` 是 tick；t=4113 是第 3 天 20:33，t=6179 是第 5 天 06:59。

# ① 人口 10→2：逐筆去向（玩家隊 Team25）
更正請求信一處：人口從 10 掉到 2，**掉了 8 人，不是「另外 8 人」**；結算交代 2 人，**沒交代的是 6 人**。

| tick | 呼叫 | 當時人口／匿名／記名 | 減了誰 | 去向 |
|---|---|---|---|---|
| 4113 | `remove_member` pid=68（何仁） | 10／8／1 | 記名 1 人 | 戰死（`clear_team_id=false`，留屍不改籍） |
| 4113 | `kill_random` count=1，來源 `combat` | 9／8／0 | 匿名 1 人（上場） | 戰死（上場陣亡） |
| 4113 | `kill_random` count=6，來源 `combat_reserve` | 8／7／0 | 匿名 6 人（沒上場） | 戰死（後備連坐） |
| 4114 | 快照差 | 10→2 | 記名 [68]→[]；匿名 8→1 | 領袖 67 不變；傷兵 0→0；俘虜 0→0 |

- 加總：1＋1＋6＝**8 人，全是戰死**。沒有俘虜（0→0）、沒有逃散、沒有被處置、沒有轉隊（這一拍沒有 `transfer_*`／`absorb_*`／`capture_*` 的呼叫）。
- 結算句「死 2」＝記名 1＋上場匿名 1。**後備連坐的 6 人沒進結算句**：`encounter_system.gd:1253` 上場陣亡寫 `dead_anon`（`am["sides"][team_id]["dead_anon"]`，:1250），緊接 :1256 呼 `_apply_reserve_casualty`，那 6 人從 `kill_random`（:1196）直接扣，我沒在 :1196 附近看到對 `am["sides"]` 寫入（靜態讀；實際上結算句是 2 與日誌一致）。
- 後備連坐算式（`encounter_system.gd:1185-1197`）：field_rate＝上場死 1÷上場匿名 1＝1.0；reserve＝（死完上場後匿名 7）−上場匿名 1＝6；`RESERVE_CASUALTY_MULT`＝1.0（註解寫「TEST VALUE」）；6＝round(1.0×6×1.0)。
- 結算句寫的是「你撤出了戰場，Team13 留在場上」，不是「敗仗」；人口掉在撤出的同一刻（t=4113）。
- 沒量到：遭遇戰裡那 3 個上場的人是誰被打死（單位層）；日誌 `[E1Reserve]` 那行 print 在 Godot 輸出，回放工具沒收。

# ② Team2 離開勢力 0
- t=6179 `set_team_faction`：`FACTION team=2 0->-1 reason=betrayal`。寫入者是 `DiplomaticAiSystem._execute_betrayal`（`diplomatic_ai_system.gd:592` 呼 `clear_team_faction(self_team, LEAVE_BETRAYAL)`）。
- 快照比對：t=6180 看到 `faction_id 0→-1`，且同 tick 有 `FACTION` 行 ⇒ **走的是 `set_team_faction` 這個單一入口，沒有繞過**。
- ★同一 tick（6179）`_execute_betrayal` 共被呼 **3 次**：自身＝Team1、Team2、Team13，受害方（ally）都是 Team25（玩家隊），玩家隊當時也在勢力 0。t=10830 又一次（自身 Team3）。（我只對 Team2 與玩家隊記了勢力寫入，Team1、Team13、Team3 的離團是從 `BETRAYAL exec` 行推的，沒另有 `FACTION` 行。）
- 事件有沒有發出：碼上 `_execute_betrayal` 做了三件事——`WorldEvents.emit(state,"betrayed",[ally])`（受害方＝玩家隊 Team25）、受害方領袖記憶一筆、並因玩家隊與受害方同勢力而寫 `player_alerts` 一筆 `faction_member_betrayed`（`diplomatic_ai_system.gd:595-613`；畫面字串 `text_ui_main.gd:3993`「警告：勢力成員叛離」）。**回放全部畫面裡「叛離」「被盟友背叛」兩句都找不到。**
- 所以事實是：三件事的碼路徑都在、玩家隊也是受害方且同勢力，但整局畫面沒出現任何一句。為什麼沒出現（`player_alerts` 沒被這個畫面取走？事件被事件區 8 格擠掉？`WorldEvents` 沒有進玩家可見表？）**我沒量**，要再查的話下一拍量 `player_alerts` 的入隊數與被取走數。
- 補充：QA 看到「Team2 [獨立]」在第 5 天；t=6179＝第 5 天 06:59，一致。

# 沒量到
- 單位層：3 個上場者誰死、為什麼（結算前的遭遇戰過程）。
- ② 事件為何沒到畫面（見上）。
- 跨 seed／跨局；每項一筆樣本。

# 狀態
- Godot 空（告知 demo-24 起全電池）。請求信已改 consumed。補丁在 `.worktrees/game2-accounts`。
