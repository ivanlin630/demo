---
from: measurer
to: systems
status: consumed
slice: 開點登進既有長程目標表（HOW 前置量測）
topic: 兩道舊門（人數 pop*2／沒帶隊人）擋下的隊：誰、之後去哪、升人副作用——只量不判
---

# 表頭
- 樹：main `e4caa61f0` ＋ 量測 worktree 的只觀測補丁（`observe-patch-faction_ai_system.diff`，零 RNG，不進 main）。
- 世界：warring_states／peaceful_economy_factioned，seed 1337，30 天（tick 43200）。warring 末 126 隊，peaceful 末 21 隊。
- ★誠實限：開 Probe 世界走另一條路（known_issues）⇒ 絕對值只算方向。
- ★warring 第一輪 GODOT_TIMEOUT 900s 被殺（工具超時，不是迴歸；檔留 `warring-r1-TIMEOUT900-incomplete.txt`，不用）；r2 以 3000s 跑完。r2 期間 QA 真玩同時在跑 Godot（CONTENDED，只影響牆鐘，不影響 tick 結果）。
- 原始輸出：`docs/measurements/2026-10-17-dispatch-gates-who-and-next/`（`warring-r2.txt`、`peaceful-factioned-r1.txt`、補丁、床 `gate_who_next_bed.gd.txt`）。
- ★對帳（兩盲同數）：warring 我的事件數 no_advisor 257／pop 165 ＝ 實作端交件信六道閘表（修後 257／165）；peaceful 的 `funnel.build_gate.*` 計數與我的事件數也各自相等（27／74）。food_bridge 兩世界都是 0（根本沒走到這道門）。

# 1. 人數門（pop*2，lv1 要 12）
| 世界 | 次數 | 不同隊（括號內 gap 欄的隊數會跨欄重複計） | gap 1–2 | gap 3–6 | gap 7+ |
|---|---|---|---|---|---|
| warring | 165 | 13 | 25 次／2 隊 | 28 次／8 隊 | 112 次／9 隊 |
| peaceful | 27 | 4 | 0 | 10 次／2 隊 | 17 次／3 隊 |

- ★集中度：warring 最多一支被擋 **51 次**（31%）；11 次以上的隊 5 支；只被擋 1 次的 2 支。peaceful 最多一支 **16 次（59%，top-1>50%，總數不得單獨當趨勢）**。
- 被擋時 pop 分布（pop→次）：warring 2→77、3→25、4→9、5→1、6→3、8→16、9→9、10→25；peaceful 2→8、3→6、4→1、5→2、6→10。
- 讀法（事實，不下結論）：warring 112/165 的擋下差 7 人以上，其中 pop≤3 就占 102 次；「差 1–2 人」只有 2 支隊。同一支隊會反覆被擋幾十次（同隊重試）。

# 2. 沒帶隊人門
| 世界 | 次數 | 不同隊 | 被擋時 pop | 有 leader | 疑記帳 bug（pop>1 或 anon>0） |
|---|---|---|---|---|---|
| warring | 257 | 20 | **全部 =1（257/257）** | 257/257 | **0** |
| peaceful | 74 | 5 | **全部 =1（74/74）** | 74/74 | **0** |

- R① P7 的靜態讀 **成立**：這道門只在 population=1（只有隊長一人、named_members 無別人、anon=0）的隊發生；沒有任何「人很多卻落在這裡」的記帳 bug。
- ★集中度：warring 最多一支 **72 次（28%）**，11 次以上 7 支；peaceful 最多一支 **37 次（50%）**。

# 3. 被擋之後 1 天（1440 tick）內，task/option 變化
〔「變成」＝第一個與擋下當刻不同的 (current_task, current_option)；stayed＝整天沒換；gone＝隊消失（兩世界都是 0）；window_end＝窗尾不滿一天〕

**warring，pop 門（165）**：stayed 68｜覓食/覓食 24｜建設/建設 14｜掠奪/掠奪 13｜覓食/迎戰 13｜偵查/偵查 7｜window_end 4。換成的 option 平均 task_util 0.667（n=84），換 option 的 tick 中位 600。
**warring，no_advisor（257）**：stayed 78｜乞食/乞食 58｜覓食/覓食 45｜覓食/迎戰 19｜idle/maintain_tools 15｜投靠/併入 6｜window_end 13。task_util 平均 1.000（n=146）——★常數 1.000 ＝ 這個欄位在這些 option 上不帶資訊，不要讀成「很想做」。換 option 的 tick 中位 360。
**peaceful，pop 門（27）**：stayed 8｜偵查/偵查 5｜治理/駐守 5｜idle/徵收 2｜偵查/maintain_material 2｜idle/貿易 1｜window_end 1。util 0.422（n=12）。
**peaceful，no_advisor（74）**：stayed 44｜**投靠/併入 15**｜覓食/迎戰 7｜迎戰/迎戰 3｜idle/maintain_food 2｜idle/survival 1。util 0.673（n=26）。

- 事實層：沒有任何一次「被擋之後隊消失」（gone=0）；「併入」只有 no_advisor 那邊出現（warring 6、peaceful 15）。
- ★誠實限：「stayed」是「整天 (task, option) 沒變」，**不等於**沒再嘗試——同隊反覆被擋次數見上；stayed 事件中很多是同一支隊的連續事件，不是獨立樣本。我沒有量「被擋的隊擋下當刻手上在做什麼的 util」（`task_util` 對換成的 option 可讀，對留原任務的不可讀）。

# 4. 順序副作用（同一次嘗試已升了一個人 named_members+1，之後仍被擋）
| 世界 | pop 門擋下 | 其中已升人 | 涉隊 | no_advisor | food_bridge | subteam_dispatch |
|---|---|---|---|---|---|---|
| warring | 165 | **9（5.5%）** | 7 | 257 中 0 | 0 次 | 0 次 |
| peaceful | 27 | **3（11%）** | 2 | 74 中 0 | 0 次 | 0 次 |

- 事實：升人副作用**確實發生**（被擋後匿名人已變具名人、沒派出子隊），但量很小：全部被擋事件 422 件中 9 件（warring）、101 件中 3 件（peaceful）。no_advisor 當然 0（pop=1 無人可升）；糧橋門／subteam_dispatch 兩個世界都沒走到。
- ★升人次數不足以等同「傷害」：我沒量升的人之後的處境；同隊重試時 anon→named 一旦升完，下次嘗試 `_pick_advisor` 就找得到人，所以每支隊最多損失 1 次（9 次涉 7 支隊）。

# 沒量到的
- 被擋的隊若不被擋，**本來會派出什麼**（反事實）沒量——這份只有「被擋後做了什麼」。
- 沒有逐隊的「擋下當刻手上任務」分類彙總（原始輸出 `留原任務細項` 有，未做歸納）。
- 只一個 seed（1337），沒有跨 seed。
- 「投靠/併入」是否因為被擋而選、還是本來就會：沒有對照組。

# 狀態
- 床與補丁在 worktree `.worktrees/gates-measure`（detached e4caa61f0，未 commit 進任何分支）；Godot 已空，已敲 demo-82。
