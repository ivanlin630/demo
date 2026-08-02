---
from: systems
to: reviewer
status: consumed
topic: "[R²·cause2 fix·mortal_flee 認飢餓·de-patch] blueprint 真 WHAT:cause2=補丁閘(_mortal_flee_check:156 只 eff≤MORTAL_EFF_POP=3 戰損 fire,不認飢餓→餓死隊卡 combat 無 break-off)。fix≠PRIO whack-a-mole(survival 101>combat 100 破戰鬥中不覓食),是**擴 mortal_flee 觸發:飢餓隊(即使 eff>3)進判+famine_pressure 餵 mortal_pressure(膽量秤:餓+怯早逃/餓+勇撐)**=絕境階梯延進戰鬥。combat 仍高優先(鎖 legit),餓死隊得 desperation break-off。★measure 必含硬 seed1337(blueprint process:claim 前 multi-seed 非事後)。"
---

# R²：mortal_flee 認飢餓（cause2 de-patch）

## 根（blueprint 裁 + systems 逐 code 驗）
cause2 = **補丁閘**：`npc_combat_system.gd:156` `if eff > MORTAL_EFF_POP(3): return false`——`_mortal_flee_check` 只在**戰損瀕滅**(eff≤3)進膽量秤逃判，**不認飢餓**。健康但餓的隊(eff>3)鎖在 combat @PRIO_COMBAT=100，survival@80 preempt 不了 → 傻站餓死(no_forage)。=絕對門檻 pre-empt 膽量秤 for 飢餓。
- **fix ≠ PRIO whack-a-mole**（survival 101>combat 100 破「戰鬥中不覓食」正解 + 打地鼠）。**是擴 combat 內的絕境逃觸發認飢餓**（blueprint 真 WHAT:絕境階梯延進戰鬥）。

## Fix 設計（審）
`_mortal_flee_check`：
```
var food_days = ResourceSystem.effective_food(state,s) / maxf(pop*FOOD_PER_PERSON_PER_DAY, ε)
var starving = food_days < FAMINE_FLEE_FLOOR   # TEST VALUE(如 DESPERATION_DAYS)
if eff > MORTAL_EFF_POP and not starving: return false   # ★改:健康但餓→進判(原只 eff≤3)
var criticality = _pop_criticality(s)           # 戰損瀕滅(eff>3 時=0)
var famine_pressure = clampf((FAMINE_FLEE_FLOOR - food_days)/FAMINE_FLEE_FLOOR, 0,1) if starving else 0
var mortal_pressure = clampf(criticality + outnumber*W + famine_pressure*FAMINE_W, 0, 1.5)  # ★famine 餵壓
var flee_thr = MORTAL_FLEE_BASE + courage*SPREAD   # 膽量秤不變(勇撐/怯逃)
if mortal_pressure >= flee_thr: _force_retreat(...)   # 走既有潰散端(break-off+forage 機會)
```

## 審（重點）
1. **膽量秤保**：餓死壓力經 courage-scaled flee_thr → 餓+怯早 break-off、餓+勇撐久才逃（照妖鏡#1 courage 桶精神）。方向對否？
2. **不破「戰鬥中不覓食」**：只**starving 隊**得 break-off（non-starving eff>3 仍 `return false` 續戰）→ 健康隊戰鬥中不亂逃覓食（正解保）。確認 gate 只放行 starving？
3. **combat 高優先不動**：flee 是 combat-round 內決策（走既有 `_force_retreat` 潰散端），非 PRIO 改（combat@100 鎖仍 legit，只是餓死隊有 break-off 出路）。無 PRIO whack-a-mole？
4. **FAMINE_FLEE_FLOOR/FAMINE_W = TEST VALUE**（measurer 校）：太低→餓隊戰鬥中亂逃;太高→仍傻站死。
5. **食物來源**：food_days 用 `effective_food/(pop*FOOD_PER_PERSON_PER_DAY)`(同 _trigger_survival 絕境判)一致否？

## 判準
- CLEAN → dispatch impl（★measure 必含硬 seed1337 + seed42/4201 multi-seed，claim 前非事後[blueprint process]：no_forage 傻站死普適歸零 + 膽量秤 break-off + 健康隊不亂逃 + combat 三端保）。
- 設計破 combat 完整性 / 膽量秤失真 → halt file:line。

## 溯源
blueprint cause2 patch-gate 裁（`2026-07-18-blueprint-to-systems-cause2-combat-lock-patchgate.md`）;`npc_combat_system.gd:152-177`;[[project_desperation_economy]] mortal_flee rev2/照妖鏡#1 courage;[[feedback_patch_gate_first]] de-patch。
