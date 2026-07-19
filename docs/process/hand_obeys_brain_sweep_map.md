# 手不聽腦結構 sweep 地圖（2026-07-20，systems 結構稽核）

> 手不聽腦 = 引擎決策了求生 task（`survival_dispatch_would_succeed=true`）但沒被 dispatch/執行 → team 卡 idle/frozen。blueprint 裁「結構 sweep 提前，停 gate-tuning」後的系統性列舉。行號指主線 `scripts/simulation/`。連 [[手不聽腦 mini-arc]]。

## survival dispatch 路由骨架（誰替誰派 survival）
`evaluate_all`（`faction_ai_system.gd:671`）三 loop：
| team 類別 | 判定 | survival dispatch 唯一入口 |
|---|---|---|
| **獨立隊** `faction_id==-1` 非子隊 | loop2 :717 | `_evaluate_solo:727`→unified/rank_scored（含 survival）。自驅、賴自身 leader |
| **子隊** `parent_team_id!=-1` | loop2 :715 `_evaluate_subteam` | loop3 `_evaluate_survival:3246` legacy `_trigger_survival`（:3267 只放子隊進） |
| **faction 成員** 非子隊 `faction_id!=-1` | loop2 :735 **只跑 `_evaluate_independent_strategy`，不跑 `_evaluate_solo`** | **僅** loop1 `_assign_tasks:1417→_assign_member_tasks:1455→_decide_unified:1475` |

**關鍵不變量**：loop3 `_evaluate_survival` 對 faction 成員 + 獨立隊都 early-return（:3267）→ **faction 成員 survival 只有 loop1 一條命脈** = team21 型結構根。

## Drop 點表（D1-D15）
**team21 核心（faction 成員 + 等待新領主 + leaderless）：**
- **D1** `:1418-1420`：`_assign_tasks` 開頭 `if leader_team==null or combat_target!=-1: return` → 領主 null（交接）/戰鬥→**全 faction 成員本 tick 零 survival**（成員 loop3 又 early-return）。
- **D2** `:1628`：`_decide_unified` 尾「全不可派→no-op，**無 terminal release**」→ 成員卡 stale `等待新領主@AMBIENT`（finder-miss/stall-exclude 落空無兜底；對比 `_trigger_survival:3453` 有 release）。
- **D3** `:3873-3886`：defection Path A `transition("等待新領主",AMBIENT)`，faction_id 不變（仍走 D1 命脈）；「等待新領主」∉ SURVIVAL_TASKS/PREEMPTIBLE/STATION/STUCK 任一集 → D4/D5 全漏接。
- **D4** `:400-401`：`_evaluate_threat` busy-gate `if task!=IDLE and not preemptible: return`，「等待新領主」∉PREEMPTIBLE(:118)→ 不 preempt 成 survival。
- **D5** `:822-825`+`:92`：station timeout 只掃 STATION_TASKS、`_is_stuck` 只認 ATTACK/LOOT →「等待新領主」不被 timeout/stuck 回收。

**release 後被非-survival 吃（影響最廣）：**
- **D6** `:383-389`（crisis-release）+**`:850-859`（loop3 ambient fallback）**：深餓 6 天→`_famine_crisis`→release→IDLE。**同 tick 稍後** :850 `rank_ambient` 派第一個 AMBIENT option（`AMBIENT_OPTION_SET=["訓練","貿易","生產","建設","囤貨","駐守"]` **不含 survival**）→ 餓隊剛釋放就被塞「貿易」。真 survival re-dispatch（loop1）要等下 tick + `_should_reeval` cadence 節流。**免疫窗（task_arbiter:45）只鎖同字串「等待新領主」，擋不住不同字串「貿易」**。影響**所有 crisis-released 隊**，尤以 D1/D2 已無 survival 的成員最致命。
- **D7** `:404-408`：`_evaluate_threat` IDLE 分支只處理 threat，無 survival；survival 補位仍全押 loop1（=D1）。

**cadence gate：**
- **D8** `:1772`：`_decide_subteam` cadence（子隊 IDLE 空窗，loop3 有兜較不致命）。
- **D9** `:1878-1884`：`_should_reeval` crisis latched 後每 tick 擋 re-rank→survival 延到 /4 cadence；撞 D1 → 疊長 frozen。

**子隊召回（subteam-idle-latch）：**
- **D10** `:1727-1729`+loop2b`:751-763`：覓食子隊抵 forage 格→merge_queue→release/召回 churn（v1/v2/v3 attempted）。
- **D11** `:1724`+`_check_discipline:1745`：隨機紀律失效 detach+release→survival 被吃。

**transition 邊界 + 免疫殘角：**
- **D12** `task_arbiter:108-119`：transition guard **只擋 stomp active survival，不 create survival**→若 survival 從沒 dispatch（D1/D2）arbiter 無從擋起（team21 空洞，註 :110 自承）。
- **D13** `:45-47`+`:115-117`：免疫窗**只鎖同字串 task**→ambient（D6）用不同字串「貿易」繞過。

**覆蓋邊界（非 bug 標記）：**
- **D14** `:3247`：玩家自領隊不進 NPC survival（設計）。
- **D15** `:1780`+`:3384`：隊 leader_id==-1 那個 pass survival gated-off，次 tick succession 修（撞深餓臨界會漏一次）。

## team21 結論
faction 成員 survival 唯一命脈（`_assign_tasks→_decide_unified`）被三重掐：①入口整包跳過（D1）②落空不兜底（D2）③釋放後被 ambient 搶位（D6）。loop3 看似救援的路（`_evaluate_survival:3267` early-return/`_evaluate_threat:400` busy-gate/timeout）對「等待新領主」AMBIENT 停車態全漏接（D4/D5）。∴「等待新領主」成員落在覆蓋最薄格：非獨立（無 solo）、loop3 明文排除、只靠一條被 D1/D2/D6 三重截胡的命脈。
