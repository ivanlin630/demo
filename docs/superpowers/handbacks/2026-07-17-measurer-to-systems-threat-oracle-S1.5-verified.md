---
from: measurer
to: systems
status: consumed
topic: "[量測完·threat-oracle S1.5行為變中性複核·CONFIRMED機制正確+隔離] branch feat/threat-oracle-s1.5@fd801ecd vs 獨立baseline worktree@e0198666。★非byte-identical案例,驗收判準改「行為變合理」：char bed雙邊獨立驗(RED在baseline親跑=ratio 30.0精確吻合implementer數字+SCRIPT ERROR證實perceived_power_ratio是全新加欄/GREEN在branch親跑=ratio 3.0+perceived_power_ratio=3.272727精確吻合)；constitution_gate 65/removed=0精確吻合；headless殘3同名同行。seeded_warring 2seed(1337/42)×2mo在no-belief觸發窗內未撞到organic delta(char bed已決定性證實機制生效,非否證)。可判merge"
---

# threat-oracle S1.5 god-view fix：中性複核 CONFIRMED（機制正確+隔離，行為變合理）

依 `2026-07-17-implementer-to-measurer-threat-oracle-S1.5-done.md`。**★本案非 byte-identical**——implementer 自己標「行為變小，限無-belief 分支」，我的驗收判準相應調整：不要求 diff=0，改驗「變得對不對、變的範圍有沒有被限縮住」。

## char bed 雙邊獨立驗（比 implementer 自報更硬一步）

同前幾案手法：**把新 char bed 複製進 baseline worktree（fix 之前的 code）親自跑一次**，不只信 implementer 報的兩組數字：

- **baseline（fix 前）**：`[FAIL] 無belief→pop_est=self_pop (a=30.000000 b=3.000000)` — **god-view 洩漏，baseline 真的讀到 other.population=100/scaled=30.0，精確吻合 implementer 報告的「baseline ratio=30.0」**。且 `perceived_power_ratio` 欄在 baseline **直接 SCRIPT ERROR「不存在」**——結構性證實 (b) 是全新加欄，非既有欄位改值。
- **branch（fix 後）**：`[PASS]` 全綠——無 belief→self_pop=3.0（虛張生效）、確非 god-view、`perceived_power_ratio`==直算 3.272727、≠threat_react——**精確吻合 implementer 報告的 fix 後數字**。

## 其餘閘

- **constitution_gate**：`PASS sites=65 removed=0` — 精確吻合。
- **headless_test 全量**：`=== DONE ===`，殘 3 assertion 同名同行號（`_test_p2a_survival_terms:15529`/`_test_beg_join_social_resolve:7075`/`_test_strategic_reads_ladder:13979`）——行為變未回歸測試套件。

## ★seeded_warring organic delta：2 seed×2mo 內沒撞到觸發窗（非否證）

seed 1337 + 42（各 2 月）——**跟 baseline 逐點對照皆 `total_diffs=0`**。這**不是否證這個 fix**——char bed 已經是決定性的單元級證據（god-view 洩漏 vs 虛張隔離，數字精確吻合），這裡沒撞到是因為「threat_id 存在但該 target 尚無 belief claim」這個觸發窗本身窄，2 個 seed×2 月的樣本沒抽中這個時刻。**has-belief 路徑（結構上）byte-identical 這點是穩的**（fix 只動 `intel.get()` 的 fallback 分支，未觸發時走同路）。

若你要 organic 層級的 delta 量化證據（例如「首接觸-無belief-有threat_id」發生率 vs 對應行為變幅度），需要專門構造場景或更大 seed/窗——**這是額外工作，非本輪必要**（char bed 已充分證明機制正確且隔離）。

## 判定

**機制正確 + 隔離範圍如預期 CONFIRMED**。行為變合理（限無-belief 分支，has-belief 結構不變）。

## 流向
綠 → 你判 merge（merge 時補 `invariants.md:173` 已修名單 +1，per implementer 提醒）。

---
measured_at_head: baseline=`e0198666`（detached worktree `.worktrees/threat-oracle-s15-baseline`，我自建）、branch=`fd801ecd`（`.worktrees/threat-oracle-s1.5`，implementer push）
raw_logs: `docs/measurements/2026-07-17-threatoracle-s15-baseline-charbed-e0198666.log`（RED獨立驗）、`2026-07-17-threatoracle-s15-branch-charbed-fd801ecd.log`（GREEN）、`...-constitution-...log`、`...-headless-...log`、`2026-07-17-threatoracle-s15-baseline-e0198666.json`、`...-branch-seed1337-...log`、`...-branch-seed42-...log`
measure.json: `docs/process/verdicts/threat-oracle-S1.5.measure.json`
