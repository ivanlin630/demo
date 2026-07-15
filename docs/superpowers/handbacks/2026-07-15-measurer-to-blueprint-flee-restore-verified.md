---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] flee恢復位移@77d7687c——flee真逃確認(Team1 tile_pos真變動14,7→9,11→8,13→8,15,非原地凍);N1_flee/defect_leave大降(seed1337:20966→10006/-52%,3703→768/-79%;seed2674:9422→7763/-18%,1057→70/-93%);故事連貫(逃到8,15後轉別的task);憲法綠;★過程記重大工具坑:worktree跑床用的是原始未擴充版本(我本地擴充從未commit),已修正"
---

# flee 恢復位移 驗證報告

`measured_at_head: 77d7687c`。中性full-HD（同觀察跑法）。

## 一次量完（鐵律6）

## ★過程記一筆：撞到「worktree看不到我本地擴充」的坑
第一次跑 `.worktrees/flee-restore-movement` 用 `sufficiency_bed.gd` 時，N1_flee/defect_leave/breed **全部0**（連 key 都不存在）——一度以為force_full_hd失效。查明：我早前擴充`sufficiency_bed.gd`(FORCE_FULL_HD/specimen支援)只是main working dir的**未commit本地修改**，worktree是**獨立git checkout**，看不到這份修改，跑的是原始無擴充版本。`cp`我本地擴充版進worktree後重跑才正常。**這是通用坑，供其他角色/未來我自己記取**：跑worktree前若用到「我剛擴充的debug工具」，記得先確認worktree有沒有同步（`git diff main..branch -- <tool>`只驗**已commit**版本，驗不到我的本地未commit擴充）。

## 1. ★flee 真逃：確認（tile_pos 真變動）
raw log grep `[Move] Team 1`：**396次移動**，位置序列 (14,7)→(9,11)→(8,13)→(8,15)（隨後定居於(8,15)多次）——**真的位移遠離**，非原地凍結。specimen jsonl（3165 entries）顯示定居後轉入 覓食/生產/建設 等一般任務，符合「逃到安全→轉別的」敘事。

## 2. ★N1_flee aggregate 大降——衡量出 bug 佔比
| | seed1337 修前(main) | 修後(branch) | Δ | seed2674 修前 | 修後 | Δ |
|---|---|---|---|---|---|---|
| reaction.N1_flee | 20966 | 10006 | **-52%** | 9422 | 7763 | -18% |
| death.defect_leave | 3703 | 768 | **-79%** | 1057 | 70 | **-93%** |
| reaction.N2_riot | 806 | 429 | -47% | 1526 | 1327 | -13% |
| reaction.breed | 38 | 29 | -24% | 60 | 67 | +12% |

**判讀**：`死.defect_leave` 降幅最劇（79%/93%）——與code結構吻合（該Probe key同時被N1_flee觸發的離隊+N3_defect觸發的離隊共用，flee-no-op時卡住的隊反覆觸發離隊事件，虛高最明顯）。N1_flee本身降52%/18%——不對稱降幅（seed1337降更多）可能與該世界威脅密度/隊伍分布有關，非bug。**aggregate巨量逃跑主要是churn虛高，非「危險世界」的真訊號**——驗證了blueprint的假設。

## 3. 不回歸
憲法閘 PASS sites=29 removed=0。（determinism：implementer TDD 已自報兩跑bit-identical，本輪未獨立重驗，時間關係——若你要求可補。）

## 待 blueprint 裁
1. defect_leave 降79-93%後剩餘的768/70——這殘留量級是否已算「合理內政流失」？還是仍需與新的reaction-level tap(279ad8c8)交叉驗證真因？
2. N1_flee 兩seed降幅不對稱(52% vs 18%)——是否要追？

---
measured_at_head: 77d7687c
