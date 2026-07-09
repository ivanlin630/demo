---
from: measurer
to: systems
status: open
topic: A2c-2 D1(015b7b1) merge-gate 全綠 + 3-month byte-identical覆核通過——可 merge
---

# A2c-2 D1 merge-gate + byte-identical 覆核結果

`.worktrees/machine-A2c2` @015b7b1（候選C FA6折入）。

## merge-gate 四項全綠
1. **constitution_gate**：`PASS (sites=30, removed=0)`（比純fold的29多1，FA6新增合理，無移除=無破契約）。
2. **framework_validation**：`PASS=7 DORMANT=0`（S1~S6全綠）。
3. **HOB**（seed=1337, 1月/7200tick, GODOT_TIMEOUT=600 無timeout）：`obey=92.7%`、`arbiter_latch=4.3% of dec(96.6% of viol)`、`leader_bypass=0 subteam_bypass=0`、**determinism PASS**（dec=15820/viol=706/ev=706 逐事件相同）。
4. **sanity**（game_sim_multi 4 config）：全跑完無SCRIPT ERROR，`InvariantSummary違反取樣總計=0`（四config皆0）。

## ★byte-identical覆核（更嚴：3seed×3月，implementer只跑1月）
D1(015b7b1) vs D0-baseline(280f0e2) pointwise diff，**3 seed(1337/42/7) × 3-month**：
- **total_diffs=3**，每seed各1處，**全部且僅**是 `probe.strat.expand_reached`（1337: 42→48, 42: 97→112, 7: 41→45）。
- **除此探針定義精化外，全metric 0 diff**——與 implementer 1-month 3seed聲稱一致，3-month更長窗覆核依然成立。

## 誠實揭露（非本slice相關）
D0-baseline(280f0e2) dump 時出現 pre-existing `SCRIPT ERROR: Out of bounds get index '50' (on base: Dictionary)` @`faction_ai_system.gd:1057 _precond_met`——與 A2c1 那輪 main-baseline 遇到的同一類異常同源（舊commit上重現，D1新commit不重現）。判讀：既有dict成長側效應蓋掉的老bug，與本slice無關，未深追（非本工單範圍）。

**merge-gate 綠 + byte-identical 覆核通過（3-month更嚴窗仍成立）。可 merge 015b7b1。**
