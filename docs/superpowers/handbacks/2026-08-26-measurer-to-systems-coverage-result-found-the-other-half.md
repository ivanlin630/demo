---
from: measurer
to: systems
status: consumed
slice: perf-spike-coverage
topic: "覆蓋率驗完：86.5~96.5%,不是大盲區。★★★真正的『另一半』找到名字了——loop3.orders_ambition(AmbitionLadder.update+OrderSystem.tick_team_orders,faction_ai_system.gd:843-849)，tick9量級跟loop1.factions幾乎相當(29.4% vs 32.9%)，完全獨立不含unified.*子孫，先前沒人看"
---

# ★頂層label分類（file:line坐實，非猜）

**頂層（互斥不巢狀，直接加總）**：`loop1.factions`(:760)、`loop2.solo`(:780)、`loop2.indep_strategy`(:778)、
`loop2.member_strategy`(:797)、`loop2b.merge`(:827)、`loop3.orders_ambition`(:850)、`loop3.survival`(:857)、
`loop3.prosperity`(:865)、`loop3.pursuit`(:868)、`loop3.threat`(:871)、`loop3.outpost`(:923)、`loop3.misc`(:950)。

**巢狀（排除，已計入上面）**：`loop1`的其他5個子階段、`assign.*`、`unified.*`、`member.unified`、`gather.*`(8種)、`indep.weakest_prey`。

---

# ★★★覆蓋率：86.5~96.5%，不是大盲區

| tick | dt_us | 頂層加總us | 覆蓋率 | gap |
|---|---|---|---|---|
| 9 | 79,185,958 | 68,727,310 | 86.8% | 13.2% |
| 19 | 2,731,163 | 2,362,060 | 86.5% | 13.5% |
| 29 | 5,755,175 | 5,553,290 | 96.5% | 3.5% |

★剩下 3.5~13.5% 的 gap 可能是迴圈迭代開銷/`beast_kind`檢查/`extinct`清理等未掛`_fai_pht`的小段，
**不是「一大塊看不見的成本」**。

---

# ★★★★真正的「另一半」找到名字了

**tick9 範例**：
| label | us | % 整tick |
|---|---|---|
| `loop1.factions`（含unified.rank等全部子孫） | 26,082,520 | 32.9% |
| **`loop3.orders_ambition`（完全獨立）** | **23,294,211** | **29.4%** |
| `loop2.solo` | 13,211,187 | 16.7% |
| `loop3.threat` | 5,086,665 | 6.4% |

★★★**`loop3.orders_ambition` 跟 `loop1.factions` 量級幾乎相當**——**這才是那「56.3%」的主要組成**，
不是儀器盲區。

`faction_ai_system.gd:843-849`：
```gdscript
if team.leader_id != -1 and state.world.current_tick >= team.ambition_eval_next_tick:
    AmbitionLadder.update(state, team)
if team.leader_id != -1 and state.world.current_tick >= team.order_eval_next_tick:
    OrderSystem.new().tick_team_orders(state, team)
```
對**每一個**`team.leader_id != -1`在 cadence 到期時執行，跟 `unified.rank` **完全不同的程式碼路徑**，
不含任何 `unified.*` 子孫。

⇒ **56.3%的「另一半」主要是 `loop3.orders_ambition`（訂單cadence+野心階梯更新）跟 `loop2.solo`
（獨立隊策略評估）——這兩個完全獨立、已有名字、已在計時，只是先前沒人看。**

---

# 落地
`docs/process/verdicts/perf-spike-coverage.measure.json`
raw: `docs/measurements/perf-coverage-smoketest.txt.checkpoint.perf_scale.txt`（tick9/19/29 完整34-label dump）
床改動：`scripts/debug/perf_scaling_curve_bed.gd`（dump完整_fai_ph字典，L3純觀測既有static dict）
