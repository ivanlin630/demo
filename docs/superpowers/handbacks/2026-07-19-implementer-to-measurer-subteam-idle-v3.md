---
from: implementer
to: measurer
status: consumed
topic: "[measure·v3 結構修·硬驗] subteam-idle v3 連續母團監看+orphan → feat/subteam-idle@c53c8cbb(extend ab3044c3)。★硬驗 6 項(別當 non-blocker):(a)recall 收斂無慢震盪 (b)seed42 famine→0 (c)seed1337 v2 惡化 6→10 回落 (d)orphan 消 (e)手不聽腦維持 0 (f)perf 每tick parent lookup 無 spike。TDD 16/16、headless 0new(baseline3)、gate 64、determinism seed1337 2mo byte-identical(md5 2ebb70aa)。gate 值 tune 排結構後。"
---
# Hand Back: subteam-idle-latch v3（連續母團監看 + orphan-forager）

承 REDIRECT `2026-07-19-systems-to-implementer-subteam-idle-v3-REDIRECT.md`（v3 R² CLEAN，extend ab3044c3）。**取代**前 v2 handback（v2 有旅途監看結構洞：seed1337 惡化 6→10）。

## 為何 v3（v2 結構洞訂正）
v2（sated-gated 條件 merge）的 `_parent_needs_food` 召回**只在 `move_target==-1` 分支內**（forager 駐 forage tile 才查）→ **旅途中 forager 完全不監看母團** → 母團垂危時出門的 forager 召不回（死案例 forager 已吃飽卻救不了，交糧太慢）。∴ 需**連續監看**（不等駐點）。

## 實作摘要（v3，extend 同 branch）
branch `feat/subteam-idle@c53c8cbb`（036fc42c v1 + ab3044c3 v2 + v3 監看；off local main；★禁 origin 落後）已 push（★過 installed pre-push 兩閘）。

**`_evaluate_subteam`**：`_check_discipline` 後、position-branch 前加**連續母團監看**（survival-work subteam 每 tick 查，旅途中也查）：
```gdscript
if sub.current_task in SURVIVAL_TASKS:
    var mon_parent = state.teams.get(sub.parent_team_id)
    if mon_parent == null:
        _orphan_forager(state, sub)          # 母團缺席/死 → 轉獨立（不囤糧）
        return
    if _parent_needs_food(state, mon_parent):
        merge_queue.append(sub.team_id)      # 母團垂危 → 立即掉頭歸建交糧（旅途也召）
        return
# （落 position-branch：v2 sated-gated merge 保留，處理「駐 tile 食足→交糧」）
```
**+`_orphan_forager`**：`detach_subteam + remove_tag(TAG_SUBTEAM) + release`（沿用 discipline-fail proven 路）→ orphan 下 tick 跑獨立決策，不無限囤糧。
- **v2 sated-merge position-branch 保留**（連續監看是 in-transit 補洞，非取代 sated 路）。
- **BUILD/ESCORT 不誤傷**：早退於監看前（BUILD:1697 / ESCORT:1720 return）。

## 我的驗證
- **TDD** `subteam_idle_latch_test` **16/16 PASS**。v3 加：①旅途中(move_target set)母團垂危→連續監看召回（★v2 漏此結構洞，v3-load-bearing）②母團死→orphan(detach/去 TAG_SUBTEAM/IDLE/不 merge)③BUILD 不被監看召回(施工不中斷)。既有 v1/v2 case 全續綠。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**（監看/orphan 非 decision-func 值閘型）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `2ebb70aa`**（無 RNG）。

## ★請你硬驗（v3 REDIRECT 明列 6 項，★別當 non-blocker）
- **(a) recall 收斂（reviewer flag）**：旅途 recall（母團缺糧掉頭）後，交糧完 forager `_decide_subteam` re-pick forage 有無**慢震盪**（recall↔re-forage 低頻振盪）。若有 → flag（收斂機制需補）。
- **(b) seed42 famine → 0**（v1 引入的 regression，v2/v3 必治）。
- **(c) seed1337 v2 惡化 6→10 回落**（v3 監看補洞必治，回 baseline 或更好）。
- **(d) orphan 現象消**：無 forager 無限囤糧（200-2000 food-days）；母團死的 forager 轉獨立。
- **(e) 手不聽腦維持 0**：committed=覓食 would_succeed=true 卻 idle 的坐死隊維持消（v1 治的別回歸）。
- **(f) perf**：每 tick survival subteam parent lookup（`state.teams.get`，O(1)）**無 spike**（per-tick 有界不變量）。
- 你用 `godot --path .worktrees/subteam-idle` 跑（★禁原地 checkout）。

## gate 值（結構後才 tune）
`FORAGE_SATED_DAYS=10`/`PARENT_LOW_DAYS=3` TEST VALUE。blueprint 裁：**gate-tune 排 v3 結構修之後**（結構洞補完才是純參數敏感度）。若你量到結構已對但殘留（囤糧仍多/母團仍餓）→ 才建議調值。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完（6 項硬驗）→ .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。
