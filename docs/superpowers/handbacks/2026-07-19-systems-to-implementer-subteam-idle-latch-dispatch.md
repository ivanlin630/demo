---
from: systems
to: implementer
status: open
topic: "[dispatch·subteam-idle-latch·HIGH·R² CLEAN·手不聽腦第3種·★off LOCAL main c2b5847b] spec=2026-07-19-subteam-idle-latch.md。root(measurer 坐實):faction_ai:1727 blanket『抵達非-IDLE→歸建 merge』把覓食 subteam 抵達 forage 目的地誤當歸建抵家→thrash(ARRIVE 337≈RELEASE 346),覓食不執行食物不進坐死。修 1 行:1727 加 `and sub.current_task not in SURVIVAL_TASKS`(faction_ai:79=RETURN_HOME/BEG/JOIN/FORAGE/CAMP,execute-at-destination 非歸建)→survival subteam 抵達執行覓食非召回。R² CLEAN(執行路 collect_resources subteam-agnostic 真執行,歸建 _decide_subteam 顯式路不受影響)。★★branch off LOCAL main c2b5847b,禁 origin(落後~40)。★pre-push hook 已裝 push 起兩閘。TDD:①覓食 subteam 抵達不 merge 留 tile 覓食食物累積無 thrash ②mission task(TRADE)抵達仍 merge ③歸建路不變 + sibling(CAMP/BEG/JOIN/RETURN_HOME)。gate/headless 0new/determinism/measure 6隊不 idle-latch+食物流。★terminal-sticky must-verify(measurer 量,非 blocker)。task 完成=systems+reviewer。"
---

# dispatch：subteam-idle-latch（手不聽腦第 3 種，R² CLEAN）

spec：`docs/superpowers/specs/2026-07-19-subteam-idle-latch.md`。root measurer trace 坐實（@9a915fe7）。

## ★★ branch base
- **off LOCAL main `c2b5847b`**（`git worktree add .worktrees/subteam-idle-latch -b feat/subteam-idle-latch c2b5847b` 或 `main`）。
- **禁 origin/main**（落後 local ~40 commit）。**pre-push hook 已裝**：push 起 constitution+verification 兩閘（FAIL 擋 push）。

## 修（1 行 de-patch）
`faction_ai_system.gd:1727`：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE \
        and sub.current_task not in SURVIVAL_TASKS:   # ← 加這條
    merge_queue.append(sub.team_id)
    return
```
`SURVIVAL_TASKS`（`faction_ai:79` = RETURN_HOME/BEG/JOIN/FORAGE/CAMP）= execute-at-destination，抵達目的地執行（留 tile 覓食）非歸建召回。de-patch：讓引擎覓食決策執行，1727 別 pre-empt。

## 驗收（spec §驗收）
- **TDD**：①覓食 subteam 抵達 forage tile（move_target=-1）→ **不進 merge_queue** → 留 tile → 覓食執行、食物累積、無 thrash ②mission task（TRADE 等非 SURVIVAL_TASKS）抵達 → 仍 merge_queue（不破 lifecycle）③歸建路（_decide_subteam:1787）不變 + sibling（CAMP/BEG/JOIN/RETURN_HOME）抵達行為對。
- **gate** PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure（→measurer）**：seed1337 6 隊（62/71/73/79/84/90）不再 idle-latch、覓食食物流進（ARRIVE↔RELEASE 振盪消失）；42/4201 無 regression。
- **★terminal-sticky must-verify（reviewer 升級，measurer 量，非 merge blocker）**：修後 fed subteam 會不會 re-rank/歸建 vs 卡 forage 永不回母團。若 terminal-sticky 真=follow-up 非本 fix blocker。

## ★WHAT flag（已告 blueprint）
修後 subteam 獨立覓食 = 引擎已決策（執行非新增）。若不該獨立覓食 = rank follow-up。

## 完成判定
= systems + reviewer/QA，非自判。做完寫 `to:measurer`（measure，含 terminal-sticky）or `to:systems`（pre-merge R²）。
