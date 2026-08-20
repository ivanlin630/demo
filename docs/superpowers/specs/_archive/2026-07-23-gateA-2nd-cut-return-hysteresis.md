# spec：GATE-A 二刀 — 返家閉環 hysteresis（破 oscillation）

> 層級：L3（1 clause，決策模型 measure-sensitive）。off main（GATE-A merge 後）。
> 來源：GATE-A merge-partial（-40%/-16% 決策層 gain）後殘留=返家 oscillation。QA §④b 坐實（Team66/85/59 warning→return_home→漂回 idle/trade→re-warn，days_left 卡 1.6-3.0 never 爬升）+ systems code-坐實（下）。blueprint 認可 hysteresis 二刀方向。= committed-not-executed / 手不聽腦家族。

## 根（code-坐實，補 QA 的 event 推論）
- **返家補給 applicable food-gate = `food_days < DESPERATION_DAYS(3)`**（`options.gd:83`）。
- ∴ 隊決定返家（TASK_RETURN_HOME）**途中** food_days 一過 3（碰 DESPERATION 線）→ **返家補給 option 消失（not applicable）→ 無 option 可承諾**（SOLO_COMMITMENT_BONUS 0.15 救不了消失的 option）→ 隊 re-rank 到 idle/trade → **漂離**（未到家）→ 不採 → food 再降 <3 → 返家補給 re-applicable → 又返家 → …。
- = **oscillation**：days_left 永卡 1.6-3.0（在 DESPERATION=3 線上下抖）= **never 真到家 harvest 補飽**。返家「決策」接上（chosen 2638）但「閉環（到家+harvest+補飽）」未成。

## 修（touch 0 ctx 暴露 + 1 clause hysteresis）
### ★touch 0（reviewer R² 必補）：`decision_context.gd` gather 加 `c.current_task = team.current_task`
- `ctx.current_task` 目前**不存在**（grep 0 match）→ 正式列為第 0 touch，別讓 implementer 從審點反推。`team.current_task`（`team_data.gd:98` team 自身欄）=自身狀態非 god-view。

### `options.gd 返家補給` applicable：加返家途中 hysteresis band
```gdscript
"返家補給": applicable = ctx.has_home_outpost \
    and (ctx.home_food >= RESTOCK_MIN or ctx.home_food_productive) \
    and ( (ctx.is_merchant and ctx.food_days < RESTOCK_DAYS) \
          or ctx.food_days < DESPERATION_DAYS \
          or (ctx.current_task == TeamData.TASK_RETURN_HOME \
              and ctx.food_days < RETURN_HYSTERESIS_DAYS) )   # ★已在返家路上→撐到舒適(>DESPERATION)才停
```
- **`RETURN_HYSTERESIS_DAYS`（新 const，TEST VALUE，起始 = `RESTOCK_DAYS(5)`）**：trigger 在 DESPERATION(3) 開始返家，但**一旦 current_task==RETURN_HOME → 撐返家到 food_days ≥ 5（舒適 buffer）才停**。hysteresis band [3,5]：破 DESPERATION 線抖動 → 隊完成返家 + 到家 harvest 補到 5+ → 才帶 buffer 出門。
- **ctx.current_task**：decision_context 需暴露（若未有；`team.current_task` 讀得到，非 god-view=自身狀態）。
- 既有 `SOLO_COMMITMENT_BONUS(0.15)` 承諾慣性保留（option 在了，bonus 撐 rank）。

## 為何足夠 + 不過鎖
- **破 oscillation**：返家 option 不再於 food≥3 消失 → 隊撐返家到真到家補飽（到家→被動 harvest→food climb 過 5→option 停→帶 buffer 出門）。QA 觀察的「漂回 idle」根因（option 消失）直接解。
- **不過鎖**：hysteresis 只在 `current_task==RETURN_HOME`（已決定返家的隊）+ food<5；到家補飽（≥5）即停 → 正常出門。**非返家隊 food 3-5 不受影響**（forest/archetype 隊照常）。food≥5 即釋放。
- **「到不了家」sub-case**：QA event 顯來源 task=idle/trade（非 travelling）→ 是**漂離**非**走不到** → hysteresis（撐住不漂）正解。若 measure 揭殘留真 travel-不到（home 太遠/pathing）= 三刀 movement，非本刀。

## 驗收
- **TDD**：①returning 隊（current_task=RETURN_HOME）+ food_days 3-5 → 返家補給 **applicable=true**（原 false，hysteresis 開）②非 returning 隊 + food 3-5 → **applicable=false**（不變，只 returning 才 hysteresis）③food≥RETURN_HYSTERESIS(5) → applicable=false（釋放出門）④food<DESPERATION(3) → applicable=true（trigger 不變）⑤productive-home returning 隊 restock_need 仍 1.0（drive 撐 rank）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術）。
- **★★measure（→measurer §④b+specimen→QA 長跑）**：返家 chosen（2638→? 應降=不再狂震盪）/ **GATE-A bucket %（58-73%→?）**/ days_left 分布（1.6-3.0 卡點是否爬升=真補飽）/ returning 隊到家補飽率 / end-絕境（15/26→?）/ **回歸：forest 不誤鎖 + 隊不永鎖家（food≥5 釋放，正常出門率）**/ 無新餓死。★逐 tick specimen 坐實 returning 隊「到家+harvest+food climb 過 5+出門」閉環成。
- **送 QA 判故事**：returning 隊撐到真到家補飽脫 oscillation coherent；forest/正常隊不被過鎖。

## 排序
二刀一 clause。R²（hysteresis band [3,5] 值合理/current_task 讀自身非 god-view/不過鎖[food≥5 釋放]/forest 不受影響/無 RNG/與 SOLO_COMMITMENT_BONUS 交互）→ dispatch。GATE-B（死法②撮合）+ settled 薄利（carrying-capacity valves）= 後續。
