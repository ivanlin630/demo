---
from: measurer
to: blueprint
status: consumed
topic: world-gen §4重baseline雙任務完成——但深度長跑抓到重大異常:default.json兩seed皆2-3月內人口崩潰83-91%(幾乎全餓死非戰爭)+established恆0，9個月死平無湧現
---

# 量測回報：world-gen §4 重 baseline（兩任務）——★深度長跑抓到重大異常

工單：`2026-07-12-systems-to-measurer-worldgen-s4-baseline.md`（含用戶追加深度規格）。main `a571bcb`（world-gen variety 已 merge）。

## 任務①：標準 baseline 重生（控制config warring_states，3seed×3mo）
`tools/orchestrator/runs/main_worldgen_baseline_std.json`——標「world-gen variety 位移，非迴歸」，供未來 emergence 硬斷對照用。無異常（floor全綠，數字量級與先前系列一致）。

## 任務②：深度長跑參照（用戶定：2seed×12月/1年，default.json，全探針）——★發現嚴重異常
`tools/orchestrator/runs/worldgen_deep_reference.json`。跑法：main上補一行 `WARRING_CONFIG` env 支援（`seeded_warring_bed.gd`，L3 surgical，向下相容不破既有呼叫）。單seed 12月僅 104s（比預期快很多，default.json 隊少）。

### ★世界崩潰模式（兩 seed 一致）
| | seed 1337 | seed 42 |
|---|---|---|
| 月1 teams/pop | 15/128 | 17/136 |
| 月3 teams/pop | 5/30 | 4/25 |
| **月3後** | **卡死不變到月12**（4隊/23-29人） | **卡死不變到月12**（2-3隊/13-22人） |
| 最終 attrition | **83.1%** | **90.97%** |
| established（全程） | **恆 0** | **恆 0** |

**兩個 seed 都在頭 2-3 個月內人口崩潰 8成以上，之後 9 個月完全死平**——teams/pop 幾乎不再變化，established（立國）全程掛零，g2.faction_found=0（無新勢力形成）。3 個月短窗量測完全看不到「崩後死平」這段，只會看到「崩潰進行中」的片段——**這正是用戶要深度長跑而非廣度短窗的理由，抓到了**。

### 死因分解——幾乎全是餓死，非戰爭
| | seed 1337 | seed 42 |
|---|---|---|
| death.starve_anon | 83 | 93 |
| death.combat_pop | **0** | **0** |
| extinct.starve | 13 | 17 |
| extinct.combat | 0 | 0 |
| combat.ended_n（全年僅） | 4 | 2 |

**戰鬥幾乎不存在**（annih=0、combat 全年僅 2-4 場），人口崩潰**幾乎完全是餓死**——非「征服/殲滅」型死亡，是經濟/糧食供應鏈型死亡。`conq.declared` 雖高（297/1046，宣戰意圖多），但 `conq.prosperity_reached=0`——宣戰歸宣戰，沒有一場真正打贏取得繁榮，因為多數隊早已餓死到打不動。

## 我不判的（供你/systems 判斷）
- 這是 **default.json（玩家實際世界）** 的現象，非我改動造成——我只是首次用深度長跑窗照出來。
- 可能根因方向（不代判，列出供查）：
  1. default.json 起始隊數少（15-17，遠低於控制config的42-50）+ 起始 pop 小（population_range [8,10]）——經濟緩衝薄，扛不住早期消耗。
  2. world-gen §1 scatter 可能把據點放在通過「覆蓋度地板」但**未必貼近資源**的位置（地板檢查的是空間分布，非食物供應鏈可行性）——scatter 評分雖有資源權重(W_RES)，但可能不夠強。
  3. 或是既有經濟系統在小規模世界下的既知短板（非本次改動新增）。
- **這是否算「world-gen variety 迴歸」還是「default.json 本來就這樣（pre-existing，只是沒人用深度窗量過）」，我沒有 pre-worldgen 的 default.json 深度基線可比對，無法判定**——如果你要我補一個「世界生成前(舊代碼)default.json 深度跑」當對照，我可以跑（需要 checkout 舊 commit 或另建 worktree）。

## 產物
- `tools/orchestrator/runs/main_worldgen_baseline_std.json`（任務①，控制config標準baseline）
- `tools/orchestrator/runs/worldgen_deep_reference.json`（任務②，default.json 深度參照，**內含上述異常數字**）
- 床改動：`scripts/debug/seeded_warring_bed.gd` 加 `WARRING_CONFIG` env（L3，向下相容）
