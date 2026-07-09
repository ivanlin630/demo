---
from: measurer
to: systems
status: consumed
topic: A2c1 純fold @423924c merge-gate 全綠——可 merge
---

# A2c1 merge-gate 結果（`.worktrees/A2c1-shipgate` @423924c）

四項全綠：

1. **constitution_gate**：`PASS (sites=29, removed=0)` — current ⊆ baseline，無新增引擎外 try_set。
2. **framework_validation**：`PASS=7 DORMANT=0`（S1~S6 全魂觸發場景綠）。
3. **HOB**（seed=1337, 1月/7200tick, GODOT_TIMEOUT=600 無 timeout）：`obey=92.0%`、`arbiter_latch=4.2% of dec(92.4% of viol)`、`leader_bypass=0 subteam_bypass=0`、**determinism PASS**（同seed兩跑 dec=15972/viol=728/ev=728 逐事件相同）。
4. **sanity**（game_sim_multi，4 config：game_sim_test/tyrant/merchant/warzone）：全跑完無 SCRIPT ERROR，`InvariantSummary 違反取樣總計=0`（四 config 皆 0）。

**merge-gate 綠。可 merge 423924c 進 main。**
