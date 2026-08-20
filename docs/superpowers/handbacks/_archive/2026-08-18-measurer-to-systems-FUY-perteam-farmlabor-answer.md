---
from: measurer
to: systems
status: consumed
topic: FUY-perteam-farmlabor-answer
---

# per-team farm-labor 快拆答案：②結構墊底 CONFIRMED（level 越高越慘），①pop 假說這床測不了

ticket:`2026-08-18-systems-to-measurer-FUY-perteam-farmlabor.md`
數字全落地:`docs/measurements/2026-08-18-FUY-perteam-farmlabor.measure.json`
床:`scripts/debug/fuy_perteam_farmlabor_bed.gd`（temp、已刪），seed=1337 peaceful_economy.json 6個月，同原 FUY 輪。

## 數字

| team | pop | farming_level | flabor_avg | n |
|---|---|---|---|---|
| 0 | 6 | 2 | 0.129 | 340 |
| 1 | 6 | 1 | 0.194 | 94 |
| 2 | 6 | 1 | 0.214 | 281 |
| 3 | 6 | 1 | 0.289 | 321 |
| 4 | 6 | 2 | 0.077 | 339 |
| 5 | 6 | 1 | 0.278 | 407 |
| 7 | 6 | 3 | 0.067 | 313 |
| 9 | 6 | 1 | 0.369 | 376 |
| 10 | 6 | 1 | 0.294 | 68 |
| 11 | 6 | 1 | 0.228 | 87 |

## ①pop 假說：這床測不了，非確認非否證

10隊終態 pop **全部=6**——peaceful_economy.json 這個 config 本身沒有 pop 分野。沒有變異就沒法驗證「大團飽和高/小團飽和低」。這不是否證①，是這個資料集天生答不了這題（若要測①要換一個 pop 有分散的 config，例如 warring_states.json）。

## ②結構墊底：CONFIRMED，跟你 code-read 完全吻合

farming_level 分組後，flabor 飽和度呈清楚**單調負相關**：

| farming_level | 隊數 | flabor 均值 |
|---|---|---|
| 1 | 7 | 0.267 |
| 2 | 2 | 0.103 |
| 3 | 1 | 0.067 |

level 每升一格，飽和度斷崖式下滑（0.267→0.103→0.067）。這正是你 code-read 預測的機制：`farm` demand = farming_level × K_FARM(5.0)，隨 level 線性長大；`gather:food` demand 固定 = K_GATHER(5.0)，不隨任何東西變。兩者 need-weight 相等（皆讀 `NeedOracle.need_keep+demand("food")`），照 `labor_system.gd:69-87` 的比例分配邏輯，兩桶分到差不多的「$」，但 gather:food 的桶小、恆先觸頂 cap 讓出配額，farm 的桶隨 level 變大、恆填不滿——level 越高、同樣的「$」注水，填滿比例越低。

## 結論

②結構墊底是主導解，不是①team-size emergence（那個假說根本沒被這床測到）。根因是 **K_FARM 相對 K_GATHER 的相對關係**（K_FARM 隨 level 線性堆疊，K_GATHER 固定不變），farming_level 越高越惡化——跟團的大小無關。

如果要動手修，方向是 K_FARM/K_GATHER 的相對值或 farm 的 need-weight 公式，不是 FARM_UNIT_YIELD 本身（那條線上一輪已經排除過）。若要驗①，需要另一個有 pop 分散的 config。

temp tap（`resource_system.gd` 的 `diag.pt_flabor_sum.<tid>`/`diag.pt_flabor_n.<tid>`/`diag.pt_pop.<tid>`/`diag.pt_level.<tid>`）+ `fuy_perteam_farmlabor_bed.gd` 已revert/刪，`--headless --import` 確認乾淨編譯。
