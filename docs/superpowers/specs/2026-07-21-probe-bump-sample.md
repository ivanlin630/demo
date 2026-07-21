# spec：Probe.bump_sample —— decision-bearing 聚合帶 bounded 樣本工具

> 層級：L3（+1 var +1 func +reset 一行，tiny tooling）。§④b 協議 enabler。off LOCAL main。
> 用戶核可 2026-07-21（建工具、不建 gate）。動機：sell_no_surplus 聚合誤讀 food/goods（[[feedback_fileline_vs_interpretation]]）。

## 目標
`Probe`（`scripts/debug/probe_stats.gd`）加 `bump_sample`：計數 key 旁存 ≤N 個具體 instance，落 fullprobe 供決策帶故事。

## 實作
```gdscript
static var samples: Dictionary = {}   # event → Array[Dictionary]（≤cap 個 instance）

# 決定性聚合帶 bounded 具體案例（§④b）。first-N cap（★禁 reservoir——耗 RNG 違 observer 鐵律）。
static func bump_sample(event: String, instance: Dictionary, cap: int = 8) -> void:
    if not enabled: return
    var arr: Array = samples.get(event, [])
    if arr.size() < cap:
        arr.append(instance)
        samples[event] = arr
```
- `reset()` 加 `samples = {}`。
- `summary()` 選加：印每 event 樣本數（`samples.<k>.size()`）——非必要，dump 端（measure bed）直讀 `Probe.samples` serialize 進 `fullprobe.json` 的 `samples.<key>`。

## ★★守則（observability 鐵律，硬約束）
1. **env-gated**：`if not enabled: return`（同 bump）→ off = **byte-identical**（sim 不讀 Probe）。
2. **★禁 RNG**：first-N cap（size<cap 才 append），**非 reservoir sampling**（reservoir 需 randf=違 [[feedback_observer_no_global_rng]] 鐵律，第 5 次同族）。純確定性。
3. **禁改 sim state**：只寫 `Probe.samples`（觀測用途）。
4. instance dict 由 caller 傳（`{tick, team, res, ...}`），Probe 不算不查（不 re-query 耗 RNG/污染）。

## 驗收
- **TDD**：①enabled=false → bump_sample no-op（samples 空）②enabled=true → append 到 cap 停③cap 後不再 append（first-N 非替換）④reset 清 samples。
- **determinism**：加此工具 + 一處 sample call（demo），specimen/probe **on/off byte-identical**（world + Probe counts；samples 是新增維度不影響既有）+ 2 跑 identical（無 RNG）。
- **gate** PASS（constitution_gate 不受影響）/ **headless** 0 new。
- **無 caller 遷移**：本 slice 只加工具，不改既有探針（決定性探針改用 bump_sample = 後續按需，非本 slice）。

## 排序
tiny，off LOCAL main。R²（★no-RNG first-N + off byte-identical 驗）→ dispatch。做完 → to:measurer（可用於 weapon-facility measure 或後續）。
