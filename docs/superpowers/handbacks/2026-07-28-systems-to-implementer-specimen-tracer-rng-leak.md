---
from: systems
to: implementer
status: consumed
topic: "[★高優先基礎設施 bug·SpecimenTracer/SpecimenDumpHelper 洩漏 RNG/state 擾動世界·違觀測禁擾動鐵律·measurer A/B 坐實(同 5b166eb1+seed1337+worktree,唯一變因 specimen on/off:OFF 凍 attrition1.35% vs ON 動9.0%)·影響過去所有 specimen-enabled 量測可信度·查 _begin_observe/_end_observe 漏包點修+specimen on/off byte-identical 驗] specimen tracing 改世界=observer 污染,範圍比 latch 大。明確 bug 直接查修。"
branch: feat/specimen-tracer-rng-fix (新 worktree)
---

# 實作：SpecimenTracer RNG/state 洩漏查修（高優先基礎設施 bug）

## bug 坐實（measurer isolated A/B）
同 commit 5b166eb1 + 同 seed1337 + 同 worktree，**唯一變因 specimen on/off**：
- specimen **OFF** → 世界凍（attrition 1.35%，teams=71/pop=438 三月不變）。
- specimen **ON**（SpecimenDumpHelper temp wiring，SPECIMEN_SAMPLE_N=10）→ 世界動（attrition 9.0%@month3，teams 72→77/pop 440→404）。
∴ **SpecimenTracer/SpecimenDumpHelper 觀測改變被觀測世界** = 違「觀測禁擾動世界／禁耗 global RNG」鐵律（memory `feedback_observer_no_global_rng`）。儘管 code 有 `_begin_observe`/`_end_observe` suppression 設計，**某處漏包**。**影響過去所有 specimen-enabled 量測可信度**（範圍大）。

## 查修（明確 bug，無設計選擇→直接修）
1. **找洩漏點**：grep `SpecimenTracer`/`SpecimenDumpHelper`/`capture_decision`/`_begin_observe`/`_end_observe`。找 observe/capture 路徑中**耗 global RNG（randf/randi/pick_random/shuffle）或改 sim state** 但**沒被 `_begin_observe`/`_end_observe` suppression 包住**的地方。候選：sample 選取（若用 randf 抽樣 = reservoir，違禁；該 first-N 確定性）、instance 重 query sim、任何 observe 中呼叫會耗 RNG 的 helper。
2. **修**：漏包點納入 suppression（`_begin_observe`…`_end_observe` 包住），或改確定性（first-N cap 非 reservoir、預存 payload 非 re-query）。對齊既有 `Probe.bump_sample`（probe_stats.gd：first-N cap、禁 reservoir、caller 傳 instance 不 re-query）。
3. **★驗（硬）**：**specimen ON vs specimen OFF 三跑各 byte-identical + ON==OFF 世界軌跡一致**（curve/attrition 同）——這才證 observer 中性（非只自己 3 跑同）。seed1337+42。

## observability_gate 補（★機器擋，mem0 reference）
「觀測探針碰 RNG/改 state」該機器擋（第 N 次同族=人肉抓不可靠）。查 `constitution_gate`（有 rng 類 site）為何沒攔 observe-path 碰 RNG → 補一條 gate：observe/tracer 路徑（`_begin_observe` 區間 or tracer func）禁 randf/randi/state-write。這防未來重蹈。**若 gate 補是另一 slice 可拆**（先修洩漏 unblock 量測，gate 補 followup）。

## 閘 + 交付
- headless 0-new + gate（sites 數看 gate 補與否）+ ★specimen ON==OFF byte-identical 世界一致（核心驗）。
- handback `to:systems`：洩漏點 file:line + 修法 + ON==OFF 驗結果。→ R² → merge。**這 unblock 過去 specimen 量測可信度 + 餵持守統一觀測中性**。

## 連帶（measurer 已標，不本刀）
measurer 2026-07-25「latch execution-verified」數字全 specimen-on 不可信 → 修後 clean 重跑（另 dispatch）。2026-07-26「build=0+凍結」沒開 specimen、結論站（clarify 獨立佐證 clean=凍）。material PARK。
