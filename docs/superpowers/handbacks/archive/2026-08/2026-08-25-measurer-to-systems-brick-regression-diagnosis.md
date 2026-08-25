---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "★★★診斷①：紮根本身0次被failure-memory折價過(18個suppressed structural id裡沒有『紮根』)——假說在字面意義上不成立；紮根輸給build_workshop/apothecary/stable的懸殊差距(root_u 0.09~0.14 vs winner_u 1.395,10~40倍)是紮根自己baseline util結構性偏低，非被壓下去；少數近戰(紮營vs紮根<2%差距)裡若suppression有方向性影響，也是幫紮根而非害紮根；★★★診斷②：漏斗won=2→start=1→complete=0→l0_to_l1=0，是第三種結果(不是沒贏也不是won>0但start=0)——斷點在【施工本身】從未完工，不在argmax或commit/仲裁端；regression真根因看起來不是『折價反傷探索』，比較像紮根天生util打不過同地點facility候選+施工完成率問題，兩者都需要main baseline同款tap才能完整對比(本輪main沒有這兩個新tap)"
---

# 兩個診斷：假說在字面意義上不成立，但regression另有更精確的樣貌

## ★★★診斷①：紮根0次被折價

`decision.opt_applicable.紮根=81`，`root.won_argmax=2`。18個suppressed structural id(`build_workshop=140` `build_apothecary=134` `build_stable=35` `建設=10` `紮營=47` `求和=92`等)裡**沒有『紮根』**——紮根這個structural id90天內0次被failure-memory折價。

**假說『紮根一失敗就被折價』字面上不成立。**

### util差距的真實樣貌

- **壓倒性輸(10~40倍，佔多數)**：主要是team5對build_workshop/apothecary/stable(同一地點(8,6)的兄弟facility候選)——`root_u`穩定0.09~0.14，對手`winner_u`穩定1.395。這是紮根自己baseline util偏低的結構性劣勢，**不是被壓下去的**(紮根0次被折價)。
- **近乎打平(<2%，罕見但存在)**：team5對紮營`1.664 vs 1.674`，team27對紮營`1.116/1.137`、`1.635/1.638`。★『紮營』本身被折價47次——若紮營未被折價，util只會更高(讓紮根輸更多非更少)。**suppression在這些近戰案例的方向性，若有影響，是幫紮根而非害紮根。**

### 判讀

regression的真根因看起來**不是**「折價反傷紮根的探索」，比較像「紮根天生util打不過同地點facility候選」這個結構性劣勢——這件事在main baseline(舊表時代)應該也存在，紮根從沒被特別優待過。★需要main baseline同款matchup的root_u/winner_u才能完整對比，本輪main沒有這兩個新tap，供你裁要不要追加。

## ★★★診斷②：won→start→complete漏斗，第三種結果

`root.won_argmax=2 → settlement.l0_to_l1_start=1 → construct.complete_crude_camp=0 → outpost.l0_to_l1=0`

**不是**「連argmax都沒贏」(won=2>0)，也**不是**「won>0但start=0」(start=1>0)——是第三種：贏了2次、其中1次真的開工、但**90天內從未完工過一次**。斷點不在argmax也不在commit/仲裁端(那道門過了)，是在**施工本身**。

需要另外查`construction_ticks_left`/`construct.stall`/`construct.timeout_cancel`看那個工地是卡住、被放棄、還是單純還沒蓋完(day90時仍在途中/censored，非真失敗)——本輪沒深挖，供你裁要不要另開一輪。

## 落地

`.measure.json`：`docs/process/verdicts/brick-regression-diagnosis.measure.json` @6c34a952(main) 2026-08-25

## L3聲明

`decision_engine.gd`的`root.lost_to.pair` sample擴充`root_u`/`winner_u`兩欄(1行)；`camp_access_diag_bed.gd`加診斷①②報表段。皆Probe-gated零行為改動。
