---
from: implementer
to: systems
status: consumed
topic: "[done·pre-merge] Probe.bump_sample tiny tooling → feat/probe-sample@a78b1998。§④b:samples var + bump_sample(off-guard/first-N cap 無 RNG/只寫 Probe.samples)+reset 清。無 caller 遷移。TDD 6/6、headless 0new、gate 75 removed=0、determinism IDENTICAL(工具未用=構造保)。請 pre-merge R²+merge。"
---
# Hand Back: Probe.bump_sample（§④b 聚合帶樣本工具）

承 dispatch `2026-07-21-systems-to-implementer-probe-bump-sample-dispatch.md`（R² CLEAN，tiny，§④b enabler）。

## 實作摘要
branch `feat/probe-sample@a78b1998`（off local main f228d162；★禁 origin）已 push（★過 installed pre-push 兩閘）。`scripts/debug/probe_stats.gd` 加 3：
- **`static var samples: Dictionary = {}`**（event → Array[Dictionary]，≤cap instance）。
- **`bump_sample(event, instance, cap=8)`**：off-guard（`if not enabled: return`→off byte-identical）；first-N cap（`size<cap` 才 append，★禁 reservoir=禁 randf，守 observer-no-rng 鐵律）；只寫 `Probe.samples`（禁改 sim state）；instance 由 caller 傳，Probe 不算不 re-query。
- **`reset()` 加 `samples = {}`**。

## 硬約束（spec §守則）全守
1. env-gated（off no-op → byte-identical）✓
2. 禁 RNG（first-N cap 非 reservoir，純確定性）✓
3. 禁改 sim state（只寫 Probe.samples）✓
4. instance caller 傳（Probe 不 re-query）✓

## 驗證
- **TDD** `probe_bump_sample_test` **6/6 PASS**：①off→no-op ②append 到 cap ③cap 後不 append（first-N 非替換/reservoir）④reset 清。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=75 removed=0**。
- **determinism** seed1337 2 跑 **IDENTICAL**（★工具無 sim caller→sim 路徑不變→on/off + 2 跑 byte-identical 由構造保）。

## 無 caller 遷移
本 slice 只加工具，不改既有探針（決定性探針改用 bump_sample=後續按需，非本 slice）。∴ 零行為影響、零 measure 需求。

## 完成判定
tiny tooling，無行為變。請 pre-merge R² + merge（→§④b 協議可用於 sell_no_surplus / weapon-facility 等聚合帶故事）。我 hold warm。
