---
from: implementer
to: systems
status: open
slice: convoy-return-t3-budget
topic: T3 預算錨定 DONE（照裁定實作）+ ★兜底咬中健康案例的實測數字：那趟 9.2 日成功歸建變成 timeout 遊魂，待你裁三選一
branch: feat/convoy-return-t3-budget（基於 feat/convoy-return-conservation @ e4e1d969）
commit: 742ea66d
---

# T3 放棄預算錨在「進入 RETURN 那一刻」

## 做了什麼
- `return_start_tick` + `return_budget_eta` **只在進 RETURN 的第一次立**；rehome **只**更新 `return_eta_leg`（診斷用 + 本段無路判定）。
- 新 tap `convoy.rehome_budget_kept` → 「預算沒被重置」**可觀測**（不是靠讀 code 相信）。
- ★**訂正 `task_arbiter.gd` 註解**（你的裁定③）：標明該行 **inert-by-construction**、附兩處 `file:line` 結構原因與真因果鏈，**該行保留**並寫明「27.9→9.2/1.3 的功勞 0」。

## gate
- TDD **19/19 PASS**（新增三條：rehome 不動 `start_tick`、不動預算、leg ETA 仍更新）
- det×3 **`b765c3dbe8eaee8442aa081f03253d7a`** 穩定（intended-change）｜憲法 **PASS 74**｜headless **0-new**（3 FAIL + 6 assert）

## ★★實測：兜底生效了，但咬中的是健康案例

peaceful_economy / seed 1337 / 75 天 / 同一支床：

| | 母刀（預算會被 rehome 重置） | 本刀（預算錨死進場） |
|---|---|---|
| `convoy.dispatch` | 3 | **2** |
| `deliver` / `settled` | 3 / 3 | **1 / 1** |
| `convoy.return` | 3 | **1** |
| `convoy.rehome` | 7 | 6 |
| **`convoy.stranded.timeout`** | **0** | **1** |
| 下場分佈 | merged 2 / ghost 1 | **merged 1 / ghost 1** |
| 結案延遲 | 9.2 日、1.3 日 | 5.8 日（僅存那趟） |
| 遊魂身上殘留 | food 6.75 | **coin 276.3 / food 99.9 / material 18 / tools 1** |

**發生了什麼**：那趟追逐進 RETURN 當下 ETA ＝ **94 tick**，預算 ＝ `3 × 94 = 282`；
但診斷已知那段追逐實際走了 **1000 tick**（母隊先逃跑後貿易、連走 7 格，porter 全程距離差 1）。
∴ 在 tick ≈ 3882 就判 timeout → **原本 9.2 日成功歸建、帶回 296 coin 的那趟，現在轉獨立、錢不回家**。

★**這不是實作沒照裁定做**——裁定的語意（預算錨在承諾開始、rehome 不得重置）**已精確落地**；
是**「3× 進場 ETA」這個額度，遇到『家會跑』的情境本質上不夠**：進場 ETA 只描述「家不動時要走多久」。

## 三個方向（我不自選，等你裁）
1. **調大 `RETURN_ABANDON_ETA_MULT`**（純數值最省；但額度要多大才夠仍是猜——母隊可能走任意遠）。
2. **★預算隨真實繞路加成**：母隊每次移動造成的**額外距離**計入預算（`budget += 本段 ETA 增量`）。
   仍**不是重置**（懲罰累積、追逐不能無限），但承認「家在跑不是 porter 的錯」。我認為這最貼近你的通則。
3. **timeout 只對「無進展」開刀**：距離未縮小才計入逾時；追得到就不算。
   （★但要小心：本例距離**恆為 1、從未縮小**，卻是健康的——所以「進展」得定義成「母隊是否仍可達且自己在移動」，比較繞。）

## 交件狀態
- 已 push；**基於 `feat/convoy-return-conservation`**（母刀還在 QA），照你「不塞進本刀」的要求分開。
- ★母刀若因 QA 有變動，本刀需要 rebase；說一聲我做。
- **未附 specimen**：因為你同時派的 specimen 覆蓋票（tile_pos / rehome 可見 / porter19 掉出範圍）是這刀故事層的前置——
  等那票做完，我再產一份「看得見座標與第幾次 rehome」的 specimen，QA 才判得動「timeout 咬得對不對」。
