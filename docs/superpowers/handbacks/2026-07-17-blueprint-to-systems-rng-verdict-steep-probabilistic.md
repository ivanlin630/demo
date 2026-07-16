---
from: blueprint
to: systems
status: consumed
topic: "[裁·乙-陡+RNG判準精修3案]用戶定乙但機率必陡。閘2/3(人格加權決策骰)=合法gate-ok但要陡:性格把清楚案例推兩端(忠2%/奸95%),骰只斷真忠奸難分的中間→不太運氣(結果掙來)+有機戲(天人交戰不可測)。閘4=event-ID非決策骰,我判錯own,gate-ok。★RNG判準3案:①純骰無人格替決策=de-patch②世界不確定outcome(訊息/事件/event-ID/遭遇)=legit③人格加權機率決策=legit-IF陡+framework-routed+seeded(陡=性格主宰清楚案例,平則太運氣要陡化)。systems驗閘2/3曲線夠陡(平則陡化非de-patch)。閘1/5/6 de-patch/7刪。re-R²整軌2"
---

# 裁：乙-陡 + RNG 判準精修（3 案）

用戶定 **乙,但機率必須陡**。

## 裁閘 2/3（人格加權決策骰）＝合法 gate-ok，但要陡
- **合法留**：慎重/loyalty 已驅動背叛/紀律機率（非純 50/50）＝走框架、seeded、不汙染 → **非零殘留違規,gate-ok。**
- **★但機率必須陡**：性格把**清楚案例推兩端**（真忠 2% 背叛 / 真奸 95%），**骰只斷真忠奸難分的中間**（40~60%）。
  - **這樣不太運氣**：清楚案例性格說了算（結果掙來的,骰動不了）+ 只有天人交戰的才擲骰（本來就該不可測＝真實）。
  - **平骰才太運氣**（性格不影響機率＝銅板決定）→ 不接受。
- **∴ systems 驗閘 2/3 曲線夠陡**：性格是否真主宰清楚案例?若曲線平/糊 → **陡化**（tuning,讓性格推兩端）,**非 de-patch**（機率決策合法,只是要陡）。

## 閘 4（event-ID）＝gate-ok（我 own 判錯）
`_maybe_request_join randi` ＝產 event ID 非決策骰,我未驗就裁 de-patch＝犯我一直抓的病,R² 抓到我的,own。**gate-ok。**

## ★RNG 判準精修（3 案，通用）
1. **純骰替決策（無人格）** → **de-patch**（骰替思考＝壞;決策交人格/情境 util）。
2. **世界不確定 outcome RNG** → **legit**（訊息到不到、隨機事件、event-ID 生成、遭遇誰＝非決策,世界的隨機）。
3. **人格加權機率決策** → **legit-IF-陡 + framework-routed + seeded**：
   - **陡**＝性格/情境主宰清楚案例（推兩端）,骰只斷真難分中間。
   - **framework-routed**＝走統一決策路（非散落 ad-hoc randf）。
   - **seeded**＝可重現（測試/release determinism 不破）。
   - **平則太運氣 → 陡化（tuning）,非 de-patch。**

## 世界性格定調（記 game-design）
**這世界＝有機非鐘錶:性格是傾向(機率)、擲骰實現,但曲線陡→清楚案例註定、天人交戰才不可測。** 服務好戲/湧現(同性格隊多數一致、卡界線的才分歧),不太運氣。roguelike 本色(DF/Kenshi/M&B)。

## 下一站
1. **閘 2/3 mark gate-ok**（+ systems 驗曲線陡,平則陡化）。閘 4 gate-ok。
2. **閘 1/5/6 de-patch、閘 7 刪**（已裁）。
3. **re-R² 整軌 2**（含精修 RNG 判準）→ CLEAN → 執行。
4. constitution_gate 的 rng 型:3 案分類（純骰 de-patch / outcome legit / 人格機率 legit-IF-陡）納入 triage 規則。
**乙-陡定案。人格機率合法但要陡,不太運氣。RNG 判準 3 案精修完。**
