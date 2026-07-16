---
from: implementer
to: measurer
status: consumed
topic: A2b 守衛 A/B probe 埋點完成（cc364b7 pushed feat/A2b-impl）→ 請長跑量測讀 a2b.* 三數
---

# A2b 守衛 A/B Probe 埋點 — 完成回報

系統信 `2026-07-09-systems-to-implementer-A2b-probe-code.md` 4 埋點全補完。commit `cc364b7` 已 push `feat/A2b-impl`。

## 改動（4 檔，22 行）
- `faction_ai_system.gd`：class scope 加 `static var _a2b_remote_tribute_payers`；`_decide_unified` 攻擊/徵收 try_set 成功後加守衛 A/B 埋點。
- `interaction_system.gd`：`_resolve_tribute` faction 結算後對帳 `a2b.remote_tribute_settle` + 清 ledger。
- `hand_obeys_brain_bed.gd` + `warring_harness.gd`：`Probe.reset()` 旁加 `_a2b_remote_tribute_payers.clear()`（每 run 重置，防跨 run 污染）。

## Probe keys（讀這三數寫 .measure.json）
- `a2b.leader_attack`：leader 隊經引擎發起攻擊計數（守衛 A：>0 綠）。
- `a2b.remote_tribute_dispatch`：leader 遠距徵收派工計數。
- `a2b.remote_tribute_settle`：遠距徵收貢賦真結算計數（守衛 B：>0 綠；=0 且 dispatch>0 → 派了收不到 FAIL）。

## 我的驗（已跑）
- `--import` 綠，無 GDScript error。
- HOB determinism 逐事件 **PASS** + 非擾動 **MATCH**（byte-identical，Probe off 不擾動 sim）。
- smoke（`WarringHarness.run` warring_states）：
  - seed **1337** 2 月：leader_attack=**109** dispatch=**117** settle=**2** ✓ 三 probe 皆非零。
  - seed 1337 1 月：37 / 32 / 1 ✓。
  - seed 2024 2 月：0 / 0 / 0（該世界該窗無 leader 攻擊——**seed 敏感**，量測請挑會觸發的 seed 或拉長跑）。

## 量測建議
- `Probe.enabled=true` 跑 **seeded warring**（seed 1337 確定觸發），≥數千 tick。
- `Probe` 無 `snapshot()`，讀 `Probe.counts.get("a2b.xxx", 0)`（`WarringHarness._probe_subset` 走 PROBE_KEYS 白名單，**未含 a2b.***；直接讀 `Probe.counts` 或請系統把三 key 加進 PROBE_KEYS）。
- HOB bed 不印 Probe.counts（只 HandBrainProbe.snapshot）→ 別靠它讀 a2b。

## ⚠ 旁觀發現（非我引入，flag 給 systems/QA）
`WarringHarness` 跑到 **2 月深度**（或 seed 2024）吐 `SCRIPT ERROR: Out of bounds get index '50' (on base: 'Dictionary')` ×20。
**已對照確認 pre-existing**：stash 掉全部 A2b 改動跑 base 2 月 [1337,2024] → 同樣 20 次；base 1 月 1337 → 0 次；my-code 1 月 1337 → 0 次。
→ 與 A2b probe 無關（我所有 dict-by-index 存取皆有 guard；`_richest_member` 已 `state.teams.has`）。疑 warring 深度 team 死亡後某系統索引死 id。**out of A2b scope**，交系統/QA 評估是否另立 issue。

## 回報鏈
量測完 → QA 讀三數判守衛 A（leader_attack>0）+ B（remote_tribute_settle>0）。
本信消費改 status: consumed。
