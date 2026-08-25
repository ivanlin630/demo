---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
branch: feat/acquisition-paths-wire-in @ WIP
topic: ★接線完成,閘②機械達成:dormant-scan 休眠 3→2,AcquisitionPaths 從清單【消失】;★TDD 綠且分得開(facility vs material);★★det×3 跑中(閘③),我會照你說的「fp 沒變先查沒接上、不先懷疑判準」
---

# 接線完成 —— **閘②已由機械閘證明**

## §1 ★★閘②：`dormant-module-scan` 讓它消失了
```
接線前（main）：休眠 3  ← AcquisitionPaths / InvariantAudit / StateFingerprint
接線後（本 branch）：休眠 2  ← ★AcquisitionPaths 不見了
```
★**這比「我接好了」這句宣稱硬** —— **閘自己說它不再是死的。**
★★**而這個閘是你為了「休眠不是錯、忘了才是」做的，現在它反過來當【接上了】的證據 —— 同一個機制兩個方向都有用。**

## §2 閘①：TDD 綠**且分得開**
```
[OK] _test_meansend_wired_into_candidates（["facility"] vs ["material"]）
```
★**我自己加了陽性對照**（你的閘⑤要求）：**先斷言磚對 `tools` 有輸出**，
★**否則「甲乙不同」這個比較沒有分母** —— **兩邊都空也會「不同」。**

## §3 實作（照 spec §3，逐條）
| spec | 落法 |
|---|---|
| 新增 `_resource_prereq_candidates`、不改舊簽名 | ✅ `_resolve_resource_prereq` 原封、`:362` caller 未動 |
| `:101` 改 `append_array` | ✅ ★**means-end 候選與既有手段【同池競爭】，不給特別待遇** |
| 接入點 ＝ fallthrough | ✅ **買／採@地形先問，都沒有才問製造**（既有優先序不變）|
| `facility` → 蓋設施 | ✅ 走既有 `_resolve_build_facility`；★**設施 key 用 `FACILITY_DEF` 反查，不建對照表** |
| `material` → 遞迴各自成 candidate | ✅ |
| `ready` → `TASK_MANUFACTURE` | ✅ |
| ★`stock` 不進價值比較 | ✅ **只發 `means_end.stock_seen.<res>` tap** |

## §4 現況
| 閘 | 結果 |
|---|---|
| ①TDD 分得開 | ✅ |
| ★②`dormant-scan` | ✅ **3 → 2，AcquisitionPaths 消失** |
| ③`fp` 該變 | **det×3 跑中** —— ★**照你說的：若沒變，我先查是不是沒接上，不先懷疑判準** |
| ④`food`／`material` 不退化 | **待跑**（床量測）|
| ⑤陽性對照 | ✅ 已內建於 ① |
| ⑥exact path | 見下 |
| headless | ✅ `標記=1／HARD 3／ASSERT 5／PARSE 0` ＝ **baseline，0-new** |

★**已落地 exact path**：
```
接線     A:\GDS\demo\.worktrees\acquisition-paths-wire-in\scripts\simulation\decision\goal_resolver.gd
         （_resource_prereq_candidates / _facility_of_level_key）
TDD      A:\GDS\demo\.worktrees\acquisition-paths-wire-in\scripts\debug\headless_test.gd
         （_test_meansend_wired_into_candidates）
```

## §5 ★程序
**本封是「起長跑前先發」之後的結果回報。** det×3 約 3 分鐘，**出來我立刻報，不累積。**
★**工作流凍改中我記得**：**本票只動 `scripts/`，沒碰任何 hooks／流程 doc。**
