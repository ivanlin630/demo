---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·Probe.bump_sample·CLEAN] tiny 觀測工具全 5 審點過:①no-RNG first-N cap(size<cap 才 append,非 reservoir=零 randf,守 observer-no-rng 鐵律第5次)②env-gated off byte-identical③只寫 Probe.samples 禁改 sim state④instance caller 傳 Probe 不 re-query⑤reset 清 samples。對齊既有 bump/note/add_amount 慣例。無 caller 遷移。CLEAN→dispatch。"
---

# R² verdict：Probe.bump_sample（觀測工具，tiny）

**VERDICT: CLEAN** — 可 dispatch。`premise_contradiction: false`。tiny observability 工具，正確守 observability 鐵律。factcheck 對 HEAD（probe_stats.gd 現況）。

## 5 審點逐一（對照既有 Probe 慣例）
1. **★no-RNG = first-N cap → CLEAN**。`if arr.size() < cap: arr.append(instance)` = **append 到 cap 停**（first-N），**零 randf**。**非 reservoir sampling**（reservoir 需 randf 決定替換=違 [[feedback_observer_no_global_rng]] 鐵律，spec 明拒=第 5 次同族正確避開）。純確定性。
2. **★env-gated off byte-identical → CLEAN**。`if not enabled: return`（同 `bump:12`/`note`/`add_amount` 慣例）。off（default false）= no-op → sim 不讀 Probe → byte-identical。
3. **禁改 sim state → CLEAN**。只寫 `Probe.samples`（static var，觀測用）；不碰 WorldState/teams。observation-only。
4. **instance caller 傳、Probe 不 re-query → CLEAN**。`instance: Dictionary` 由 caller 預建傳入，Probe 純 append，**不 re-query state**（不耗 RNG/不污染被觀測物）——這正是 observer 鐵律的關鍵（觀測不改被觀測）。
5. **reset 清 samples → CLEAN**。`reset()` 加 `samples = {}`（對齊 `counts/peaks/amounts` 清法）。

## 其餘
- **TDD 4 型**（off no-op / append-to-cap / cap-stop-first-N-非替換 / reset 清）+ **determinism on/off byte-identical + 2 跑 identical** → 覆蓋充分。samples 是新增維度不影響既有 world/counts。
- **無 caller 遷移**（只加工具，既有探針按需後遷）→ 最小 scope，零行為改。
- **GDScript array-by-ref 細節（非 blocker）**：`arr = samples.get(event, [])` 對既有 event 拿 reference→`append` 原地改→`samples[event]=arr` 冗餘但無害；新 event 拿 fresh `[]`→append→存。兩路正確。

## 回覆
CLEAN → dispatch implementer。impl pre-merge R²（tiny）重點：①first-N（size<cap）非 reservoir、零 randf ②`if not enabled: return` 首行 ③reset 加 samples ④determinism on/off byte-identical 測綠。做完 to:measurer（§④b：聚合帶具體 instance 供決策帶故事，治 sell_no_surplus 型聚合誤讀）。

——正確守 observer-no-rng（first-N 非 reservoir）= 這族第 5 次教訓已內化進工具設計本身。tiny slice，範式一致，無驚喜。
