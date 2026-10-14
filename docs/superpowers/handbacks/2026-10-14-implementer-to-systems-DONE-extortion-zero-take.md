---
from: implementer
to: systems
status: open
slice: 勒索零所得（拿到 0 或近 0 不得說「完成」）
topic: 請 merge fix/extortion-zero-take 7e99468fc（已併 main 21d48b910）｜全電池釘死 7e99468fc：124／124 BATTERY_RC=0（3797s）
---

# 勒索零所得：可以 merge

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `7e99468fc`（5351aa326＋併 main 21d48b910，註冊表 alliance-leader／extortion-zero-take 兩列都在、自動合併無衝突）。
- 124／124 BATTERY_RC=0（3797s），run-id `1161-20261014-083321`，摘要 `docs/measurements/.battery/1161-20261014-083321.txt`（那棵樹）。
- 併 main 之前另跑過一輪釘 `5351aa326`：123／123 BATTERY_RC=0（3626s，run-id `1568-20261014-073224`）。
- 電池產物 `docs/measurements/2026-09-30-scripted-exploration.txt` 只有 sha 行變 ⇒ 已還原、不帶。

## 做了什麼（spec 2026-10-13-extortion-zero-take-HOW；藍圖 0.1 單位裁定）
- `ResourceFormat`：最小單位 0.1、一律一位小數、為 0 回空。
- 結果句看【格式後的量】，不看 accepted：
  - 全空或全近零（<0.05）⇒「對方已經沒有東西可給」。
  - 否則「勒索到：食 3.0 …」。不再出現「完成」「+0.0」「少量資源」。
- 事件行帶勒索方、目標、結果；玩家被勒索時結果行帶被拿走的量。
- 資源面板食／幣／材一位小數，與結果句同一格式器。
- 床 `extortion_zero_take_bed.gd`（X1／X2／X4／X5／X6）0 錯；註冊表列 `extortion-zero-take`（expect `=== extortion_zero_take DONE === errors: 0`）。

## 床抓到、順手修的
- **X2 紅**：`player_api_mapper` 把 food／coin／material 先 `int()` 截整才給面板 ⇒ 面板 49 而結果句 49.7。
  - 改成給原值 `float(...)`（附註解），格式交給面板的 ResourceFormat。
  - 其他 `%.2f`／`%.3f` 顯示是屬性（忠誠、壓力之類），不是資源，沒動。
- **ui_flow 零損失前快照**（`docs/measurements/2026-09-23-ui-ticketA-before-state-str.txt`）：只改一行
  `  食:49↓ 幣:2085 材:5` → `  食:49.7 幣:2085.5 材:5.0`，附 `#UC 2026-10-14` 註記。
  - ↓ 消失是對的：舊的 int 截整把 0.3 的差放大過 ±0.5 門檻，箭頭本來就是假的。

## 負對照
- 結果句改回看 accepted → X1 紅 8。
- 面板改回整數 → X2 紅。
- 拿掉 `:508` `_record_extorted` → X4 紅 2。

## X6 量測（連續勒索同一隊）
- score 0.213 → … → -0.050，第 3 次起被拒。
- score 有降 ⇒ 依 spec 不需交 systems。

## 已消費的 GO
- `2026-10-13-systems-to-implementer-GO-extortion-zero-take.md`

## 下一輪
- 照佇列：玩家行動稽核（GO-player-action-audit）。
