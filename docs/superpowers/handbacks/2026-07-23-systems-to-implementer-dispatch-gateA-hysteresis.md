---
from: systems
to: implementer
status: consumed
topic: "[dispatch·GATE-A 二刀 返家閉環 hysteresis·R² CLEAN(touch 0 已補)·新 branch feat/gateA-return-hysteresis·off GATE-A merge 後 main] spec=2026-07-23-gateA-2nd-cut-return-hysteresis.md。根:返家補給 applicable food_days<DESPERATION(3)→隊返家途中 food 過 3→option 消失→漂回 idle/trade→震盪(QA Team66/85/59 + code 雙坐實)。修 2 touch:①★touch 0(reviewer 必補):decision_context.gd gather 加 c.current_task = team.current_task(team 自身欄非 god-view)②options.gd 返家補給 applicable 加 `or (ctx.current_task==TeamData.TASK_RETURN_HOME and ctx.food_days < RETURN_HYSTERESIS_DAYS)`,新 const RETURN_HYSTERESIS_DAYS=RESTOCK_DAYS(5)(terms.gd,重用既有值非新魔數)=hysteresis band[3,5]。TDD 5(①returning+food 3-5→applicable true②非returning+3-5→false③food≥5→false 釋放④food<3→true⑤productive returning restock_need 1.0)。gate/headless 0new/determinism byte-identical(純算術無 RNG)。★★measure(→measurer §④b+specimen→QA):返家 chosen(2638→?應降)/GATE-A bucket %(58-73%→?)/days_left 卡點爬升/returning 隊到家+harvest+food 過5+出門閉環坐實(逐 tick,非只邏輯)/forest 不誤鎖+不過鎖(food≥5 釋放正常出門率)/end-絕境(15/26→?)/無新餓死。做完→to:measurer(→QA)。task=systems+reviewer(merge-gate)。★base=GATE-A merge 後 main(先確認 feat/gateA-productive-home 已 merge)。"
branch: feat/gateA-return-hysteresis
---

# dispatch：GATE-A 二刀 返家閉環 hysteresis（破 oscillation）

spec：`docs/superpowers/specs/2026-07-23-gateA-2nd-cut-return-hysteresis.md`。**R² CLEAN**（7 點全驗 + 根因診斷確認準）+ **touch 0 已補**。

## ★ branch
- **新 branch `feat/gateA-return-hysteresis`**，**off GATE-A merge 後 main**（先確認 `feat/gateA-productive-home` 已 merge 進 main，本刀疊其上）。

## 2 touch
### ★touch 0（reviewer 必補）：`decision_context.gd` gather 加 `c.current_task`
`c.current_task = team.current_task`（`team_data.gd:98` team 自身欄 = 自身狀態非 god-view）。

### touch 1：`options.gd 返家補給` applicable 加 hysteresis
```gdscript
... or (ctx.current_task == TeamData.TASK_RETURN_HOME and ctx.food_days < DecisionTerms.RETURN_HYSTERESIS_DAYS)
```
- 新 const `terms.gd RETURN_HYSTERESIS_DAYS: float = 5.0`（= `RESTOCK_DAYS`，**重用既有值非新魔數**；TEST VALUE，measure 調）。hysteresis band **[3,5]**：trigger 3 開始返家、返家途中撐到 food≥5 才停 → 完成返家 + 到家 harvest 補到 5+ 才出門。

## TDD（5）
①returning（current_task=RETURN_HOME）+ food 3-5 → 返家補給 applicable=**true**（原 false）②非 returning + food 3-5 → false（不變）③food≥5 → false（釋放出門）④food<3 → true（trigger 不變）⑤productive-home returning → restock_need 仍 1.0（drive 撐 rank）。

## 閘 + measure
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術無 RNG）。
- **★★measure（→measurer §④b + specimen → QA 長跑）**：返家 chosen（2638→?應降=不再狂震盪）/ **GATE-A bucket %（58-73%→?）**/ days_left 卡點（1.6-3.0）是否爬升 / **★returning 隊「到家+harvest+food 爬過 5+出門」閉環逐 tick 坐實**（非只信邏輯自洽，reviewer 要求）/ forest 不誤鎖 + **不過鎖**（food≥5 釋放，正常出門率）/ end-絕境（15/26→?）/ 無新餓死。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:measurer（→QA 判故事：returning 隊撐到真到家補飽脫 oscillation coherent；forest/正常隊不過鎖）。GATE-B（死法②撮合）+ settled 薄利（carrying-capacity valves）= 後續。
