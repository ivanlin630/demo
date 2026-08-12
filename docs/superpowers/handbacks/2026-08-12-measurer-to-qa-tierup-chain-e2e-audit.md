---
from: measurer
to: qa
status: open
topic: "[請QA故事稽核:tier-up鏈端到端specimen(790KB,T0/T1/T2/T3全記錄)]這輪結論(訓練util 0.32-0.34穩定輸給build/覓食0.5-1.1+,T0.anon_exp[平民]全程0.0)是從specimen candidates逐日讀出來的behavior-causal claim,非純聚合計數,依§長跑hook需要你的故事稽核才能鎖。★最想請你核:①我讀的candidates數字(訓練=0.32~0.34穩定敬陪末座)是否真的代表『訓練從未真正接近勝出』,還是有我沒注意到的日子/tick訓練其實贏過但被我的day-boundary抽樣漏看(我的bed只在日邊界抽樣,同unified-dispatch-diverse那次的已知限制)②T2(non-FORCE)候選清單完全不見『訓練』選項這個negative evidence你能否獨立驗證(applicable=false)③T0.ambition_archetype全程='武力'我有沒有看錯(這是整個E2E測試成立的前提,若archetype其實中途變了會推翻整個設計)。"
---

# 請 QA 故事稽核：tier-up 鏈端到端 specimen

`2026-08-12-measurer-to-systems-tierup-chain-e2e-verdict.md` 已回 systems（並行送你）。這輪結論（訓練 util 穩定 0.32-0.34、持續輸給 build/覓食等 0.5-1.1+ 選項、`T0.anon_exp["平民"]` 全程 0.0）是從 specimen candidates 逐日讀出來的 behavior-causal claim，不是純聚合計數——依 §長跑 hook 需要你的故事稽核才能鎖定。

## 最想請你核的三點

1. **訓練 util 是否真的從未接近勝出**：我讀的 candidates 數字（`訓練=0.32~0.34` 穩定敬陪末座）是否代表「20 天內訓練從未真正接近勝出」，還是有我沒注意到的日子/tick 訓練其實贏過，但被我的**日邊界抽樣**（同 unified-dispatch-diverse 那輪的已知限制——只在 `tick%TICKS_PER_DAY==0` 採樣）漏看了中間某個 tick 的真實勝出？

2. **T2（non-FORCE）候選清單完全不見「訓練」**：這個 negative evidence（`applicable=false` 導致訓練從未進入候選清單）你能否獨立驗證，跟我讀到的一致？

3. **T0.ambition_archetype 全程是否真的穩定 = "武力"**：這是整個 E2E 測試設計成立的前提——如果 archetype 中途因為某種機制變了（比如 `AmbitionLadder.update` 週期性重算，某天可能因為某個條件翻轉），會推翻我「T0 是合格 FORCE 領主但仍打不贏 argmax」這個核心論點。

## 落地檔案（已 git commit `8a4cfd32`）
- `docs/measurements/2026-08-12-tierup-chain-e2e-seed8181.specimen.jsonl`（790KB，T0/T1/T2/T3 全記錄）
- `docs/measurements/2026-08-12-tierup-chain-e2e-seed8181.json`（daily_log，含每日 archetype/task/tiers/exp 快照）
- `docs/measurements/2026-08-12-tierup-chain-e2e-raw.txt`（完整 log）
