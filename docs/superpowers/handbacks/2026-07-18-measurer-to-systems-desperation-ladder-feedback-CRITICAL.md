---
from: measurer
to: systems
status: consumed
topic: "[★★致命發現·stall_exclude從未觸發·patch-gate錯位置] desperation-ladder-feedback(ed2fdff6)單元層CONFIRMED(char bed 13/13邏輯正確)，但organic 3seed×8mo顯示survival.stall_exclude counter全程=0——新機制一次都沒fire過！code追蹤：_update_survival_stall(faction_ai_system.gd:3361)被呼叫處在一個受`uses_unified(team) or parent_team_id==-1→return`早退閘擋住的legacy函式裡,只有『非unified-tag+是subteam』的窄子集隊伍才執行得到。★這代表大多數team族群(merchant/produce走_decide_unified、獨立非子隊solo隊走_evaluate_solo)完全碰不到這次的stall-detection——同本session反覆出現的patch-gate錯位置教訓。附帶seed42從S1-only基線0隊starve死亡惡化到8隊,因果鏈待查(非stall機制直接造成因其從未觸發,疑DecisionContext.gather()額外呼叫間接影響RNG消耗順序)"
---

# ★★致命發現：desperation-ladder-feedback 的 stall 偵測從未觸發

依 `2026-07-18-implementer-to-measurer-desperation-ladder-done.md`。**單元層 CONFIRMED，但 organic 測試揭露機制本身是死碼。**

## 單元層：CONFIRMED（邏輯正確）

- **char bed**（`survival_stall_ladder_test.gd`）：13/13 ALL PASS。
- **constitution_gate**：`PASS sites=64 removed=0`。
- **headless_test**：殘 3 assertion 同名同行號，無新增。

## ★★致命發現：`survival.stall_exclude` 全程 = 0

```
seed 1337: survival.stall_exclude = 0
seed 42  : survival.stall_exclude = 0
seed 4201: survival.stall_exclude = 0
```

**三個 8 個月的 organic 世界，新機制一次都沒 fire 過。**

## code 追蹤：wiring 位置錯了

`_update_survival_stall(state, team, _sctx)`（`faction_ai_system.gd:3361`）被呼叫的位置，在包裹它的整個函式（含 `rank_survival` 獨立迴圈）**受早退閘擋**：

```gdscript
# faction_ai_system.gd:~3225
if uses_unified(team) or team.parent_team_id == -1: return
```

**這函式本體只有「非 unified-tag 且是 subteam（`parent_team_id!=-1`）」的隊才會執行到。** 這代表：

- **unified-tag 隊**（merchant/produce）→ 走 `_decide_unified` → **碰不到 stall-detection**
- **獨立非子隊**（`parent_team_id==-1`，大多數玩家/AI 獨立隊）→ 走 `_evaluate_solo` → **碰不到 stall-detection**
- 只有**非 unified-tag 的子隊**這個窄子集才會執行到這段新加的邏輯

**這是本 session 反覆出現的同款教訓——patch-gate/錯位置 bug**：修法邏輯本身經 char bed 證實正確，但 wiring 位置放在一個大多數隊伍根本走不到的 legacy 分支裡，等於死碼。這也解釋了為何我先前坐實的 seed1337 那 7 隊嚴重飢荒案例（`task_reason` 混合 unified/solo/subteam，其中 subteam 只 1 隊）絕大多數不會被這個修法碰到。

## 附帶：seed42 惡化（因果鏈待查）

```
              extinct.starve   attrition_pct
S1-only基線:        0              低
本輪(ed2fdff6):     8             24.31%
```

**seed42 從 S1-only 基線的 0 隊 starve 死亡惡化到 8 隊**——因 `stall_exclude=0`（新邏輯從未執行），理論上不該有直接因果，但不排除 `_update_survival_stall` 呼叫本身的 `DecisionContext.gather()` 額外開銷、或程式碼改動間接影響了 RNG 消耗順序，導致世界分岔（RNG-cascade 效應，同本 session 已見過多次的世界分岔模式）。**這條需要你/implementer 進一步查因果鏈**，我只能確認「不是 stall 機制本身造成」（因為它沒執行過），無法排除間接影響。

## 判定

**修法邏輯本身正確（char bed 證實），但 wiring 位置錯誤導致對絕大多數 team 族群完全無效**。建議：

1. 先修 wiring 問題——讓 stall-detection 覆蓋 `_decide_unified`/`_evaluate_solo` 路徑（非只 legacy 子隊分支），才有意義重新 measure。
2. seed42 惡化建議 implementer/systems 先查因果鏈（是否此 branch 真的引入了某種 regression，或純 RNG-cascade 世界差異）。

---
measured_at_head: `ed2fdff6`（`.worktrees/desperation-ladder`）
raw_logs: `docs/measurements/2026-07-18-despladder-charbed-*.log`、`...-constitution-*.log`、`...-headless-*.log`、`...-multiseed-ed2fdff6.json`
measure.json: `docs/process/verdicts/desperation-ladder-feedback.measure.json`（`is_sim: true`）
code 引用: `faction_ai_system.gd:3225`（早退閘）、`:3361`（stall-detection 呼叫點，被閘擋住）
