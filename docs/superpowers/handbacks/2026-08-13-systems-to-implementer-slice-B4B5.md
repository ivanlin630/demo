---
from: systems
to: implementer
status: consumed
topic: "[dispatch slice B4+B5(生存產出層、R² CLEAN、bundle 一 worktree、先做):堵『安家後採糧硬零/material 排擠 food』=已 settled 團餓死根·完整 inline plan 免依賴 worktree 有 spec 檔·★B4 settle→invalidate labor cache(明確 bug 小修):settle/紮營成功落腳點立即 LaborSystem.ensure_fresh(state,tile)、加在 _convert_to_resident(interaction:1363 body 末+呼叫端 faction_ai:1963 後)+establish_crude_camp 成功後;只提早刷既有 cadence 非改分配邏輯·TDD:bed settle 一團於 fresh tile→同 tick labor_mult(tile,gather:food)>0(非等3天)·★B5 food need 隨飢餓升(NeedOracle 單點勿平行):need_oracle:105 _self_use food 分支×famine_escalation=1+maxf(0,(SAFE_DAYS−food_days)/SAFE_DAYS)×FAMINE_GAIN;SAFE_DAYS=ResourceSystem.FORAGE_FLOOR_DAYS(5、既有錨非新knob)、FAMINE_GAIN=TEST VALUE bounded(建議2.0、measurer bounded-verify);food_days=effective_food(state,team)/(pop×FOOD_PER_PERSON_PER_DAY);thread state 進 _self_use(need_keep:14 已有 state 可傳、trivial);TDD bounded 兩象限:食飽(food_days>=5)→escalation=1 need 不變+瀕餓(food_days=0)→need=base×(1+GAIN)+整合:飢餓團 gather:food weight 升→rebalance 多分 labor·★invariant:感知鐵律(B5 讀自家 food_days=自知非god-view、B4 無決策讀);零新RNG;fp 標 intended-change(B5 行為有意改)·★量測 gate(交 measurer 綠才 merge):B4 新居民首3天採糧非硬零+B5 飢餓村勞力回糧/吃飽村照舊 bounded 兩象限·worktree feat/survival-prod-b4b5 base 現 main(code 未改=同origin)、handback 寫 main mailbox 絕對路徑·地基 KEEP"
---

# dispatch slice B4+B5 — 生存產出層（R² CLEAN、bundle 一 worktree、先做）

堵「安家後採糧硬零 / material 排擠 food」= 已 settled 團餓死根。design=`specs/2026-08-13-survival-economy-access-arc-design.md`、HOW=`specs/2026-08-13-survival-economy-access-arc-HOW.md`（R² CLEAN）。完整 inline plan 如下（免依賴 worktree 有 spec 檔）。

## ★B4 settle 時 invalidate labor cache（明確 bug、小修）
**根**：`labor_alloc` 3 天 cadence（`ensure_fresh` labor_system:17-19）→ 新居民首 3 天採糧硬零 57-80%。
**改**：settle/紮營成功落腳點**立即** `LaborSystem.ensure_fresh(state, tile)`：
- `_convert_to_resident`（interaction_system.gd:1363 body 末）+ 呼叫端 faction_ai_system.gd:1963 後。
- `establish_crude_camp`（空地 founding）成功後。
- ★只**提早刷既有 cadence**、非改分配邏輯 = 無行為外溢（determinism 只早不晚）。
**TDD**：bed settle 一團於 fresh tile → **同 tick** `LaborSystem.labor_mult(tile,"gather:food")>0`（非等 3 天）。

## ★B5 food need 隨飢餓升（NeedOracle 單點、勿平行 food-need）
**根**：`_self_use`（need_oracle:105-108）food 分支 = `FOOD_PER_PERSON_PER_DAY×pop×food_security_target`=**純靜態零讀 famine** → material 排擠 food。
**改**（此單點）：food 分支 × `famine_escalation`：
```
food_days = ResourceSystem.effective_food(state,team) / maxf(pop×FOOD_PER_PERSON_PER_DAY, 0.001)
famine_escalation = 1.0 + maxf(0.0, (SAFE_DAYS − food_days)/SAFE_DAYS) × FAMINE_GAIN
return FOOD_PER_PERSON_PER_DAY × pop × food_security_target(leader_values) × famine_escalation
```
- `SAFE_DAYS = ResourceSystem.FORAGE_FLOOR_DAYS`（=5、**既有錨非新 knob**、>5 天食=subsistence-safe 不 escalate）。
- `FAMINE_GAIN`：**TEST VALUE**（建議 2.0、bounded；measurer bounded-verify、非 fire-crank）。
- **thread `state` 進 `_self_use`**：`_self_use(team,res,lv)` → `_self_use(state,team,res,lv)`；更新 `need_keep`（:14）呼叫端（已有 state、trivial）。查其他 _self_use 呼叫端一併補 state。
**TDD bounded 兩象限（硬）**：
- 食飽（food_days≥5）→ escalation=1.0 → food need **不變**（照舊採礦）。
- 瀕餓（food_days=0）→ food need = base×(1+FAMINE_GAIN)。
- 整合：飢餓團 `gather:food` weight（labor_system:99 讀 need_keep+demand）升 → rebalance 多分 labor 給採糧。

## ★invariant（硬守）
- **感知鐵律**：B5 讀**自家** food_days（自知肚餓≠god-view）；B4 無決策讀。
- **零新 RNG**；**determinism**：B4 只早刷 cadence（結果收斂同）；B5 fp 標 **intended-change**（need→labor→gather 行為有意改、非 byte-identical）。
- **禁 crank**：SAFE_DAYS 導既有錨；FAMINE_GAIN bounded、食飽=1 不動（reviewer 已驗兩端界）。

## ★量測 gate（交 measurer、綠才 merge）
- B4：新居民首 3 天採糧**非硬零**。
- B5：**飢餓村勞力回糧 + 吃飽村照舊**（bounded 兩象限、machine-demonstrate）。
- determinism/regression/constitution 綠。

## worktree
`feat/survival-prod-b4b5`、base 現 main（我只改 docs、code 同 origin）。code 寫 worktree、**handback 寫 main mailbox 絕對路徑**（`<main-repo>/docs/superpowers/handbacks/`）。B4/B5 各一 commit。完 → handback to:systems（附 measurer 量測請求）。

序：你做 B4+B5 → 我收 → 交 measurer bounded 量測 → 綠 merge → 我 dispatch A1（camp_marginal）。地基 KEEP。
