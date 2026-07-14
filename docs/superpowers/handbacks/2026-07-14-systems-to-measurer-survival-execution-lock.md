---
from: systems
to: measurer
status: consumed
topic: "[量測] 求生執行鎖 thrash-fix——headline thrash歸零 + 買糧成交 + tap-gap收 + .specimen.jsonl給QA;首個試驗新workflow"
---

# 量測請求：求生執行鎖 thrash-fix

branch `feat/survival-execution-lock` @ `4fbaa7e8`（worktree `.worktrees/survival-execution-lock`，已 push）。base = main `f490f364`。
spec：`docs/superpowers/specs/2026-07-14-survival-execution-lock-thrash-fix.md §驗收法`
系統已驗 code 合 spec、R② CLEAN、implementer sanity 全綠。

## ★本 slice = 全量暫態可觀測性 + QA 故事性判官 workflow 首個試驗
標準床外**必產 `.specimen.jsonl`**（`03b §⑤` 逐 specimen 全量 dump，含死隊）給 QA 判官讀 motive→action→outcome。此為新 workflow dogfood。

## 要產的數字（spec §驗收法，branch vs base 同世界對照）
1. **★headline：thrash 歸零**：Team14 型非-unified 子隊 `貿易↔idle`（+掠奪/佔村同型抖）**同-tick task-flip/tick 次數** → branch 應歸零/趨零 vs base 高（base Team14 seed1337 曾 122 次）。量法：`reeval_attribution_bed.gd` 或 specimen trace 數 flip；`[Survival] TeamN …→…` 每-tick flip print 消失。
2. **買糧單下得成**：餓子隊 fire 買糧 → HOLD 到抵市集 + `[Order] TeamN buy food` 出現（非落空抖死）。
3. **Fix B tap-gap 收**：`SPECIMEN_TEAM_ID` 設一個子隊 → `decision_count > 0`（非假象 0）；子隊每次 `_decide_subteam` winner 進 trace。
4. **`.specimen.jsonl`**：抽 thrash-死/thrash-救活 specimen（子隊，含死隊），逐事件 dump 想法(decision trace/控制流轉換)+狀態(pop/food_days/意圖)+資源(coin/food/weapons)時序 → 餵 QA 判故事性。
5. **雙數字（防換皮）**：thrash flip 數 **+** attrition 一起報。
6. **不回歸**：determinism byte-identical；憲法閘 sites=29 不變；established/attrition 跨 seed 不退化（**本刀治抖不治死亡率，attrition 不強求回 baseline**——但不能惡化）。

## seed
seed1337（血證世界，Team14）+ 補 seed42/7（跨世界 robustness）。

## 溯源鐵律
raw log 落地 `docs/measurements/*.log` + 附 commit hash（`4fbaa7e8` branch / `f490f364` base）+ 引數字附來源檔:行。

## 下游
- 數字 handback `to:blueprint`（判率/release）。
- `.specimen.jsonl` → **QA 故事性判官**讀（你產齊 trace，QA 判 motive→action→outcome，`04_qa §第五職`）。
- 全量完成才寄一封完整信（鐵律6，不分批）。缺項標 incomplete 報藍圖。
