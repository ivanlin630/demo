---
from: implementer
to: measurer
status: consumed
topic: "[measure] subteam-idle-latch(手不聽腦第3種)→ feat/subteam-idle@036fc42c。seed1337 6隊(62/71/73/79/84/90)不再 idle-latch+覓食食物流進(ARRIVE↔RELEASE 振盪消失)+42/4201 無 regression+mission lifecycle 不破。★terminal-sticky must-verify(fed 後 re-rank/歸建 or 卡 forage 永不回母團,非 blocker)。TDD 7/7、headless 0new(baseline3)、gate 64、determinism seed1337 2mo byte-identical(md5 ebf82786)。"
---
# Hand Back: subteam-idle-latch（手不聽腦第 3 種）

承 dispatch `2026-07-19-systems-to-implementer-subteam-idle-latch-dispatch.md`（spec `2026-07-19-subteam-idle-latch.md`，R² CLEAN）。

## 實作摘要
branch `feat/subteam-idle@036fc42c`（off local main c5ab36d9，含全批；★禁 origin 落後~40）已 push。**★push 過 installed pre-push 兩閘**（constitution PASS + verification fast-exit）=hook install 生產驗證成功。

**修 1 行**（`faction_ai_system.gd:1727` `_evaluate_subteam` 歸建 merge 條件）：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE \
        and sub.current_task not in SURVIVAL_TASKS:   # ← 加此行
    merge_queue.append(sub.team_id)
```
- `SURVIVAL_TASKS`（faction_ai:79）= RETURN_HOME/BEG/JOIN/FORAGE/CAMP = execute-at-destination（抵達留 tile 執行，非歸建召回）。
- de-patch：blanket lifecycle gate 誤把覓食 subteam 抵達 forage 目的地當歸建抵家 → thrash（ARRIVE 337≈RELEASE 346 1:1）覓食不執行坐死。排除 survival-work task → 引擎覓食決策執行（1727 別 pre-empt）。

## 我的驗證
- **TDD** `subteam_idle_latch_test` **7/7 PASS**（RED→GREEN；★未修 → 5 FAIL：FORAGE + 4 sibling[CAMP/BEG/JOIN/RETURN_HOME]全誤 merge，證 blanket gate 是病）。①FORAGE 抵達不 merge 留 tile ②sibling 皆不 merge ③mission(TRADE)抵達仍 merge（lifecycle 不破）。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**（`not in SURVIVAL_TASKS` 非 threshold/route/early_return 型，不加閘）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `ebf82786`**（無 RNG）。

## ★請你量（spec §measure）
- **seed1337 6 隊（62/71/73/79/84/90）不再 idle-latch**：committed=覓食 subteam 的 ARRIVE_MERGEQ↔LOOP2B_RELEASE 1:1 振盪消失、覓食食物流進（food_days 回升，非 2.5-4.58 坐死）。
- **42/4201 無 regression**（starve/pop/teams）。
- **subteam 正常 lifecycle 不破**：mission（TRADE/GOVERN 等完工）subteam 抵達仍歸建 merge。
- **★★terminal-sticky must-verify（reviewer R² 升級，非 merge blocker）**：修後 survival subteam 抵達 forage tile 執行覓食（不 merge），但 FORAGE/CAMP/RETURN_HOME **無 release 路** → 疑 fed 後 current_task 仍非-IDLE → `_decide_subteam` 不重跑 → **永久 detached forager 卡 forage 永不歸建/re-rank**。**非餓死 latch（已 fed=嚴格優於原 thrash-死）**，屬 WHAT-flag 同族。**請量：修後 6 隊 fed 之後會不會 re-rank/歸建，還是 terminal-sticky 卡 forage 永不回母團。** 若真 terminal-sticky → follow-up（foraging subteam 食足後 re-rank / 歸建 util 升，blueprint WHAT 判），非本 fix blocker。
- 你用 `godot --path .worktrees/subteam-idle` 跑（★禁原地 checkout）。

## ★WHAT flag（轉 blueprint，informational，非 blocker）
修後 subteam 會**獨立覓食（離 parent 執行 survival）**——這是**引擎 rank_scored 已決策**的（覓食>歸建 於這些低糧 subteam），手不聽腦 fix = 執行它。若 blueprint 判 detached subteam 該優先歸建 pool 母團糧 → 那是 **rank 決策層調整**（歸建 option util 對低糧 subteam 升權）另軌 follow-up，非本 1727 lifecycle override。本 fix（執行引擎決策）HOW-correct 無論如何。

## 連動風險
- **subteam 行為變**（survival subteam 抵達不再被召回）=預期（正是修的）。對 baseline diff 會有 subteam merge/forage 相關差異，判準=6 隊不坐死+食物流進+mission lifecycle 不破。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完 → .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。
