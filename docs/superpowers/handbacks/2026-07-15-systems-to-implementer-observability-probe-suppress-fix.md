---
from: systems
to: implementer
status: open
topic: "[FIX·觀測污染根因] on/off發散源=tracer re-query(capture_decision best_estimate/capture_options to_task)bump Probe→污染counter(非world破,Probe純寫sim不讀);修=tracer re-query包Probe-suppress鏡射suppress_observe_noise"
---

# Fix：tracer re-query Probe 污染（on/off 發散根因）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

measurer HALT（on/off 非 byte-identical）根因 systems 定音（code-verified）：

## 根因（非 world 破，是 Probe counter 污染）
- **control flow 未變**（solo/unified 三早退 continue 全保留，taps 純加，我逐行核）。
- **無 randf**（新 code 零 RNG）。
- **真源＝`capture_decision:80` re-query `BeliefSystem.best_estimate` → `Probe.bump("bel.best_call/hit/claim_*")`**。新 attempt-tap（Fix2b/Fix3）使 specimen 隊多呼 capture_decision → 多呼 best_estimate → **Probe counter 膨脹**（measurer 見 bel 694059 vs 693715）。
- **★這非 world-state 破**：grep 證 **sim 不讀 Probe counter**（Probe.note/add_amount/bump 皆純寫測量，無 sim 決策回饋）→ **teams/pop 實際 byte-identical**，發散只在 Probe aggregate 輸出。measurer 把 counter 差誤讀為 world 差。
- **但仍是觀測不變量違反**：觀測儀器（tracer）觸發另一觀測儀器（Probe）＝**同 RNG confound 家族**（觀測改共享測量狀態）。必修。

## 修（鏡射既有 suppress_observe_noise RNG 模式）
tracer 的**所有 re-query**（純觀測用途，非真決策）包 **Probe-suppress**：
- **`specimen_tracer.gd:80`**（capture_decision 的 best_estimate re-query）：`var _pe := Probe.enabled; Probe.enabled = false; var bel := BeliefSystem.best_estimate(...); Probe.enabled = _pe`（scope 只包這一呼，微秒級）。
- **`capture_options`（:45 附近）to_task re-query**：已有 `suppress_observe_noise`（RNG）包裹——**加同段 Probe.enabled save/restore**（to_task→finder 可能 bump Probe）。
- **capture_reaction / heartbeat 的 `_snapshot`**：查 `_snapshot` callees（target_rung/effective_food…）有無 bump Probe → 有則同包。
- **統一 helper**（建議）：`SpecimenTracer` 加 `_begin_observe()/_end_observe()`（save/restore Probe.enabled + suppress_observe_noise 一起），所有 re-query 段包它 → 觀測非侵入單點保證（RNG+Probe 都中性）。

## 驗收（★這次 TDD 要含 Probe）
- **★on/off byte-identical 含 Probe aggregate**（前輪 TDD 漏了 Probe——小場景 Probe 差不顯，full-HD 才爆；本次硬驗 Probe counter 也 identical）。
- specimen=A/=B/無 三跑：除 tracer entries 外**世界 + Probe aggregate 全 byte-identical**。
- 憲法 sites=29；headless 零新增。

## 在哪
`feat/observability-path-completion` 續（`279ad8c8`+）。**注**：此分支 base 早於 flee merge（`12d3d7b1`）→ 完成後 **rebase 到最新 main + 解 faction_ai flee_from_pos vs capture 衝突**（同區塊，衝突小；flee 的 `if td.task==FLEE: flee_from_pos=...` 行 vs 你的 capture 行相鄰）→ 再 handback。

## 完成後
→ handback `to:systems` → measurer 重驗（world + Probe on/off byte-identical）→ blueprint 批 merge。
