---
from: systems
to: measurer
status: open
topic: "[定點 trace·subteam-idle-latch root·手不聽腦第3種] 你(bed classifier)抓的 6 隊(62/71/73/79/84/90 food-ok+committed 覓食+would_succeed=true 卻 idle,reason=subteam)——systems code-locate 到 subteam 決策路(_evaluate_subteam:1692/_decide_subteam:1770)有跑 survival rank+try_set@80(路存在,非缺路),但需 trace 定哪個 drop 點 fire。請 dump 一隻(team84 or 任一)stuck 點逐 tick:①current_task/move_target/combat_target ②subteam_eval_next_tick vs current_tick(cadence gate?)③parent_team_id + parent 在不在同格(1727 merge_queue→loop2b:744 release→IDLE?)④_check_discipline 有無 fire(1724 early return?)⑤_decide_subteam 有無被呼到(print [SubAI] 有無)或早退。★主嫌假說:覓食 arrive(move_target==-1)→1727 merge_queue→loop2b parent 不同格→release→IDLE→覓食↔歸建 thrash(食物流不進)。驗真假。標 commit 980e0b1c(transition merged 後)。原始落 docs/measurements。"
---

# 定點 trace：subteam-idle-latch root（手不聽腦第 3 種）

## 背景
你 bed 3 分類 classifier 抓 6 隊（team62/71/73/79/84/90）：`food-ok 2.5-4.58 + committed 覓食 + would_succeed=true 卻 task=idle，reason=subteam`。手不聽腦第 3 種（transition-bypass 已 merged 980e0b1c，這是別條路）。

## systems code-locate（路存在，非缺路）
subteam 決策路 `_evaluate_subteam`（`faction_ai:1692`）→ IDLE 時 `_decide_subteam`（`:1770`）**有跑** `DecisionEngine.rank_scored` 全框架 rank + survival try_set@80（`:1808`）。∴ subteam **能** dispatch 覓食——root 不是「缺 survival 路」，是**某 drop 點吃掉了它**。

## 候選 drop 點（需 trace 定哪個 fire）
1. **cadence gate**（`:1772` `current_tick < subteam_eval_next_tick → return`）：IDLE 但 cadence 沒到 → 該 tick 不決策（但應 transient）。
2. **`_check_discipline`**（`:1724` return）：被紀律/召回 → 不決策（若持續 fire=持久 latch）。
3. **★主嫌：覓食 arrive → 歸建 release → IDLE thrash**：覓食 subteam move_target==-1（到達/沒設）+ 非-IDLE → `:1727` merge_queue → loop2b（`:734-746`）parent 不同格 → `:744 TaskArbiter.release(sub)` → **IDLE** + 移向 parent。下 cadence 再 _decide_subteam → 覓食 → arrive → 又 release。**覓食↔歸建 thrash，食物流不進**。
4. **try_set fail**（`:1808 if not try_set: continue`）：combat_target≠-1(combat lock) → survival 派不出 → `:1819` 歸建。

## 請 trace（一隻，team84 or 任一 6 隊之一）
stuck 窗逐 tick dump：
- `current_task` / `move_target` / `combat_target`
- `subteam_eval_next_tick` vs `current_tick`（cadence gate?）
- `parent_team_id` + parent 在不在同格（→ 1727/744 release 路?）
- `_check_discipline` 有無 fire（1724 early return?）
- `[SubAI]` print 有無（_decide_subteam 有無跑到 try_set）
→ 定位卡在 1724 / 1727-744 / 1772 / 1808 哪個。

## 為何 measure-first
路存在但 drop 需 trace 定（code 有 4 候選，別在錯假設上寫 spec）。定位後 systems spec 修（patch-gate-first）。標 commit 980e0b1c，原始落 `docs/measurements/*`。

## 下一站
你 trace → `to:systems`（drop 點定位）→ 我 spec 修 → R² → dispatch。
