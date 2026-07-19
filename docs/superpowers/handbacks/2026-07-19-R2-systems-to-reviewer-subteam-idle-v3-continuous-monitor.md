---
from: systems
to: reviewer
status: open
topic: "[R² v3·subteam-idle-latch 連續母團監看+orphan·結構修] measurer 查 seed1337 v2 惡化(6→10)=真結構洞:_parent_needs_food 召回在 move_target==-1 分支內(只駐 forage tile 查)→旅途中 forager 不監看母團→母團垂危召不回,forager 已飽卻救不了(交糧太慢)。v3 兩結構修:①連續監看——foraging subteam 每 tick(旅途中也查,_check_discipline 後 position-branch 前)查 parent,母團<PARENT_LOW→merge_queue 掉頭交糧;parent==null→orphan ②orphan-forager——parent 死/缺席→detach 轉獨立(沿用 discipline_fail 現成路)。v2 sated-merge 保留(駐點正常路)。審點:①連續監看每 tick merge_queue 掉頭 vs loop2b release-move 交互不 thrash②orphan detach 沿用 discipline_fail 路安全(轉獨立後跑獨立戰略)③監看位置(discipline 後 position 前)不誤傷 ESCORT/BUILD④parent 垂危 recall vs sated deliver 兩路並存不衝突。gate-tune 排結構後。off 980e0b1c 後 HEAD,extend 036fc42c。CLEAN→redirect implementer。"
---

# R² v3：subteam-idle-latch 連續母團監看 + orphan（結構修）

## v2→v3 為何（measurer 結構洞坐實）
seed1337 v2 惡化（6→10）= **真結構洞非 cascade**：v2 的 `_parent_needs_food` 召回在 `move_target==-1` 分支內（只 forager **駐 forage tile** 才查）→ **旅途中 forager 完全不監看母團** → 母團垂危召不回；死案例 forager 已飽（food 10-11）卻救不了（交糧太慢）。

## v3 兩結構修（spec 已更新）
1. **連續母團監看（主）**：foraging subteam 每 tick（旅途中也查，`_check_discipline` 後、position-branch 前）：
   - `parent == null` → `_orphan_forager`（轉獨立）。
   - `_parent_needs_food(parent)` → `merge_queue.append`（母團垂危 → 掉頭歸建交糧，loop2b 移向 parent → 抵達 merge）。
2. **orphan-forager**：parent 死/缺席 → `detach_subteam + remove_tag(TAG_SUBTEAM) + release`（沿用 discipline_fail 現成路）→ 轉獨立不無限囤糧。
3. v2 sated-gated merge 保留（駐 forage tile 食足→交糧正常路）。

## R² v3 審點
1. **連續監看不 thrash**：母團垂危時每 tick merge_queue → loop2b（parent 不同格）release + move toward parent。forager 持續朝 parent 移動（一致，非振盪）→ 抵達 merge 交糧。確認每 tick merge_queue vs loop2b 交互**不振盪**（持續掉頭 ≠ thrash）。
2. **orphan detach 安全**：沿用 discipline_fail 的 `detach_subteam+remove_tag+release`——轉獨立後跑獨立戰略（`_evaluate_independent_strategy`/`_evaluate_solo`）自行覓食/入 faction，不再囤糧。確認 detach 雙向同步乾淨（parent.member 清、sub.parent_team_id 清）。
3. **監看位置不誤傷**：放 `_check_discipline` 後、position-branch 前，只對 `current_task in SURVIVAL_TASKS`——ESCORT/BUILD/CONSTRUCT/SETTLE（上段已 return）不受影響。確認 survival-work 才進監看。
4. **recall vs sated deliver 兩路並存**：連續監看（in-transit 垂危 recall）+ position-branch（駐點 sated deliver）並存不衝突（一個 in-transit、一個 arrived）。
5. **無新 RNG/違憲**；perf（每 tick foraging subteam parent lookup=cheap，若量出 spike 再 cadence-gate）。

## gate-tune 排後（blueprint 裁）
SATED/PARENT_LOW 值待結構修落地才 tune（v2 證純調參數不堵召回洞治標不治本）。本 R² 不糾結閾值。

## 回覆
`to:systems`：CLEAN / blocking(file:line)。CLEAN → redirect implementer extend 036fc42c（v3 連續監看+orphan）。
