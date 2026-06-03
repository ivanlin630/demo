# UI-API 完整接合設計：Spec 3 — 新功能 UI

## Goal

暴露 batch1-3 新功能的 UI 入口：勢力面板 [F]、前哨站面板 [O]、子隊面板 [U]、顧問模式 [V]、alert bar、gather_intel 子模式、encounter_view 補充按鍵。

## 新 Mode 鍵位

| 鍵 | 模式變數 | 說明 |
|---|---|---|
| `F` | `_faction_mode` | 勢力面板 |
| `O` | `_outpost_mode` | 前哨站面板 |
| `U` | `_subteam_mode` | 子隊面板 |
| `V` | `_advisor_mode` | 顧問模式 |

**互斥：** 開任一 mode 時關閉其他（T/P/I/F/O/U/V 全互斥）。`Esc` 退出當前 mode。

## Alert Bar

**節點：** `text_ui_main.gd` 新增 `@onready var _alert_bar: Label`，置於 InputBar 上方。

**邏輯：**
```gdscript
func _check_alerts() -> void:
    var alerts: Array = _bridge.get_and_clear_alerts()
    if not alerts.is_empty():
        _pending_alerts.append_array(alerts)
    if not _pending_alerts.is_empty():
        _alert_bar.text = "[!] %s  [Z 確認]" % _pending_alerts[0]
    else:
        _alert_bar.text = ""
```
- `[Z]` → `_pending_alerts.pop_front()`，若空則清空 alert_bar
- `_check_alerts()` 在每次 `_refresh()` 呼叫

**Alert 類型顯示文字：**
| type | 顯示 |
|---|---|
| `food_critical` | 警告：糧食危急 |
| `faction_member_betrayed` | 警告：勢力成員叛離 |
| 其他 | 警告：{description} |

## [F] 勢力面板

**資料來源：** `_bridge.query_faction_panel()`

**顯示格式：**
```
── 勢力{faction_id} [{Leader 或 成員}] ──
AI 目標: {faction_goal}   玩家目標: {player_goal_override 或 "（跟隨 AI）"}
徵收率: {tribute_rate*100}%

── 成員指令 ──
[1] Team{id} @({q},{r})  指令: {commanded_task 或 "無" 或 "傳達中（{pending_task}）"}
[2] Team{id} ...

── 行動 ──
[A]設定目標  [B]調整徵收率  [C]離開勢力
[D]背叛勢力  [E]解散勢力（僅 leader）
[F/Esc]關閉
```

**行動流程：**
- `[A]` 設定目標 → input_mode，輸入字串 → `_bridge.set_player_input("faction_goal_input", str)` → `set_faction_goal`
- `[B]` 調整徵收率 → input_mode，輸入數字（0-100）→ `_bridge.set_player_input("tribute_rate_input", float/100)` → `set_tribute_rate`
- `[C/D/E]` → 直接 `execute_action`
- 成員列 `[1~9]` → input_mode 輸入任務字串 → `_bridge.set_player_input("order_member_id", team_id)` + `set_player_input("member_task", str)` → `order_faction_member`
  - **信使機制**：`order_faction_member` 不直接設 `player_commanded_task`，改派一個 TASK_HERALD 信使（1人從玩家 team 分出），帶 `order_task = commanded_task` 前往 `order_target_id = member_team_id` 所在格
  - 信使抵達同格時：interaction_system 偵測 TASK_HERALD + order_target_id → 設 `target.player_commanded_task = herald.order_task`，信使 team 解散回歸玩家主隊人口
  - UI 顯示：成員指令欄中信使出發後顯示 `指令: 傳達中（{commanded_task}）`，實際套用後顯示 `指令: {commanded_task}`
  - 需新增 `WorldState` 追蹤欄位：`player_pending_orders: Dictionary = {}` → `{ member_team_id: { "task": str, "herald_id": int } }`，供 UI 查詢傳達狀態

## [O] 前哨站面板

**資料來源：** `_bridge.query_outpost_panel()`

**顯示格式：**
```
── 前哨站 @({q},{r}) ──
類型: {outpost_type 或 "無"}  等級: {level}
擁有者: {owner 或 "無"}  支配權: {has_control}
{施工中: 剩餘 {ticks_left} Tick 或 ""}

── 可用行動 ──
[1]{action_label} ...
[O/Esc]關閉
```

**行動對應：**
| action | label |
|---|---|
| `build_outpost` | 建設前哨站 |
| `upgrade_outpost` | 升級等級 |
| `upgrade_farming` | 升級農作 |
| `upgrade_manufacturing` | 升級製造 |
| `demolish_outpost` | 拆除 |

行動全部透過 `execute_action`，outpost 類行動不需 target_id（傳 -1）。

## [U] 子隊面板

**資料來源：** `_bridge.query_subteam_panel()`

**顯示格式：**
```
── 子隊 ──
[1] Team{id} @({q},{r})  {task}  pop:{pop}
    [A]下令移動  [B]召回
[2] ...
（無子隊）
[U/Esc]關閉
```

**行動流程：**
- `[數字]` 選子隊 → `_subteam_selection = team_id`
- 選後 `[A]` → input_mode 輸入座標 → `order_subteam`（寫 `player_state["order_sub_id"]`, `["order_sub_q"]`, `["order_sub_r"]`, `["order_sub_task"]`）
- `[B]` → `recall_subteam`（寫 `player_state["recall_sub_id"]`）

## [V] 顧問模式

**資料來源：** snapshot `members_detail`（已有）

**顯示格式：**
```
── 顧問 ──
[1] {name}  計謀:{val} 交涉:{val} 戰術:{val}
[2] {name}  ...
選顧問後輸入情境關鍵字
[V/Esc]關閉
```

**流程：**
1. `[1~9]` 選顧問 → `_advisor_selection = person_id`
2. → input_mode，輸入 situation 字串（如「攻擊」「外交」「資源」）
3. 呼叫 `AdvisorSystem.new().get_advice(advisor, situation, {}, state)` 直接（無需透過 Bridge，純查詢不改 state）
4. 結果顯示在 StateLabel 額外行，或 event log

## gather_intel 子模式

**觸發：** 互動模式已選目標，選 `gather_intel` action。

**新模式變數：** `_intel_mode: bool`、`_intel_target_id: int`

**流程：**
1. `execute_action("gather_intel")` → `player_state["pending_intel_target"]` 被寫入
2. `_intel_mode = true`，呼叫 `_bridge.query_player_actions({"focus_team_id": _intel_target_id})` 取 confirm_gather_intel 的 questions
3. 實際上由 `InquirySystem` 生成問題，暫以 `player_state["inquiry_options"]` Array 傳出

**顯示格式：**
```
── 打聽 Team{id} ──
[1] {question_text}
[2] {question_text}
...
[1~5]選題  [Esc]取消
```

4. 選題 → 寫 `player_state["inquiry_choice"] = idx` → `execute_action("confirm_gather_intel")`
5. 結果進 event log，退出 `_intel_mode`

**Note：** `gather_intel` 的 options 從 command result `payload["inquiry_options"]` 取得（Array[Dictionary]，每項有 `"label": String`）。UI 本地暫存至 `_intel_options: Array`。選題後：
```gdscript
_bridge.set_player_input("gather_intel_npc_id", _intel_target_id)
_bridge.set_player_input("gather_intel_choice", _intel_options[idx].get("label", ""))
_bridge.command_player("execute_action", {"action_id": "confirm_gather_intel", "target": {}})
```
`PlayerCommandApi.execute_action` 需已修正轉發底層 payload（見 Spec 1）。

## encounter_view.gd 補充

**新增按鍵：**
- `[S]` → `surrender_in_encounter`（戰鬥中，玩家為防守或攻擊皆可）
- `[J]` → `subjugate_enemy`（戰鬥結束後，`can_subjugate == true` 時才顯示）

在 `encounter_view.gd` 的 `_input` 或 button 區塊加：
```gdscript
KEY_S:
    if state.encounter_active:
        var r := _bridge.command_player("execute_action", {"action": "surrender_in_encounter", "target_id": -1})
        _log(r.get("message", ""))
KEY_J:
    if not state.encounter_active and state.last_encounter_result.get("can_subjugate", false):
        var r := _bridge.command_player("execute_action", {"action": "subjugate_enemy", "target_id": -1})
        _log(r.get("message", ""))
```

## 成功標準

- `[F]` 面板顯示勢力資訊，`[A]` 可設目標並透過 `faction_ai` 反映
- `[O]` 面板顯示當前格前哨站，行動執行後次 tick 可見變化
- `[U]` 面板可召回子隊（信使出發 print 出現）
- `[V]` 顧問給出文字建議
- Alert bar 在食物危急 tick 出現 `[!]` 警報
- gather_intel 子模式選題後 event log 出現打聽結果
- encounter_view `[S]` 投降成功後 encounter 結束

## 測試

headless_test 無崩潰，1000 tick 無 SCRIPT ERROR。新 print 驗證：
- `[Advisor]` 建議觸發（V 模式）
- `[Inquiry]` 打聽結果觸發
