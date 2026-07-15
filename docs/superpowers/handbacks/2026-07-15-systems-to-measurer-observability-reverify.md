---
from: systems
to: measurer
status: consumed
topic: "[量測·重驗] observability Probe-suppress修+rebase@f4b8bb6d——★這次驗world+Probe全on/off byte-identical(HALT根因修);+內政reaction敘事+盲點閘綠"
---

# 量測：observability 重驗（Probe-suppress 修後）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/observability-path-completion` @ **`f4b8bb6d`**（★已 rebase 到 flee-merged main `c5b89307`）。systems 驗 diff PASS：
- **HALT 根因修**：`SpecimenTracer._begin_observe/_end_observe`（save/restore `Probe.enabled=false` + `suppress_observe_noise=true`）包住 `capture_decision` 的 best_estimate re-query + `capture_options` 的 to_task re-query → tracer 不再污染 Probe/RNG。
- **rebase 衝突解**：flee_from_pos（3 站 threat/unified/solo）+ observability capture（Fix2a/2b/3）**並存不 revert**（你上輪擔心的同區塊，已正確合併）。
- implementer 自報 on/off world+Probe byte-identical、headless 3+3、sites=29。

## 重驗（★這次含 Probe）
1. **★on/off byte-identical 含 Probe aggregate**（HALT 根因驗收）：specimen=12 vs 無，**排除 tracer entries 後 world + Probe 全 byte-identical**（上輪 world 已你確認一致，這次驗 Probe 也一致=Probe-suppress 生效）。**這是硬紅線,非則 halt。**
2. **內政 reaction 敘事**（原 unblock 目的）：force_full_hd 抓高-defect specimen → jsonl 顯 `phase:"reaction"` entry（誰/reaction/why loyalty·stress）→ 內政 defect/riot 可判真因。
3. **盲點閘綠**：`observability_gate.gd` PASS。
4. **無回歸**：headless 零新增、憲法 sites=29。
5. flee 已 merged 進 base → 本分支含 flee，順帶確認 flee+observability 並存不互擾（reaction/decision tap 對 flee 隊也正常）。

## 判定
- world+Probe on/off byte-identical + 內政敘事可讀 + 閘綠 → 觀測工具真修好 → handback `to:blueprint` 批 merge。
- Probe 仍 on/off 有差（suppress 沒包全）→ halt `to:systems`（貼哪個 counter 仍差）。

## 溯源
raw + measured_at_head `f4b8bb6d`。log/jsonl 存前 UTF-8。
