# 玩家行動稽核：三個空動作／不符宣稱——HOW

狀態：草稿，待 R²
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-player-action-audit-no-op-and-mismatched-actions（第五輪回饋 #9，53 個 handler 逐一稽核）
順位：勒索零所得（#5）之後；「通商只加名聲」歸深層批貿易票，不在本票。
原則：宣稱動作必須改世界（2026-10-06 裁）。

## ① 調整武裝比例被蓋回
- 事實：`_action_set_armed_ratio` 寫 `pt.armed_anon_ratio`；`equipment_system.gd:62-73 _update_anon_ratio` 用武器庫存重算同一欄並直寫 ⇒ 玩家設的值被蓋。藍圖標 ★：順序與頻率要床驗。
- 先量：床設比例後推 1 tick、1 天，印每次 `_update_anon_ratio` 前後的值與呼叫來源；確認確實被蓋。
- 改法（選服從，不拿掉鍵）：新欄 `armed_anon_target`（玩家設的目標，-1＝未設＝照舊全武裝）；`_update_anon_ratio` 算出「庫存可武裝比例」後取 `min(目標, 可武裝)`。武器不夠 ⇒ 結果句與面板印「武器只夠 N%」。`armed_anon_ratio` 仍只由 equipment_system 寫（單寫者），玩家只寫目標。
- NPC 隊 target=-1 ⇒ 行為逐字不變（world-fp 不動是驗收之一）。
- 「三個人口比例旋鈕」（2026-08-03）其餘兩顆不在本票。

## ② 訓練沒人可練照扣錢
- 事實：`player_command_system.gd:741-763 _action_train`：precheck 過後先扣 `TRAIN_COST_COIN`（:747-748），再發現無可升階對象（:755）回 ok:true「訓練（-X 幣，無可升階對象）」。
- 改法：「無可升階對象」併進 precheck（同一支，動作清單因此列在不可側、原因寫出），扣錢之後不再有這條出口。

## ③ 重掃同格對象不是世界動作
- 事實：`refresh_targets`（player_command_api.gd:272、285）是介面重整，卻走行動路，每次進事件流「指令｜重掃同格對象：已重掃同格對象」。
- 改法：不進事件流、不寫結果行；畫面靜默重整。若有床或 E2E 依賴那一句 ⇒ 交件信列出並改。
- 查：它還有沒有其他入口把它當行動計數（行動清單、按即一 tick 的活檔表）。

## 驗收
- A1（修前紅）：設比例 0.5、武器足 ⇒ 1 天後 `armed_anon_ratio` = 0.5；武器只夠 30% ⇒ 0.3，結果句含「武器只夠 30%」。
- A2：NPC 隊 world-fp 不變。
- T1（修前紅）：無可升階對象 ⇒ 錢不變、ok:false、動作列在不可側並帶原因。
- R1（修前紅）：按重掃 ⇒ 事件流不增加、結果行不變；同格對象清單更新。
- 負對照：①拿掉 min 目標 ⇒ A1 紅；②還原扣錢順序 ⇒ T1 紅。
