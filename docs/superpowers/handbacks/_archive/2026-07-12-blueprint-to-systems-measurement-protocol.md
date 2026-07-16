---
from: blueprint
to: systems
status: consumed
topic: [流程intent] 分層量測協議——迭代用秒級床/確認用平行+金字塔resume;砍「每rev大窗」浪費;編入流程doc+memory
---

# 藍圖 intent：分層量測協議（省 wall-time）

用戶：量測太浪費時間（這 session 燒最多在重跑大窗）。`02_reviewer.md`/`03b_measurer.md`/量測流程 doc 你 owner，我給 WHAT-intent，你+measurer 編入 + memory。

## 根因（這 session 浪費）
1. 大窗(35-85分)在 **code 還迭代時**反覆跑（pursuit rev1/2/3 各跑大窗、consolidation 多輪）。
2. seed 序列跑（沒吃滿核）。
3. 窗太短要重跑（3mo 沒看到崩潰→重跑12mo）。
4. 變因混淆要重跑（2×2）。

## 協議（分層：快迭代 / 慢確認）
**Tier 1｜迭代用（秒級,迭代期只用這個）**：
- 控制場景床（手構最小 WorldState,如 `consolidation_decision_trace.gd`）——機制/邏輯/因果。
- 純生成掃（如 `worldgen_floor_scan`,只 GameSetup 不跑 sim）——結構/分布。
- **★鐵律：code 還在改 → 只用 Tier 1,禁大窗。** 本 session 最大浪費就是違反這條。

**Tier 2｜確認用（code 穩才跑一次,當閘）**：
- organic 多 seed 只在 code 定稿後跑一次,非迭代工具。
- **平行 seed 吃滿核**（最大 wall-time 槓桿,~N倍）。
- **金字塔 resume**（systems 提,採納）：廣度 8×3mo → 挑兩極 resume 續深度,複用前綴省~46%。
- **右尺寸**：窗長/seed 數配問題,別預設大（3mo 能答別 12mo）。

## 三大槓桿排序
1. **迭代期不碰大窗**（行為改,零成本,省最多）。
2. **平行 seed 吃滿核**（技術）。
3. **控制場景床查因果 > organic 聚合**（decision-trace 秒級且更有料,本 session 驗證兩次）。

## 更深(先不做)
sim 慢的根=O(N²) faction AI（timescale wave backlog）。加速 sim 讓全量測變快,但大 arc。現在快贏=協議+平行,非重寫 sim。

## 落地
- systems 編入量測流程 doc（`03b_measurer.md` 或新協議段）+ memory（reference_量測協議：分層/平行/金字塔/右尺寸）。
- measurer 建：Tier1 床庫規範 + 平行 launcher（吃滿核）+ 金字塔 resume SOP（`WARRING_RESUME` 已有）。
- 此後量測預設走協議：迭代 Tier1、確認 Tier2 平行。

編完確認即可。這砍掉這 session 那種重跑浪費。
