---
from: systems
to: reviewer
status: open
topic: "[R²·Probe.bump_sample 工具·§④b enabler·tiny] spec=2026-07-21-probe-bump-sample.md。用戶核可(建工具不建 gate)。Probe(probe_stats.gd)加 samples dict + bump_sample(event,instance,cap=8):計數 key 旁存 ≤N 具體 instance,落 fullprobe 供決策帶故事。審點:①★no-RNG=first-N cap(size<cap 才 append)非 reservoir sampling(reservoir 需 randf 違 observer-no-rng 鐵律第5次)②★env-gated off(if not enabled return)=byte-identical(sim 不讀 Probe)③禁改 sim state(只寫 Probe.samples)④instance 由 caller 傳,Probe 不 re-query(不耗 RNG/污染)⑤reset 清 samples。TDD 4型+determinism on/off byte-identical。無 caller 遷移(只加工具)。CLEAN→dispatch implementer。tiny slice。"
---

# R²：Probe.bump_sample（§④b enabler，tiny）

spec：`docs/superpowers/specs/2026-07-21-probe-bump-sample.md`。用戶核可（建工具、不建 gate=ROI 差）。§④b「decision-bearing 聚合帶 bounded 樣本」的機制 enabler。

## 什麼
`Probe`（`scripts/debug/probe_stats.gd`）加 `samples` dict + `bump_sample(event, instance, cap=8)`：計數 key 旁存 ≤N 個 instance dict，dump 端 serialize 進 `fullprobe.json` 的 `samples.<key>`。決定性數字直接帶故事。

## ★審點（observability 鐵律敏感）
1. **★no-RNG**：`first-N cap`（`size < cap` 才 append），**非 reservoir sampling**。reservoir 需 `randf`=違 [[feedback_observer_no_global_rng]] 觀測禁耗 RNG 鐵律（第 5 次同族會咬人）。純確定性 append。
2. **★env-gated off**：`if not enabled: return`（同 bump）→ off = **byte-identical**（sim 不讀 Probe）。
3. **禁改 sim state**：只寫 `Probe.samples`（觀測用途）。
4. **instance 由 caller 傳**（`{tick,team,res,...}`）：Probe 不算不 re-query（不耗 RNG / 不污染 aggregate，避 SpecimenTracer bel.best_call 污染前例）。
5. `reset()` 清 samples。

## 驗收
TDD 4 型（off no-op / append 到 cap / cap 後不 append / reset 清）+ determinism on/off byte-identical（2 跑 identical，無 RNG）+ gate PASS + headless 0 new。**無 caller 遷移**（只加工具，決定性探針改用=後續按需）。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch implementer（off LOCAL main）。tiny slice。
