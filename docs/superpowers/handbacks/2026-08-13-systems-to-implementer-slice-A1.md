---
from: systems
to: implementer
status: open
topic: "[dispatch slice A1(紮營價值=MarginalEconomy 真帳、R² CLEAN 含 design 背書 term-非-gate、禁crank命門雙重anti-crank防線)·完整 inline plan·★①新 MarginalEconomy.camp_marginal(est,forage_floor)=maxf(0,_inflow_est(est)−forage_floor)純算術零新常數鏡射 migrant_marginal(god-view防線一致只吃est)②DecisionContext.gather 建新欄 camp_target_est(VillageEstimate.make(terrain,outpost_level=1,farming_level=0,pop)、terrain 從既有 _find_unowned_farmable_tile:4643 掃到的靶 tile 地理=belief;無靶→null)+camp_forage_floor(=_forage_subsist_buffer(team)/... 日產同源)③camp_drive(terms:190)換=若 opt≠紮營 or not has_farmable_tile or camp_target_est==null:return 0;marg=MarginalEconomy.camp_marginal(camp_target_est,camp_forage_floor);daily_need=pop×FOOD_PER_PERSON_PER_DAY;urgency=clampf((URGENCY_DAYS−food_days)/URGENCY_DAYS,0,1);return clampf(marg/maxf(daily_need,ε),0,CAMP_CAP)×urgency·常數 CAMP_CAP(bound TEST VALUE 建議1.5、封頂非inflate)+URGENCY_DAYS(TEST VALUE 建議 PROVISION_DAYS=10 既有錨、measurer bounded-verify)·★TDD bounded 四象限(硬gate、★mountain 被 farmable 排除故『純山地→不紮』走 gate;marginal→0 anti-crank 路徑用低產farmable[森林regen3+高pop→marg→0]測):①有家/已resident→紮營 N/A or marg≈0②富流浪(food_days≥URGENCY_DAYS)→urgency=0→camp_drive=0③瀕餓+肥沃平原→marg高×urgency高=高④瀕餓+低產farmable(森林高pop marg→0)→maxf(0)=0→camp_drive=0不紮·★invariant:感知鐵律(est 從 _find_unowned_farmable_tile 地理=belief 非他隊live、food_days自家自知)、零新RNG、fp intended-change(camp_drive行為有意改)、禁crank(雙防線:has_farmable gate排mountain+camp_marginal maxf(0))·worktree feat/survival-access-a1 base現main·完→handback to:systems附measurer bounded四象限量測請求·地基KEEP"
---

# dispatch slice A1 — 紮營價值 = MarginalEconomy 真帳（R² CLEAN + design 背書 term-非-gate）

design=`specs/2026-08-13-survival-economy-access-arc-design.md` §2 A1、HOW=`-HOW.md`。R² CLEAN（親算禁crank雙防線 + design opinion=維持 term 非 gate）。完整 inline plan：

## ①新方法 `MarginalEconomy.camp_marginal(est, forage_floor) -> float`
```
= maxf(0.0, _inflow_est(est) − forage_floor)
```
純算術、**零新常數**、鏡射 `migrant_marginal`（god-view 防線一致=只吃 `est` 拿不到 live state）。

## ②`DecisionContext.gather` 建新欄
- `camp_target_est: VillageEstimate`：`VillageEstimate.make(terrain, outpost_level=1, farming_level=0, pop)`——**terrain 從既有 `_find_unowned_farmable_tile`（faction_ai:4643）掃到的靶 tile 地理**（=belief、只掃自己鄰近 7 格地理/ownership、已排除 mountain）。無靶 → `null`（保守不行動）。
- `camp_forage_floor: float`：覓食餬口日產（`_forage_subsist_buffer(team)` 日產同源）。

## ③`camp_drive`（terms.gd:190）換算法
```
if opt != "紮營" or not ctx.has_farmable_tile or ctx.camp_target_est == null: return 0.0
var marg = MarginalEconomy.camp_marginal(ctx.camp_target_est, ctx.camp_forage_floor)
var daily_need = float(ctx.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
var urgency = clampf((URGENCY_DAYS − ctx.food_days) / URGENCY_DAYS, 0.0, 1.0)
return clampf(marg / maxf(daily_need, 0.001), 0.0, CAMP_CAP) * urgency
```
- `CAMP_CAP`：**bound TEST VALUE**（建議 1.5、封頂非 inflate、measurer bounded-verify）。
- `URGENCY_DAYS`：TEST VALUE（建議 `ResourceSystem.PROVISION_DAYS`=10 既有錨、food runway 緊迫度尺）。

## ★TDD bounded 四象限（硬 gate）
★注：mountain 被 `_find_unowned_farmable_tile` 排除 → 「純山地→不紮」走 **gate**（has_farmable_tile=false）；**marginal→0 的 anti-crank 路徑用低產 farmable 測**（森林 regen 3 + 高 pop → `_inflow_est` 邊際 → 0）。
1. **有家/已 resident** → 紮營 N/A or marg≈0。
2. **富流浪**（food_days≥URGENCY_DAYS）→ urgency=0 → camp_drive=0。
3. **瀕餓+肥沃平原** → marg 高 × urgency 高 = 高。
4. **瀕餓+低產 farmable**（森林高 pop marg→0）→ `maxf(0)`=0 → camp_drive=0 不紮（★anti-crank marginal 路徑）。

## ★invariant
- **感知鐵律**：est 從 `_find_unowned_farmable_tile` 地理（belief、非他隊 live）；food_days 自家自知。
- 零新 RNG；fp 標 **intended-change**（camp_drive 行為有意改）。
- **禁 crank**：雙防線（has_farmable gate 排 mountain + camp_marginal `maxf(0)`）；CAMP_CAP bound 非 inflate。

## worktree
`feat/survival-access-a1`、base 現 main。code 寫 worktree、handback 寫 main mailbox 絕對路徑。完 → handback to:systems（附 measurer bounded 四象限量測請求）。

序：你做 A1 → 我收+review → measurer bounded 四象限 gate → 綠 merge → dispatch A2/A3（diagnostic-first）。地基 KEEP。
