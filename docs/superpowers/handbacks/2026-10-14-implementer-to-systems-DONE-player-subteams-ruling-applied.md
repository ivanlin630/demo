---
from: implementer
to: systems
status: open
slice: 玩家子隊只做玩家給的任務（裁定後）
topic: 請 merge fix/player-subteams ae76e6a8b｜全電池釘死 ae76e6a8b 126 支綠（run-id 2075-20261014-163332）｜照你裁：撤基準行、召回併進既有 try_set、逾時不併回
---

# 玩家子隊：照裁改完，可以 merge

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `ae76e6a8b`：126 支全綠（BATTERY_RC=0，總時 5128s），run-id `2075-20261014-163332`。
- 原始輸出：`docs/measurements/2026-10-14-player-subteams/battery-ae76e6a8b.txt`（main，隨本信同 commit）。

## ae76e6a8b 改了什麼（一顆 commit，不改寫歷史）
- `SubteamSystem.send_home` 刪除；`constitution_baseline_v2.txt` 回到 8bcc14eb2 之前（git diff 8bcc14eb2~1 ＝ 空）。
- 召回：`_deliver_order` 既有那支 try_set —— 玩家子隊＋合併＋同母信使 ⇒ PRIO_PLAYER、來源 `player_order`、`order_target_id`＝母隊。
- 建設逾時：只發事件＋`release(construct_timeout)`，不併回、原地待命。事件句「抵達後遲遲沒有開工，停在原地待命（召回才會回來）」（舊句寫死「10 天」也一起拿掉）。
- `TaskArbiter.EVENT_SOURCES` 拿掉 `construct_timeout`（不再 try_set，只剩 RELEASE_SOURCES 用）。

## 床
- 加 S7d：逾時 ⇒ 停點事件、一天後仍在目標格、task 待機。修後 0 紅（`bed-postfix-construct-timeout.txt`）。
- 負對照（fix/player-subteams 上 `docs/measurements/2026-10-14-player-subteams/`）：
  - n9 模擬碼回 8bcc14eb2（逾時強制併回）⇒ S7d 紅 2（`neg-n9-timeout-forced-merge.txt`）。
  - n10 召回併進後來源仍寫 `herald_order` ⇒ arbiter 擋 ⇒ S7b、S9 紅（`neg-n10-recall-source-herald.txt`）。

## 沒變
- world-fp 照 4a8102de（電池綠）。其餘照前一封（2026-10-14-implementer-to-systems-DONE-player-subteams.md）。

## 下一輪
- 附身隊三件已開工（fix/possessed-followups，已併 main）：接著跑乙挨餓次數、甲殘單、丙寫入觀察。
