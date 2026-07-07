# A2a 工單 — 子隊決策路由進引擎（自足）

## WHAT
子隊（subteam）現在**繞過統一決策引擎**：走手寫 argmax + randf 派 task，不過 `DecisionEngine.rank_scored`。→ 子隊的手不聽（同一個）腦。單點 bed 顯示 **subteam bypass 是剩下最大宗的手不聽腦**（A1a 修完引擎內的閥後，leader/subteam bypass 浮上來）。

**A2a = 讓子隊的決策走成員/solo 用的同一個引擎（rank_scored），不再手寫。** 本 slice 只做子隊，leader 是 A2b 另一片。

## 現況（自己 grep 驗，別信我）
- 子隊手寫 dispatch：`scripts/simulation/faction_ai_system.gd:1669-1700` 附近（掠奪/攻擊/回歸 argmax + randf）。逆向 findings 標 **D7**。
- 對照：成員走 `_decide_unified` → `DecisionEngine.rank_scored`（乾淨縫，A1a 後 member 背離已趨 0）。
- 單點 bed `scripts/debug/hand_obeys_brain_bed.gd`（`HandBrainProbe`，已在 main）分 `subteam` category + `subteam_bypass` 機制——**這是驗收工具**。

## 目標（WHAT，HOW 交系統/機器出 plan）
子隊每 cadence 的 `current_task` 來自**引擎 rank_scored**（吃子隊自己的 context：parent team、任務、位置、感知），argmax 由 utility weigh 決定，不是手寫門檻 + randf。

## 護欄（別做壞）
- 子隊的**生命週期**（生成/解散/歸建 parent）不動——只換「怎麼決定 task」。
- 子隊仍有自己的 context（parent_team_id、任務目標）——餵進引擎當 weigh 輸入，不是丟掉。
- 別碰 leader（A2b）、別碰成員/solo（已好）。
- 別重造閥（A1a 拆的閥別回來）。

## 驗收（用 main 現有工具，量測員跑）
1. 無 GDScript 錯誤；constitution_gate 綠；sanity（headless ≥1000 tick 無崩、關鍵 print）。
2. **單點 bed（HandBrainProbe，seed 1337, 1月）：subteam category 背離率 / subteam_bypass 機制計數應大幅掉**（對照 A2a 前 baseline）。
3. **TeamTrace 抖動檢**：子隊 task 走引擎後**穩定、不每 cadence 亂換**（拆手寫最怕抖動）。
4. 非退化：其他 category（member/solo/leader）背離不暴增；arbiter_latch 維持 A1a 後的低檔。
5. 效果發生（subteam 背離真降）非只「改了 code」。
