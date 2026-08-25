---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
branch: feat/acquisition-paths-wire-in @ c7f5fe1c (pushed)
topic: ★★★最後一格交了:380 個 emitted 裡【224 個是既有機制從未提出的】(weaponsmith 184 / workshop 40),dup 156,224+156=380 零殘差 ⇒ 本票有世界層價值;★四項前置全過,而先前同一顆 tap 的壞掉版本會把「0」報成發現;★★我一個錯誤歸因也記在 commit 裡
---

# 最後一格：**224 / 380 是既有機制沉默處的提案**

## §1 ★★★數字（`warring_states` 10d）
```
means_end.unique_no_existing   = 224     ← ★既有機制【從未提出】
    weaponsmith = 184
    workshop    =  40
means_end.dup_existing_present = 156     ← 與既有候選重複
                                 ─────
                                 380 ✓ 零殘差
```
⇒ ★**照你先寫死的判準：`> 0` ⇒ 本票有世界層價值。**
★★**而分佈本身有內容**：**`weaponsmith` 佔 184** —— **既有機制對「為了兵器而蓋兵器坊」幾乎完全沉默。**
★**那不是我調出來的，是既有 `build_weaponsmith` goal 的 desire 門檻與觸發條件造成的。**

## §2 ★四項前置全過（**這條判準允許 0，所以必須證明量測有在跑**）
| 前置 | 值 |
|---|---|
| `teams` | **79** ✓ |
| `SCRIPT ERROR` | **0** ✓ |
| ★`res_prereq.entry` | **6357**（母體非零）✓ |
| ★`candidates_emitted` | **380**（與三組乾淨基準一致）✓ |

★★★**同一顆 tap 的壞掉版本四項全失敗，而它的輸出是 `unique = 0 / dup = 0`** ——
★**若我只看目標欄位，會把「本票零世界層價值」報成結論。**
⇒ ★★**「判準預先允許 0」本身放大了風險**：**它讓壞掉的零看起來像預期中的答案。**
★**建議通則（你裁）：允許 0 的判準，必須配【母體非零】的前置。**

## §3 ★我一個錯誤歸因，記在 commit 裡
**那個壞掉版本的症狀（大量 parse error ＋ 世界跑歪 ＋ teams 數字不對）與今天三次 class 快取陷阱【完全吻合】** ——
★**我直接套用了那個現成解釋，沒查。**
★★**真因是我 tap 自己的續行符寫成了字面 `\n`。**
⇒ ★**攔住它的是「`--import` 之後 `ERR` 仍是 2480」** —— **修法無效才逼我去讀真正的錯誤訊息。**
★★★**症狀吻合已知模式，是最容易跳過查證的時刻** —— 而**我今天已經在別人的數字上抓過這個形狀好幾次。**

## §4 六閘總表（交件）
| 閘 | 結果 |
|---|---|
| ①TDD 缺設施 vs 缺原料分得開 | ✅ `["facility"] vs ["material"]` |
| ②`dormant-scan` | ✅ **branch 3→2**（`main` 仍 3 ＝ 未 merge）|
| ★③`fp`（已倒轉為否證器） | ✅ **未變**（`5c1fa2fc…` ×3）＝ **一行動一真值成立** |
| ④不退化 | ✅ `emitted` 四版本恆 **380** |
| ⑤陽性對照 | ✅ 內建①＋每輪四項前置 |
| ⑥exact path | ✅ 見 §5 |
| headless | ✅ **標記=1／HARD 3／ASSERT 5／PARSE 0** |
| 憲法 | ✅ **PASS(74)** |
| lineage | ✅ **PASS** |
| ★**世界層價值** | ✅ **224 / 380** |

## §5 ★已落地 exact path
```
接線＋計價＋uniqueness tap
  A:\GDS\demo\.worktrees\acquisition-paths-wire-in\scripts\simulation\decision\goal_resolver.gd
床  同 worktree \scripts\debug\goal_delegate_diag_bed.gd
TDD 同 worktree \scripts\debug\headless_test.gd（_test_meansend_wired_into_candidates）
量測 C:\...\scratchpad\ws_unique3.txt（最終）／ws_final2.txt（1.5）／ws_final.txt（1.0 對照）
commit c7f5fe1c（已 push）
```

★**本票我這側完成，等你判 merge。**
