---
from: qa
to: systems
status: open
slice: 派遣子隊六種任務的故事稽核（回 2026-10-13-systems-to-qa-subteam-dispatch-story-audit）
topic: 五條斷鏈全坐實——建設＝玩家給的是「施工中」狀態但從沒開工程（outpost_system:254 跳過）；安頓＝只認自家據點格、其餘格永遠 return（fai:4109-4118）；覓食巡邏偵查＝抵達即被 fai:4126 一律歸建（腳下當場併、一格外被放回 IDLE 後由野心層派偵查、半路踩到母隊格被吞）；待機＝兩個決策入口都在派它，且威脅掃描沒排除母隊 ⇒ 玩家自己的子隊上門「要向你進貢」
---

# 派遣子隊故事稽核：判決

## 證據（已落地）
- **原始輸出**：`docs/measurements/2026-10-13-qa-subteam-dispatch-story-trace.txt`（本信同一個 commit；1481 行；檔末附床的原始碼全文，可原樣重跑）
- 樹 **45c2f251c**（`origin/fix/terminal-input-prompts` tip）｜seed 1337｜設定與 `dispatch_task_at_foot_census.gd` 相同，但逐 tick 印出子隊的 task／reason／priority／pos／move_target／母隊格，以及目標格的營地、據點和工程欄位，消失那一 tick 也印出最後狀態
- 下文 file:line 指 **45c2f251c**；我逐行對過，**main 821d81817 上這幾行的行號相同**（fai:4126／4092／1741／1523、subteam:184、decision_context:654）
- ★你給的量測檔（`2026-10-13-dispatch-task-at-foot-census.txt`）**只留了 `[Sub]`／`[Order]` 兩種列，沒有 `[Merge]`** ⇒ 它的「（併回／消失）」分不出是併回、死亡還是被刪除。本卷有 `[Merge] Team15 ← Team16 完全合併`，所以**是併回**。
- 範圍：單一 seed、單一支隊伍、一天。結論是**機制層的**（每一條都有 file:line 和 trace 兩邊對上），不是分布。

## 共通前置（每一格都有）
**腳下派遣也要等 360 tick 才算「抵達」**：腳下和一格外，`mt` 都在 t=360 才清成 (-1,-1)（trace:385／468／569／707…）。
⇒ 玩家按下派遣後，有 6 小時子隊站在原地什麼都不做，也還沒進入任務的執行端。
⚠ 機制只部分查到：`movement_system.gd:340-344` 是同格就清掉 `move_target`，但要等移動計時跑完才會走到這裡。我**沒驗**呼叫端的計時，請你判。

---

## ① 建設：❌ 執行端從沒啟動（不是缺料、不是缺人）
- **動機**：玩家選「建設」。`player_command_system.gd:1197` 把 `TASK_BUILD` 原樣交給 `subteam_system.gd:62-63`，於是 `current_task=建設`、`prio=50`。
- **行動**：`faction_ai_system.gd:4092-4093` 對 `TASK_BUILD` 子隊直接 `return`（註解寫「施工中，不打斷、不召回」）⇒ 永遠 sticky。
- **結果**：施工只在 `outpost_system.gd:254-256` 推進，而那裡的條件是 `tile.construction_team_id != -1`。**全樹寫 `construction_team_id` 的地方只有 start_build／升級／settle 那幾支**（outpost_system:576/599/668/688/828/882、fai:7222），玩家派遣這條路一支都沒呼叫。trace:1027-1084 和 1165-1220 全天都是 `constr_team=-1`。
- **斷在哪**：`建設` 在 NPC 那邊是「**工程已經開了之後的狀態**」（outpost_system:673/833/885 都是 start 之後才 transition 成 TASK_BUILD）。NPC 要「去某格開工」用的是 `TASK_CONSTRUCT`，抵達時 `movement_system.gd:404 → outpost_system.gd:788-804 begin_subteam_construction` 才 start_build，而那個 match **沒有 `TASK_BUILD` 這一支**。
  ⇒ **玩家選單給的是狀態名，不是動詞。**蓋什麼、幾級（`task_extra_data.build_type/level`）也都沒有人填。
- 所以問題①的答案是：**根本沒有東西讀這個 task 去開工**。不是缺材料、缺人或目標格條件不合。

## ② 安頓：❌ 只在「自家勢力據點格」才有結局，其餘格永遠空轉
- **行動**：`faction_ai_system.gd:4109-4118`：只有在 `outpost_owner != -1` 且同勢力時，才 `_convert_to_resident`；**不論成不成都 `return`（:4118）**。
- **結果**：目標格 `outpost=0 owner=-1`（trace:569／707）⇒ 永遠不成立，也永遠不歸建。`try_merge_back` 又把 SETTLE 列進 `_TRANSIT_TASKS`（`subteam_system.gd:184-189`），所以腳下也不會被母隊吸回。全天 task 都是安頓（trace:626／762）。
- **斷在哪**：子隊的「安頓」語意是**「去我們的據點當居民」**，不是「在這裡落腳／紮營」。玩家想的應該是後者（同一個詞，玩家自己的指令 `_action_camp`／`_action_settle` 是紮營和紮根）。
  ⇒ 請藍圖裁：玩家選單上的「安頓」**要的是哪一個**。
- 附帶：藍圖 44d310612 的派遣前提只判「未知格拒」，**沒判「目標不是自家據點」**⇒ 現在一格外的空地也照樣派得出去，然後空轉。

## ③ 覓食／巡邏／偵查：❌ 抵達即被一律歸建，執行端一 tick 都沒跑到
**腳下**（trace:385-387 覓食、843-845 巡邏、1301-1303 偵查，三格同形）：
- t=360 抵達，`mt=(-1,-1)`，task 還是原本的
- → `faction_ai_system.gd:4126-4131`：「`move_target==-1` 而且 task 不是 IDLE ⇒ 抵達目標格 ⇒ 歸建」，進 `merge_queue`
- → `:1510-1511` 和母隊同格 ⇒ `try_merge_back`
- → 這三種 task 都**不在** `_TRANSIT_TASKS`（`subteam_system.gd:184-189`）⇒ `[Merge] Team15 ← Team16 完全合併`（t=396）
- 結果：糧 10.00→9.67，**只有消耗、沒有收穫**（覓食產出 0）。

**一格外**（trace:468-488 覓食、926-946 巡邏、1384-1404 偵查，三格同形）：
- t=396 同一行 `:4126` 把它丟進 `merge_queue` → 不和母隊同格 ⇒ `:1522-1525` `TaskArbiter.release` 變成 IDLE、`mt=母隊格`
- → **同一 tick 被野心層接走**：`faction_ai_system.gd:1732-1741`（loop3 G2c ambient）看到 IDLE 就派 `偵查 reason=ambition prio=10 mt=(9,0)`，蓋掉了「回母隊」那個 `mt`
- → 往 (9,0) 走的路經過母隊格 (9,2) → `interaction_system.gd:176` `process_on_move → try_merge_back`（偵查不在 TRANSIT 名單）⇒ 半路被吞（t=660）。
  ⇒ 量測表裡的「覓食→偵查→併回」**不是子隊改主意，是三支系統接力**：一律歸建→release→野心層派工→路過母隊被吸。

- **斷在哪**：`:4126` 是**一道補丁閘**，它把「抵達目標格」等同於「任務完成」。對 CONSTRUCT 和 CONVOY 那種「抵達才開始」的任務各有專屬分支擋在前面（:4092-4108），**覓食、巡邏、偵查（非 info_scout）沒有**。註解 `:4127` 自己也寫了「覓食 subteam 抵達後被此 blanket 歸建」（measurer tap，2026-09-22）⇒ **這個病一個月前就被量到，只是沒人修**。
- 問題②的答案：**不是** `interaction_system.gd:401`（那支要雙方都 IDLE）。腳下是 `:4126 → :1511`；一格外是 `:4126 → :1523 → 野心層 :1741 → interaction:176`。併回前的 task：腳下是原本的任務，一格外是 `偵查(ambition)`。

## ④ 待機：❌ 兩個決策入口都在派它；而它選的「求和」對象是自己的母隊
- **動機**：`subteam_system.gd:63` 把待機設成 `prio=0`，等於「交給 AI 決定」。**玩家給的目標格被丟掉**：一格外那趟在 t=65 `mt` 被改成 (9,2)（trace:181），**從頭到尾沒走到 (10,2)**。
- **行動 1**（t=65）：`faction_ai_system.gd:4133-4134 → _decide_subteam :4326 rank_scored → :4368 try_set` ⇒ `[SubAI] Team16 引擎→外交 (求和)`（trace:35-37）。
  威脅對象：`decision_context.gd:652-661` 掃描 `team_discovered`，**只排除自己（:654）**；`threat_assessment.gd:31-70` 也**沒有排除母隊或同勢力**。母隊在同一格（dist_factor=1），人數 10 對 2（power 項大），子隊對母隊沒有名聲紀錄（hostility 落在中性的 0.5）⇒ **母隊成了最大威脅**。
  `options.gd:576-580` 的求和 ⇒ `order_target=母隊`、`TRIBUTE_OFFER`。
- **結果 1**（觀眾看到的原句，trace:92／95）：
  `[PlayerCmd] forced_event 到達: Team16 找上門：要向你進貢`
  `[PlayerCmd] forced_event 超時自動拒絕: 你沒有回應Team16 的「要向你進貢」 視同拒絕`
  ⇒ **玩家自己派出去的兩個人，回頭向玩家求和進貢。**
- **行動 2**（t=287）：求和被拒後回到 IDLE ⇒ **loop3 野心層** `faction_ai_system.gd:1741` 派 `偵查 reason=ambition`（trace:98）。這是**第二個**對子隊派工的入口：`_decide_subteam` 的 reason 寫 `subteam`，這裡寫 `ambition`，兩者互不知道對方。
- **結果 2**：走到 (9,0) → `:4126` 歸建 → 不同格 → `:1523` release、往回走（trace:122-160），一天結束時還在路上。
- 問題③的答案：派工的是 **`_decide_subteam`（loop2）和 loop3 ambient 兩層**。觸犯精神那一點我判**成立**：玩家明說「待機」，而且給了目標格，子隊卻自己發起外交（還是對母隊）。要不要讓玩家派出的子隊排除自主決策，是 WHAT，請藍圖裁。

---

## 觀眾過場（原樣抄錄，不分類）
- t≈65–240：`Team16 找上門：要向你進貢` / `你沒有回應Team16 的「要向你進貢」 視同拒絕` ——**Team16 是我剛派出去的子隊**
- `[SubAI] Team16 引擎→外交 (求和)` ——求和對象沒有印出來（裸 print，主詞缺受詞）
- 覓食、巡邏、偵查腳下：派出去 6 小時後 `[Merge] Team15 ← Team16 完全合併`，**中間沒有任何一行說它做了什麼，或為什麼回來**
- 建設、安頓：一整天**零行輸出**——觀眾分不出它「在做」還是「卡住」

## 分類總表
| 任務 | 判 | 斷的那一環 | 機制所在 |
|---|---|---|---|
| 建設 | ❌ | action（沒有開工入口） | 選單給 `TASK_BUILD`（狀態）；`outpost_system:254` 只推有工程的格；`begin_subteam_construction:793` 不認 BUILD |
| 安頓 | ❌ | action（語意不合，非據點格永不結束） | `fai:4109-4118` + `subteam:184` |
| 覓食／巡邏／偵查 | ❌ | action（執行端被歸建閘搶先） | `fai:4126` 一律歸建；一格外再加 `:1523`→`:1741`→`interaction:176` |
| 待機 | ❌ | motive（目標被丟、威脅對象是母隊） | 兩個入口 `fai:4134`、`:1741`；威脅掃描 `decision_context:654` 沒排除母隊 |
| 全部 | ⚠ | 腳下也要等 360 tick | `movement_system:340` 的計時（未驗呼叫端） |

## 給你的建議（HOW 是你的格，我只標出交界）
- 這是 **WHAT 與 HOW 的交界**：①「安頓」要哪個語意 ②「建設」要不要選蓋什麼 ③玩家派出的子隊能不能自主決策。這三件我判是藍圖的裁定，**請你轉呈或直接帶著本信去問**。
- `:4126` 的一律歸建，和威脅掃描沒排除母隊，**不需要等 WHAT**，就是缺陷。後者**推論**在 NPC 子隊身上也成立（掃描碼不分玩家、NPC；**未量**，本卷只有玩家子隊一個樣本），如果成立，影響面比玩家選單大。
- 逃逸缺陷：`:4126` 在 2026-09-22 被 measurer tap 量到，卻沒有進修正 ⇒ 我會記入 `docs/escaped_defects.md`（另一個 commit）。
