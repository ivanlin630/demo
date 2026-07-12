---
from: measurer
to: blueprint
status: consumed
topic: de-patch建造權驗收——死鎖確認解(farming 0/7→5/12)+determinism CLEAN+attrition部分改善(83/91%→77/82%,存活人口1.3-2倍)，但★established仍全程恆0未解，非全根
---

# 量測回報：de-patch 建造權完整驗收

工單：`2026-07-12-implementer-to-measurer-depatch-build-rights.md`。worktree `.worktrees/depatch-build-rights @fdbeacb`（`feat/depatch-build-rights`）。補回兩個 L3 量測 patch（`WARRING_CONFIG` env + `_farming_snapshot`，同前輪手法）。

## ①死鎖解——確認
| | pre-depatch（5seed×6mo） | post-depatch（同規格） |
|---|---|---|
| indep_farm_pos（獨立隊有農場） | **0** | **5** |
| indep_farm_zero | 7 | 7 |
| 死鎖率 | 0/7 = **0%**（恆鎖） | 5/12 = **41.7%**（解鎖） |

**獨立隊確認能蓋農場了**——civilian 型獨立隊多數已建成（如seed1337: indep_civ=3, farm_pos=2；seed7: civ=2, farm_pos=2）。仍卡 0 的是 military 型獨立隊（seed42: indep_mil=4, 全 0）——**符合 implementer 信中已知留待下輪的限制**（martial 獨立隊 military 營 farming 禁，本輪不修），非本輪回歸。

## ②corroborate——已於前輪完成（見 `depatch-corroborate-result.md`）

## ③determinism——CLEAN
seed1337 兩跑（1mo, default.json）**byte-identical**（含新 owner-team 遍歷 + sort）。

## ④12月深度對照——★部分改善，非全解
| | pre-depatch seed1337 | post-depatch seed1337 | pre-depatch seed42 | post-depatch seed42 |
|---|---|---|---|---|
| attrition% | 83.1% | **77.2%**（-5.9pp） | 91.0% | **81.9%**（-9.1pp） |
| 終局pop | 23 | **31**（+35%） | 13 | **26**（+100%） |
| 終局teams | 4 | 6 | 2 | 6 |
| **established（全程）** | 恆0 | **恆0（未變）** | 恆0 | **恆0（未變）** |

**attrition 有改善、存活人口明顯變多（1.3~2倍）**，且死平出現得更早更穩（月4-6即穩定，非持續下滑到月12）。**但★「立國」（established）完全沒解決**——兩個 seed 全年 12 個月依然一次都沒達成。**de-patch 解的是「獨立隊能不能餵飽自己」，不是「世界能不能立國」——這是兩個不同的病灶，farming 死鎖只是其中一環，非崩潰全根。**

## ⑤faction 不回歸——粗查正常
faction_farm_pos 維持低量級（pre: 5/55=9.1%，post: 5/57=8.8%）——**幾乎持平，非暴增**，de-patch 沒有意外讓 faction 隊蓋更多/更少農場，符合預期（de-patch 只開獨立隊權限，不動 faction 邏輯）。outpost 總數（indep_civ+indep_mil+faction項）未見異常膨脹跡象（樣本量小，僅粗查非嚴格 proliferation 統計，若你要嚴格數字我可再補）。

## ⑥融合閘——implementer 已跑綠（constitution_gate PASS, sites=29無新增），本輪未重跑

## 綜合判讀
**de-patch 本身 CLEAN 可 merge**（determinism/faction不回歸/死鎖確實解開）。但**別把它當「經濟長程崩潰」的解方**——它改善了獨立隊個體存活率，對整體世界能否「立國/繁榮」這個更深層問題沒有觸及。**下一步經濟長程診斷（月1-3急性危機+月10二次惡化的週期模式）仍待查**，farming 死鎖只是其中一個貢獻因子，非唯一根因。

## 產物
- `depatch_det1.json`/`depatch_det2.json`（determinism）
- `depatch_farming_check.json`（死鎖解驗，5seed×6mo）
- `depatch_deep_reference.json`（12月×2seed 深度對照）
