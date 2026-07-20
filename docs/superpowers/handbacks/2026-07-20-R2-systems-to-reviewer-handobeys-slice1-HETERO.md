---
from: systems
to: reviewer
status: consumed
topic: "[★異質 R²·手不聽腦 slice1 結構修·框外挑框三對齊] blueprint 同意升異質框外審(大結構改 core survival routing+高信心診斷+難逆 merge)。★請用不同模型/代 + refute prompt(非 confirm)——目標 REFUTE 診斷,非背書。spec=2026-07-20-hand-obeys-brain-slice1-survival-lifeline.md。診斷(sweep map):faction 成員 survival 只有 loop1 _decide_unified 一條命脈,三重掐:D1(:1418 領主戰鬥整包跳過)+D2(:1628 落空無兜底)+D6(:851 crisis-release→IDLE 同 tick ambient 塞貿易)。三修:A ambient fallback 加 food-crisis gate/B 成員 survival 不被領主-combat gate/C _decide_unified 終端兜底 release。★refute 標的:①診斷真根嗎(D1/D2/D6 真掐死 team21,還是我 sweep 誤讀路由骨架/漏了成員別條 survival 路?)②修 A ambient-skip 會不會餓隊卡 IDLE 更久(survival 次 reeval 真接得到嗎)?③修 B 分離領主協調/成員 survival 會不會破 faction 協調語意?④would_succeed=true vs finder-miss 矛盾(修 C)——是純 finder-miss 還是漏試可成 option(影響修法)?⑤改 core survival routing 有無下游 regression(改 :851 影響所有 IDLE 隊)。off main HEAD。CLEAN→dispatch。"
---

# ★異質 R²：手不聽腦 slice1 結構修（框外挑框）

blueprint 同意升**異質框外審**（框外挑框三對齊：①大結構改 core survival routing ②高信心診斷 sweep map ③難逆 merge core）。

## ★★請用不同模型/代 + refute prompt
**目標 = REFUTE 診斷與修法，非 confirm/背書**。同 Opus reviewer=框內審（同 priors）。此 call 我很確信（sweep map 15 drop 點），**高信心=危險信號**——請異質 skeptic 挑框。

spec：`docs/superpowers/specs/2026-07-20-hand-obeys-brain-slice1-survival-lifeline.md`；sweep map：`docs/process/hand_obeys_brain_sweep_map.md`。

## 診斷（請 refute）
faction 成員 survival **只有 loop1 `_assign_tasks→_decide_unified` 一條命脈**（`_evaluate_survival:3267` `uses_unified or parent==-1 → return` 排除成員走引擎）。三重掐：D1（`:1418` 領主戰鬥/null→整包跳過）+D2（`:1628` 落空無 release 兜底）+D6（`:851` crisis-release→IDLE 同 tick ambient 塞貿易）。

## 三修（請 refute 每個）
- **A（D6）**：`:851` ambient fallback 加 `_survival_food_days >= SURVIVAL_BOOST_FLOOR` gate → 餓隊 IDLE 不被 ambient 搶。
- **B（D1）**：領主-combat/null 時 food-crisis 成員仍跑 survival dispatch（分離協調/成員 survival）。
- **C（D2）**：`_decide_unified` 落空→food-crisis 成員 release IDLE 兜底。

## ★refute 標的（挑框重點）
1. **診斷真根嗎**：D1/D2/D6 真掐死 team21，還是我 sweep **誤讀路由骨架**（成員是否真只有 loop1 一條 survival 路？有沒有我漏看的成員 survival 補位路，如 `_decide_crisis`/別的 cadence 路）？`uses_unified(team)` 對 faction 成員真回 true 嗎（決定它走 D1 命脈還是別條）？
2. **修 A 副作用**：ambient-skip 後餓隊卡 IDLE，survival **次 reeval 真接得到嗎**（loop1 _decide_unified 對餓隊 IDLE 次 tick 真 dispatch survival？還是 cadence/D1 又擋→卡更久 IDLE 反更糟）？
3. **修 B 破協調**：分離「領主協調」vs「成員 survival」——會不會破 faction 協調語意（領主戰鬥時成員各自求生 vs 應協調）？
4. **would_succeed=true vs finder-miss 矛盾**（修 C 關鍵）：team21 報 would_succeed=true 但 _decide_unified finder-miss——是**純 finder-miss（真無 target，release 兜底夠）**還是**漏試可成 option（survival ranker 沒試到那個會成的，需補 dispatch 非只 release）**？這決定修 C 對不對。**請坐實**（可能需 measurer 一輪）。
5. **下游 regression**：改 `:851`（所有 IDLE 隊的 ambient 入口）+ `:1418`（faction 協調入口）=core 路——有無非-手不聽腦的下游隊行為被誤傷？

## 回覆
`to:systems`：CLEAN / blocking(file:line + refute)。`premise_contradiction`（若診斷被 refute）→ halt 重估。CLEAN → dispatch implementer。
