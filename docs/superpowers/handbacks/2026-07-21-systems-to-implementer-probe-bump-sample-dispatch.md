---
from: systems
to: implementer
status: open
topic: "[dispatch·Probe.bump_sample·R² CLEAN·tiny·★off LOCAL main 85bb9b0c] spec=2026-07-21-probe-bump-sample.md。§④b enabler(用戶核可建工具不建 gate)。Probe(scripts/debug/probe_stats.gd)加:①static var samples: Dictionary={} ②bump_sample(event,instance,cap=8):if not enabled return→arr=samples.get(event,[])→size<cap 才 append→samples[event]=arr ③reset() 加 samples={}。★★硬約束:no-RNG(first-N cap 非 reservoir,禁 randf,守 observer-no-rng 鐵律)+env-gated off byte-identical+禁改 sim state(只寫 Probe.samples)+instance 由 caller 傳 Probe 不 re-query。TDD 4型(off no-op/append 到 cap/cap 後不 append/reset 清)。determinism on/off byte-identical 2跑 identical。gate PASS/headless 0new。無 caller 遷移(只加工具,決定性探針改用=後續)。task=systems+reviewer。做完→to:systems merge。"
---

# dispatch：Probe.bump_sample（R² CLEAN，tiny）

spec：`docs/superpowers/specs/2026-07-21-probe-bump-sample.md`。reviewer R² **CLEAN**（全 5 審點過）。§④b「decision-bearing 聚合帶 bounded 樣本」enabler（用戶核可建工具、不建 gate）。

## ★★ branch base
- **off LOCAL main `85bb9b0c`**（禁 origin）。pre-push hook 已裝。

## 實作（`scripts/debug/probe_stats.gd`）
```gdscript
static var samples: Dictionary = {}   # event → Array[Dictionary]（≤cap 個 instance）

# 決定性聚合帶 bounded 具體案例（§④b）。★first-N cap（禁 reservoir——耗 RNG 違 observer 鐵律）。
static func bump_sample(event: String, instance: Dictionary, cap: int = 8) -> void:
    if not enabled: return
    var arr: Array = samples.get(event, [])
    if arr.size() < cap:
        arr.append(instance)
        samples[event] = arr
```
- `reset()` 加 `samples = {}`。
- `summary()` 選加樣本數印（非必要）；dump 端直讀 `Probe.samples`。

## ★★硬約束（observability 鐵律）
1. **no-RNG**：first-N cap（`size < cap` 才 append），**非 reservoir sampling**（reservoir 需 `randf`=違鐵律第 5 次）。
2. **env-gated off**：`if not enabled: return` → off byte-identical。
3. **禁改 sim state**：只寫 `Probe.samples`。
4. **instance 由 caller 傳**：Probe 不算不 re-query（不耗 RNG / 不污染 aggregate）。

## 驗收
- **TDD 4 型**：①off → no-op（samples 空）②on → append 到 cap ③cap 後不 append（first-N 非替換）④reset 清 samples。
- **determinism**：加工具 + 一處 demo sample call → on/off **byte-identical**（world+Probe counts；samples 新維度不影響既有）+ 2 跑 identical（無 RNG）。
- **gate** PASS / **headless** 0 new。**無 caller 遷移**（只加工具）。

## 完成判定 = systems + reviewer。做完 → to:systems merge（我 merge，tiny 不需 measure）。
