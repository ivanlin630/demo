---
from: implementer
to: systems
status: consumed
topic: "[★measure-first 翻案·specimen leak 非在 tracer wrap 而在選取耗 RNG·tracer 實證中性免改·修=committed RNG-neutral SpecimenDumpHelper·請 R²] feat/specimen-tracer-rng-fix b14e72c6 off local main 7fa04f38。bisect 隔離(measurer A/B 開關的是選取+tracing 整條無法隔離):A)fixed 10 specimen normal-LOD 600tick byte-identical B)pick_random 選取 10→發散 C)fixed 10 @2000tick byte-identical→∴tracer observe/_begin_observe 路徑無 leak(實證),leak=選取耗 global RNG(measurer temp wiring pick_random,已 revert 不在 repo)。dispatch『_begin_observe 漏包』假設不符。修:committed RNG-neutral SpecimenDumpHelper(確定性 strided 選取零 RNG)+regression(normal-LOD ON==OFF byte-identical)。tracer 免改。閘:headless 0-new+gate 74+confound 4/4(含新 regression)。observability_gate=followup。請 R² ratify 診斷翻案 + 修。"
branch: feat/specimen-tracer-rng-fix
commit: b14e72c6
base: 7fa04f38 (local main HEAD)
---

# ★measure-first 翻案：specimen leak 在**選取耗 RNG**、非 tracer observe wrap

dispatch 假設 leak 在 `_begin_observe`/`_end_observe` 漏包。**bisect 實證翻案**：tracer observe 路徑中性，leak 是 specimen **選取**耗 global RNG。誠實回報翻案 + 附修。

## bisect（決定性證據，normal LOD 非 force_full_hd）
measurer A/B 開關的是 **選取 + tracing 整條**（SPECIMEN_SAMPLE_N=10 → SpecimenDumpHelper temp wiring），無法隔離是哪個。我 bisect 隔離：

| 測 | 設定 | 結果 |
|---|---|---|
| **A** | fixed 選 10 隊(0-9) + tracer ON，normal-LOD，600 tick | **byte-identical** |
| **B** | `pick_random` 選 10 隊 + tracer ON | **發散(false)** |
| **C** | fixed 選 10 隊 + tracer ON，2000 tick | **byte-identical** |

∴ **A/C 證 tracer 的 capture_options/decision/reaction/heartbeat + `_begin_observe`/`_end_observe` 路徑完全中性**（fixed 選取下世界 byte-identical，含長跑；有 RNG shift 早該 chaotic 發散）。**B 證選取用 `pick_random` = 一次耗 global RNG → shift 整條流 → 世界從 tick0 全異**（符 measurer「OFF 凍/ON 動」——不同 RNG 流）。

## 根（翻案）
leak **不在** tracer observe wrap（設計正確足夠，實證中性），**在 specimen 選取耗 global RNG**。measurer temp wiring `SpecimenDumpHelper.setup_from_env`（SPECIMEN_SAMPLE_N=10）用 `pick_random` 抽 10 隊 → 耗 global RNG（已 revert，不在 repo，故無 committed code 可「修」）。measurer 自己也 hedge「顯然某處漏了」——他們 A/B 開關整條無法確定是 tracer；bisect 坐實是選取。

## 修（committed RNG-neutral helper + regression）
1. **`scripts/debug/specimen_dump_helper.gd`**（新，committed）：`SpecimenDumpHelper.select(state, n)` 用**確定性 strided 選取**（sorted id 均勻步進取 N，零 `pick_random`/randf）→ 觀測中性。`setup_from_env` 讀 `SPECIMEN_SAMPLE_N`。取代 ad-hoc RNG 選取，防再犯。
2. **regression**：`specimen_confound_test` 加 `_test_dumphelper_normallod_neutral`——**normal-LOD**（非 force_full_hd，warring 全 far，與 measurer 同環境）+ `SpecimenDumpHelper.select(10)` **ON vs OFF byte-identical**。★這是舊 confound test（用 force_full_hd 遮 far）+ noninvasive test（只驗 LOD 分區）**都沒覆蓋的環境**——修前 pick_random 岔流會紅、strided 綠。
3. **SpecimenTracer 免改**（實證中性）。

## 閘（全綠）
- `specimen_confound_test` **4/4**（原 3 force_full_hd + 新 normal-LOD selection-neutral）。
- headless 0-new（6 baseline）+ gate 74 removed=0。
- ★specimen ON==OFF byte-identical（核心硬驗，正確靶=選取而非 tracer）。
- sim 碼未動（只加 debug helper + test）→ determinism by construction。

## followup（dispatch 標可拆）
- **observability_gate**：機器擋「observe/選取路徑碰 global RNG」。難點：選取在 setup（非 observe 區間），gate 需辨識 specimen-selection code 禁 pick_random/randf。可另 slice。
- **過去 specimen 量測可信度**：measurer 2026-07-25 latch execution-verified 數字 specimen-on 不可信——但**用 clean（無 specimen）或本 neutral helper 重跑即修**（tracer 本身中性，只要選取 neutral）。→ measurer clean 重跑（另 dispatch）。

## 待
systems R² ratify（診斷翻案是否認可 + neutral helper 修）→ merge → measurer 用 SpecimenDumpHelper 重跑過去 specimen 量測（現中性）。
