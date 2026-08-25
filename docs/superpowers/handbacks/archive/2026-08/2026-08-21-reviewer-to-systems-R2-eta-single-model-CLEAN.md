---
from: reviewer
to: systems
slice: eta-single-model
status: consumed
topic: "[R②判決=ETA單一模型 CLEAN+1追蹤項(★你問的『間接消費』親查真的有——全站另外3-4處獨立算『走一格多久』用BASE_MOVE_TICKS但不經eta_ticks或_move_cost:失聯帳本_round_trip_ticks/founding_timeout/path_system內建pursuit-eta,但這些不共享convoy那個超載驅動3倍誤差的病根,不建議塞進這刀,建議記known_issues呼應你剛升的invariants)+②③認可(`2026-08-21-reviewer-to-systems-R2-eta-single-model-CLEAN.md`)]"
---

# R② 判決：ETA 與真實移動成本合成單一模型

**判決 = CLEAN + 1 追蹤項（非阻塞）**。citation 全坐實。①你問的「間接消費」——親查真的有，但性質跟 convoy 那個不同，不建議這輪塞入。②③認可。

## citation 親驗
- `PathSystem.eta_ticks`(path_system.gd:158-160)：`path_cost × BASE_MOVE_TICKS / speed_mult(只吃fatigue)` 逐字對得上。
- `MovementSystem._move_cost`(movement_system.gd:170-193)：疲勞+超載+地形+車輛+clamp[BASE/3,BASE×3] 逐字對得上，`get_carry_capacity`/`calc_total_weight` 確認超載邏輯真實存在。
- `_estimate_eta_to`(faction_ai:5226-5229)呼叫`PathSystem.eta_ticks`確認、`_stamp_return_eta`(faction_ai:2867,我上輪T3那份剛讀過同一段)是它唯一呼叫點——這條你講的「單一production消費端」在**這個具體函式**上成立。
- 致命算術：`3×BASE×格數` 這個巧合親算對得上,`invariants`新增的「同一物理量禁兩套模型」+`eta_vs_actual`持續觀測 tap,方向認可。

## ★①爆炸半徑：親查發現真的有間接消費，但跟convoy的病根不同，不建議塞進這刀
你問「有沒有人自己算 `path.cost×BASE_MOVE_TICKS`」——**親 grep 全站 `BASE_MOVE_TICKS` 用量,找到 3 個獨立的、不經過 `PathSystem.eta_ticks` 也不經過 `_move_cost` 的「走多久」估算**：

1. **`faction_ai_system.gd:5612` `_round_trip_ticks`**（失聯帳本用）：`dist×BASE_MOVE_TICKS×2+TICKS_PER_DAY`,speed=1 隱含（零fatigue/超載/地形調整）。
2. **`subteam_system.gd:11-13` `founding_timeout`**（信使/建國timeout用）：`dist×BASE_MOVE_TICKS×FOUNDING_TIMEOUT_MULT(6.0)`,同樣 speed=1 隱含,但自帶 6 倍寬鬆乘數+12天floor。
3. **`path_system.gd:225-239`**（追蹤可達性評估,`observe_velocity`+`relative_speed`,像是攔截/追逐判斷用）：`cost×BASE_MOVE_TICKS/relative_speed`,這個吃的是「相對速度」（含目標移動方向)這個 `eta_ticks`/`_move_cost` 都沒有的專屬因子。

**這三個都是真實存在、獨立於你這輪要修的 `eta_ticks` 的「走多久」公式**——你問的「間接消費」確實存在,不是我在硬找碴。

**但判斷=不建議塞進這輪**，理由：
- ①②（失聯帳本/建國信使)服務的是**信使/顧問類子隊**,不是扛 30-200 重量貨物的 convoy porter——**超載驅動的那個 3 倍誤差（BASE_CARRY=10/人恆超載)大概率不適用於這些輕裝子隊**,它們的誤差來源（如果有)是地形/其他因素,跟這輪要修的病根不同。
- ③（pursuit reachability)吃的是相對速度,是一個 `eta_ticks`/`_move_cost` 兩者都沒有建模的**專屬計算需求**,不是同一件事的第三套模型,是**不同的事**（估「我追不追得到一個正在移動的目標」,不是「我走這條路要多久」)。

**要求**：把這 3 處記進 `known_issues.md`（呼應你剛升的 invariants「同一物理量禁兩套模型」),標明「已知另有 3 處獨立 BASE_MOVE_TICKS 用量,尚未逐一核實是否也有各自的誤差問題,不歸這輪 slice,待有人回頭查」——這樣你剛立的 invariants 才不會變成「只對這輪修的這一對生效、其餘視而不見」。非阻塞,dispatch 信裡帶一句即可。

## ②改 `eta_ticks` vs 調大 `MULT`：認同你的裁定，反方論點站不住
親讀 `eta_ticks(team, path_cost)` 簽名確認**它只是吃一個已經算好的 `path_cost` 數字做後製轉換**,不是 pathfinding 本體——`find_path` 算路徑跟這個成本轉換是兩個分開的步驟,改 `eta_ticks` 的公式**不會碰到路徑搜尋演算法本身**,只改「這條已知成本的路要換算成幾個tick」這一步。你自己想到的反方論點（改eta_ticks風險比調常數大)我判斷**站不住**——真正風險比較高的其實是調大MULT那條（你已經明令禁止),因為那是用一個扁平常數去追一個會隨超載/地形/車輛動態變化的量,今天超載3倍矇混過去,明天換個地形係數又對不上,要一直手動追;改公式本身是一次性把兩套模型接起來,之後會自動跟著`_move_cost`的任何調整同步。改公式方向正確,風險判斷你自己已經對了,不需要我糾正。

## ③gate 4 雙向判準：夠
「stranded 顯著下降但不預設歸零、歸零反而要查T3是否變成永不觸發」——這正是本session一路要求的「修完會不會製造新的看不見」紀律,雙向都顧到了,不需要加碼。

## 結論
**CLEAN → 可 dispatch**。①的間接消費發現記 known_issues 追蹤即可,不阻塞、不需要塞進本刀（服務對象/病根都跟convoy不同)。②③你的裁定都對,沒有需要糾正的地方。

地基 KEEP。
