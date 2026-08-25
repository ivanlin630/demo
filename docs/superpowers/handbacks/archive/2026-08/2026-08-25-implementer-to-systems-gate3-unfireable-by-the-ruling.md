---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
branch: feat/acquisition-paths-wire-in @ e8ac7e26 (pushed)
topic: ★★★閘③「fp 該變」在這張票上【結構性不可觸發】,而原因就是裁定本身:一行動一真值 ⇒ 兩個候選導向完全相同的 to_task ⇒ 誰贏世界都一樣;★若 fp 真的變了,那才會【否證】裁定;★五閘綠、det 三跑一致
---

# 閘③紅 —— **但它紅的方式證明了裁定是對的**

## §1 ★先排除兩個常見解釋（**不是它們**）
| 可能 | 排除依據 |
|---|---|
| **沒接上** | ★`won_argmax = 187`（且 `dormant-scan` branch 上 3→2）|
| **a4 視窗太短** | ★**means-end 在 `tick 10` 就 emit 且 `me_won: true`**，a4 跑 **1000 tick** ⇒ **視窗內確實贏過** |

## §2 ★★★真因：**兩個候選導向【完全相同的行動】**
**means-end 的 facility 候選 與 既有 facility 候選，都是 `_resolve_build_facility` 對【同一設施、同一支隊】產生的 `to_task`。**
⇒ ★**誰贏都做同一件事 ⇒ 世界完全一樣 ⇒ `fp` 必然不變。**

★★**而這正是「一行動一真值」的直接後果**：**兩個提案可互換。**
⇒ ★★★**若 `fp` 真的變了，反而代表那兩個「相同」的提案其實做了不同的事 —— 那會【否證】裁定。**

⇒ ★**閘③在這張票上【結構性不可觸發】，而不可觸發的原因是裁定本身。**
★**我不改判準、也不宣告通過** —— **交你裁：是移除③、還是改成「fp 必須【不】變」？**
（★**後者會是一條【可能失敗】的判準**：若 fp 變了就是紅 —— **這比移除它更有力。**）

## §3 六閘現況
| 閘 | 結果 |
|---|---|
| ①TDD 缺設施 vs 缺原料分得開 | ✅ `["facility"] vs ["material"]` |
| ②`dormant-scan` | ✅ **branch 3→2**（★`main` 仍 3 ＝ 未 merge，**兩個都對，差別在 ref**）|
| ★③`fp` 該變 | ★**未變（`5c1fa2fc…` ×3）** ⇒ **見 §2，我認為判準本身要改** |
| ④`food`／`material` 不退化 | ✅ ★**`emitted` 三版本恆 380** ⇒ 控制流未受計價改動影響 |
| ⑤陽性對照 | ✅ 內建於①，且每輪驗 `teams=79`／`ERR=0` |
| ⑥exact path | ✅ 見 §5 |
| headless | ✅ **標記=1／HARD 3／ASSERT 5／PARSE 0** ＝ baseline 0-new |
| 憲法 | ✅ **PASS(74)** |
| `estimator-lineage-scan` | ✅ **PASS** |

## §4 ★三組乾淨數據（都經前置健全檢查：`teams=79`、`ERR=0`）
```
修控制流後(1.0)   emitted 380 / won_argmax   0 / winner = me × 1.5（恆定）
1.0 錨版(supersede) emitted 380 / won_argmax   0 / 同上
★一行動一真值(1.5)  emitted 380 / won_argmax 187 / me_util == winner_util
```
★**`emitted` 三組全 380** ⇒ **差別純粹在計價，控制流完全沒動。**

## §5 ★已落地 exact path
```
接線＋計價  A:\GDS\demo\.worktrees\acquisition-paths-wire-in\scripts\simulation\decision\goal_resolver.gd
            （_resource_prereq_candidates / _facility_of_level_key）
TDD         同 worktree \scripts\debug\headless_test.gd（_test_meansend_wired_into_candidates）
量測輸出    C:\...\scratchpad\ws_final2.txt（1.5）／ws_final.txt（1.0 對照）
commit      e8ac7e26（已 push）
```
