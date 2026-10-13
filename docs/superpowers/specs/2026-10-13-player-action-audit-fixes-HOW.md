# 玩家行動稽核：三個空動作／不符宣稱——HOW

狀態：收 R²（…-R2-alliance-8-and-audit-9-ISSUES，同版不需再審）
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-player-action-audit-no-op-and-mismatched-actions（第五輪回饋 #9，53 個 handler 逐一稽核）
順位：勒索零所得（#5）之後；「通商只加名聲」歸深層批貿易票，不在本票。
原則：宣稱動作必須改世界（2026-10-06 裁）。

## ① 調整武裝比例被蓋回
- 事實：`_action_set_armed_ratio` 寫 `pt.armed_anon_ratio`；`equipment_system.gd:62-73 _update_anon_ratio` 用武器庫存重算同一欄並直寫 ⇒ 玩家設的值被蓋。藍圖標 ★：順序與頻率要床驗。
- 先量：床設比例後推 1 tick、1 天，印每次 `_update_anon_ratio` 前後的值與呼叫來源；確認確實被蓋。
- 改法（選服從，不拿掉鍵）：新欄 `armed_anon_target`（玩家設的目標，-1＝未設＝照舊全武裝）；`_update_anon_ratio` 算出「庫存可武裝比例」後取 `min(目標, 可武裝)`。武器不夠 ⇒ 結果句與面板印「武器只夠 N%」。`armed_anon_ratio` 仍只由 equipment_system 寫（單寫者），玩家只寫目標。
- NPC 隊 target=-1 ⇒ 行為逐字不變。新欄若被 fingerprint 反射全欄收進 ⇒ fp 一定動：先查 fp 是列舉欄位還是反射；反射 ⇒ 證明只差新欄（分域比）再換基準。
- 面板印「目標 X%／實際 Y%」；先量 `_update_anon_ratio` 的呼叫節奏。
- 「三個人口比例旋鈕」（2026-08-03）其餘兩顆不在本票。

## ② 訓練沒人可練照扣錢
- 事實：`player_command_system.gd:741-763 _action_train`：precheck 過後先扣 `TRAIN_COST_COIN`（:747-748），再發現無可升階對象（:755）回 ok:true「訓練（-X 幣，無可升階對象）」。
- 改法：「無可升階對象」併進 precheck——精確條件與動作清單可用性**共用同一支函式**（清單列在不可側、原因寫出），扣錢之後不再有這條出口。

## ③ 重掃同格對象不是世界動作
- 事實：`refresh_targets`（player_command_api.gd:272、285）是介面重整，卻走行動路，每次進事件流「指令｜重掃同格對象：已重掃同格對象」。
- **不准搬出指令佇列**（2026-09-24 裁；sim_bridge.gd:424-431，它寫 `player_pending_targets`＝世界狀態，P14 守）。
- 改法：既有 `SimBridge.UI_INTERNAL_COMMANDS`（sim_bridge.gd:495，現只用來不蓋結果行）——在同一個結果排空迴圈（text_ui_main.gd 約 317-332）對它再濾掉 `_events.append` 與 `_feed_push`；佇列與世界寫入不動。
- 順查頂列「待執行 N」是否把 UI 內部令算進去；是 ⇒ 一併排除。

## 驗收
- A1（修前紅）：設比例 0.5、武器足 ⇒ 1 天後 `armed_anon_ratio` = 0.5；武器只夠 30% ⇒ 0.3，結果句含「武器只夠 30%」。
- A2：NPC 隊 world-fp 不變。
- T1（修前紅）：無可升階對象 ⇒ 錢不變、ok:false、動作列在不可側並帶原因。T1b：清單顯示可做 → 移走唯一可升階對象 → 執行 ⇒ 不扣錢、回原因。
- R1（修前紅）：按重掃 ⇒ 事件流不增加、結果行不變；同格對象清單更新；`player_pending_targets` 內容與修前逐字相同。
- 負對照：①拿掉 min 目標 ⇒ A1 紅；②還原扣錢順序 ⇒ T1 紅。
