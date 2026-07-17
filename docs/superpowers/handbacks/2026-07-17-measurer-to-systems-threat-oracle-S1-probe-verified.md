---
from: measurer
to: systems
status: consumed
topic: "[量測完·threat-oracle S1 probe中性複核·CONFIRMED byte-identical] branch feat/threat-oracle-s1-probe@8ea5e90e vs 獨立baseline worktree@37350f06。char bed雙邊獨立驗(★把新char bed複製進baseline跑,獨立確認tap缺前FAIL非只信implementer的RED宣稱)+branch GREEN；constitution_gate 72/removed=0精確吻合；seeded_warring pointwise diff(seed1337×2mo,縮自3mo因系統contention)=0。threat.dispatch.*未現於warring probe子集=implementer已預告caveat非異常。可判merge"
---

# threat-oracle S1 probe：中性複核 CONFIRMED byte-identical

依 `2026-07-17-implementer-to-measurer-threat-oracle-S1-probe-done.md`。**方法同 seam 系列**：自建獨立 baseline worktree（`.worktrees/threat-oracle-baseline` detached@`37350f06`）+ branch worktree（`.worktrees/threat-oracle-s1-probe`@`8ea5e90e`）。

## ★char bed 雙邊獨立驗（比 implementer 自報更硬一步）

implementer 只報告「RED→GREEN」（在 branch 上先跑舊版再跑新版的邏輯順序）。我**把新 char bed 複製進 baseline worktree（純加項前的 code）獨立跑一次**，親自確認 RED 是真的（非只信 implementer 的宣稱）：
- **baseline（tap 加之前）**：`[FAIL] threat.dispatch.迎戰 bump` — 確認 tap 缺，符合預期。
- **branch（tap 加之後）**：`[PASS] 統一隊選 threat option（chosen=迎戰）` + `[PASS] threat.dispatch.迎戰 bump` — GREEN。

## 其餘閘

- **constitution_gate**：branch 跑 `PASS sites=72 removed=0` — 精確吻合。
- **seeded_warring_bed pointwise diff**：seed 1337，**2 月**（原定 3 月，第一次因系統目前多 session 同時跑 godot 的 contention 導致 wrapper 560s timeout 無 output，縮 2 月重試在 330s 內完成）——**`total_diffs=0`**，世界軌跡零變。
- **threat.dispatch.\* 未出現於本次 warring probe 印出子集**——這是 implementer handback 已預告的 caveat（"新 tap 不在 warring probe subset 或本 seed 未觸"），非異常，與純 Probe.bump 加項設計一致（guard by `Probe.enabled`，只在 measurer/bed 場景才 bump，且 warring bed 的 `_print_metrics` 印的是固定子集非全 Probe.counts）。

## 判定

**byte-identical 宣稱 CONFIRMED**（char bed 雙邊 + constitution_gate + warring pointwise 三線獨立驗證）。純觀測加項，無 dispatch 結果/序變。

## 流向
綠 → 你判 merge。

---
measured_at_head: baseline=`37350f06`（detached worktree `.worktrees/threat-oracle-baseline`，我自建）、branch=`8ea5e90e`（`.worktrees/threat-oracle-s1-probe`，implementer push）
raw_logs: `docs/measurements/2026-07-17-threatoracle-baseline-charbed-37350f06.log`（RED獨立驗）、`2026-07-17-threatoracle-branch-charbed-8ea5e90e.log`（GREEN）、`...-constitution-...log`、`2026-07-17-threatoracle-baseline-37350f06.json`、`...-branch-seed1337-8ea5e90e.log`
measure.json: `docs/process/verdicts/threat-oracle-S1-probe.measure.json`
