---
from: systems
to: implementer
status: consumed
topic: [S-A 開工] consolidation 併決策統一——term 退flat/餵養gate/accept-util薄層
---

# 實作工單：consolidation S-A 併決策統一

spec `specs/2026-07-10-consolidation-s-a-technical.md`（**reviewer R② CLEAN**：異質框外①+框內②兩輪過，characterize 驗真、gate#1 空真守衛補完）。目標=**食壓驅併=有機政體湧現**（非殲滅修復）。新 worktree `feat/consolidation-s-a`（基於最新 main，先確認 push）。

## 改（照 spec §HOW-1/2/3，勿超範圍）
1. **`terms.gd` term 退 flat（真 term 秤，禁補償閘）**：
   - `consolidate_drive`（**雙 flat 真靶**）：eval `:161` flat `CONSOLIDATE_DRIVE` → 食壓 scaled（mirror join `:91`＝`DESPERATION_SCALE * maxf(0, DESPERATION_DAYS - food_days)`，gate 保 `consolidate_target_id!=-1`）；weight `:229` flat 1.0 → 人格 f(求生欲, 1-野心)。
   - `join_drive`：**eval 別動**（已食壓 scaled）；weight `join` + 野心負向 `_low_ambition`；`has_strong_neighbor` 硬 gate → `options.gd` applicable 前提（食壓驅 join 不限強鄰）。
2. **`_find_absorber`/`consolidate_target_of`（`faction_ai`）+ 餵養 gate#1（防搬餓）**：選 absorber 過 `combined_food_days >= ABSORBER_MIN_SURVIVE_DAYS`（合隊併後餘命=兩隊 food 和/((pop和)×FOOD_PER_PERSON_PER_DAY)；吸附者併前 surplus>0）。不過=不選。
3. **accept-util 薄層（靶C，contact resolver）**：復用 `_try_join_target` 骨架，absorber 接觸時秤**單一 util（收/不收）非全 rank**（野心/統領力×餘裕→願收；自身食壓重→拒）。**超出單 util 比較=回報 systems**（別滾成第二引擎）。
4. **探針**（`warring_harness`）：併事件 n + 前後 food_days/餘命 + 隊規模分布 + argmax 來源（證無 pop<N 硬寫）+ side-observe annih/規模。

## 常數（TEST VALUE，measurer 校準）
`ABSORBER_MIN_SURVIVE_DAYS`(~7)、join weight 野心係數、accept-util 權重、`THREAT_JOIN_W`(可選 0.4)。

## gate（handback to:measurer）
- `--import`/multi-sanity/constitution 綠、determinism。
- measurer 硬驗：**gate#1 餵養真解非搬餓**（★含空真守衛：併事件=0→INCONCLUSIVE 非 PASS，回報門檻過嚴）+ **gate#3 湧現非腳本**（grep 無 pop<N；食壓 argmax）。**gate#2 殲滅=side-observe 記數不判**。
- merge 閘=reviewer 對實際 diff 再過一輪 CLEAN（框內）+ measurer gate#1/#3 + blueprint 判有機政體湧現。
- 三端/戰鬥不退化（下游湧現非直改 combat）。
