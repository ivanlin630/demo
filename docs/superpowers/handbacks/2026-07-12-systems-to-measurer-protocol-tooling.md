---
from: systems
to: measurer
status: consumed
topic: [分層量測協議工具] 建Tier1床庫規範+平行seed launcher(吃滿核)+金字塔resume SOP;此後量測預設走協議
---

# 工單：分層量測協議 落地工具（藍圖 intent + 我編入 03b）

協議已編入 `03b_measurer.md §★★分層量測協議` + memory `reference_measurement_protocol`。你 owner 工具側，建三樣：

## 1. Tier 1 床庫規範
- 盤點現有控制場景床（`consolidation_decision_trace` 等 decision-trace 秒級床）+ 純生成掃（`worldgen_floor_scan`）→ 列一份「迭代期該用哪個床查哪類問題」對照（機制/因果→decision-trace；結構/分布→生成掃）。
- 缺的常用維度補建最小 trace 床（秒級、手構 WorldState、不跑 organic）。
- 目的:迭代期有現成秒級床可抓，不落回大窗。

## 2. 平行 seed launcher（吃滿核）
- Tier 2 確認跑:**跨 seed 平行吃滿核**（最大 wall-time 槓桿）。
- **★守 §大窗 SOP①**:單一大窗 run 不自拆 2 godot（撞記憶體被 kill 血證）。平行=**不同 seed 各一進程** launcher，併發上限看資源（sim compute-bound，godot 搶 CPU+import lock，~2-3 起評，thrash 反慢就降）。
- launcher 收 seed 列表 → 分配核 → 各 seed detach/bg → 收 progress sidecar 湊齊。

## 3. 金字塔 resume SOP
- 廣度 8×3mo（非 18）→ 看 attrition/combat CV 分布 → **挑兩極 seed**（一和平/低 vs 一血戰/高）→ `WARRING_RESUME` 從第 3 月狀態續跑到 12mo。
- 複用前綴省 ~46%（8×3+2×9=42 vs naive 78 seed-月）。深度樣本=廣度同世界（連續）。
- 寫成可複跑 SOP（哪個 env、resume 怎麼接、挑極怎麼判）。

## 此後預設
迭代 Tier1（秒級床，禁大窗）、確認 Tier2（平行+金字塔）。右尺寸配問題（3mo 能答別 12mo）。

## 註
- 這是工具建設，非 gate 某 slice。可 Tier1 優先（迭代期立即受益），平行 launcher 次，金字塔 SOP 隨手。
- 現進行中的 default 崩潰交叉注入診斷（若藍圖裁跑）正好用 Tier1/控制場景思路（分離 scatter vs config 變因＝控制變數，秒級生成掃即可能分離大半）。
