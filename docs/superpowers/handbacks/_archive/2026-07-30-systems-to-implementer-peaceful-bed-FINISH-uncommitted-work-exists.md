---
from: systems
to: implementer
status: consumed
topic: "[★收尾:你的工作在worktree未commit不是沒做·.worktrees/peaceful-econ有config/peaceful_economy.json(03:33)+peaceful_economy_bed.gd(03:37)+peaceful_economy_liveness_test.gd未commit(??狀態)=你派工後9分做完只是沒commit+沒handback·收尾4步:①跑liveness test(need_keep material>0+forest靶,綠才續)②跑bed產4問數③commit④handback to:systems帶4問結果·別重做已有的檔] 你的檔在worktree未commit。收尾:跑liveness→跑bed→commit→handback帶4問數。"
branch: feat/peaceful-economy-bed
---

# ★收尾：你的工作已在 worktree（未 commit），不是沒做

`.worktrees/peaceful-econ` git status 有你派工後產的 3 檔（`??` untracked、未 commit）：
- `config/peaceful_economy.json`（03:33，12 隊、好戰=0、11 outpost）
- `scripts/debug/peaceful_economy_bed.gd`（03:37，@observe-pure + WarringHarness.run + 4 問 dump + liveness 前置）
- `scripts/debug/peaceful_economy_liveness_test.gd`（need_keep(material)>0 + forest 靶斷言）

**檔做完了、只是沒 commit + 沒 handback**（派工 03:28→產檔 03:37=9 分）。**別重做**，收尾即可。

## 收尾 4 步
1. **跑 liveness test**（`.\tools\godot.ps1 --headless --script scripts/debug/peaceful_economy_liveness_test.gd`）→ **綠**（每 ①/③料窮側 `need_keep(material)>0` + ①有 unowned forest 靶在 SEEK_TILE_RANGE）才續；紅=fixture 死路，修 config 到綠（R² 教訓：死 fixture 產假訊號）。
2. **跑 bed**（`peaceful_economy_bed.gd`）→ 產 **4 問 probe 數**（founding dispatch? 發展? 貿易? runway 機制 fire?）+ 逐隊月故事。★同時 observability_gate（bed 有 @observe-pure marker）掃過不 FAIL（零 RNG 驗）。
3. **commit**（config + bed + liveness test；headless 0-new + 三閘綠）。
4. **handback `to:systems`** 帶 **4 問結果**（各 probe 計數 + gate funnel 分「動機無」vs「有動機卡 gate」+ 逐隊故事摘要）+ 落地路徑（bed 輸出存 docs/measurements 標 exact path）。

## 交付後
systems R²（實作：liveness 真擋死 fixture、bed 零 RNG、4 問齊）→ **回 blueprint 裁分支（economy 有+runway fire→續 runway / economy 無→pivot material arc）**。

★你的 session 沒死（檔為證）。收尾這 4 步即可，卡住報 `to:systems`（別空等、別重做）。
