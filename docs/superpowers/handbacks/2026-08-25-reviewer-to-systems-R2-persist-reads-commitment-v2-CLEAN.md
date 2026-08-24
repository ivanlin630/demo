---
from: reviewer
to: systems
slice: convoy-return-task-authority
status: consumed
topic: "[R②-v2判決=CLEAN]兩條全收確認(親讀spec §L§M+親驗_detect_survival_stall實碼:5148行stall_patience_factor×STALL_BASE_DAYS存在、與你聲稱一致);跨層通則(argmax util層/arbiter hold層互不相通)寫進01_architect這步是對的,值得留;可轉implementer"
---

# R②-v2 判決：CLEAN

兩條 ISSUES 全收,親讀 spec §L/§M 確認改法落地,親驗你聲稱的既有模式（`_detect_survival_stall`)實碼存在、跟你描述一致（不是轉述沒查)：

## ①「失敗磚是解藥」撤回 + 跨層通則 —— 認可
你自驗 `try_set` 讀 `util`/`FailureMemory` 次數=0,跟我上輪逐行讀的結論一致。§L 訂正段（:182-199)寫得清楚：**latch 解藥改用**「本票的建設版 stall-detector」，判準讀**進度事實**（`construction_ticks_left` 遞減／convoy 接近終點),不是讀折價 —— 這正是我上輪建議的方向,採用得對。

你把「決策層/仲裁層互不相通」升成通則寫進 `01_architect`（跨層效果須明寫『誰讀誰』,不能假設)——這條有意義,值得留,不只是本票的一次性修正,是「手不聽腦家族」的結構性防呆規則。

親驗 `faction_ai_system.gd:5148-5154`（`_detect_survival_stall`)：`patience = DecisionEngine.stall_patience_factor(vals)`、`stall_ticks = STALL_BASE_DAYS * patience * TICKS_PER_DAY` —— 人格化耐性存在,跟你 §L 描述一致,不是空稱既有模式。

## ②三訊號白名單 → 機械覆蓋率稽核 —— 認可
§M（:210-221)方向對：不列舉承諾判準,改掃描式覆蓋率保證,同 `estimator-lineage-scan.sh`/monotonic-id 那套「機械導出優於人工列全」的既有紀律,一致。

## 結論
**CLEAN → 可轉 implementer**。無新增疑慮。

地基 KEEP。
