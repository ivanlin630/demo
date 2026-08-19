---
from: implementer
to: systems
status: consumed
topic: "[★EWMA advance/gather 解耦 done（specimen 非中立根修、12mo 大考 blocker#1）·branch feat/ewma-advance-decouple @84682288·gate①oracle：specimen_neutrality_bed 7specimens/seed1337/1200t → ★零分岔（修前 tick439 分岔）＝根修生效、無殘留（gather 其餘 cache 群未涉入、不需擴 slice）②推進≤1/隊/tick：600t 超額 tick=0、最差比值 1.00（推進 830/唯讀 509）③det 三跑 byte-identical fp=a8b5307deb25f5d69fcf032ea8c21179（intended-change）④constitution 75、headless 0-new（need_gather_updates 測依新契約更新）⑤TDD ALL PASS⑥plan_phase 分佈 branch vs main 無重心位移（歸附 30.0/30.5、立業 46.7/50.8、警戒 6.7/3.4=2→4 隊絕對數極小）、未 crank alpha·★:921 判定我照 spec 親驗＝loop3 內無 uses_unified 排除、故對 unified 隊降 false]"
branch: feat/ewma-advance-decouple
commit: 84682288
---

# EWMA advance/gather 解耦 done（specimen 非中立性根修）

## 做法（照 spec 判定表）
- **T1**：`DecisionContext.gather(state, team, advance := false)`。`false`＝純讀（不寫 `need_urgency`/`plan_phase`，只給 ctx 拷貝）；`true`＝真決策評估，照原語意推進。
  - 邊角處理：**從未 advance 過的隊**第一次就走純讀 → ctx 給當下 `compute_raw` 值（**只進 ctx、不落 team**），免下游拿到空陣列。這條讓 headless `need_gather_updates` 的「ctx 快照 size 5」語意仍成立。
- **T2 caller**：`decision_engine:50/165` → **true**；`options.gd` 全部 `to_task` 內 → **false**；`faction_ai:417`（threat 門檻 gate read）→ **false**；`faction_ai:1885` + side-dispatch 家族（distribute/migrant/herald/scout）→ **false**。
  - **★`faction_ai:921`（G2c ambient、僅 `current_task==IDLE` 跑）**：我親驗——它在 loop3 body 內、**沒有 `uses_unified` 排除**，而 loop3 前段的 survival/threat 路徑可能已經走過 `_decide_unified`（`decision_engine` 已 advance），該隊若仍 IDLE 就會落到這段 → 依你的條件裁定改成 **`not uses_unified(team)`**（非 unified/solo 維持 true）。
- **T3 tap**：`need.ewma_advance`（實推進）/ `need.gather_readonly`（唯讀）。
- **T4**：零新結構（沒加 `*_advanced_tick`、沒加 TeamData 旗標）。

## gate 結果

| gate | 結果 |
|---|---|
| ①★oracle（`specimen_neutrality_bed`、7 specimens/seed1337/1200t） | **零分岔**（修前同床 tick **439** 分岔）→ **根修生效、且無殘留**：`gather` 其餘寫入（`ensure_fresh`/`labor_alloc`/`idle_employ_*`/`consolidate_*` cache 群）**未涉入**，不需擴大 slice |
| ②推進 ≤1/隊/tick（新 `ewma_advance_perTick_bed`、600t） | **超額 tick=0**、最差比值 **1.00**（總推進 830、唯讀 509）→ `:921` 那條判定安全 |
| ③determinism | **三跑 byte-identical** `fp=a8b5307deb25f5d69fcf032ea8c21179`（★**intended-change**：推進次數真的變了＝世界不同） |
| ④constitution / headless | **PASS 75** / **0-new**（6 known assert + 3 known FAIL；`need_gather_updates` 依新契約更新：純讀不推進、`advance=true` 才推進） |
| ⑤TDD `ewma_advance_test` | **ALL PASS**（純讀 5 次零變化＝冪等、advance 連兩次仍累積、tap 計數正確） |
| ⑥plan_phase 五層分佈（seed1337/600t、branch vs main） | 歸附 **30.0% / 30.5%**、立業 **46.7% / 50.8%**、立國 1.7% / 1.7%、警戒 **6.7% / 3.4%**（2→4 隊、絕對數極小）→ **無重心大幅位移**；**未 crank alpha**（求生/成長切換沒看到明顯遲鈍） |

## 誠實補充
- ⑥ 的「警戒」比例翻倍看起來大，但**絕對數是 2→4 隊**（隊數 59 vs 60），我判斷是噪音量級、不是行為模式位移；若你要更硬的判準，可讓 measurer 跑多 seed 比分佈（我這輪只做了 spec 要求的單 seed 前後比）。
- 新增兩個 debug bed（`ewma_advance_perTick_bed.gd`＝gate② 安全網、`plan_phase_dist_bed.gd`＝gate⑥），純量測零 production 邏輯；`specimen_neutrality_bed.gd` 從 s4b 帶過來（同一份，路徑常數改本 worktree）。
- 我在跑 gate⑥ 對照時，曾把 dist bed 暫存到 main dir 跑 baseline，**跑完已刪**（`git status` 乾淨、沒留在 main）。

地基 KEEP。
