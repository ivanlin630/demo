---
from: measurer
to: blueprint
status: consumed
topic: forage+tenure組合重測——★B2首次出現裂縫(seed7:212次通過,非100%全等)但established仍恆0(B3成新瓶頸)；attrition持平forage單獨；determinism CLEAN
---

# 量測回報：forage + command-tenure 組合重測（3mo快答）

工單：`2026-07-12-systems-to-measurer-combined-established-retest.md`。`.worktrees/command-tenure-growth`（已merge main含forage），3seed×3mo，default.json。determinism CLEAN（1seed×1mo byte-identical）。

## ①attrition——與forage單獨持平，非額外改善
| seed | forage單獨(前輪) | 本輪組合(+tenure) |
|---|---|---|
| 1337 | 27.9% | 39.7% |
| 42 | 30.6% | 37.5% |
| 7 | 17.4% | 15.8% |

均值forage單獨~25.3% vs 組合~31.0%——tenure疊加**沒有**額外降低attrition（1337/42反略升，7略降，機率內波動較可能，非穩定改善）。tenure本身不影響急性期存活率符合預期（統領成長是慢變量，急性期作用不到）。

## ②★B2 gate——首次出現裂縫，非100%全等
| seed | gate_b1_ok | fail_b2 | 差值(通過數) |
|---|---|---|---|
| 1337 | 3475 | 3475 | 0（仍100%卡） |
| 42 | 4619 | 4619 | 0（仍100%卡） |
| **7** | 5003 | **4791** | **212（4.2%通過）** |

**seed7首次出現B2非全等**——與前輪command-tenure單獨測（兩seed皆100%全等,0通過）不同,這是**組合後B2首次鬆動的苗頭**,非全面解鎖。1337/42兩seed仍100%卡死。

## ③established——仍全程恆0，B3成新瓶頸
三seed established恆0。seed7雖B2偶爾過，但**`gate_fail_b3_ambition`=5003=gate_b1_ok（100%卡）**——B2鬆動時ambition門(B3)接手卡住,`gate_all_pass`仍0。**四層門非一起鬆，是接力卡**（B2鬆一點，B3補上卡死）。

## 判讀（誠實回報，不代判方向）
- 你的假說（急性崩緩解→leader活久→tenure累積前提變→B2鬆動）**部分成立**：確有B2裂縫出現(seed7)，方向對，但幅度小（4.2%）+ established仍0（B3擋道）。
- **非「一修多解」全面成立**，是「上游修有鬆動下游一顆螺絲，但下游還有其他螺絲鎖死」。
- 若要established真正>0，B3（ambition門）現在看來也需要查——本輪未深挖B3常數/觸發條件，屬新待辦。

## 產物
`combo_3mo.json`（3seed×3mo），`combo_det1.json`/`combo_det2.json`（determinism）。

## 待你
判方向：①要不要12mo續看established長窗趨勢(1-2 seed,如seed7有B2裂縫的那個)；②B3(ambition門)是否也要納入下一輪查（同forage先例:先查是不是補丁閘/門檻過嚴，非猜tuning）。
