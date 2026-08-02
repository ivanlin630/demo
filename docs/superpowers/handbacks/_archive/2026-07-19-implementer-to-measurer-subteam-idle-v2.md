---
from: implementer
to: measurer
status: consumed
topic: "[measure·v2 供給環] subteam-idle-latch v2 → feat/subteam-idle@ab3044c3(extend 036fc42c)。★seed42 famine 0→10 regression 必回 0(v1 引入,v2 供給環治)+囤糧 200-2000 food-days 消+6隊解 idle-latch+無 re-thrash。TDD 9/9、headless 0new(baseline3)、gate 64、determinism seed1337 2mo byte-identical(md5 bac0e781)。gate 值(FORAGE_SATED_DAYS=10/PARENT_LOW_DAYS=3)TEST VALUE 請 tune。"
---
# Hand Back: subteam-idle-latch v2（供給環閉合）

承 REDIRECT `2026-07-19-systems-to-implementer-subteam-idle-v2-REDIRECT.md`（v2 spec R² CLEAN，extend 036fc42c）。**取代**前 v1 handback（1 行版 SEND-BACK：引入 terminal-sticky 破供給環）。

## 為何 v2（v1 SEND-BACK 訂正）
v1（1 行 `not in SURVIVAL_TASKS` 全排除 merge）治 thrash-死**但 forager 永久囤糧不交母團→破供給環→seed42 famine 0→10**（我原 flag terminal-sticky 為 non-blocker，blueprint+你坐實=**真 blocker**）。教訓：blanket 拆 merge = 拆掉粗糙的交糧機制。v2 = 閉合供給環（條件交糧）。

## 實作摘要（v2，extend 同 branch）
branch `feat/subteam-idle@ab3044c3`（036fc42c v1 保留當基 + v2 供給環；off local main；★禁 origin 落後）已 push（★過 installed pre-push 兩閘）。

**`faction_ai_system.gd:1727`**：survival-work 抵達 merge 由「全排除」改「條件」：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
    var parent = state.teams.get(sub.parent_team_id)
    if sub.current_task in SURVIVAL_TASKS \
            and not (_forager_sated(state, sub) or _parent_needs_food(state, parent)):
        return                       # 未食足 且 母團不缺 → 留 tile 覓食（不 thrash，food 累積）
    merge_queue.append(sub.team_id)  # 食足/母團缺糧/非-survival → 歸建（try_merge_back 交糧=供給環閉合）
    return
```
**+2 helper**（緊接 `_survival_food_days`）：`_forager_sated`=`food_days(sub)>=FORAGE_SATED_DAYS`、`_parent_needs_food`=`parent!=null and food_days(parent)<PARENT_LOW_DAYS`。
**+2 TEST VALUE 常數**（近 FORAGE_VIABLE_POP）：`FORAGE_SATED_DAYS=10.0`、`PARENT_LOW_DAYS=3.0`。

## 我的驗證
- **TDD** `subteam_idle_latch_test` **9/9 PASS**（★自證條件 gate：同 FORAGE task，未食足+母團不缺→留 tile[mq 空] / 食足→merge / 母團缺糧未食足→merge；sibling 未食足留;mission TRADE 恆 merge）。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**（helper 非 decision-func→threshold 偵測不掃；1727 if 多行 return 非 early_return 型）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `bac0e781`**（無 RNG）。

## ★請你量（spec §驗收，v2 核心 must-pass）
- **★★seed42 famine 0→10 regression 必回 0**（v1 引入的，v2 供給環必治）——最關鍵驗收。
- **terminal-sticky 消**：forager food_days 不再無限累積（食足即歸建交糧），囤糧 200-2000 food-days 現象消失。
- **供給環閉合**：forager 食足→歸建 `try_merge_back` **food 進 parent**（母團失覓食貢獻的餓死鏈消）。
- **seed1337 6 隊（62/71/73/79/84/90）不再 idle-latch**：ARRIVE↔RELEASE 1:1 振盪消失 + 覓食食物流進。
- **★無 re-thrash**：sated 後歸建移向 parent、food 足→不 re-pick forage→不回 thrash（驗 ARRIVE↔RELEASE 及新的 sated-歸建路都不振盪）。
- **42/4201 無 regression**；mission subteam lifecycle 不破。
- **★gate 值 tune**：`FORAGE_SATED_DAYS=10`/`PARENT_LOW_DAYS=3` 是 TEST VALUE——若你量到囤糧仍過多（SATED 太高晚交）或母團仍餓（PARENT_LOW 太低晚救），建議調值 flag 我或 systems。
- 你用 `godot --path .worktrees/subteam-idle` 跑（★禁原地 checkout）。

## 連動風險
- **subteam 行為變**（survival subteam 條件歸建交糧）=預期。判準=seed42 famine 回 0 + 6 隊解 + 無 re-thrash + mission lifecycle 不破。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完 → .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。
