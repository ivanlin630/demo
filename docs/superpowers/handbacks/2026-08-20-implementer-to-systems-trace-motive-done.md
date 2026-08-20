---
from: implementer
to: systems
status: open
topic: "[trace 動機欄 done（考前小觀測 slice）·branch feat/trace-motive-field @bc50c05b·T1 intent→strategic_intent（why/mode 一起、flush 印出兩層並列）·T2 新增「本tick動機」＝主需求層(need_urgency argmax 的 narrative_label、純讀現成)+五層層值+winner_util（直接從既有 candidates 取、★沒重算 term loop 沒重算 ctx）·T3 仍在 _begin_observe 內、零 state 寫入零 RNG·gate 全綠:specimen bed 新欄有值(decision rows 12/18 實例已附)+★specimen_neutrality_bed 7specimens/1200t 零分岔+det fp=3d154f2678a474a942d7a5d7446e8acc 與現 main byte-identical(純觀測零行為變)+constitution 75+headless 0-new]"
branch: feat/trace-motive-field
commit: bc50c05b
---

# trace 動機欄 done

## 你的 code-read 我複驗成立
該欄來自 `capture_intent`（`specimen_tracer:78`）tap，掛在**戰略層**（`_emit_goal` / `_evaluate_independent_strategy`、慢 cadence）→ 存進 `_scratch(team_id)["intent"]`，`capture_decision` 只是把它照抄進 entry。**不是 stale bug，是兩層混用同一欄名**。

## 做了什麼
- **T1 改名**：輸出欄 `intent` → **`strategic_intent`**（`why`/`mode` 一起帶）。`flush` 印出也改成兩層並列：
  `[Specimen T0] tick=90 strategic_intent={"intent":"通商",...} | motive=立業(util=0.20) | winner=紮營 task=…`
- **T2 「本tick動機」**（答「這個 winner 為什麼贏」）：
  - `主需求層` ＝ `NeedHierarchy.narrative_label(team.need_urgency)`（**純讀現成值**）
  - `層值` ＝ 五層 `need_urgency` 快照（QA 可看到是哪層在頂）
  - `winner_util` ＝ winner 在**既有** `candidates` 陣列裡的 util（**直接取、零重算**）
  - **★沒有取 winner 的最大貢獻 term**：那需要重跑 rank 的 term loop＝觀測改被觀測物（且 EWMA 解耦剛修完同族病）→ 照你「取不出就不要為此重算」的指示**不做**。
- **T3**：capture 路徑仍在 `_begin_observe` 內；新欄全部純讀現成值、**零 state 寫入、零 RNG**。

## gate（全綠）
| gate | 結果 |
|---|---|
| specimen bed 新欄有值 | decision rows 12/18；實例：`strategic_intent={"intent":"通商","mode":"trade","why":"經濟外動，treasury 增"}`、`本tick動機={"主需求層":"立業","層值":[0,0,0,0.25,0],"winner_util":0.2}` |
| ★`specimen_neutrality_bed`（7 specimens/seed1337/1200t） | **零分岔**（剛修好的東西沒被我弄壞） |
| determinism | `fp=3d154f2678a474a942d7a5d7446e8acc` ＝**與現 main（`047b13e3`）byte-identical**＝純觀測零行為變 |
| constitution / headless | **PASS 75** / **0-new**（6 known assert + 3 known FAIL） |

## 一個給 QA 的讀法提醒（附在此、不改 code）
`strategic_intent` 為 `null` 的 entry 是**心跳/尚未有戰略姿態**的隊（`capture_intent` 還沒 fire），不是資料掉了；此時看 `本tick動機` 就好。反過來若兩者長期矛盾（戰略姿態 vs 主需求層），那正是「慢層姿態沒跟上真實處境」的可報告現象，而不再是欄位誤導。

地基 KEEP。
