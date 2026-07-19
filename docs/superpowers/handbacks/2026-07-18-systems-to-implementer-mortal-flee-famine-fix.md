---
from: systems
to: implementer
status: consumed
topic: "[dispatch·cause2 fix·mortal_flee 認飢餓·de-patch·B 前置] R² CLEAN。npc_combat_system.gd `_mortal_flee_check`:擴觸發認飢餓——(1):156 `if eff>MORTAL_EFF_POP and not starving: return false`(飢餓隊即使 eff>3 進判)(2)加 famine_pressure 餵 mortal_pressure(膽量秤:餓+怯早逃/餓+勇撐)。★邊界(R² 抓):FAMINE_W 須大到極端斷糧(food_days→0)時 famine_pressure 超過**最勇 flee_thr**(連勇者餓極也逃,否則勇者+無劣勢仍傻站死)。combat 高優先不動(非 PRIO whack-a-mole)。★measure 必含硬 seed1337(claim 前 multi-seed,blueprint process)。worktree feat/mortal-flee-famine off origin/main@31f9833c。"
---

# cause2 fix：mortal_flee 認飢餓（de-patch，B 前置）

## scope（R² CLEAN 設計）
`npc_combat_system.gd:152-177` `_mortal_flee_check` 擴觸發認飢餓（絕境階梯延進戰鬥）。**de-patch**:eff≤3 絕對門檻 pre-empt 膽量秤 for 飢餓=補丁閘。

## Fix（R² CLEAN）
```
var food_days = ResourceSystem.effective_food(state,s) / maxf(pop*ResourceSystem.FOOD_PER_PERSON_PER_DAY, ε)
var starving = food_days < FAMINE_FLEE_FLOOR   # TEST VALUE
if eff > MORTAL_EFF_POP and not starving: return false   # ★改:健康但餓→進判
var criticality = _pop_criticality(s)   # eff>3 時=0
var famine_pressure = clampf((FAMINE_FLEE_FLOOR - food_days)/FAMINE_FLEE_FLOOR, 0,1) if starving else 0
var mortal_pressure = clampf(criticality + outnumber*MORTAL_OUTNUMBER_W + famine_pressure*FAMINE_W, 0, ?)   # ★clamp 上限抬夠
var flee_thr = MORTAL_FLEE_BASE + courage*MORTAL_COURAGE_SPREAD   # 膽量秤不變
if mortal_pressure >= flee_thr: _force_retreat(...)
```
- **food_days 公式與 `decision_context.gd:143` / _trigger_survival 絕境判一致**（R² 核實）。

## ★邊界（R² 抓，FAMINE_W 校關鍵）
famine_pressure×FAMINE_W 太小 → **勇者(高 courage→高 flee_thr)+無數量劣勢+極端斷糧仍撞不破 flee_thr → 重演傻站死**。
- **FAMINE_W 須大到:food_days→0(極端斷糧)時 famine_pressure×FAMINE_W 單獨 ≥ 最勇 flee_thr**(`MORTAL_FLEE_BASE + 1.0×MORTAL_COURAGE_SPREAD`)→ 連最勇餓極也 break-off（餓極必逃=絕境階梯保證，同 survival boost 破頂精神）。
- 注意 mortal_pressure clamp 上限（現 1.5）要夠讓 famine 分量頂過最勇 flee_thr（若 flee_thr_max>1.5 需抬 clamp 或調係數）。

## measure（★含硬 seed1337，claim 前非事後——blueprint process 鐵律）
1. **multi-seed 含 seed1337 + 42 + 4201**（8mo）：`_on_team_extinct` **no_forage 傻站死普適歸零**（餓死回 survival-action/mortal_flee 自限）——**seed1337 必驗**（上輪就是它壞）。
2. **char bed 極端場景**：勇者(courage~1)+健康(eff>3)+極端斷糧(food_days~0)→ mortal_flee **fire**（驗 FAMINE_W 夠，勇者餓極也逃非傻站死）。
3. **戰鬥中不覓食保**：健康+不餓隊 eff>3 仍 `return false` 續戰（non-starving 不亂逃）。
4. **膽量秤 break-off**：餓+怯早逃/餓+勇撐久（照妖鏡#1 courage 桶）。
5. combat 三端保 + world sustain（seed1337 pop 不 bleed）。

## 完成 → 下一站
done+綠 → to:measurer（★含 seed1337 multi-seed 中性複核）→ to:systems 判 merge。**claim 普適前必過 seed1337**（3 度過早宣勝教訓）。

## 溯源
R² CLEAN（`2026-07-18-reviewer-to-systems-mortal-flee-famine-r2-clean.md`）;blueprint cause2 patch-gate 裁;`npc_combat_system.gd:152-177`;[[project_desperation_economy]];[[feedback_patch_gate_first]];[[reference_measurement_protocol]] multi-seed-before-claim。
