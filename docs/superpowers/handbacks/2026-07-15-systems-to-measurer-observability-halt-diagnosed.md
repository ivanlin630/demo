---
from: systems
to: measurer
status: consumed
topic: "[HALT 回·根因定音] on/off發散=Probe counter污染(tracer re-query bump Probe)非world破;world byte-identical(Probe純寫sim不讀);修派implementer;請排除Probe行複驗world確認"
---

# HALT 回：根因 = Probe counter 污染（非 world 破）

你 HALT 對——on/off 確有差，該擋。但 systems code 定音：**差在 Probe counter 污染，非 world state**。

## 根因
- `SpecimenTracer.capture_decision` re-query `best_estimate` → `Probe.bump("bel.best_call/hit")`。新 attempt-tap 使 specimen 隊多呼 → **Probe aggregate 膨脹**（你見 bel 694059 vs 693715）。
- **grep 證 sim 不讀 Probe counter**（Probe 純寫測量，無決策回饋）→ **teams/pop 實際 byte-identical**。你診斷「teams=19 vs 不同」——**大概率是 SUFF 輸出把 Probe-衍生數字（belief 讀/問率等）當 world 行 diff 進去了**。
- 但仍違觀測不變量（觀測儀器 tracer 污染另一觀測儀器 Probe），已升 invariants + 派 implementer 修（tracer re-query 包 Probe-suppress，鏡射 RNG suppress_observe_noise）。

## 請你確認（決定性）
**重 diff on(specimen=12) vs off，但這次排除所有 Probe-aggregate 行**（bel.*/reaction.*/merge.*/diag.* 等 counter 率/count 行），只留**真 world 狀態**（每月 teams count / pop total / 存活隊 id / 資源）：
- **world 段 byte-identical** → 坐實我分析（純 Probe 污染）→ 等 implementer Probe-suppress fix → 全 byte-identical（含 Probe）→ 綠。
- **world 段仍差**（teams/pop 真不同）→ 我漏了更深的 mutation → **回報 to:systems 硬 halt**（貼真 world 差的具體行）。

## 時序
- implementer Probe-suppress fix（`2026-07-15-systems-to-implementer-observability-probe-suppress-fix`）+ rebase 到 flee-merged main（`12d3d7b1`）中。
- 你先做上面「排除 Probe 行的 world diff」確認（快，不必等 fix）→ 回 to:systems。
- fix + rebase 落 → 你重驗 world+Probe 全 byte-identical → 綠 → merge。

## 溯源
你 HALT `279ad8c8`；根因 grep 定音 sim 不讀 Probe。
