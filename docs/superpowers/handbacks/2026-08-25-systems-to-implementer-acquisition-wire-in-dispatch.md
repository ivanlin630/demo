---
from: systems
to: implementer
status: open
slice: acquisition-paths-wire-in
tier: full
topic: ★dispatch:讓 dormant 的 means-end 磚真的進決策(R² CLEAN);★★這次「fp 該變」reviewer 親追呼叫鏈驗過成立,不是我又寫一條不可達判準;★交付閘六條
---

# dispatch：`docs/superpowers/specs/2026-08-25-acquisition-paths-wire-in-HOW.md`

**R² ＝ CLEAN**（reviewer 三點全親驗 ＋ **親跑 `dormant-module-scan.sh` 確認 `AcquisitionPaths` 在 `main` 上真的 DORMANT**）。

## ★這張票要解的事，一句話
**你上一票做的磚是對的，但它現在是死的** —— ★**接上去，「為了取得 X 先做 Y」才會真的進到隊伍的決策裡。**

## ★★reviewer 幫我驗掉一個我上次踩過的坑
**我上次寫「`fp` 該變」寫錯過**（`_sellable_qty` 只走 player 路徑、a4 無玩家 ⇒ 判準不可達）。
★**這次他親追呼叫鏈**：`frontier_candidates` 被 **`decision_engine.gd:100-103` 每 tick 呼叫**、
**`ensure_maintain_goals(:49)` 確保 unified team 恆有 active 資源維持 goal**
⇒ ★★**這是 NPC 核心決策路徑，不是 player-only ⇒ `fp` 該變這條【站得住】。**
★**所以這次 `fp` 不變 ＝ 真的沒接上，不是判準寫錯。**

## ⇒ 做法（★spec §3 已裁，照做）
- ★**新增** `_resource_prereq_candidates(...) -> Array`，**不改** `_resolve_resource_prereq` 簽名
- **`:101` 的 caller 改 `out.append_array(...)`**（★**它本來就在收集多個 candidate 進 rank 池**）
- ★**`:362` 的 caller 維持不動**
- **接入點 ＝ `goal_resolver.gd:494-496` 的 fallthrough**（★**那行既有註解就寫著「缺的是【製造】那條手段」**）

**三種 `kind` 映射**：`facility` → 蓋設施（既有 build/delegate 路徑）｜`material` → 遞迴結果各自成 candidate｜`ready` → **`TeamData.TASK_MANUFACTURE`**
★**`stock` 形狀【不進價值比較】** —— 只標形狀、發 tap。

## ★交付閘（六條）
1. ★**TDD 先寫**：「**缺設施 vs 缺原料**產出不同 candidate」——★**分不開等於沒做**（同上一票）
2. ★**`dormant-module-scan.sh` 跑一次**：**`AcquisitionPaths` 應該從清單消失**（★**這是最直接的「接上了」證據**）
3. ★★**`fp` 該變**（見上，reviewer 已驗這條站得住）★**若 `fp` 沒變，先查是不是沒接上，不要先懷疑判準**
4. **反向：`food`／`material` 既有行為不退化**（`emitted.<res>` 不掉）
5. ★**陽性對照**：同一次跑要有【已知必然非零】的量（★**否則儀器沒開時判準會一起「通過」**）
6. **交接標【已落地 exact path】**

## ★兩件程序上的事
1. ★★**工作流凍改中**（用戶令）：**本票純專案 —— 不要順手改 hooks／流程 doc。** 有需要**先回報我，不要動手。**
2. ★**落地 ≠ 遞送**：**做完發信，不要只 commit**（★**Monitor 靠信喚醒，不靠 commit**）。
   ★**起長跑前先發一封短的**（跑什麼／預期多久）——**「安靜地正常工作」和「卡住」在外面看起來一模一樣。**
