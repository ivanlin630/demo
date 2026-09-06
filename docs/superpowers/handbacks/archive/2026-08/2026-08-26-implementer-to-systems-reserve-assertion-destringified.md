---
from: implementer
to: systems
status: consumed
slice: reserve-assertion-destringify
tier: probe
topic: ★交付 @033933e8:四條關係斷言取代手抄公式,床 ALL PASS ⇒ 那條從 baseline【消失】(0 vs 0)、fp 不變;★★★第④條是重點——把「炸掉舊斷言的隱形機制」變成被斷言的對象,而不是繞開它
---

# 交付 — 手抄公式的斷言拆掉

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\reserve-assert`／`feat/reserve-assertion-destringify` |
| **commit** | `033933e8` |
| **改的檔** | `scripts/debug/survival_layer_unify_test.gd`＋`docs/test-baseline-survival_layer_unify_test.txt`（★**production 零改動**） |

## ★四條斷言（**零魔數**，公式怎麼改都成立、公式被【繞過】才會紅）
| # | 斷言 | 實測 |
|---|---|---|
| ① **單一源** | `reserve(food)` **就是** `NeedOracle.need_keep`（不是「約等於」） | PASS |
| ② **對人口線性** | pop 10→20 ⇒ reserve ×2 | `96 → 192` PASS |
| ③ **人格化的定義** | `r_caut / r_neut` ＝ `food_security_target` 的比值（★**共用常數在比值裡相消**） | `2.000 vs 2.000` PASS |
| ★④ **飢餓升壓有方向** | 同人格同人口，**餓隊留底 > 飽隊留底** | `96 > 32` PASS |

★★★**第④條是這票的重點**：**那個 ×3 的 famine escalation 原本是【隱形的】——
它不是被斷言的對象，只是默默把舊斷言炸掉。** ⇒ ★**現在它自己變成一條斷言**：
**機制沒有被繞開，而是被寫進了測試要保護的東西裡。**
（★**這也回答了「為什麼不改成 96」**：改成 96 是**繞開**它；斷言「餓的比飽的高」是**承認**它。）

## ★驗收三條
| 條 | 判準 | 實測 |
|---|---|---|
| ① | 該床 baseline **少一條**（★**消失，不是改類別**） | ✅ 床 **ALL PASS** ⇒ 條目移除 ⇒ 閘 **baseline=0 實測=0 PASS** |
| ② | `fp` 不變（純測試改動） | ✅ **`5c1fa2fce6c6aa01135d961371693d39`**，與 main 相同 |
| ③ | 閘 PASS | ✅ 見上（含 `[TEST-SUITE-COMPLETE]`，Q1=YES） |

## ★沒做 / 邊界
- **`tools_demand_test` 那條 `stale-test` 沒動** —— **你只派了這一條。**
  ★**若要一起拆，它的修法不同**：那條不是手抄公式，是**斷言了一個被授權改掉的值**
  ⇒ **修法是「跟上真值」或「改斷言【兩個設施同族同價】這個關係」**，★**後者才不會再爛一次**（同族＝關係）。**要不要做你派。**
- **`scripts/simulation/` 一行未動。**

## ★一件小事回報
★**舊註解「中性 = target(4) × pop(10) × 0.8 = 32」我沒有留著當歷史** —— **它是錯的**（真值 96），
留著會讓下一個人以為那是規格。★**改成講「為什麼不寫死數字」的註解。**
