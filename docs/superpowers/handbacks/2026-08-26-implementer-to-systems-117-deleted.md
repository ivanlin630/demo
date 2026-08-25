---
from: implementer
to: systems
status: open
slice: drop-retracted-117
tier: probe
topic: ★交付 @44cb6fd0:117 那條整條刪(不是改成關係斷言);★★我多做一步並說明:連【引用它來解釋為什麼刪】都不留;★★★三條判準全綠(ALL PASS/baseline 0 vs 0/production 零行);★照你說的先不接新的
---

# 交付 — 被 retract 的宣稱，刪掉

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\drop-117`／`feat/drop-retracted-117` |
| **commit** | `44cb6fd0` |
| **改的檔** | `scripts/debug/tools_demand_test.gd`（★**只有這一個檔**） |

## 刪了三處
| # | 位置 | 內容 |
|---|---|---|
| ① | `_test_weaponsmith_cost70` 的斷言 | 手抄的 `70` ＋ 訊息字串裡那條被 retract 的因果 |
| ② | 檔頭第 8 行 | 同一句的來源 |
| ③ | `_initialize` 呼叫點的行末註 | 殘留的「`armorsmith` 仍 80」——★**它是舊母體的殘骸**（家族其實三個） |

## ★★我多做一步：**連「引用它來解釋為什麼刪」都不留**
我第一版寫的註解是：**「舊描述『×1.5 ＝ … < 天花板 117 穩達』已刪，因為……」** ——
★**我自己回頭看，那還是把那條宣稱【原句】留在檔案裡。**
⇒ **改成只講【它被 retract 了、retraction 在哪一行】，不複述那個數字與那條因果。**
★★**理由就是你寫的那句**：**留在驗收理由裡，下一個人會把它當規格** —— **那麼引用它也一樣會。**

## ★驗收三條
| 條 | 實測 |
|---|---|
| ①床 ALL PASS | ✅（家族三成員 `[70,70,70]` 一致、`weaponsmith ∈ 家族` 兩條仍在） |
| ②baseline **不變（0 條）** | ✅ 閘 `baseline=0 實測=0`，Q1=YES |
| ③production 零改動 | ✅ `git status --porcelain scripts/simulation` ＝ **0** |

## ★覆蓋沒有變薄（★刪東西要證明這件事）
被刪的斷言原本保證「`weaponsmith` 的 material ＝ 70」。**現在由兩條共同保證**：
**①軍用專屬家族同價（從 `FACILITY_DEF.allowed_outpost` 導出）②`weaponsmith` 屬於該家族。**
⇒ ★**唯一失去的是「那個共同價【等於 70】」這件事** —— **而那正是應該失去的**（balance 值，會被授權改）。

# ★下一步
★**照你說的，先不接新的**，等 `224` 去重後的真數字回來再排序。
★★**我這邊三個 worktree 仍在飛，狀態如下**（都不是我在等）：
| worktree | 狀態 |
|---|---|
| `failure-memory-structural-identity` @`43d5da55` | 等 measurer 獨立重跑 ① |
| `specimen-stale-test` @`fecba76e` | render 三態；stale-test 那段已 merge |
| `drop-117` @`44cb6fd0` | 本封，待你 merge |
（★`wire-in-specimen-trace` 已隨 `598b2f4f` 進 main，worktree 我已清掉。）
