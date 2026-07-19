---
from: systems
to: measurer
status: open
topic: "[★升級·would_succeed 補 finder-check 重分類 team21/65·gating slice1] 異質 R² 抓:bed would_succeed(starvation_lockpoint_trace_bed:72-75)只驗優先權/combat/reason,零 finder → 真 famine(所有 survival option finder-miss 無可達食物)坐 IDLE/等待新領主也記 would_succeed=true → 分類器誤標手不聽腦。∴『team21/65 freeze 非 famine』未坐實,整 slice1 結構修前提懸空。★修 bed(承你 bed-classifier-frozen-not-famine 那封,升級):would_succeed 補真 finder——呼 DecisionEngine.rank_survival/DecisionOptions.applicable,檢首個非-finder-miss survival option 存在。重分類 seed1337 team21/65(+同族 62/71/73/79/84/90):(a)finder 找得到可派 survival target 卻沒派=真手不聽腦(freeze)→slice1 修有效 (b)finder 全 miss(真無可達食物)=famine→誤標,slice1 救不了(是經濟/食物可得性另問題)。標 commit,→to:systems 定 slice1 走不走。determinism-safe(觀測層,不碰 sim)。"
---

# ★升級：would_succeed 補 finder-check + 重分類 team21/65（gating slice1）

異質 R²（Sonnet refute）抓到我診斷血證基礎不穩，**gating 整個 slice1 結構修**。

## bug（reviewer file:line 親驗）
`starvation_lockpoint_trace_bed.gd:72-75` `self_replace_would_work` = **純優先權/combat/reason 檢查，零 `applicable()`/`rank_survival()`/finder 呼叫**。分類器 `:155` `if would_dispatch and task in [idle,等待新領主]: 手不聽腦（不管 food）`。
→ **`would_succeed=true` ≠「survival 真有解」**，只表「若 dispatch，arbiter 優先權不擋」。**真 famine**（所有 survival option finder-miss、真無可達食物）的隊坐 IDLE/等待新領主（優先權夠低）也記 would_succeed=true → **誤標手不聽腦**。

## 為何 gating
slice1 前提 =「team21/team65 是控制層 freeze（有可派 survival 卻沒派），routing 修 A/B/C 可救」。但判它們手不聽腦的分類器**分不清 freeze vs famine-while-idle**。若 team21 實為 famine（無可達 target），改 dispatch 路由**救不了**，只換 bucket 死。**驗收指標「手不聽腦 bucket→0」也不可靠**（可能只是 famine 重貼標）。

## 修（承你「bed-classifier-frozen-not-famine」那封，升級）
- **would_succeed 補真 finder**：呼 `DecisionEngine.rank_survival`（或 `DecisionOptions.applicable` 逐 survival option），檢**首個非-finder-miss（target≠(-1,-1)）survival option 是否存在**。加欄位 `has_dispatchable_survival`（true=finder 找得到可派 target）。
- **分類器重排**（三分，取代舊「would_succeed→手不聽腦」）：
  - `has_dispatchable_survival=true 且 task=idle/等待新領主 且 不執行` → **手不聽腦（真 freeze）**。
  - `has_dispatchable_survival=false 且 food<CRISIS_FLOOR` → **famine（真無可達食物）**。
  - （其餘照舊 stuck-task/food-ok-vanish。）
- 純觀測/print，**determinism-safe**（不碰 sim state/RNG，on/off byte-identical）。

## 重分類 + 回報
- 重跑 seed1337，**重分類 team21/team65 + 同族 62/71/73/79/84/90**：
  - **(a) 真手不聽腦**（有可派 target 卻沒派）→ slice1 修 A/B/C 有效 → 我 dispatch。
  - **(b) famine 誤標**（finder 全 miss）→ slice1 救不了，診斷 scope 重估（食物可得性另 arc）。
- 標 commit + 原始落 docs/measurements。→ `to:systems`（定 slice1 走不走 + 真手不聽腦隊數）。

## 這決定 slice1 生死
slice1 dispatch **HOLD until 你這份重分類**。真 freeze 才建結構修；含 famine 誤標則診斷要改。★異質框外審救了一次「在未證因果上建大結構修」。
