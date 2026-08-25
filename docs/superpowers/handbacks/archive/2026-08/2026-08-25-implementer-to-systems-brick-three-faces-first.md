---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity
branch: feat/failure-memory-structural-identity @ f0b586b8 (+WIP tap)
topic: ★磚三面重量第一輪:②買糧仍咬27綠 / ①outpost.l0_to_l1=0(要同床main baseline,且這輪根本沒紮根成功) / ★★③=0且【③b 前提型 blocked_total 也=0】——磚的招牌改動(前提型不折價)在這張床一次都沒 fire;★已加③c入口tap分辨「接線斷」vs「根本沒走到」
---

# 磚三面（★開發回饋，非驗收）

**床**：`failure_feedback_measure_bed`（`peaceful_economy` / seed 1337 / 90 天）@ `f0b586b8`

## §1 三面

| 面 | 數字 | 判 |
|---|---|---|
| ②**買糧 339 型仍咬** | `failure.suppressed.買糧 = 27`（最深折價 `0.600`） | ✅ **有咬** |
| ①**文明化恢復** | `outpost.l0_to_l1 = 0` | ⚠️ ★**不可判**：要同床 main baseline；★**而且這輪根本沒有任何紮根成功** |
| ③**紮根執行型失敗進記憶** | **0** | ⛔ ★**沒進料**（見 §2） |

★`failure.recorded.*` 的**完整分佈只有一項**：`order_abandoned_buy = 396`。
⇒ ★**記憶裡目前【全部】是買單失敗，紮根一筆都沒有。**

## §2 ★★而且 ③b 也是 0 —— **磚的招牌改動在這張床從未 fire**

```
③b 前提型 failure.blocked_total = 0
```
★**`record_blocked`（「不要為世界沒備妥的事懲罰隊伍」——磚的第二個 commit）一次都沒被呼叫。**
⇒ ★**這不是「三面缺一面」，是【兩個新機制都沒進料】。**

★**我不說「機制沒生效」**，因為 0 有兩種意思，**而這份報告當時分不出來** ——
所以我先補了 ③c 才報：

## §3 ★③c：**加了「這支函式有沒有被呼叫」的入口 tap**

`record_blocked` 的 4 個站全在 `_dispatch_builder()` 裡。
★**而那支函式開頭就有一個【完全靜默的 early-return】**：
```gdscript
for cid in leader_team.subteam_ids:
    if ct.current_task == TASK_CONSTRUCT or ct.current_task == TASK_BUILD:
        return false        # ← 在所有 record_blocked 【之前】，原本零 tap
```
⇒ ★**已加兩顆**（純計數，不寫世界狀態，合你新立的觀測器條款）：
`dispatch.builder_entry`（有沒有被呼叫）／`dispatch.builder_skip_busy`（是不是卡在這個 early-return）。

★**理由**：`blocked_total = 0` 目前有三種可能，**沒有入口 tap 就永遠只能猜**：
1. `_dispatch_builder` **根本沒被呼叫**（上游就沒派）
2. 被呼叫了，但**卡在那個靜默 early-return**（已有 CONSTRUCT 子隊）
3. 走到檢查了但**全部通過**（那 `blocked` 本來就該是 0，機制正常）

★**這三種的處置完全不同**（改上游／de-patch 那個 gate／什麼都不用做）——
**混成一句「沒 fire」會導向錯的修法。** 重跑中，出來才報判。

## §4 ★一個現在就能講的關聯
convoy 那邊同床同 seed 量到 **`abandon_fire = 0`、`site_completed = 3`**
⇒ ★**紮根/建設在 `peaceful_economy` 裡「開了工的都蓋完、沒有人半途丟下」。**
**如果 ③c 顯示 `builder_entry > 0` 且大多 `skip_busy`**，那圖就一致了：
★**這個世界的建設是【排隊等前一支蓋完】，不是【失敗】** ——
**那樣的話 ③ 的 0 是「世界真的沒有」，磚沒有接線問題，但【這張床不是驗第三面的床】。**
★**我不預判，等數字。**

## §5 需要你決定的（等 ③c 出來後才有意義，先預告）
若 ③c 證實「世界真的沒有紮根執行型失敗」：
★**第三面要換一張床（會發生放棄的情境），還是接受「這一版第三面無法在現有床驗證」並明記為已知限制？**
★**我傾向換床**，因為「無法驗證」的 acceptance 面等於沒有 acceptance ——
**但那是新增量測工作，成本要你認。**
