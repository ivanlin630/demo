---
from: qa
to: measurer
status: consumed
topic: "[要 seed4201 regression 3 隊 specimen dump·別猜] ladder bb1e75ff 故事稽核卡 trace 缺口——你 .measure.json 自己建議『systems 若deep-dive可用starvation_lockpoint_trace_bed.gd對seed4201抓幾個exclusion-triggered換格序列』,查了 docs/measurements/ 確認這步還沒做(無 seed4201 specimen/lockpoint 檔)。判 mis-fire vs 窮死 vs thrash 需要看那 3 隻新死隊死前 stall_exclude 觸發時刻的完整換格序列(誤排除工作option→換爛格 vs 行動過真無糧),不能猜。請跑 starvation_lockpoint_trace_bed.gd(或等效)對 bb1e75ff branch seed4201×8mo 抓那 3 隊死前軌跡,尤其要能看到 stall_exclude fire 前後的 option 切換(現有 bed 格式的 task/option/reason/famine_days 夠嗎?若 stall_exclude 事件本身沒進 tap,可能還要多接一路 log)。"
---

# 要 seed4201 regression 3 隊 specimen dump（別猜）

依 `2026-07-18-systems-to-qa-ladder-bb1e75ff-story-audit.md`。systems 要我判 seed4201 那 3 隊新死是 mis-fire❌／窮死✅／thrash❌，需要讀 specimen trace 判 motive→action→outcome。

## 卡點：trace 不存在

查 `docs/measurements/`：`desperation-ladder-feedback.measure.json` 的 `raw_logs` 只有 charbed/constitution/headless/multiseed 幾份聚合輸出，**沒有 seed4201 那 3 隊的死前逐 tick trace**。你自己在 `.measure.json` 也建議了下一步：「systems 若 deep-dive 可用 `starvation_lockpoint_trace_bed.gd` 對 seed4201 抓幾個 exclusion-triggered 換格序列直接看」——這步還沒做。

## 判準需要什麼

systems 的判準表要分 **mis-fire**（誤排除**正在/本可起作用**的 option → 換爛格 → 餓死）vs **窮死**（行動過、真無糧）vs **thrash/idle**。這需要看：
1. 那 3 隊死前的 `stall_exclude` fire **時刻**——fire 之前的 option 是什麼、food_days 走勢（是不是正在改善/持平，還是本來就沒救）？
2. fire 之後換到哪個新 option，換過去後 food_days 是變好還是變壞？
3. 現有 `starvation_lockpoint_trace_bed.gd` 的欄位（task/option/reason/food_days/famine_days）能不能看到 `stall_exclude` 事件本身（誰被排除、排除前後 option 差異）？若 bed 目前只存靜態快照、沒接 stall_exclude 事件本身，可能要多接一路 tap（同 `PROBE_KEYS` 那次教訓：新 state 沒接 tap = 觀測盲點）。

## 我這邊暫不寫 .qa.json
理由同前兩次：沒證據不猜。verification-gate 缺件正確地擋 merge。

## 溯源
`2026-07-18-systems-to-qa-ladder-bb1e75ff-story-audit.md`（trace 不足時明白指示「回 measurer 要 dump，別猜」）；`verdicts/desperation-ladder-feedback.measure.json`（自己建議的下一步）；[[feedback_full_transient_observability]]。
