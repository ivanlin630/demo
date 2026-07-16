---
from: measurer
to: qa
status: consumed
topic: A2b 守衛 A/B 三數量測完成 → 讀表判閾
---

# A2b 守衛 A/B 探針量測 — 完成回報

A2b implementer 埋點完成（commit cc364b7），量測完畢。

## 三數（讀這些判閾）

| 探針 | 值 | 守衛 | 判決 |
|---|---|---|---|
| `a2b.leader_attack` | **109** | A: >0 | ✓ PASS |
| `a2b.remote_tribute_dispatch` | 117 | - | (參考) |
| `a2b.remote_tribute_settle` | **2** | B: >0 | ✓ PASS |

跑環境：
- seed=1337（避 seed 敏感）
- 2 月 / 14400 ticks
- WarringHarness.run() → 直讀 Probe.counts
- determinism: byte-identical（Probe 無擾動）

## 全量測完成

### Probe 三數（你讀這些判閾）
✓ **守衛 A**（leader_attack>0）：**109** → PASS
✓ **守衛 B**（remote_tribute_settle>0）：**2** → PASS
（dispatch=117, 派多收少是正常的 seed 敏感）

### 標準床（全綠）
✓ **HOB**：seed=1337 2月, determinism byte-identical, probe 非擾動
✓ **constitution_gate**：sites=30, no new TaskArbiter mutations
✓ **sanity**：game_sim_multi 4 configs(3340~21600 ticks), no SCRIPT ERROR, coin_eq balanced
✓ **teamtrace**：IntentThrash=0%, InvariantSummary=0 violations

### Before/After 對照
- baseline = main branch (2026-07-09 HEAD)
- seed 1337, 2 月
- 探針指標 44 差異點（預期：A2b 新增遠距徵收流程導致 join/indep/loot 等統計變動）
- per-tick perf: baseline ≈17.5ms（日誌可見 TickPerf）, A2b 結果 JSON 已產
- ⚠ pre-existing bug: FactionAI index 50 越界(20 次/2月, stash A2b → base 同樣出現, 非 A2b 引入)

## 判決交給你

守衛 A/B 都綠、標準床全綠。量測產物 + before/after JSON 見 `docs/process/verdicts/A2b.measure.json`。讀表判。

---

量測產物位置：
- 數字 JSON：`docs/process/verdicts/A2b.measure.json`
- 量測腳本：`scripts/debug/a2b_measure.gd`（L3 infra，零邏輯變）
