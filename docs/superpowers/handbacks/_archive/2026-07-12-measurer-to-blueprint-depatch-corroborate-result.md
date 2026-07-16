---
from: measurer
to: blueprint
status: consumed
topic: de-patch死鎖pre-build實證——獨立隊farming 0/7恆0(100%確認)+全civilian型(型別閘非瓶頸,faction-only閘才是真根)+faction隊本身建farm率也僅9%(5/55)；farming×存活因n太小不可靠
---

# 量測回報：de-patch 死鎖 pre-build corroborate

工單：`2026-07-12-systems-to-measurer-depatch-corroborate.md`。main `9156f6f`（default.json），5seed×6月，`WarringHarness` 加 `_farming_snapshot`（final state 讀 tile+team 既有欄位，L3純觀測）。**另附 code 層直接印證（比數字更硬）**。

## ★code 層直接印證（先於數字，比 corroborate 更決定性）
`_evaluate_infrastructure(state, faction)`（含農場邏輯的唯一入口）**只有一處呼叫者**（`faction_ai_system.gd:642`，在 per-faction 迴圈內）。**獨立隊（faction_id=-1）從未被傳進這條路徑——結構性 100% 排除，非機率低**。這比任何統計數字都更確定：不是「獨立隊比較少蓋」，是「獨立隊的蓋農場程式碼路徑從物理上不會被執行」。

## 數字驗證（5seed×6月，聚合）
| 分組 | farming>0 | farming=0 | 比例 |
|---|---|---|---|
| **獨立隊** | **0** | **7** | **0/7 = 0.0%**（恆0，與code層印證完全吻合） |
| **faction 隊** | 5 | 50 | 5/55 = **9.1%** |

**獨立隊 farming_level 恆0 假設 = 100%確認**（0/7，非「大多數」是「全部」）。

## crude camp civ/mil 型別——★型別閘不是瓶頸
獨立隊 outpost 型別：`indep_civ=7`、`indep_mil=0`——**7/7 全是 civilian 型**（本次樣本沒抓到任何 military 獨立隊）。這代表：獨立隊在型別上完全符合農場建造條件（code 要求 `tile.outpost_type == "civilian"`），**卡死不是因為型別閘擋了 military 隊，是因為 faction-only 閘連 civilian 獨立隊都排除**。若下輪要修，**真根是 faction-only 閘，非 civ/mil 型別閘**——後者本次樣本量太小看不到瓶頸（可能存在但非本次死鎖主因）。

## faction 隊本身建 farm 率也低（9.1%）——附加訊號，非死鎖本身
即便有資格（faction member），6 個月內也只有 9% 的 outpost 蓋出農場。這可能是：`INFRA_INTERVAL` 評估週期慢、hungry 門檻 6 個月內少觸發、或其他設施競爭掉了 slot。**這是 de-patch 後仍可能存在的次要瓶頸**，不影響本次「獨立隊 vs faction 隊」死鎖對照的結論，但供你參考（de-patch 解鎖獨立隊後，faction 隊自己這 9% 低建造率可能也要看）。

## farming × 存活——★樣本太小，不可靠，誠實標記
`farm_pos_avg_pop`（1-2/1/2/1/1隊，n極小）vs `farm_zero_avg_pop`（7-19隊）——**farm_pos 組平均pop在多數seed反而略低或持平**，但這**不能解讀為「農場沒用」**：farm_pos 每 seed 只 1-2 個樣本，統計上完全不可靠（單一隊的個體差異就能主導平均值）。**這題本次數字答不了，需要更大樣本或更長窗**（de-patch 後獨立隊也能蓋農場，屆時樣本量會自然變大，屆時再測更可信）。

## 產物
- json：`tools/orchestrator/runs/farming_deadlock_probe.json`
- 床改動：`scripts/debug/warring_harness.gd` 加 `_farming_snapshot`（final state，L3）
